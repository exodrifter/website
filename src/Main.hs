module Main
( main
) where

import Exo.Build ((<//>), (</>), (-<.>), (|%>), (%>))
import qualified Exo.Build as Build
import qualified Exo.Pandoc as Pandoc
import qualified Exo.RSS as RSS

import qualified Codec.Picture as Picture
import qualified Data.Binary as Binary
import qualified Data.Map.Strict as Map
import qualified Data.Text as T
import qualified Network.URI as URI
import qualified System.FilePath as FilePath

newtype TagMapOracle = TagMapOracle ()
  deriving newtype (Binary.Binary, Eq, Hashable, NFData, Show)
newtype BacklinksOracle = BacklinksOracle ()
  deriving newtype (Binary.Binary, Eq, Hashable, NFData, Show)

main :: IO ()
main = Build.runShake Build.wantWebsite $ do
  Build.oracleRules

  -- By default, if no commands are given, build the website.
  Build.action Build.wantWebsite

  -- Copy static files.
  let
    copyExtensions =
      [ "*.css"
      , "*.gif"
      , "*.jpg"
      , "*.mp4"
      , "*.png"
      , "*.svg"
      , "*.ttf"
      , "*.txt"
      ]
  (Build.outputDirectory <//>) <$> copyExtensions |%> \out -> do
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

    -- Helper function for iterating one-by-one over the metadata for a list of
    -- file paths.
    forFiles :: (a -> Pandoc.Metadata -> a)
             -> a
             -> [FilePath]
             -> Build.Action a
    forFiles fn =
      foldlM \a path -> fn a <$> Build.getMetadata path

  -- Create a map of tags to files.
  getTagMap <- (. TagMapOracle) <$> Build.cacheJSON \(TagMapOracle ()) -> do
    Build.putInfo "Creating tag map..."
    let
      metaToTagMap :: Pandoc.Metadata -> Map Text [FilePath]
      metaToTagMap meta =
        fromList
          [ (tag, [Pandoc.metaInputPath meta])
          | tag <- Pandoc.metaTags meta
          ]

      fn :: Map Text [FilePath] -> Pandoc.Metadata -> Map Text [FilePath]
      fn acc meta = Map.unionWith (<>) acc (metaToTagMap meta)

    sourceFiles <- Build.findSourceFiles "."
    forFiles fn Map.empty sourceFiles

  -- Create a map of backlinks, which is a list of files that link to a file.
  getBacklinks <- (. BacklinksOracle) <$> Build.cacheJSON \(BacklinksOracle ()) -> do
    Build.putInfo "Creating backlinks..."
    let
      metaToBacklinkMap :: Pandoc.Metadata -> Map FilePath [FilePath]
      metaToBacklinkMap meta =
        fromList
          [ (link, [Pandoc.metaInputPath meta])
          | link <- toList (Pandoc.metaOutgoingLinks meta)
          ]

      fn :: Map FilePath [FilePath] -> Pandoc.Metadata -> Map FilePath [FilePath]
      fn acc meta = Map.unionWith (<>) acc (metaToBacklinkMap meta)

    sourceFiles <- Build.findSourceFiles "."
    forFiles fn Map.empty sourceFiles

  -- Generate website pages.
  Build.outputDirectory <//> "*.html" %> \out -> do
    let inputPath = Pandoc.pathInput (Pandoc.pathInfoFromOutput out)
    pandoc <- Build.getPandoc inputPath
    metadata <- Build.getMetadata inputPath
    commitHash <- Build.getCommitHash inputPath

    let logoPath = Build.contentDirectory </> "logo.svg"
    Build.need [logoPath]
    logoSource <- Build.decodeByteString =<< readFileBS logoPath

    -- Find image dependencies.
    let workingDirectory = Build.takeDirectory out
    referencedImages <- needImageDependencies workingDirectory pandoc

    -- Find tagged page dependencies.
    let
      tagPath p = Build.outputDirectory </> "tags" </> T.unpack p -<.> ".html"
      tagPaths = tagPath <$> Pandoc.metaTags metadata
    Build.need (filter (Pandoc.metaOutputPath metadata /=) tagPaths)

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
          Just a -> sortBy listingSort <$> traverse Build.getMetadata a
      else pure []

    -- Find all of the backlinks.
    allBacklinks <- getBacklinks ()
    let
      canonicalPath = Pandoc.metaCanonicalPath metadata
      backlinkPaths = fromMaybe [] (Map.lookup canonicalPath allBacklinks)
    backlinks <-
          sortBy (comparing Pandoc.metaTitle)
      <$> traverse Build.getMetadata backlinkPaths

    -- Generate RSS
    let
      metaPath = Pandoc.metaPath metadata
    rssPath <-
      case (Pandoc.pathDirectory metaPath, Pandoc.pathFile metaPath) of
        (dir, "index") -> do
          Build.need [ Build.outputDirectory </> dir </> "index.xml" ]
          pure (Just ("/" </> dir </> "index.xml"))
        _ ->
          pure Nothing

    let args = Pandoc.TemplateArgs {..}
    template <- Build.buildTemplate (Build.contentDirectory </> "template.html")
    html <- Build.runEither (Pandoc.makeHtml args template pandoc)
    Build.writeFileChanged out (T.unpack html)

  -- Generate RSS feeds
  Build.outputDirectory <//> "*.xml" %> \out -> do
    let
      inputPath = Pandoc.pathInput (Pandoc.pathInfoFromOutput out)
      canonicalPath = Build.dropDirectory1 out
      canonicalFolder = FilePath.takeDirectory canonicalPath

    metas <- listFiles canonicalFolder (/= inputPath) listingSort
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
     comparing (Down . Pandoc.metaPublished)
  <> comparing (Down . Pandoc.metaUpdated)
