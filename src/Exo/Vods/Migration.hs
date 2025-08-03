module Exo.Vods.Migration
( migrateVods
) where

import Data.Aeson ((.:), (.=))
import System.FilePath((</>), (-<.>))
import qualified Data.Aeson as Aeson
import qualified Data.Attoparsec.Text as Atto
import qualified Data.ByteString.Lazy as LBS
import qualified Data.NonEmptyText as NET
import qualified Data.Set as Set
import qualified Data.Text as T
import qualified Data.Text.IO as TIO
import qualified Data.Text.Encoding as TE
import qualified Data.Time as Time
import qualified Data.Time.TimeSpan as TimeSpan
import qualified Data.Yaml as Yaml
import qualified Exo.Vods.Vimeo as Vimeo
import qualified Turtle
import qualified System.Directory as Directory

--------------------------------------------------------------------------------
-- Jekyll Types
--------------------------------------------------------------------------------

data Post =
  Post
    { postTitle :: Maybe NET.NonEmptyText
    , postDate :: Time.ZonedTime
    , postDuration :: TimeSpan.TimeSpan
    , postThumbUri :: Maybe Text
    , postCategories :: Set Text
    , postTags :: Set Text
    , postVideoId :: Maybe Text
    , postShorts :: [Short]
    }

instance Eq Post where
  (==) l r =
       postTitle l == postTitle r
    && Time.zonedTimeToUTC (postDate l) == Time.zonedTimeToUTC (postDate r)
    && postDuration l == postDuration r
    && postThumbUri l == postThumbUri r
    && postCategories l == postCategories r
    && postTags l == postTags r
    && postVideoId l == postVideoId r
    && postShorts l == postShorts r

instance Aeson.ToJSON Post where
  toJSON p =
    Aeson.object
      [ "title" .= (NET.toText <$> postTitle p)
      , "created" .= postDate p
      , "videoDuration" .= TimeSpan.toSeconds (postDuration p)
      , "videoThumbId" .= postThumbUri p
      , "tags" .= postTags p
      , "videoId" .= postVideoId p
      , "videoShorts" .= postShorts p
      ]

instance Aeson.FromJSON Post where
  parseJSON = Aeson.withObject "Post" $ \a ->
    Post
      <$> ((NET.fromText =<<) <$> a .: "title")
      <*> (a .: "created" <|> a .: "timestamp")
      <*> (TimeSpan.seconds <$> (a .: "videoDuration" <|> a .: "duration"))
      <*> (a .: "videoThumbId" <|> a .: "thumbUri")
      <*> (a .: "categories" <|> pure Set.empty)
      <*> a .: "tags"
      <*> a .: "videoId"
      <*> (a .: "videoShorts" <|> a .: "shorts")

data Short =
  Short
    { shortName :: Text
    , shortLinks :: [ShortLink]
    } deriving Eq

instance Aeson.ToJSON Short where
  toJSON a =
    Aeson.object
      [ "name" .= shortName a
      , "links" .= shortLinks a
      ]

instance Aeson.FromJSON Short where
  parseJSON = Aeson.withObject "Short" $ \a ->
    Short
      <$> a .: "name"
      <*> a .: "links"

data ShortLink =
  ShortLink
    { shortLinkService :: ShortService
    , shortLinkId :: Text
    } deriving Eq

instance Aeson.ToJSON ShortLink where
  toJSON p =
    Aeson.object
      [ "service" .= shortLinkService p
      , "id" .= shortLinkId p
      ]

instance Aeson.FromJSON ShortLink where
  parseJSON = Aeson.withObject "ShortLink" $ \a ->
    ShortLink
      <$> a .: "service"
      <*> a .: "id"

data ShortService = Twitch | YouTube
  deriving Eq

instance Aeson.ToJSON ShortService where
  toJSON a =
    case a of
      Twitch -> Aeson.String "twitch"
      YouTube -> Aeson.String "youtube"

instance Aeson.FromJSON ShortService where
  parseJSON = Aeson.withText "ShortService" $ \t ->
    case t of
      "twitch" -> pure Twitch
      "youtube" -> pure YouTube
      _ -> fail "Unknown short service"

--------------------------------------------------------------------------------
-- Logic
--------------------------------------------------------------------------------

parseTime :: (Time.ParseTime t, MonadFail m) => String -> Text -> m t
parseTime fmt = Time.parseTimeM True Time.defaultTimeLocale fmt . T.unpack

formatTime :: Time.FormatTime t => String -> t -> Text
formatTime fmt = T.pack . Time.formatTime Time.defaultTimeLocale fmt

migrateVods :: IO ()
migrateVods = do
  context <- Vimeo.loadVimeoContext
  videos <- Vimeo.runVimeo context Vimeo.getVideos
  result <- catMaybes <$> traverse migrate videos
  traverse_ (downloadThumbIfNeeded context) result

  let allTags = Set.unions (postTags <$> mapMaybe snd result)
  traverse_ createMissingTag allTags

createMissingTag :: Text -> IO ()
createMissingTag tag = do
  now <- Time.getCurrentTime

  let
    path = "content/tags" </> T.unpack tag -<.> ".md"
    created =
      Time.formatTime Time.defaultTimeLocale "%Y-%m-%dT%H:%M:%SZ" now

  exists <- Directory.doesFileExist path
  unless exists do
    TIO.writeFile path
      ( "---\n\
        \created: " <> T.pack created <> "\n\
        \tags:\n\
        \- " <> tag <> "\n\
        \---\n"
      )

