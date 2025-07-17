-- Runs a server for testing purposes. It is built to emulate the routing of
-- GitHub Pages, since that is what I use to deploy my website.
module Exo.Scotty
( runServer
) where

import System.FilePath ((</>))
import qualified Data.ByteString as BS
import qualified Data.List.Extra as List
import qualified Data.Text as T
import qualified Data.Text.Encoding as TE
import qualified Data.Text.Lazy as TL
import qualified Network.Mime as Mime
import qualified Network.Wai as Wai
import qualified System.Directory as Directory
import qualified System.FilePath as FilePath
import qualified Web.Scotty as Scotty

-- Runs a server which serves files at the specified directory.
runServer :: FilePath -> IO ()
runServer dir =
  Scotty.scotty 8000 do
    Scotty.notFound do
      req <- Scotty.request
      serveFile dir (T.unpack <$> pathInfo req)

-- Does the same as Scotty's `pathInfo`, but with an empty string at the end of
-- the list if there is a trailing forward slash.
--
-- The trailing forward slash is important, because in GitHub Pages it is used
-- for disambiguation.
--
-- For example:
--   https://exodrifter.github.io/github-pages-routing/routing
--   ^ This loads /routing.html
--
--   https://exodrifter.github.io/github-pages-routing/routing/
--   ^ This loads /routing/index.html
pathInfo :: Wai.Request -> [Text]
pathInfo req =
  let
    path = Wai.pathInfo req
  in
    if "/" `BS.isSuffixOf` Wai.rawPathInfo req
    then path <> [""]
    else path

serveFile :: FilePath -> [FilePath] -> Scotty.ActionM ()
serveFile dir pieces = do
  let respond404 = Scotty.text "File not found"

  case fromMaybe ([], "") (List.unsnoc pieces) of

    -- Serve the index
    (folderPieces, file)
      | file `elem` ["", "index", "index.html"] -> do
        let folder = FilePath.joinPath (dir : folderPieces)
        indexExists <- liftIO (Directory.doesFileExist (folder </> "index.html"))
        if indexExists
        then do
          Scotty.setHeader "Content-Type" "text/html"
          Scotty.file (FilePath.combine folder "index.html")
        else do
          respond404

      | otherwise -> do
        -- Serve the file if it exists.
        let path = FilePath.joinPath (dir : pieces)
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
            respond404
