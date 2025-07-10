-- Runs a server for testing purposes.
module Exo.Scotty
( runServer
) where

import System.FilePath ((</>))
import qualified Data.List.Extra as List
import qualified Data.Text as T
import qualified Data.Text.Encoding as TE
import qualified Data.Text.Lazy as TL
import qualified Exo.Const as Const
import qualified Network.Mime as Mime
import qualified Network.Wai as Wai
import qualified System.Directory as Directory
import qualified System.FilePath as FilePath
import qualified Web.Scotty as Scotty

-- The server tries to serve files using clean URLs, similar to what GitHub
-- pages would do, for HTML pages.
runServer :: IO ()
runServer = Scotty.scotty 8000 $ Scotty.notFound do

  pieces <- fmap T.unpack . Wai.pathInfo <$> Scotty.request

  -- Redirect to the clean URL, if applicable.
  let
    redirect filepath =
      Scotty.redirect ("/" <> TL.pack filepath)
  case List.unsnoc pieces of
    Just (path, file)

      | FilePath.takeExtension file == ".html" -> do
          redirect (FilePath.replaceExtension (FilePath.joinPath pieces) "")

      | file == "index.html" ->
          redirect (FilePath.joinPath path)

      | otherwise ->
          serveFile pieces

    Nothing ->
      serveFile pieces

serveFile :: [FilePath] -> Scotty.ActionM ()
serveFile pieces = do
  -- Serve the index if the file is a directory and the index exists.
  let
    path = FilePath.joinPath (Const.outputDirectory : pieces)
  directoryExists <- liftIO (Directory.doesDirectoryExist path)
  indexExists <- liftIO (Directory.doesFileExist (path </> "index.html"))
  if directoryExists && indexExists
  then do
    Scotty.setHeader "Content-Type" "text/html"
    Scotty.file (FilePath.combine path "index.html")
  else do

    -- Serve the file if it exists.
    fileExists <- liftIO (Directory.doesFileExist path)
    if fileExists
    then do
      let
        fileName = T.pack (FilePath.takeFileName path)
        mimeType = TE.decodeUtf8 (Mime.defaultMimeLookup fileName)
      Scotty.setHeader "Content-Type" (TL.fromStrict mimeType)
      Scotty.file path
    else do

      -- If there's no extension, assume we're looking for an HTML file.
      if not (FilePath.hasExtension path)
      then do
        let htmlPath = FilePath.replaceExtension path "html"
        Scotty.setHeader "Content-Type" "text/html"
        Scotty.file htmlPath
      else do

        Scotty.text "File not found"
