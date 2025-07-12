-- Loads known metadata fields from Pandoc documents.
module Exo.Pandoc.Meta
( getTitle
, getPublishedTime
, getPublishedText
, getCreatedTime
, getCreatedText
, getModifiedTime
, getModifiedText
, getLastUpdatedTime
, getTags

-- Helpers
, hasMetaKey
, lookupMetaString
) where

import qualified Data.Map.Strict as Map
import qualified Exo.Pandoc.Time as Time
import qualified Text.Pandoc as Pandoc
import qualified Text.Pandoc.Shared as Pandoc

getTitle :: Pandoc.Pandoc -> Either Text Text
getTitle (Pandoc.Pandoc (Pandoc.Meta meta) _) =
  lookupMetaString "title" meta

-- The time the file was published to the internet. This type of time is only
-- used for articles like blog posts. It can be older than the creation time of
-- the file, if the article was migrated from a different site.
getPublishedTime :: Pandoc.Pandoc -> Either Text Time.UTCTime
getPublishedTime = Time.parseTime <=< extractTime "published"

getPublishedText :: Pandoc.Pandoc -> Either Text Text
getPublishedText = Time.reformatTime <=< extractTime "published"

-- The time the file was created. This time can be after the publish date, in
-- which case it indicates that I wrote and published the article's content
-- elsewhere before I migrated it to my personal site.
getCreatedTime :: Pandoc.Pandoc -> Either Text Time.UTCTime
getCreatedTime = Time.parseTime <=< extractTime "created"

getCreatedText :: Pandoc.Pandoc -> Either Text Text
getCreatedText = Time.reformatTime <=< extractTime "created"

-- The time the file was modified. This indicates the time the content of the
-- document was last edited. This time is not updated when the metadata of the
-- document is edited.
getModifiedTime :: Pandoc.Pandoc -> Either Text Time.UTCTime
getModifiedTime = Time.parseTime <=< extractTime "modified"

getModifiedText :: Pandoc.Pandoc -> Either Text Text
getModifiedText = Time.reformatTime <=< extractTime "modified"

-- The latest time the file was added or modified.
getLastUpdatedTime :: Pandoc.Pandoc -> Either Text Time.UTCTime
getLastUpdatedTime p =
  case getModifiedTime p of
    Right time -> Right time
    Left err1 ->
      case getCreatedTime p of
        Right time -> Right time
        Left err2 -> Left (err1 <> " and " <> err2)

getTags :: Pandoc.Pandoc -> Either Text [Text]
getTags pandoc@(Pandoc.Pandoc (Pandoc.Meta meta) _) =
  if hasMetaKey "tags" pandoc
  then lookupMetaStrings "tags" meta
  else Right []

--------------------------------------------------------------------------------
-- Pandoc Helpers
--------------------------------------------------------------------------------

hasMetaKey :: Text -> Pandoc.Pandoc -> Bool
hasMetaKey key (Pandoc.Pandoc (Pandoc.Meta meta) _) = Map.member key meta

extractTime :: Text -> Pandoc.Pandoc -> Either Text Text
extractTime key (Pandoc.Pandoc (Pandoc.Meta meta) _) = do
  lookupMetaString key meta

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
