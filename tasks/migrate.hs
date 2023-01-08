#!/usr/bin/env stack
{- stack runghc
    --resolver lts-20.4
    --package aeson
    --package aeson-pretty
    --package bytestring
    --package containers
    --package non-empty-text
    --package relude
    --package req
    --package safe
    --package text
    --package turtle
    --package tz
-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}

import Relude hiding (die)

import Control.Monad.Catch (MonadThrow)
import Data.Aeson hiding ((<?>))
import Data.Aeson.Encode.Pretty
import Data.Attoparsec.Text ((<?>))
import Network.HTTP.Req
import Safe
import Turtle
import qualified Data.ByteString.Char8 as BS8
import qualified Data.ByteString.Lazy as LBS
import qualified Data.Char as Char
import qualified Data.List as List
import qualified Data.Map as Map
import qualified Data.NonEmptyText as NET
import qualified Data.Set as Set
import qualified Data.Text as T
import qualified Data.Text.Encoding as TE
import qualified Data.Text.IO as Text
import qualified Data.Time as Time
import qualified Data.Time.Zones as TZ
import qualified Data.Time.Zones.All as TZ
import qualified Network.HTTP.Client as HTTP
import qualified Network.HTTP.Client.TLS as HTTP

toBS = TE.encodeUtf8
toLBS = LBS.fromStrict . TE.encodeUtf8
fromLBS = TE.decodeUtf8 . LBS.toStrict

--------------------------------------------------------------------------------
-- System Types
--------------------------------------------------------------------------------

data Secrets =
  Secrets
    { clientId :: ByteString
    , clientSecret :: ByteString
    , accessToken :: ByteString
    }

instance FromJSON Secrets where
  parseJSON = withObject "Secrets" $ \o ->
    Secrets
      <$> (toBS <$> o .: "client_id")
      <*> (toBS <$> o .: "client_secret")
      <*> (toBS <$> o .: "access_token")

--------------------------------------------------------------------------------
-- Vimeo Types
--------------------------------------------------------------------------------

data UserResult =
  UserResult
    { totalResults :: Int
    , currentPage :: Int
    , resultsPerPage :: Int
    , pagingInfo :: Paging
    , results :: [Video]
    }

instance FromJSON UserResult where
  parseJSON = withObject "UserResult" $ \o ->
    UserResult
      <$> o .: "total"
      <*> o .: "page"
      <*> o .: "per_page"
      <*> o .: "paging"
      <*> o .: "data"

data Paging =
  Paging
    { nextPage :: Maybe Text
    , previousPage :: Maybe Text
    , firstPage :: Text
    , lastPage :: Text
    }

instance FromJSON Paging where
  parseJSON = withObject "Paging" $ \o ->
    Paging
      <$> o .: "next"
      <*> o .: "previous"
      <*> o .: "first"
      <*> o .: "last"

data Video =
  Video
    { videoURI :: Text
    , videoId :: Text
    , name :: Text
    , description :: Maybe Text
    , pictures :: Pictures
    , parentFolder :: Maybe Folder
    }

instance FromJSON Video where
  parseJSON = withObject "Video" $ \o -> do
    a <- o .: "uri"
    Video
      <$> pure a
      <*> maybe (fail "Could not parse video id") pure
                (Safe.lastMay . T.splitOn "/" $ a)
      <*> o .: "name"
      <*> o .: "description"
      <*> o .: "pictures"
      <*> o .: "parent_folder"

data Pictures =
  Pictures
    { pictureURI :: Maybe Text
    , pictureId :: Maybe Text
    , baseLink :: Text
    }

instance FromJSON Pictures where
  parseJSON = withObject "Pictures" $ \o -> do
    mUri <- o .: "uri"
    case Safe.lastMay . T.splitOn "/" <$> mUri of
      Just Nothing ->
        fail "Could not parse picture id"
      Just (Just a) ->
        Pictures
          <$> pure mUri
          <*> pure (Just a)
          <*> o .: "base_link"
      Nothing ->
        Pictures
          <$> pure Nothing
          <*> pure Nothing
          <*> o .: "base_link"

data Folder =
  Folder
    { folderName :: Text
    }

instance FromJSON Folder where
  parseJSON = withObject "Folder" $ \o ->
    Folder
      <$> o .: "name"

--------------------------------------------------------------------------------
-- Jekyll Types
--------------------------------------------------------------------------------

data Post =
  Post
    { postTitle :: Maybe NET.NonEmptyText
    , postDate :: Time.ZonedTime
    , postThumbPath :: Maybe Text
    , postThumbId :: Maybe Text
    , postCategories :: Set Text
    , postTags :: Set Text
    , postVideoId :: Maybe Text
    , postShorts :: [Short]
    }

instance ToJSON Post where
  toJSON p =
    object
      [ "title" .= (NET.toText <$> postTitle p)
      , "timestamp" .= postDate p
      , "thumbPath" .= postThumbPath p
      , "thumbId" .= postThumbId p
      , "categories" .= postCategories p
      , "tags" .= postTags p
      , "videoId" .= postVideoId p
      , "shorts" .= postShorts p
      ]

