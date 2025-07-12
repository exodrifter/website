module Site
( main
) where

import Exo.Shake ((<//>), (</>), (-<.>), (|%>), (%>))
import qualified Exo.Const as Const
import qualified Exo.Pandoc as Pandoc
import qualified Exo.RSS as RSS
import qualified Exo.Shake as Shake

import qualified Data.Map.Strict as Map
import qualified Data.Text as T
import qualified Network.URI as URI
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
    Shake.need [inputPath]
    Shake.copyFileChanged inputPath out

  -- Parse markdown files
  getPandoc <- Shake.cachePandoc \path -> do
    Shake.need [path]
    md <- T.pack <$> readFile' path
    Shake.runEither (Pandoc.parseMarkdown md)

  -- Cache parsed metadata
  getTagMap <- Shake.cacheJSON \() -> do
    sourceFiles <- Shake.findSourceFiles "."
    let
      fetchPandocs path = do
        pandoc <- getPandoc path
        pure (path, pandoc)
    pandocs <-
      Pandoc.sortPandocsNewestFirst
        <$> traverse fetchPandocs sourceFiles

    let
      fetchData (path, pandoc) = do
        tags <- Shake.runEither (Pandoc.getTags pandoc)
        pure (path, pandoc, tags)
    taggedPandocs <- traverse fetchData pandocs

    let
      fn acc (path, pandoc, tags) =
        let thisMap = Map.fromList [(tag, [(path, pandoc)]) | tag <- tags]
        in  Map.unionWithKey (const (<>)) acc thisMap
    pure (foldl' fn Map.empty taggedPandocs)

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
        let
          isImmediate =
            filter (\p -> FilePath.takeDirectory p == inputFolderPath)
        sourceFiles <- isImmediate <$> Shake.findSourceFiles inputFolderPath
        pandocs <- traverse (\p -> (,) p <$> getPandoc p) sourceFiles
        pure (Pandoc.sortPandocsNewestFirst pandocs)
      else pure []

    -- If this is a tag, list other files with this tag.
    taggedListing <-
      if inputFolderPath == "content/tags" && fileName /= "index"
      then do
        tagMap <- getTagMap ()
        pure (fromMaybe [] (Map.lookup (T.pack fileName) tagMap))
      else pure []

    let args = Pandoc.TemplateArgs {..}
    template <- Shake.buildTemplate (Const.contentDirectory </> "template.html")
    html <- Shake.runEither (Pandoc.makeHtml args template pandoc)
    Shake.writeFileChanged out (T.unpack html)

  -- Generate RSS feeds
  Const.outputDirectory <//> "*.xml" %> \out -> do
    let
      canonicalPath = Shake.dropDirectory1 out
      canonicalFolder = FilePath.takeDirectory canonicalPath
      inputPath = Const.contentDirectory </> canonicalFolder

    sourceFiles <-
          filter (\p -> FilePath.takeFileName p /= "index.md")
      <$> Shake.findSourceFiles inputPath
    pandocs <- traverse (\p -> (,) p <$> getPandoc p) sourceFiles

    feed <- Shake.runEither (RSS.makeRss canonicalFolder pandocs)
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
