module Exo.Vods.Migration
( migrateVods
) where

import Control.Monad.Catch (MonadThrow)
import Data.Aeson ((.:), (.=))
import Network.HTTP.Req ((/:), (=:))
import qualified Data.Aeson as Aeson
import qualified Data.Aeson.Encode.Pretty as Aeson
import qualified Data.ByteString.Char8 as BS8
import qualified Data.ByteString.Lazy as LBS
import qualified Data.NonEmptyText as NET
import qualified Data.Set as Set
import qualified Data.Text as T
import qualified Data.Text.IO as TIO
import qualified Data.Text.Encoding as TE
import qualified Data.Time as Time
import qualified Data.Time.TimeSpan as TimeSpan
import qualified Network.HTTP.Client as HTTP
import qualified Network.HTTP.Client.TLS as HTTP
import qualified Network.HTTP.Req as Req
import qualified Safe
import qualified Turtle

toBS :: Text -> BS8.ByteString
toBS = TE.encodeUtf8

toLBS :: Text -> LBS.ByteString
toLBS = LBS.fromStrict . TE.encodeUtf8

fromLBS :: LBS.ByteString -> Text
fromLBS = TE.decodeUtf8 . LBS.toStrict

--------------------------------------------------------------------------------
-- System Types
--------------------------------------------------------------------------------

data Secrets =
  Secrets
    { accessToken :: ByteString
    }

instance Aeson.FromJSON Secrets where
  parseJSON = Aeson.withObject "Secrets" $ \a ->
    Secrets
      <$> (toBS <$> a .: "access_token")

--------------------------------------------------------------------------------
-- Vimeo Types
--------------------------------------------------------------------------------

data UserResult =
  UserResult
    { currentPage :: Int
    , pagingInfo :: Paging
    , results :: [Video]
    }

instance Aeson.FromJSON UserResult where
  parseJSON = Aeson.withObject "UserResult" $ \a ->
    UserResult
      <$> a .: "page"
      <*> a .: "paging"
      <*> a .: "data"

data Paging =
  Paging
    { nextPage :: Maybe Text
    }

instance Aeson.FromJSON Paging where
  parseJSON = Aeson.withObject "Paging" $ \a ->
    Paging
      <$> a .: "next"

data Video =
  Video
    { videoId :: Text
    , name :: Text
    , description :: Maybe Text
    , duration :: TimeSpan.TimeSpan
    , pictures :: Pictures
    , parentFolder :: Maybe Folder
    }

instance Aeson.FromJSON Video where
  parseJSON = Aeson.withObject "Video" $ \a -> do
    uri <- a .: "uri"
    Video
      <$> maybe (fail "Could not parse video id") pure
                (Safe.lastMay . T.splitOn "/" $ uri)
      <*> a .: "name"
      <*> a .: "description"
      <*> (TimeSpan.seconds <$> a .: "duration")
      <*> a .: "pictures"
      <*> a .: "parent_folder"

data Pictures =
  Pictures
    { pictureUri :: Maybe Text
    , baseLink :: Text
    }

instance Aeson.FromJSON Pictures where
  parseJSON = Aeson.withObject "Pictures" $ \a -> do
    Pictures
      <$> a .: "uri"
      <*> a .: "base_link"

data Folder =
  Folder
    { folderName :: Text
    }

instance Aeson.FromJSON Folder where
  parseJSON = Aeson.withObject "Folder" $ \a ->
    Folder
      <$> a .: "name"

--------------------------------------------------------------------------------
-- Jekyll Types
--------------------------------------------------------------------------------

