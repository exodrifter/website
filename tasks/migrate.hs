#!/usr/bin/env stack
{- stack runghc
    --resolver lts-20.4
    --package aeson
    --package attoparsec
    --package bytestring
    --package containers
    --package relude
    --package req
    --package safe
    --package text
    --package turtle
-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}

import Relude hiding (die)

import Data.Aeson hiding ((<?>))
import Data.Attoparsec.Text ((<?>))
import Network.HTTP.Req
import Safe
import Turtle
import qualified Data.Attoparsec.Text as Atto
import qualified Data.ByteString.Char8 as BS8
import qualified Data.ByteString.Lazy as LBS
import qualified Data.Char as Char
import qualified Data.List as List
import qualified Data.Map as Map
import qualified Data.Set as Set
import qualified Data.Text as T
import qualified Data.Text.Encoding as TE
import qualified Data.Text.IO as Text
import qualified Network.HTTP.Client as HTTP
import qualified Network.HTTP.Client.TLS as HTTP

toBS = TE.encodeUtf8

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
    , paging :: Paging
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
    { uri :: Text
    , videoId :: Text
    , name :: Text
    , description :: Text
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
    { baseLink :: Text
    }

instance FromJSON Pictures where
  parseJSON = withObject "Pictures" $ \o ->
    Pictures
      <$> o .: "base_link"

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
    { postTitle :: Text
    , postDate :: Text
    , postTeaserPath :: Text
    , postCategories :: Set Text
    , postTags :: Set Text
    , postVideoId :: Text
    , postContent :: Text
    }

postFromText :: Text -> Either String Post
postFromText = Atto.parseOnly p
  where
    -- Atto.skipSpace also skips newlines
    skipSpace = Atto.skipWhile (`elem` [' ', '\t'])
    skipTrailingSpace =
      Atto.skipWhile (\x -> x /= '\n' && Char.isSpace x) <* Atto.endOfLine
    takeLine = Atto.takeTill (=='\n') <* Atto.endOfLine
    element = skipSpace *> "- " *> takeLine <?> "element"
    p = do
      "---" *> skipTrailingSpace <?> "open meta"
      title <- "title:" *> takeLine <?> "title"
      date <- "date:" *> takeLine <?> "date"
      "header:" *> skipTrailingSpace <?> "header"
      teaser <- skipSpace *> "teaser:" *> takeLine <?> "teaser"
      "categories:" <?> "categories"
      categories <-
            (skipSpace *> "[]" *> pure [] <* skipTrailingSpace <?> "empty array")
        <|> (skipTrailingSpace *> Atto.many1 element <?> "element list")
        <?> "category elements"
      "tags:" <?> "tags"
      tags <-
            (skipSpace *> "[]" *> pure [] <* skipTrailingSpace <?> "empty array")
        <|> (skipTrailingSpace *> Atto.many1 element <?> "element list")
        <?> "tag elements"
      "---" *> skipTrailingSpace <?> "close meta"

      "{% include video id=" *> Atto.skipWhile (=='\"') <?> "vimeo start"
      videoId <- Atto.takeTill (`elem` ['\"', ' ']) <?> "vimeo id"
      Atto.skipWhile (=='\"') <* " provider=\"vimeo\" %}" <?> "vimeo end"
      Atto.endOfLine

      rest <- Atto.takeText <?> "rest"

      pure Post
        { postTitle = T.strip title
        , postDate = T.strip date
        , postTeaserPath = T.strip teaser
        , postCategories = Set.fromList $ T.strip <$> categories
        , postTags = Set.fromList $ T.strip <$> tags
        , postVideoId = T.strip videoId
        , postContent = rest
        }

postToText :: Post -> Text
postToText p =
     "---\n"
  <> "title: " <> postTitle p <> "\n"
  <> "date: " <> postDate p <> "\n"
  <> "header:\n"
  <> "  teaser: " <> postTeaserPath p <> "\n"
  <> "categories:" <> (elements $ postCategories p)
  <> "tags:" <> (elements $ postTags p)
  <> "---\n"
  <> "{% include video id=\"" <> postVideoId p <> "\" provider=\"vimeo\" %}\n"
  <> postContent p
  where
    elements arr =
      case Set.toList arr of
        [] -> " []\n"
        xs -> "\n" <> (T.concat $ element <$> xs)
    element a = "- " <> a <> "\n"

--------------------------------------------------------------------------------
-- Logic
--------------------------------------------------------------------------------

expectJust :: MonadIO io => Text -> io (Maybe a) -> io a
expectJust message fn = do
  ma <- fn
  case ma of
    Nothing -> die message
    Just a -> pure a

getVideos secrets = do
  let url = https "api.vimeo.com" /: "users" /: "104901742" /: "videos"
  runReq defaultHttpConfig $ req GET url NoReqBody jsonResponse $
       headerRedacted "Authorization" ("bearer " <> accessToken secrets)
    <> "fields" =: ("uri,name,description,pictures.base_link,parent_folder.name" :: Text)

getThumbnail manager url = do
  request <- HTTP.parseRequest $ T.unpack url
  let req = request { HTTP.path = HTTP.path request <> "_640x360.jpg" }
  response <- HTTP.httpLbs req manager
  pure $ HTTP.responseBody response

main = do
  manager <- HTTP.newManager HTTP.tlsManagerSettings
  secrets <- expectJust "Cannot parse env.json" $ decodeFileStrict "env.json"

  rs <- results . responseBody <$> getVideos secrets
  traverse (migrate manager) rs

  -- args <- getArgs
  -- echo $ fromString $ List.intercalate ", " args

migrate manager video =
  case folderName <$> parentFolder video of
    Just n | n == "Streams" -> do
      echo $ fromString . T.unpack $
        "Migrating " <> videoId video <> " - " <> name video
      migrate' manager video
    _ ->
      echo $ fromString . T.unpack $
        "Skipping " <> videoId video <> " - " <> name video

migrate' manager video = do
  (service, date, time) <-
    case T.words $ name video of
      a:b:c:d:[] -> pure (T.toLower a, c, d)
      _ -> die $ "Could not parse name \"" <> name video <> "\""

  -- There's a bug in the minimal mistakes theme which treats the pipe character
  -- as table syntax for markdown only in some parts of the website.
  let desc = 
        case T.replace "|" "&#124;" $ description video of
          -- If there is no description, I didn't save the original title of the
          -- stream if there was one. Default to the date instead.
          "" -> date <> " " <> time
          a -> a
      fileName = T.unpack $ T.replace ":" "-" $ date <> "-" <> time

  let thumbPath = "assets/thumbs/" <> fileName <> ".jpg"
  echo $ fromString . T.unpack $
    "  Downloading thumb for " <> videoId video <> " to " <> T.pack thumbPath
  thumb <- getThumbnail manager (baseLink $ pictures video)
  LBS.writeFile thumbPath thumb

  let postPath = "_posts/" <> fileName <> ".md"
  postExists <- testpath $ decodeString postPath
  if postExists
  then do
      echo $ fromString . T.unpack $
        "  Updating " <> videoId video <> " at " <> T.pack postPath
      t <- Text.readFile postPath
      case postFromText t of
        Left err -> die $ "Failed to read post; " <> T.pack err
        Right p -> Text.writeFile postPath . postToText $
          p { postTitle = desc
            , postDate = date <> "T" <> time
            , postTeaserPath = "/assets/thumbs/" <> T.pack fileName <> ".jpg"
            , postCategories = Set.insert service $ postCategories p
            , postVideoId = videoId video
            }
  else do
    echo $ fromString . T.unpack $
      "  Creating " <> videoId video <> " at " <> T.pack postPath
    Text.writeFile postPath . postToText $
      Post
        { postTitle = desc
        , postDate = date <> "T" <> time
        , postTeaserPath = "/assets/thumbs/" <> T.pack fileName <> ".jpg"
        , postCategories = Set.singleton service
        , postTags = Set.empty
        , postVideoId = videoId video
        , postContent = ""
        }
