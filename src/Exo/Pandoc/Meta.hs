{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE MultiParamTypeClasses #-}

-- Loads known metadata fields from Pandoc documents.
module Exo.Pandoc.Meta
( Metadata(..), Crosspost(..)
, parseMetadata

, metaInputPath
, metaOutputPath
, metaCanonicalPath
, metaCanonicalFolder
, metaLink
, metaUpdated
, metaTypeIcon

, getMetaStrings
, getMetaString
) where

import qualified Data.Aeson as Aeson
import qualified Data.Map.Strict as Map
import qualified Data.Text as T
import qualified Exo.Pandoc.Link as Link
import qualified Exo.Pandoc.Time as Time
import qualified Network.URI as URI
import qualified System.FilePath as FilePath
import qualified Text.DocTemplates as DocTemplates
import qualified Text.Pandoc as Pandoc
import qualified Text.Pandoc.Shared as Pandoc
import qualified Text.Pandoc.Walk as Pandoc

data Metadata =
  Metadata
    { metaPath :: Link.PathInfo
    -- ^ The paths associated with this file.

    , metaTitle :: Text
    -- ^ The title of the document.

    , metaCreated :: Time.Timestamp
    -- ^ The best-known time for when the document was originally created. For
    -- documents originally created on this website, this is the time the note
    -- was added to the file system. For documents created on other websites,
    -- this is the earliest time it was posted on another website. For physical
    -- documents, this is the best-known time that the document was written.
    , metaPublished :: Maybe Time.Timestamp
    -- ^ The time the document was published to the internet. This type of time
    -- is only used for documents meant to be published in whole at a specific
    -- time, like blog posts. This must always be after the created date.
    , metaModified :: Maybe Time.Timestamp
    -- ^ The time the document was modified. This indicates the time the content
    -- of the document was last edited. This time is not updated when the
    -- metadata of the document is edited or when the document's content does
    -- not meaningfully change (such as when link urls are updated to point to
    -- the new location of moved documents). This must always be after the
    -- created date.
    , metaMigrated :: Maybe Time.Timestamp
    -- ^ The time the document was either transcribed from a physical medium
    -- into this website or copied into this website from an external source.
    -- This must always be after the created date.

    , metaOutgoingLinks :: Set FilePath
    -- ^ All outgoing internal links.
    , metaCrossposts :: [Crosspost]
    -- ^ The places where either this document has been posted or an
    -- announcement of this document was posted.
    , metaTags :: [Text]
    -- ^ The manually curated tags that have been added to this document, which
    -- are used for categorization and search.
    }
  deriving stock (Eq, Generic, Show)

instance Aeson.FromJSON Metadata
instance Aeson.ToJSON Metadata

instance DocTemplates.ToContext Text Metadata where
  toVal meta@Metadata{..} =
    let
      maybeToVal = maybe DocTemplates.NullVal DocTemplates.toVal
      items = Map.fromList
        [ ("path", DocTemplates.toVal metaPath)
        , ("title", DocTemplates.toVal metaTitle)
        , ("created", DocTemplates.toVal metaCreated)
        , ("published", maybeToVal metaPublished)
        , ("modified", maybeToVal metaModified)
        , ("migrated", maybeToVal metaMigrated)
        , ("updated", DocTemplates.toVal (metaUpdated meta))
        , ("outgoing", DocTemplates.toVal (T.pack <$> toList metaOutgoingLinks))
        , ("crossposts", DocTemplates.toVal metaCrossposts)
        , ("tags", DocTemplates.toVal metaTags)
        , ("typeIcon", DocTemplates.toVal (metaTypeIcon meta))
        ]
    in
      DocTemplates.MapVal (DocTemplates.Context items)

-- The path to the input source file.
metaInputPath :: Metadata -> FilePath
metaInputPath Metadata{..} = Link.pathInput metaPath

-- The path to the output source file.
metaOutputPath :: Metadata -> FilePath
metaOutputPath Metadata{..} = Link.pathOutput metaPath

-- The absolute path to the document on the website.
metaCanonicalPath :: Metadata -> FilePath
metaCanonicalPath Metadata{..} = Link.pathCanonical metaPath

-- The absolute path to the folder containing the document on the website.
metaCanonicalFolder :: Metadata -> FilePath
metaCanonicalFolder Metadata{..} = Link.pathCanonicalFolder metaPath

-- The URL to the document on the website.
metaLink :: Metadata -> Text
metaLink Metadata{..} = Link.pathLink metaPath

-- The most recent time the file was updated.
metaUpdated :: Metadata -> Time.Timestamp
metaUpdated Metadata{..} = fromMaybe metaCreated metaModified

metaTypeIcon :: Metadata -> Text
metaTypeIcon meta =
  case FilePath.splitDirectories (metaCanonicalFolder meta) of
    "/":"albums":_ -> "ri-album-fill"
    "/":"blog":_ -> "ri-article-fill"
    "/":"entries":_ -> "ri-sticky-note-fill"
    "/":"gallery":_ -> "ri-palette-fill"
    "/":"notes":_ -> "ri-booklet-fill"
    "/":"press-kits":_ -> "ri-pages-fill"
    "/":"tags":_ -> "ri-price-tag-3-fill"
    "/":"vods":_ -> "ri-vidicon-fill"
    _ -> "ri-booklet-fill"

data Crosspost =
  Crosspost
    { crosspostUrl :: Text
    , crosspostSite :: Text
    , crosspostTime :: Time.Timestamp
    }
  deriving stock (Eq, Generic, Show)

instance Aeson.FromJSON Crosspost
instance Aeson.ToJSON Crosspost

instance DocTemplates.ToContext Text Crosspost where
  toVal Crosspost{..} =
    let
      items = Map.fromList
        [ ("url", DocTemplates.toVal crosspostUrl)
        , ("site", DocTemplates.toVal crosspostSite)
        , ("time", DocTemplates.toVal crosspostTime)
        ]
    in
      DocTemplates.MapVal (DocTemplates.Context items)
--------------------------------------------------------------------------------
-- Parser
--------------------------------------------------------------------------------

parseMetadata :: FilePath -> Pandoc.Pandoc -> Either Text Metadata
parseMetadata inputPath pandoc@(Pandoc.Pandoc (Pandoc.Meta meta) _) = do
  -- Paths
  let metaPath = Link.pathInfoFromInput inputPath

  -- Title
  let baseName = Link.pathFile metaPath
  metaTitle <-
    if Map.member "title" meta
    then getMetaString "title" meta
    else pure (T.pack baseName)

  -- Times
  let extractTime k = Time.parseTime <=< getMetaString k
  metaCreated <- extractTime "created" meta
  metaPublished <-
    if Map.member "published" meta
    then Just <$> extractTime "published" meta
    else pure Nothing
  metaModified <-
    if Map.member "modified" meta
    then Just <$> extractTime "modified" meta
    else pure Nothing
  metaMigrated <-
    if Map.member "migrated" meta
    then Just <$> extractTime "migrated" meta
    else pure Nothing

  let
    checkTimeValidity mTime =
      case mTime of
        Just time | time < metaCreated ->
          error
            (  "\"" <> T.pack inputPath <> "\""
            <> " has timestamp "
            <> show time
            <> " which is before the created timestamp."
            )
        _ ->
          pure ()
  traverse_ checkTimeValidity [metaPublished, metaModified, metaMigrated]

  let metaOutgoingLinks = parseOutgoingLinks metaPath pandoc
  metaCrossposts <- parseCrossposts meta
  metaTags <-
    if Map.member "tags" meta
    then getMetaStrings "tags" meta
    else pure []
  pure Metadata {..}

parseCrossposts :: Map Text Pandoc.MetaValue -> Either Text [Crosspost]
parseCrossposts meta =
  case Map.lookup "crossposts" meta of
    Just (Pandoc.MetaList arr) -> traverse parseCrosspost arr
    Just _ -> Left "\"crossposts\" metadata is not a list!"
    Nothing -> Right []

parseOutgoingLinks :: Link.PathInfo -> Pandoc.Pandoc -> Set FilePath
parseOutgoingLinks path pandoc =
  let
    extractLink inline =
      case inline of
        (Pandoc.Link _ _ (url, _))
          | "http:" `T.isPrefixOf` url -> []
          | "https:" `T.isPrefixOf` url -> []
          | "mailto:" `T.isPrefixOf` url -> []
          | otherwise -> [T.unpack url]
        _ -> []
    links = Pandoc.query extractLink pandoc
  in
    fromList (Link.canonicalizeLink path <$> links)

parseCrosspost :: Pandoc.MetaValue -> Either Text Crosspost
parseCrosspost v =
  case v of
    Pandoc.MetaMap m -> do
      crosspostUrl <- getMetaString "url" m
      crosspostSite <- extractSite =<< getMetaString "url" m
      crosspostTime <- Time.parseTime =<< getMetaString "time" m
      pure Crosspost {..}
    _ -> Left "\"crosspost\" metadata list item is not a map!"

extractSite :: Text -> Either Text Text
extractSite text = do
  uri <-
    case URI.parseURI (T.unpack text) of
      Just u -> Right u
      Nothing -> Left ("Key \"url\" is not a URI! Saw: \"" <> text <> "\"")
  auth <-
    case URI.uriAuthority uri of
      Just u -> Right u
      Nothing -> Left ("Key \"url\" has no authority! Saw: \"" <> text <> "\"")
  case URI.uriRegName auth of
    "bsky.app" -> Right "bsky"
    "cohost.org" -> Right "cohost!"
    "exodrifter.itch.io" -> Right "itch.io"
    "forum.tsuki.games" -> Right "t/suki"
    "ko-fi.com" -> Right "ko-fi"
    "music.exodrifter.space" -> Right "bandcamp"
    "soundcloud.com" -> Right "soundcloud"
    "store.steampowered.com" -> Right "steam"
    "twitter.com" -> Right "twitter"
    "www.patreon.com" -> Right "patreon"
    "www.youtube.com" -> Right "youtube"
    "x.com" -> Right "twitter"
    "steamcommunity.com" -> Right "steam"
    a -> Right (T.pack a)

--------------------------------------------------------------------------------
-- Meta Helpers
--------------------------------------------------------------------------------

getMetaStrings :: Monad m => Text -> Map Text Pandoc.MetaValue -> m [Text]
getMetaStrings key meta =
  case Map.lookup key meta of
    Just (Pandoc.MetaString text) -> pure [text]
    Just (Pandoc.MetaInlines inlines) -> pure (Pandoc.stringify <$> inlines)
    Just (Pandoc.MetaList inlines) -> pure (Pandoc.stringify <$> inlines)
    Just _ ->
      error ("Key \"" <> key <> "\" is not a list of strings!")
    _ ->
      error ("Key \"" <> key <> "\" does not exist!")

getMetaString :: Monad m => Text -> Map Text Pandoc.MetaValue -> m Text
getMetaString key meta =
  case Map.lookup key meta of
    Just (Pandoc.MetaString text) -> pure text
    Just (Pandoc.MetaInlines inlines) -> pure (Pandoc.stringify inlines)
    Just _ ->
      error ("Key \"" <> key <> "\" is not a string!")
    _ ->
      error ("Key \"" <> key <> "\" does not exist!")
