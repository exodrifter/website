-- Generates an RSS feed
module Exo.RSS
( makeRss
) where

import qualified Data.Text as T
import qualified Data.Text.Lazy as TL
import qualified Data.Time as Time
import qualified Development.Shake.FilePath as FilePath
import qualified Exo.Pandoc as Pandoc
import qualified Text.Feed.Export as Feed
import qualified Text.Feed.Types as Feed
import qualified Text.RSS.Syntax as RSS

makeRss :: FilePath -> [Pandoc.Metadata] -> Either Text Text
makeRss path metas = do
  -- Convert the pandocs into an RSS feed
  items <- traverse toRssItem metas
  let
    folderName = FilePath.takeBaseName path
    rss =
      RSS.nullRSS
        ("exodrifter " <> T.pack folderName)
        ("http://www.exodrifter.space/" <> T.pack path)
    rssWithItems =
      rss
        { RSS.rssChannel =
          (RSS.rssChannel rss)
            { RSS.rssItems = items
            }
        }

  case Feed.textFeed (Feed.RSSFeed rssWithItems) of
    Nothing ->
      error ("Failed to create feed \"" <> T.pack path <> "\"")
    Just text ->
      Right (TL.toStrict text)

toRssItem :: Pandoc.Metadata -> Either Text RSS.RSSItem
toRssItem metadata@Pandoc.Metadata{..} = do
  let pubDate = fromMaybe metaCreated metaPublished
  Right (RSS.nullItem metaTitle)
    { RSS.rssItemPubDate = Just (rfc822Format (fst pubDate))
    , RSS.rssItemLink = Just (Pandoc.metaLink metadata)
    , RSS.rssItemGuid = Just (RSS.nullGuid (Pandoc.metaLink metadata))
      { RSS.rssGuidPermanentURL = Just True
      }
    }

rfc822Format :: Time.UTCTime -> Text
rfc822Format =
  T.pack . Time.formatTime Time.defaultTimeLocale "%a, %d %b %Y %H:%M:%S GMT"
