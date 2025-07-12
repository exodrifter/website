{-# LANGUAGE TypeFamilies #-}

-- Helpers for using Shake.
module Exo.Shake
( module X
, runShake

-- Rules
, cleanPhony
, serverPhony

-- Oracles
, cacheOracle
, cachePandoc

-- Actions
, wantWebsite
, findSourceFiles
, buildTemplate
, runEither
) where

import Data.List ((\\))
import Development.Shake as X
import Development.Shake.FilePath as X
import Development.Shake.Util as X
import qualified Data.Aeson as Aeson
import qualified Data.Binary as Binary
import qualified Data.ByteString.Lazy as BSL
import qualified Data.Text as T
import qualified Exo.Const as Const
import qualified Exo.Scotty as Scotty
import qualified System.Directory.Extra as Directory
import qualified Text.DocTemplates as DocTemplates
import qualified Text.Pandoc as Pandoc

runShake :: Rules () -> IO ()
runShake rules = do
  -- Rebuild all of the files if the build system has changed.
  sourceFiles <- Directory.listFilesRecursive "src"
  ver <- getHashedShakeVersion sourceFiles
  let
    options :: ShakeOptions
    options = shakeOptions { shakeVersion = ver }

    -- Prune stale files in the output folder.
    pruner :: [FilePath] -> IO ()
    pruner live = do
      -- The directory might not exist if we ran the clean action.
      directoryExists <- Directory.doesDirectoryExist Const.outputDirectory
      if directoryExists
      then do
        present <- Directory.listFilesRecursive Const.outputDirectory
        let toRemove = present \\ live
        traverse_ Directory.removeFile toRemove
      else pure ()

  shakeArgsPrune options pruner rules

--------------------------------------------------------------------------------
-- Rules
--------------------------------------------------------------------------------

-- Deletes the output directory.
cleanPhony :: Rules ()
cleanPhony =
  phony "clean" do
    putInfo ("Deleting " <> Const.outputDirectory)
    removeFilesAfter Const.outputDirectory ["//*"]

-- Runs a server for testing purposes.
serverPhony :: Rules ()
serverPhony =
  phony "server" do
    wantWebsite
    liftIO Scotty.runServer

--------------------------------------------------------------------------------
-- Oracles
--------------------------------------------------------------------------------

-- Generic caching
newtype Cache q = Cache q
  deriving newtype (Binary.Binary, Eq, Hashable, NFData, Show)

type instance RuleResult (Cache q) = ByteString

cacheOracle :: (Binary.Binary q, Hashable q, NFData q, Show q, Typeable q)
            => (q -> Action ByteString)
            -> (ByteString -> Action a)
            -> Rules (q -> Action a)
cacheOracle encode decode =
  decodeCache decode <$> (addOracleCache \(Cache q) -> encode q)

decodeCache :: (ByteString -> Action a)
            -> (Cache q -> Action ByteString)
            -> (q -> Action a)
decodeCache decode runCache = \filepath -> do
  bs <- runCache (Cache filepath)
  decode bs

-- We can cache parsed Pandoc documents by serializing them to JSON.
cachePandoc :: (FilePath -> Action Pandoc.Pandoc)
            -> Rules (FilePath -> Action Pandoc.Pandoc)
cachePandoc parse =
  cacheOracle
    ( \path -> do
        pandoc <- parse path
        pure (BSL.toStrict (Aeson.encode pandoc))
    )
    ( \bs ->
        case Aeson.eitherDecode (BSL.fromStrict bs) of
          Left err -> fail err
          Right res -> pure res
    )

--------------------------------------------------------------------------------
-- Actions
--------------------------------------------------------------------------------

-- Creates a list of files needed for the website.
wantWebsite :: Action ()
wantWebsite = do
  -- Generate webpages from markdown.
  sourceFiles <- findSourceFiles "."
  let
    toOutputPath path =
      Const.outputDirectory </> X.dropDirectory1 path -<.> "html"
    webpages = toOutputPath <$> sourceFiles

    -- Feeds to generate.
    feedFiles =
      (Const.outputDirectory </>) <$>
        [ "index.xml"
        , "blog/index.xml"
        , "entries/index.xml"
        , "notes/index.xml"
        ]

    -- Static files to copy.
    staticFiles =
      (Const.outputDirectory </>) <$>
        [ "keybase.txt"
        , "logo.svg"
        , "style.css"
        ]

  need . concat $
    [ webpages
    , feedFiles
    , staticFiles
    ]

-- Finds all files that will become webpages in the content directory.
findSourceFiles :: FilePath -> Action [FilePath]
findSourceFiles dir = do
  sourceFiles <- getDirectoryFiles (Const.contentDirectory </> dir) ["//*.md"]
  let
    rebuildPath path = Const.contentDirectory </> dir </> path
    ignoreObsidianDirectory =
      filter (notElem ".obsidian" . splitDirectories)
  pure (rebuildPath <$> ignoreObsidianDirectory sourceFiles)

-- Builds a template on disk.
buildTemplate :: DocTemplates.TemplateTarget a
              => FilePath -> Action (Pandoc.Template a)
buildTemplate path = do
  fileExists <- liftIO (Directory.doesFileExist path)
  if fileExists
  then do
    -- Since the file already exists on disk, this won't actually trigger
    -- another rule since the file appears to be built already. Instead, all
    -- this does is make sure the rule is re-run when the file is changed.
    need [path]
    result <- liftIO (DocTemplates.compileTemplateFile path)

    case result of
      Left err -> error (T.pack err)
      Right template -> pure template

  else
    error ("Cannot find template at path \"" <> T.pack path <> "\"")

-- Fails the action if the Either is a Left.
runEither :: Either Text a -> Action a
runEither e =
  case e of
    Right a -> pure a
    Left err -> error err
