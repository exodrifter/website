-- Loads known metadata fields from Pandoc documents.
module Exo.Pandoc.Meta
( getPublished
, getCreated
, getLastUpdated

-- Helpers
, lookupMetaString
) where

import qualified Data.Map.Strict as Map
import qualified Exo.Pandoc.Time as Time
import qualified Text.Pandoc as Pandoc
import qualified Text.Pandoc.Shared as Pandoc

-- The time the file was published to the internet. This type of time is only
-- used for articles like blog posts. It can be older than the creation time of
-- the file, if the article was migrated from a different site.
getPublished :: Pandoc.Pandoc -> Either Text Time.UTCTime
getPublished = extractTime "published"

-- The time the file was created. This time can be after the publish date, in
-- which case it indicates that I wrote and published the article's content
-- elsewhere before I migrated it to my personal site.
getCreated :: Pandoc.Pandoc -> Either Text Time.UTCTime
getCreated = extractTime "created"

-- The latest time the file was added or modified.
getLastUpdated :: Pandoc.Pandoc -> Either Text Time.UTCTime
getLastUpdated p =
  case extractTime "modified" p of
    Right time -> Right time
    Left err1 ->
      case extractTime "created" p of
        Right time -> Right time
        Left err2 -> Left (err1 <> " and " <> err2)

--------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------

lookupMetaString :: Text -> Map Text Pandoc.MetaValue -> Either Text Text
lookupMetaString key meta =
  case Map.lookup key meta of
    Just (Pandoc.MetaString text) -> Right text
    Just (Pandoc.MetaInlines inlines) -> Right (Pandoc.stringify inlines)
    Just _ ->
      Left ("Key \"" <> key <> "\" is not a string!")
    _ ->
      Left ("Key \"" <> key <> "\" does not exist!")

extractTime :: Text -> Pandoc.Pandoc -> Either Text Time.UTCTime
extractTime key (Pandoc.Pandoc (Pandoc.Meta meta) _) = do
  text <- lookupMetaString key meta
  Time.parseTime text
