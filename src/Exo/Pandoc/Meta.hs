{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE MultiParamTypeClasses #-}

-- Loads known metadata fields from Pandoc documents.
module Exo.Pandoc.Meta
( Metadata(..), Crosspost(..)
, parseMetadata

, metaInputPath
, metaOutputPath
, metaCanonicalPath
, metaLink
, metaUpdated
) where

import qualified Data.Aeson as Aeson
import qualified Data.Map.Strict as Map
import qualified Data.Text as T
import qualified Exo.Pandoc.Link as Link
import qualified Exo.Pandoc.Time as Time
import qualified Network.URI as URI
import qualified Text.DocTemplates as DocTemplates
import qualified Text.Pandoc as Pandoc
import qualified Text.Pandoc.Shared as Pandoc

data Metadata =
  Metadata
    { metaPath :: Link.PathInfo
    -- ^ The paths associated with this file.

    , metaTitle :: Text
    -- ^ The title of the document.

    , metaCreated :: (Time.UTCTime, String)
    -- ^ The time the document was created. This time can be after the publish
    -- date, in which case it indicates that I wrote and published the
    -- document's content elsewhere before I migrated it to my personal site.
    , metaPublished :: Maybe (Time.UTCTime, String)
    -- ^ The time the document was published to the internet. This type of time
    -- is only used for documents like blog posts. It can be older than the
    -- creation time of the document, if the document was migrated from a
    -- different site.
    , metaModified :: Maybe (Time.UTCTime, String)
    -- ^ The time the document was modified. This indicates the time the content
    -- of the document was last edited. This time is not updated when the
    -- metadata of the document is edited or when the document's content does
    -- not meaningfully change (such as when link urls are updated to point to
    -- the new location of moved documents).
    , metaTranscribed :: Maybe (Time.UTCTime, String)
    -- ^ The time the document was transcribed from a physical medium.

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
        , ("published", maybeToVal (Time.formatTime <$> metaPublished))
        , ("created", DocTemplates.toVal (Time.formatTime metaCreated))
        , ("modified", maybeToVal (Time.formatTime <$> metaModified))
        , ("transcribed", maybeToVal (Time.formatTime <$> metaTranscribed))
        , ("updated", maybeToVal (Time.formatTime <$> metaUpdated meta))
        , ("crossposts", DocTemplates.toVal metaCrossposts)
        , ("tags", DocTemplates.toVal metaTags)
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

-- The URL to the document on the website.
metaLink :: Metadata -> Text
metaLink Metadata{..} = Link.pathLink metaPath

metaUpdated :: Metadata -> Maybe (Time.UTCTime, String)
metaUpdated Metadata{..} = metaModified <|> metaPublished

data Crosspost =
  Crosspost
    { crosspostUrl :: Text
    , crosspostSite :: Text
    , crosspostTime :: (Time.UTCTime, String)
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
        , ("time", DocTemplates.toVal (Time.formatTime crosspostTime))
        ]
    in
      DocTemplates.MapVal (DocTemplates.Context items)
--------------------------------------------------------------------------------
-- Parser
--------------------------------------------------------------------------------

parseMetadata :: FilePath -> Pandoc.Pandoc -> Either Text Metadata
parseMetadata inputPath (Pandoc.Pandoc (Pandoc.Meta meta) _) = do
  -- Paths
  let metaPath = Link.pathInfoFromInput inputPath

  -- Title
  let baseName = Link.pathFile metaPath
  metaTitle <- lookupMetaString "title" meta <> pure (T.pack baseName)

  -- Times
  let extractTime k = Time.parseTime <=< lookupMetaString k
  metaCreated <- extractTime "created" meta
  metaPublished <-
    if Map.member "published" meta
    then Just <$> extractTime "published" meta
    else pure Nothing
  metaModified <-
    if Map.member "modified" meta
    then Just <$> extractTime "modified" meta
    else pure Nothing
  metaTranscribed <-
    if Map.member "transcribed" meta
    then Just <$> extractTime "transcribed" meta
    else pure Nothing

  metaCrossposts <- parseCrossposts meta
  metaTags <- lookupMetaStrings "tags" meta <> pure []
  pure Metadata {..}

parseCrossposts :: Map Text Pandoc.MetaValue -> Either Text [Crosspost]
parseCrossposts meta =
  case Map.lookup "crossposts" meta of
    Just (Pandoc.MetaList arr) -> traverse parseCrosspost arr
    Just _ -> Left "\"crossposts\" metadata is not a list!"
    Nothing -> Right []

parseCrosspost :: Pandoc.MetaValue -> Either Text Crosspost
parseCrosspost v =
  case v of
    Pandoc.MetaMap m -> do
      crosspostUrl <- lookupMetaString "url" m
      crosspostSite <- extractSite =<< lookupMetaString "url" m
      crosspostTime <- Time.parseTime =<< lookupMetaString "time" m
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

lookupMetaStrings :: Text -> Map Text Pandoc.MetaValue -> Either Text [Text]
lookupMetaStrings key meta =
  case Map.lookup key meta of
    Just (Pandoc.MetaString text) -> Right [text]
    Just (Pandoc.MetaInlines inlines) -> Right (Pandoc.stringify <$> inlines)
    Just (Pandoc.MetaList inlines) -> Right (Pandoc.stringify <$> inlines)
    Just _ ->
      Left ("Key \"" <> key <> "\" is not a list of strings!")
    _ ->
      Left ("Key \"" <> key <> "\" does not exist!")

lookupMetaString :: Text -> Map Text Pandoc.MetaValue -> Either Text Text
lookupMetaString key meta =
  case Map.lookup key meta of
    Just (Pandoc.MetaString text) -> Right text
    Just (Pandoc.MetaInlines inlines) -> Right (Pandoc.stringify inlines)
    Just _ ->
      Left ("Key \"" <> key <> "\" is not a string!")
    _ ->
      Left ("Key \"" <> key <> "\" does not exist!")
