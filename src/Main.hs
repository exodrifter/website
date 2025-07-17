module Main
( main
) where

import Exo.Build ((<//>), (</>), (-<.>), (|%>), (%>))
import qualified Exo.Build as Build
import qualified Exo.Const as Const
import qualified Exo.Pandoc as Pandoc
import qualified Exo.RSS as RSS

import qualified Codec.Picture as Picture
import qualified Data.Map.Strict as Map
import qualified Data.Text as T
import qualified Network.URI as URI
import qualified System.FilePath as FilePath

main :: IO ()
main = Build.runShake Build.wantWebsite $ do
  Build.oracleRules

  -- By default, if no commands are given, build the website.
  Build.action Build.wantWebsite

  -- Copy static files.
  let
    copyExtensions = [ "*.css", "*.gif", "*.mp4", "*.png", "*.jpg", "*.svg", "*.txt" ]
  (Const.outputDirectory <//>) <$> copyExtensions |%> \out -> do
    let inputPath = Pandoc.pathInput (Pandoc.pathInfoFromOutput out)
    Build.need [inputPath]
    Build.copyFileChanged inputPath out

  -- Helper function for listing and sorting files based on their metadata
  let
    listFiles :: FilePath
              -> (FilePath -> Bool)
              -> (Pandoc.Metadata -> Pandoc.Metadata -> Ordering)
              -> Build.Action [Pandoc.Metadata]
    listFiles dir filterFn sortFn = do
      sourceFiles <- filter filterFn <$> Build.findSourceFiles dir
      metas <- traverse Build.getMetadata sourceFiles
      pure (sortBy sortFn metas)

  -- Create a map of tags to files.
  getTagMap <- Build.cacheJSON \() -> do
    metas <- listFiles "." (const True) listingSort
    let
      metaToMap meta =
        Map.fromList [(tag, [meta]) | tag <- Pandoc.metaTags meta]
    pure (Map.unionsWith (<>) (metaToMap <$> metas))

  -- Generate website pages.
  Const.outputDirectory <//> "*.html" %> \out -> do
    let inputPath = Pandoc.pathInput (Pandoc.pathInfoFromOutput out)
    pandoc <- Build.getPandoc inputPath
    metadata <- Build.getMetadata inputPath
    commitHash <- Build.getCommitHash inputPath

    let logoPath = Const.contentDirectory </> "logo.svg"
    Build.need [logoPath]
    logoSource <- Build.decodeByteString =<< readFileBS logoPath

    -- Find dependencies
    let workingDirectory = Build.takeDirectory out
    referencedImages <- needImageDependencies workingDirectory pandoc

    -- If this is an index, list other files in the directory.
    let
      fileName = FilePath.takeBaseName inputPath
      inputFolderPath = FilePath.takeDirectory inputPath
    indexListing <-
      if fileName == "index"
      then do
        let
          -- Include either files immediately under this folder or index files
          -- for folders immediately under this folder.
          isImmediate p =
            if FilePath.takeBaseName p == "index"
            then FilePath.takeDirectory (FilePath.takeDirectory p) == inputFolderPath
            else FilePath.takeDirectory p == inputFolderPath
        listFiles "." isImmediate listingSort
      else pure []

    -- If this is a tag, list other files with this tag.
    taggedListing <-
      if inputFolderPath == "content/tags"
      then do
        let tag = T.pack fileName
        tagMap <- getTagMap ()
        case Map.lookup tag tagMap of
          Nothing -> error ("Tag " <> tag <> " has no tagged pages!")
          Just a -> pure a
      else pure []

    -- Make sure the tag pages exist for the tags used.
    let
      tagPath p = Const.outputDirectory </> "tags" </> T.unpack p -<.> ".html"
      tagPaths = tagPath <$> Pandoc.metaTags metadata
    Build.need (filter (Pandoc.metaOutputPath metadata /=) tagPaths)

    let args = Pandoc.TemplateArgs {..}
    template <- Build.buildTemplate (Const.contentDirectory </> "template.html")
    html <- Build.runEither (Pandoc.makeHtml args template pandoc)
    Build.writeFileChanged out (T.unpack html)

  -- Generate RSS feeds
  Const.outputDirectory <//> "*.xml" %> \out -> do
    let
      canonicalPath = Build.dropDirectory1 out
      canonicalFolder = FilePath.takeDirectory canonicalPath

    metas <- listFiles
      canonicalFolder
      (\p -> FilePath.takeFileName p /= "index.md")
      listingSort

    feed <- Build.runEither (RSS.makeRss canonicalFolder metas)
    Build.writeFileChanged out (T.unpack feed)

-- Marks every locally referenced image as needed.
needImageDependencies :: FilePath
                      -> Pandoc.Pandoc
                      -> Build.Action (Map Text Picture.DynamicImage)
needImageDependencies dir pandoc = do
  -- Mark the images as needed.
  let
    extractUrl :: Pandoc.Inline -> [FilePath]
    extractUrl i =
      case i of

        (Pandoc.Image _ _ (u,_)) ->
          -- Ignore URIs
          case URI.parseURI (T.unpack u) of
            Nothing -> [T.unpack u]
            Just _ -> []

        _ -> []

    urls = Pandoc.query extractUrl pandoc
  Build.need ((dir </>) <$> urls)

  -- Try to load the images, so we can reference them when generating the HTML.
  let
    maybeGetImage url = do
      case FilePath.takeExtension url of
        ".gif" -> Just <$> getImage url
        ".jpg" -> Just <$> getImage url
        ".png" -> Just <$> getImage url
        _ -> pure Nothing
    getImage url = do
      result <- liftIO (Picture.readImage (dir </> url))
      case result of
        Left err -> error (T.pack err)
        Right i -> pure (T.pack url, i)
  Map.fromList . catMaybes <$> traverse maybeGetImage urls

listingSort :: Pandoc.Metadata -> Pandoc.Metadata -> Ordering
listingSort =
     comparing (Down . fmap fst . Pandoc.metaPublished)
  <> comparing (Down . fmap fst . Pandoc.metaUpdated)
  <> comparing (Down . Pandoc.metaCreated)