instance FromJSON Post where
  parseJSON = withObject "Post" $ \o ->
    Post
      <$> ((NET.fromText =<<) <$> o .: "title")
      <*> o .: "timestamp"
      <*> o .: "thumbPath"
      <*> o .: "thumbId"
      <*> o .: "categories"
      <*> o .: "tags"
      <*> o .: "videoId"
      <*> o .: "shorts"

data Short =
  Short
    { shortName :: Text
    , shortLinks :: [ShortLink]
    }

instance ToJSON Short where
  toJSON a =
    object
      [ "name" .= shortName a
      , "links" .= shortLinks a
      ]

instance FromJSON Short where
  parseJSON = withObject "Short" $ \o ->
    Short
      <$> o .: "name"
      <*> o .: "links"

data ShortLink =
  ShortLink
    { shortLinkService :: ShortService
    , shortLinkId :: Text
    }

instance ToJSON ShortLink where
  toJSON p =
    object
      [ "service" .= shortLinkService p
      , "id" .= shortLinkId p
      ]

instance FromJSON ShortLink where
  parseJSON = withObject "ShortLink" $ \o ->
    ShortLink
      <$> o .: "service"
      <*> o .: "id"

data ShortService = YouTube | Vimeo

instance ToJSON ShortService where
  toJSON a =
    case a of
      YouTube -> String "youtube"

instance FromJSON ShortService where
  parseJSON = withText "ShortService" $ \t ->
    case t of
      "youtube" -> pure YouTube
      _ -> fail "Unknown short service"

postToText :: Post -> Text
postToText p =
     "---\n"
  <> "title: \"" <> title <> "\"\n"
  <> "date: \"" <> (formatTime "%FT%T%z" $ postDate p) <> "\"\n"
  <> "header:\n"
  <> "  teaser: \"" <> (fromMaybe "/assets/images/missing.png" $ postThumbPath p) <> "\"\n"
  <> "categories:" <> (elements $ postCategories p)
  <> "tags:" <> (elements $ postTags p)
  <> "---\n"
  <> videoEmbed (postVideoId p)
  <> shortsText (postShorts p)
  where
    title =
      case postTitle p of
        -- If there is no description, I didn't save the original title of the
        -- stream if there was one. Default to the date instead.
        Nothing -> encHtml $ formatTime "%F %T%z" $ postDate p
        Just title -> encHtml $ NET.toText title
    videoEmbed mId =
      case mId of
        Nothing -> "&nbsp;\n\nUnfortunately, this VOD has been lost to the sands of time."
        Just i -> "{% include video id=\"" <> i <> "\" provider=\"vimeo\" %}\n"
    shortsText shorts =
      case shorts of
        [] -> ""
        _ -> "\nSee also:\n" <> T.intercalate "\n" (shortText <$> shorts)
    shortText short =
      "* " <> shortName short <> ": " <>
      T.intercalate ", " (shortLink <$> shortLinks short)
    shortLink link =
      case shortLinkService link of
        YouTube ->
          "[YouTube](https://www.youtube.com/watch?v=" <> shortLinkId link <> ")"

    elements arr =
      case Set.toList arr of
        [] -> " []\n"
        xs -> "\n" <> (T.concat $ element <$> xs)
    element a = "- \"" <> a <> "\"\n"

encHtml :: Text -> Text
encHtml =
  -- There's a bug in the minimal mistakes theme which treats the pipe character
  -- as table syntax for markdown only in some parts of the website.
  T.replace "|" "&#124;"

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
      <$> expectJust "Cannot parse env.json" (decodeFileStrict "env.json")
      <*> HTTP.newManager HTTP.tlsManagerSettings
  runReaderT migration context

expectJust :: MonadIO io => Text -> io (Maybe a) -> io a
expectJust message fn = do
  ma <- fn
  case ma of
    Nothing -> die message
    Just a -> pure a

getVideos :: Int -> Migration UserResult
getVideos page = do
  auth <- asks (accessToken . migrationSecrets)
  let url = https "api.vimeo.com" /: "users" /: "104901742" /: "videos"
  response <- runReq defaultHttpConfig $ req GET url NoReqBody jsonResponse $
       headerRedacted "Authorization" ("bearer " <> auth)
    <> "fields" =: ("uri,name,description,pictures.base_link,pictures.uri,parent_folder.name" :: Text)
    <> "page" =: (show page :: Text)
    <> "per_page" =: (100 :: Int)
  pure $ responseBody response

getThumbnail :: Text -> Migration LBS.ByteString
getThumbnail url = do
  manager <- asks migrationManager
  request <- HTTP.parseRequest $ T.unpack url
  let req = request { HTTP.path = HTTP.path request <> "_640x360.jpg" }
  response <- liftIO $ HTTP.httpLbs req manager
  pure $ HTTP.responseBody response

parseTime :: (Time.ParseTime t, MonadFail m) => String -> Text -> m t
parseTime fmt = Time.parseTimeM True Time.defaultTimeLocale fmt . T.unpack

formatTime :: Time.FormatTime t => String -> t -> Text
formatTime fmt = T.pack . Time.formatTime Time.defaultTimeLocale fmt

