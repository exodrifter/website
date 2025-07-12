-- Generates an RSS feed
module Exo.RSS
( makeRss
) where

import qualified Exo.Const as Const
import qualified Exo.Pandoc as Pandoc
import qualified Development.Shake.FilePath as FilePath
import qualified Data.Map.Strict as Map
import qualified Data.Text as T
import qualified Data.Time as Time
import qualified Data.Text.Lazy as TL
import qualified Text.RSS.Syntax as RSS
import qualified Text.Feed.Types as Feed
import qualified Text.Feed.Export as Feed

makeRss :: FilePath -> [(FilePath, Pandoc.Pandoc)] -> Either Text Text
makeRss path pandocs = do
  -- Sort the pandocs from newest to oldest
  let
    extractUpdatedTime p =
          rightToMaybe (extractTime "modified" p)
      <|> rightToMaybe (extractTime "created" p)

    sortedPandocs = flip sortBy pandocs \(lf, l) (rf, r) ->
         comparing (Down . extractTime "published") l r
      <> comparing (Down . extractUpdatedTime) l r
      <> compare lf rf

  -- Convert the pandocs into an RSS feed
  items <- sequence (uncurry toRssItem <$> sortedPandocs)
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

toRssItem :: FilePath -> Pandoc.Pandoc -> Either Text RSS.RSSItem
toRssItem path pandoc@(Pandoc.Pandoc (Pandoc.Meta meta) _) =
  let
    result = do
      title <-
        if Map.member "title" meta
        then Pandoc.lookupMetaString "title" meta
        else Right (T.pack (FilePath.takeBaseName path))
      pubDate <-
        case (extractTime "published" pandoc, extractTime "created" pandoc) of
          (Right published, _) -> Right published
          (_, Right created) -> Right created
          (Left err1, Left err2) ->
            Left
              ( "Could not find publish date for \"" <> T.pack path <> "\"; "
              <> err1 <> " and " <> err2
              )
      let
        link = Const.baseUrl
            <> Pandoc.makeCleanLink (FilePath.dropDirectory1 path)
      Right (RSS.nullItem title)
        { RSS.rssItemPubDate = Just (rfc822Format pubDate)
        , RSS.rssItemLink = Just link
        , RSS.rssItemGuid = Just (RSS.nullGuid link)
          { RSS.rssGuidPermanentURL = Just True
          }
        }
  in
    case result of
      Left err ->
        Left ("Failed to make RSS item for " <> T.pack path <> "; " <> err)
      Right item -> Right item

extractTime :: Text -> Pandoc.Pandoc -> Either Text Time.UTCTime
extractTime key (Pandoc.Pandoc (Pandoc.Meta meta) _) = do
  text <- Pandoc.lookupMetaString key meta
  parseTime text

parseTime :: Text -> Either Text Time.UTCTime
parseTime text =
  let
    parse format =
      Time.parseTimeM False Time.defaultTimeLocale format (T.unpack text)
  in
    case viaNonEmpty head (mapMaybe parse (fst <$> Pandoc.timeFormats)) of
      Nothing -> Left ("Cannot parse time \"" <> text <> "\"")
      Just time -> Right time

rfc822Format :: Time.UTCTime -> Text
rfc822Format =
  T.pack . Time.formatTime Time.defaultTimeLocale "%a, %d %b %Y %H:%M:%S GMT"
