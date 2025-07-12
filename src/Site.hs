module Site
( main
) where

import Exo.Shake ((<//>), (</>), (-<.>), (|%>), (%>))
import qualified Exo.Const as Const
import qualified Exo.Pandoc as Pandoc
import qualified Exo.RSS as RSS
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

  -- Parse markdown files
  getPandoc <- Shake.cachePandoc \path -> do
    Shake.need [path]
    md <- T.pack <$> readFile' path
    Shake.runEither (Pandoc.parseMarkdown md)

  -- Generate website pages.
  Const.outputDirectory <//> "*.html" %> \out -> do
    let
      canonicalPath = Shake.dropDirectory1 out
      inputPath = Const.contentDirectory </> canonicalPath -<.> "md"
    pandoc <- getPandoc inputPath

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

  -- Generate RSS feeds
  Const.outputDirectory <//> "*.xml" %> \out -> do
    let
      folderPath =
        FilePath.takeDirectory (Shake.dropDirectory1 out)

    sourceFiles <-
          filter (\p -> FilePath.takeFileName p /= "index.md")
      <$> Shake.findSourceFiles folderPath
    pandocs <- traverse (\p -> (,) p <$> getPandoc p) sourceFiles

    feed <- Shake.runEither (RSS.makeRss folderPath pandocs)
    Shake.writeFileChanged out (T.unpack feed)

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