extractServiceAndTime :: Vimeo.Video -> IO (T.Text, Time.ZonedTime)
extractServiceAndTime video = do
  case T.words (T.toLower (Vimeo.name video)) of
    [service, _, day, time] ->
      case parseTime "%F %T%z" (day <> " " <> time) of
        Just zonedTime -> pure (service, zonedTime)
        Nothing ->
          die $ "Could not determine timezone for \""
              <> T.unpack (Vimeo.name video) <> "\""

    _ -> die $ "Could not parse name \"" <> T.unpack (Vimeo.name video) <> "\""

migrate :: Vimeo.Video -> IO (Maybe (Vimeo.Video, Maybe Post))
migrate video = do
  case Vimeo.folderName <$> Vimeo.parentFolder video of
    Just n | n == "Streams" -> do
      Just <$> migrate' video
    _ ->
      pure Nothing

splitFrontmatter :: Atto.Parser (Text, Text)
splitFrontmatter = do
  let delimiter = Atto.string "---" >> Atto.endOfLine
  frontMatter <- delimiter *> Atto.manyTill Atto.anyChar delimiter
  rest <- Atto.takeText
  Atto.endOfInput
  pure (T.pack frontMatter, rest)

migrate' :: Vimeo.Video -> IO (Vimeo.Video, Maybe Post)
migrate' video = do
  (service, zonedTime) <- extractServiceAndTime video
  -- Try to load the old data
  let fileName = formatTime "%Y%m%d%H%M%S" $ Time.zonedTimeToUTC zonedTime
      dataPath = "content/vods/" <> T.unpack fileName <> ".md"
  postExists <- Turtle.testpath dataPath
  oldPost <-
    if postExists
    then do
      t <- liftIO $ TIO.readFile dataPath
      case Atto.parseOnly splitFrontmatter t of
        Left err ->
          die err
        Right (frontMatter, _markdown) ->
          case Yaml.decodeEither' (TE.encodeUtf8 frontMatter) of
            Left reason -> die ("Failed to read post; " <> displayException reason)
            Right p -> pure (Just p)
    else pure Nothing

  -- Update the post
  let desc = NET.fromText =<< Vimeo.description video
      newPost =
        case oldPost of
          Just p ->
            p { postDate = zonedTime
              , postDuration = Vimeo.duration video
              , postThumbUri = Vimeo.pictureUri $ Vimeo.pictures video
              , postCategories = Set.empty
              , postVideoId = Just $ Vimeo.videoId video
              , postTags = fromList (migrateTag <$> toList (postTags p) <> toList (postCategories p) <> [service])
              }
          Nothing ->
            Post
              { postTitle = desc
              , postDate = zonedTime
              , postDuration = Vimeo.duration video
              , postThumbUri = Vimeo.pictureUri $ Vimeo.pictures video
              , postCategories = Set.empty
              , postTags = Set.singleton service
              , postVideoId = Just $ Vimeo.videoId video
              , postShorts = []
              }
  when (oldPost /= Just newPost) $ do
    echo ("Updating " <> Vimeo.videoId video <> " at " <> T.pack dataPath)

  let
    content = "---\n" <> TE.decodeUtf8 (Yaml.encode newPost) <> "---\n"
  liftIO (TIO.writeFile dataPath content)

  pure (video, oldPost)

migrateTag :: Text -> Text
migrateTag =
    (\t -> if t == "lost-contact" then "no-signal" else t)
  . (\t -> if "raid" `T.isPrefixOf` t then t else T.toLower t)
  . T.replace "game-" ""
  . T.replace "code-" ""
  . T.replace "language-" ""
  . T.replace "'" ""
  . T.replace "," ""
  . T.replace ":-" "-"
  . T.replace " " "-"

downloadThumbIfNeeded :: Vimeo.VimeoContext -> (Vimeo.Video, Maybe Post) -> IO ()
downloadThumbIfNeeded context (video, oldPost) = do
  (_, zonedTime) <- extractServiceAndTime video
  let
    fileName = formatTime "%Y%m%d%H%M%S" $ Time.zonedTimeToUTC zonedTime
    thumbPath = "content/vods/" <> fileName <> ".jpg"
  thumbExists <- Turtle.testpath (T.unpack thumbPath)
  case (thumbExists, Vimeo.pictureUri $ Vimeo.pictures video) of

    -- Vimeo is sending us the default thumbnail and we have a thumbnail on
    -- disk. We don't delete the thumb in case the user wants to keep it.
    (True, Nothing) ->
      echo ("  Warning: " <> Vimeo.videoId video <> " no longer has a thumbnail!")

    -- Don't download the default thumbnail from Vimeo
    (False, Nothing) -> pure ()

    (True, Just pUri) ->
      case postThumbUri =<< oldPost of

        -- We don't have the thumbnail yet
        Nothing -> liftIO (downloadThumb context video thumbPath)

        -- Download the thumbnail only if it is different
        Just oldThumbUri
          | oldThumbUri /= pUri -> liftIO (downloadThumb context video thumbPath)
          | otherwise -> pure ()

    -- We don't have the thumbnail yet
    (False, Just _) -> liftIO (downloadThumb context video thumbPath)

downloadThumb :: Vimeo.VimeoContext -> Vimeo.Video -> Text -> IO ()
downloadThumb context video thumbPath = do
  echo ("  Downloading thumb for " <> Vimeo.videoId video <> " to " <> thumbPath)
  thumb <- Vimeo.runVimeo context (Vimeo.getThumbnail video)
  liftIO $ LBS.writeFile (T.unpack thumbPath) thumb

echo :: MonadIO m => Text -> m ()
echo text = traverse_ Turtle.echo (Turtle.textToLines text)
