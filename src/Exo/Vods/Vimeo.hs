module Exo.Vods.Vimeo
( Video(..)
, Pictures(..)
, Folder(..)

, Vimeo
, VimeoContext
, loadVimeoContext
, runVimeo
, getVideos
, getThumbnail
) where

import Control.Monad.Catch (MonadThrow)
import Data.Aeson ((.:))
import Network.HTTP.Req ((/:), (=:))
import qualified Data.Aeson as Aeson
import qualified Data.ByteString.Lazy as LBS
import qualified Data.Text as T
import qualified Data.Text.Encoding as TE
import qualified Data.Time.TimeSpan as TimeSpan
import qualified Network.HTTP.Client as HTTP
import qualified Network.HTTP.Client.TLS as HTTP
import qualified Network.HTTP.Req as Req

--------------------------------------------------------------------------------
-- Types
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
                (viaNonEmpty last . T.splitOn "/" $ uri)
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
-- Monad
--------------------------------------------------------------------------------

data Secrets =
  Secrets
    { accessToken :: ByteString
    }

instance Aeson.FromJSON Secrets where
  parseJSON = Aeson.withObject "Secrets" $ \a ->
    Secrets
      <$> (TE.encodeUtf8 <$> a .: "access_token")

newtype Vimeo a = Vimeo (ReaderT VimeoContext IO a)
  deriving
    ( Applicative
    , Functor
    , Monad
    , MonadIO
    , MonadReader VimeoContext
    , MonadThrow
    )

data VimeoContext =
  VimeoContext
    { migrationSecrets :: Secrets
    , migrationManager :: HTTP.Manager
    }

loadVimeoContext :: IO VimeoContext
loadVimeoContext = do
  let
    expectJust message fn = do
      ma <- fn
      case ma of
          Nothing -> die $ T.unpack message
          Just a -> pure a

  VimeoContext
    <$> expectJust "Cannot parse .env.json" (Aeson.decodeFileStrict ".env.json")
    <*> HTTP.newManager HTTP.tlsManagerSettings

runVimeo :: VimeoContext -> Vimeo a -> IO a
runVimeo context (Vimeo migration) = runReaderT migration context

--------------------------------------------------------------------------------
-- Video API
--------------------------------------------------------------------------------

getVideos :: Vimeo [Video]
getVideos = do
  let
    go pageNumber = do
      page <- getVideoPage pageNumber
      case nextPage (pagingInfo page) of
        Nothing ->
          pure (results page)
        Just _ -> do
          rest <- go (currentPage page + 1)
          pure (results page <> rest)
  go 1

getVideoPage :: Int -> Vimeo UserResult
getVideoPage page = do
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

getThumbnail :: Video -> Vimeo LBS.ByteString
getThumbnail video = do
  let
    url = T.unpack (baseLink (pictures video))
    withThumbUrl r = r { HTTP.path = HTTP.path r <> "_640x360.jpg" }
  request <- withThumbUrl <$> HTTP.parseRequest url

  manager <- asks migrationManager
  response <- liftIO (HTTP.httpLbs request manager)
  pure (HTTP.responseBody response)
