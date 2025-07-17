module Main
( main
) where

import Exo.Shake ((<//>), (</>), (-<.>), (|%>), (%>))
import qualified Exo.Const as Const
import qualified Exo.Pandoc as Pandoc
import qualified Exo.RSS as RSS
import qualified Exo.Shake as Shake

import qualified Codec.Picture as Picture
import qualified Data.Binary as Binary
import qualified Data.Map.Strict as Map
import qualified Data.Text as T
import qualified Network.URI as URI
import qualified System.FilePath as FilePath

-- If we use the same input type for multiple oracles, Shake will think that
-- the oracles are recursive.
newtype CommitHashOracle = CommitHashOracle ()
  deriving newtype (Binary.Binary, Eq, Hashable, NFData, Show)
newtype PandocOracle = PandocOracle FilePath
  deriving newtype (Binary.Binary, Eq, Hashable, NFData, Show)
newtype MetaOracle = MetaOracle FilePath
  deriving newtype (Binary.Binary, Eq, Hashable, NFData, Show)

main :: IO ()
main = Shake.runShake $ do

  Shake.cleanPhony
  Shake.serverPhony

  Shake.action Shake.wantWebsite

  -- Parse markdown files.
  getCommitHash <- (. CommitHashOracle) <$> Shake.cacheJSON \(CommitHashOracle ()) -> do
    Shake.Stdout result <- Shake.cmd
      ( "git describe" :: String )
      [ "--always" :: String
      , "--dirty"
      ]
    pure (T.pack result)

  -- Copy static files.
  let
    copyExtensions = [ "*.css", "*.gif", "*.mp4", "*.png", "*.jpg", "*.svg", "*.txt" ]
  (Const.outputDirectory <//>) <$> copyExtensions |%> \out -> do
    let inputPath = Pandoc.pathInput (Pandoc.pathInfoFromOutput out)
    Shake.need [inputPath]
    Shake.copyFileChanged inputPath out

  -- Parse markdown files.
  getPandoc <- (. PandocOracle) <$> Shake.cacheJSON \(PandocOracle path) -> do
    Shake.need [path]
    md <- Shake.decodeByteString =<< readFileBS path
    Shake.runEither (Pandoc.parseMarkdown md)

  -- Parse metadata.
  getMetadata <- (. MetaOracle) <$> Shake.cacheJSON \(MetaOracle path) -> do
    pandoc <- getPandoc path
    Shake.runEither (Pandoc.parseMetadata path pandoc)

  -- Helper function for listing and sorting files based on their metadata
  let
    listFiles :: FilePath
              -> (FilePath -> Bool)
              -> (Pandoc.Metadata -> Pandoc.Metadata -> Ordering)
              -> Shake.Action [Pandoc.Metadata]
    listFiles dir filterFn sortFn = do
      sourceFiles <- filter filterFn <$> Shake.findSourceFiles dir
      metas <- traverse getMetadata sourceFiles
      pure (sortBy sortFn metas)

  -- Create a map of tags to files.
  getTagMap <- Shake.cacheJSON \() -> do
    metas <- listFiles "." (const True) listingSort
    let
      metaToMap meta =
        Map.fromList [(tag, [meta]) | tag <- Pandoc.metaTags meta]
    pure (Map.unionsWith (<>) (metaToMap <$> metas))

  -- Generate website pages.
  Const.outputDirectory <//> "*.html" %> \out -> do
    let inputPath = Pandoc.pathInput (Pandoc.pathInfoFromOutput out)
    pandoc <- getPandoc inputPath
    metadata <- getMetadata inputPath
    commitHash <- getCommitHash ()

    let logoPath = Const.contentDirectory </> "logo.svg"
    Shake.need [logoPath]
    logoSource <- Shake.decodeByteString =<< readFileBS logoPath

    -- Find dependencies
    let workingDirectory = Shake.takeDirectory out
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
    Shake.need (filter (Pandoc.metaOutputPath metadata /=) tagPaths)

    let args = Pandoc.TemplateArgs {..}
    template <- Shake.buildTemplate (Const.contentDirectory </> "template.html")
    html <- Shake.runEither (Pandoc.makeHtml args template pandoc)
    Shake.writeFileChanged out (T.unpack html)

  -- Generate RSS feeds
  Const.outputDirectory <//> "*.xml" %> \out -> do
    let
      canonicalPath = Shake.dropDirectory1 out
      canonicalFolder = FilePath.takeDirectory canonicalPath

    metas <- listFiles
      canonicalFolder
      (\p -> FilePath.takeFileName p /= "index.md")
      listingSort

    feed <- Shake.runEither (RSS.makeRss canonicalFolder metas)
    Shake.writeFileChanged out (T.unpack feed)

-- Marks every locally referenced image as needed.
needImageDependencies :: FilePath
                      -> Pandoc.Pandoc
                      -> Shake.Action (Map Text Picture.DynamicImage)
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
  Shake.need ((dir </>) <$> urls)

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