data Post =
  Post
    { postTitle :: Maybe NET.NonEmptyText
    , postDate :: Time.ZonedTime
    , postDuration :: TimeSpan.TimeSpan
    , postThumbPath :: Maybe Text
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
    && postThumbPath l == postThumbPath r
    && postThumbUri l == postThumbUri r
    && postCategories l == postCategories r
    && postTags l == postTags r
    && postVideoId l == postVideoId r
    && postShorts l == postShorts r

instance Aeson.ToJSON Post where
  toJSON p =
    Aeson.object
      [ "title" .= (NET.toText <$> postTitle p)
      , "timestamp" .= postDate p
      , "duration" .= (TimeSpan.toSeconds $ postDuration p)
      , "thumbPath" .= postThumbPath p
      , "thumbUri" .= postThumbUri p
      , "categories" .= postCategories p
      , "tags" .= postTags p
      , "videoId" .= postVideoId p
      , "shorts" .= postShorts p
      ]

instance Aeson.FromJSON Post where
  parseJSON = Aeson.withObject "Post" $ \a ->
    Post
      <$> ((NET.fromText =<<) <$> a .: "title")
      <*> a .: "timestamp"
      <*> (TimeSpan.seconds <$> a .: "duration")
      <*> a .: "thumbPath"
      <*> a .: "thumbUri"
      <*> a .: "categories"
      <*> a .: "tags"
      <*> a .: "videoId"
      <*> a .: "shorts"

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

newtype Migration a = Migration (ReaderT MigrationContext IO a)
  deriving
    ( Applicative
    , Functor
    , Monad
    , MonadIO
    , MonadReader MigrationContext
    , MonadThrow
    )

data MigrationContext =
  MigrationContext
    { migrationSecrets :: Secrets
    , migrationManager :: HTTP.Manager
    }

runMigration :: Migration a -> IO a
runMigration (Migration migration) = do
  context <-
    MigrationContext
      <$> expectJust "Cannot parse .env.json" (Aeson.decodeFileStrict ".env.json")
      <*> HTTP.newManager HTTP.tlsManagerSettings
  runReaderT migration context

expectJust :: MonadIO io => Text -> io (Maybe a) -> io a
expectJust message fn = do
  ma <- fn
  case ma of
    Nothing -> die $ T.unpack message
    Just a -> pure a

getVideos :: Int -> Migration UserResult
getVideos page = do
  auth <- asks (accessToken . migrationSecrets)
  let url = Req.https "api.vimeo.com" /: "users" /: "104901742" /: "videos"
  response <- Req.runReq Req.defaultHttpConfig
    . Req.req Req.GET url Req.NoReqBody Req.jsonResponse
    $ Req.headerRedacted "Authorization" ("bearer " <> auth)
    <> "fields" =: ("uri,name,description,duration,pictures.base_link,\
                    \pictures.uri,parent_folder.name" :: Text)
    <> "page" =: (show page :: Text)
    <> "per_page" =: (100 :: Int)
  pure $ Req.responseBody response

getThumbnail :: Text -> Migration LBS.ByteString
getThumbnail url = do
  manager <- asks migrationManager
  request <- HTTP.parseRequest $ T.unpack url
  response <- liftIO $ flip HTTP.httpLbs manager $
    request { HTTP.path = HTTP.path request <> "_640x360.jpg" }
  pure $ HTTP.responseBody response

parseTime :: (Time.ParseTime t, MonadFail m) => String -> Text -> m t
parseTime fmt = Time.parseTimeM True Time.defaultTimeLocale fmt . T.unpack

formatTime :: Time.FormatTime t => String -> t -> Text
formatTime fmt = T.pack . Time.formatTime Time.defaultTimeLocale fmt

migrateVods :: IO ()
migrateVods = runMigration $ do
  page <- getVideos 1
  traverse_ migrate (results page)
  followPagination page

followPagination :: UserResult -> Migration ()
followPagination page =
  case nextPage $ pagingInfo page of
    Nothing -> pure ()
    Just _ -> do
      next <- getVideos (currentPage page + 1)
      traverse_ migrate (results next)
      followPagination next

migrate :: Video -> Migration ()
migrate video = do
  case folderName <$> parentFolder video of
    Just n | n == "Streams" -> do
      migrate' video
    _ ->
      pure ()

migrate' :: Video -> Migration ()
migrate' video = do
  (service, zonedTime) <-
    case T.words (T.toLower (name video)) of
      service:_:day:time:[] ->
        case parseTime "%F %T%z" (day <> " " <> time) of
          Just zonedTime -> pure (service, zonedTime)
          Nothing ->
            die $ "Could not determine timezone for \""
               <> T.unpack (name video) <> "\""

      _ -> die $ "Could not parse name \"" <> T.unpack (name video) <> "\""

  -- Try to load the old data
  let fileName = formatTime "%Y-%m-%d-%H-%M-%S" $ Time.zonedTimeToUTC zonedTime
      dataPath = "vods/data/" <> fileName <> ".json"
  postExists <- Turtle.testpath (T.unpack dataPath)
  oldPost <-
    if postExists
    then do
      t <- liftIO $ TIO.readFile (T.unpack dataPath)
      case Aeson.eitherDecode $ toLBS t of
        Left reason -> die $ "Failed to read post; " <> reason
        Right p -> pure $ Just p
    else pure Nothing

  -- Update the post
  let desc = NET.fromText =<< description video
      newPost =
        case oldPost of
          Just p ->
            p { postDate = zonedTime
              , postDuration = duration video
              , postThumbPath = Just $ "/assets/thumbs/" <> fileName <> ".jpg"
              , postThumbUri = pictureUri $ pictures video
              , postCategories = Set.insert service (postCategories p)
              , postVideoId = Just $ videoId video
              }
          Nothing ->
            Post
              { postTitle = desc
              , postDate = zonedTime
              , postDuration = duration video
              , postThumbPath = Just $ "/assets/thumbs/" <> fileName <> ".jpg"
              , postThumbUri = pictureUri $ pictures video
              , postCategories = Set.singleton service
              , postTags = Set.empty
              , postVideoId = Just $ videoId video
              , postShorts = []
              }
  when (oldPost /= Just newPost) $ do
    echo ("Updating " <> videoId video <> " at " <> dataPath)
  liftIO $ TIO.writeFile (T.unpack dataPath)
                         (fromLBS . Aeson.encodePretty $ newPost)

  downloadThumbIfNeeded fileName video oldPost

downloadThumbIfNeeded :: Text -> Video -> Maybe Post -> Migration ()
downloadThumbIfNeeded fileName video oldPost = do
  let thumbPath = "vods/assets/thumbs/" <> fileName <> ".jpg"
  thumbExists <- Turtle.testpath (T.unpack thumbPath)
  case (thumbExists, pictureUri $ pictures video) of

    -- Vimeo is sending us the default thumbnail and we have a thumbnail on
    -- disk. We don't delete the thumb in case the user wants to keep it.
    (True, Nothing) ->
      echo ("  Warning: " <> videoId video <> " no longer has a thumbnail!")

    -- Don't download the default thumbnail from Vimeo
    (False, Nothing) -> pure ()

    (True, Just pUri) ->
      case postThumbUri =<< oldPost of

        -- We don't have the thumbnail yet
        Nothing -> downloadThumb video thumbPath

        -- Download the thumbnail only if it is different
        Just oldThumbUri
          | oldThumbUri /= pUri -> downloadThumb video thumbPath
          | otherwise -> pure ()

    -- We don't have the thumbnail yet
    (False, Just _) -> downloadThumb video thumbPath

downloadThumb :: Video -> Text -> Migration ()
downloadThumb video thumbPath = do
  echo ("  Downloading thumb for " <> videoId video <> " to " <> thumbPath)
  thumb <- getThumbnail (baseLink $ pictures video)
  liftIO $ LBS.writeFile (T.unpack thumbPath) thumb

echo :: MonadIO m => Text -> m ()
echo text = traverse_ Turtle.echo (Turtle.textToLines text)
