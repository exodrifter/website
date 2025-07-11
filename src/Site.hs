module Site
( main
) where

import Exo.Shake ((<//>), (</>), (-<.>), (|%>), (%>))
import qualified Exo.Const as Const
import qualified Exo.Pandoc as Pandoc
import qualified Exo.Shake as Shake

import qualified Data.Text as T
import qualified Network.URI as URI
import qualified System.Directory.Extra as Directory
import qualified System.FilePath as FilePath

main :: IO ()
main = Shake.runShake $ do

  Shake.cleanPhony
  Shake.serverPhony

  Shake.action Shake.wantWebsite

  -- Copy files.
  let
    copyExtensions = [ "*.css", "*.gif", "*.mp4", "*.png", "*.jpg", "*.svg", "*.txt" ]
  (Const.outputDirectory <//>) <$> copyExtensions |%> \out -> do
    let inputPath = Const.contentDirectory </> Shake.dropDirectory1 out
    Shake.copyFileChanged inputPath out

  -- Generate website pages.
  Const.outputDirectory <//> "*.html" %> \out -> do
    let
      canonicalPath = Shake.dropDirectory1 out
      inputPath = Const.contentDirectory </> canonicalPath -<.> "md"
    md <- T.pack <$> readFile' inputPath
    pandoc <- Shake.runEither (Pandoc.parseMarkdown md)

    -- Find dependencies
    let workingDirectory = Shake.takeDirectory out
    needImageDependencies workingDirectory pandoc

    -- If this is an index, list other files in the directory.
    let
      fileName = FilePath.takeBaseName inputPath
      inputFolderPath = FilePath.takeDirectory inputPath
    indexListing <-
      if fileName == "index"
      then do
        listing <- liftIO (Directory.listFiles inputFolderPath)
        pure (filter (/= inputPath) listing)
      else pure []

    let args = Pandoc.TemplateArgs {..}
    template <- Shake.buildTemplate (Const.contentDirectory </> "template.html")
    html <- Shake.runEither (Pandoc.makeHtml args template pandoc)
    Shake.writeFileChanged out (T.unpack html)

-- Marks every locally referenced image as needed.
needImageDependencies :: FilePath -> Pandoc.Pandoc -> Shake.Action ()
needImageDependencies dir pandoc =
  let
    extractUrl :: Pandoc.Inline -> [FilePath]
    extractUrl i =
      case i of

        (Pandoc.Image _ _ (u,_)) ->
          -- Ignore URIs
          case URI.parseURI (T.unpack u) of
            Nothing -> [dir </> T.unpack u]
            Just _ -> []

        _ -> []
  in
    Shake.need (Pandoc.query extractUrl pandoc)
