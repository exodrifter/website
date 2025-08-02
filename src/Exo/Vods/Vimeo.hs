module Exo.Vods.Vimeo
( UserResult(..)
, Paging(..)
, Video(..)
, Pictures(..)
, Folder(..)
) where

import Data.Aeson ((.:))
import qualified Data.Aeson as Aeson
import qualified Data.Text as T
import qualified Data.Time.TimeSpan as TimeSpan

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