main = runMigration $ do
  page <- getVideos 1
  traverse migrate (results page)
  followPagination page
  writePosts

followPagination page =
  case nextPage $ pagingInfo page of
    Nothing -> pure ()
    Just _ -> do
      next <- getVideos (currentPage page + 1)
      traverse migrate (results next)
      followPagination next

migrate video = do
  case folderName <$> parentFolder video of
    Just n | n == "Streams" -> do
      echo $ fromString . T.unpack $
        "Migrating " <> videoId video <> " - " <> name video
      migrate' video
    _ ->
      echo $ fromString . T.unpack $
        "Skipping " <> videoId video <> " - " <> name video

migrate' video = do
  let nameParsingFail = die $ "Could not parse name \"" <> name video <> "\""
  (service, zonedTime) <-
    case T.words $ name video of
      a:b:c:d:[] ->
        case parseTime "%F %T%z" (c <> " " <> d) of
          Just zonedTime -> pure (T.toLower a, zonedTime)
          Nothing ->

            -- In this case, I had not yet started recording the time zone
            -- offset, but I know I was in Central Time.
            case parseTime "%F %T" (c <> " " <> d) of
              Nothing -> nameParsingFail
              Just localTime ->
                case TZ.localTimeToUTCFull (TZ.tzByLabel TZ.America__Chicago) localTime of
                  TZ.LTUUnique _ tz ->
                    pure (T.toLower a, Time.ZonedTime localTime tz)
                  _ ->
                    die $ "Could not determine offset for \"" <> name video <> "\""

      _ -> nameParsingFail

  -- Try to load the old data
  let fileName = formatTime "%Y-%m-%d-%H-%M-%S%z" zonedTime
      dataPath = "data/" <> fileName <> ".json"
  postExists <- testpath $ decodeString (T.unpack dataPath)
  oldPost <-
    if postExists
    then do
      t <- liftIO $ Text.readFile (T.unpack dataPath)
      case eitherDecode $ toLBS t of
        Left err -> die $ "Failed to read post; " <> T.pack err
        Right p -> pure $ Just p
    else pure Nothing

  -- Update the post
  let desc = NET.fromText =<< description video
  echo $ fromString . T.unpack $
    "  Updating " <> videoId video <> " at " <> dataPath
  let newPost =
        case oldPost of
          Just p ->
            p { postTitle = desc
              , postDate = zonedTime
              , postThumbPath = Just $ "/assets/thumbs/" <> fileName <> ".jpg"
              , postThumbId = pictureId $ pictures video
              , postCategories = Set.insert service $ postCategories p
              , postVideoId = Just $ videoId video
              }
          Nothing ->
            Post
              { postTitle = desc
              , postDate = zonedTime
              , postThumbPath = Just $ "/assets/thumbs/" <> fileName <> ".jpg"
              , postThumbId = pictureId $ pictures video
              , postCategories = Set.singleton service
              , postTags = Set.empty
              , postVideoId = Just $ videoId video
              , postShorts = []
              }
  liftIO $ Text.writeFile (T.unpack dataPath)
                          (fromLBS . encodePretty $ newPost)
  downloadThumbIfNeeded fileName video oldPost

downloadThumbIfNeeded fileName video oldPost = do
  let thumbPath = "assets/thumbs/" <> fileName <> ".jpg"
  thumbExists <- testpath $ decodeString (T.unpack thumbPath)
  case (thumbExists, pictureId $ pictures video) of

    -- Vimeo is sending us the default thumbnail and we have a thumbnail on
    -- disk. We don't delete the thumb in case the user wants to keep it.
    (True, Nothing) ->
      echo $ fromString . T.unpack $
        "  Warning: " <> videoId video <> " no longer has a thumbnail on Vimeo!"

    -- Don't download the default thumbnail from Vimeo
    (False, Nothing) -> pure ()

    (True, Just pId) ->
      case postThumbId =<< oldPost of

        -- We don't have the thumbnail yet
        Nothing -> downloadThumb video thumbPath

        -- Download the thumbnail only if it is different
        Just oldThumbId
          | oldThumbId /= pId -> downloadThumb video thumbPath
          | otherwise -> pure ()

    -- We don't have the thumbnail yet
    (False, Just pId) -> downloadThumb video thumbPath

downloadThumb video thumbPath = do
  echo $ fromString . T.unpack $
    "  Downloading thumb for " <> videoId video <> " to " <> thumbPath
  thumb <- getThumbnail (baseLink $ pictures video)
  liftIO $ LBS.writeFile (T.unpack thumbPath) thumb

writePosts =
  sh $ do
    filepath <- ls "data/"

    t <- liftIO $ readTextFile filepath
    p <- case eitherDecode $ toLBS t of
      Left err -> die $ "Failed to read post; " <> T.pack err
      Right p -> pure p

    -- Write the post down
    let fileName = formatTime "%Y-%m-%d-%H-%M-%S%z" $ postDate p
        postPath = "_posts/" <> fileName <> ".md"
    liftIO . Text.writeFile (T.unpack postPath) . postToText $ p
