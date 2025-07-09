-- Helpers for using Shake.
module Exo.Shake
( module X
, runShake

-- Rules
, cleanPhony
, serverPhony
, wantWebpages
) where

import Data.List ((\\))
import Development.Shake as X
import Development.Shake.FilePath as X
import Development.Shake.Util as X
import qualified Exo.Const as Const
import qualified Exo.Scotty as Scotty
import qualified System.Directory.Extra as Directory

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
        present <- Directory.listFilesRecursive Const.outputDirectory
        let toRemove = present \\ live
        traverse_ Directory.removeFile toRemove

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
    wantWebpages
    liftIO Scotty.runServer

--------------------------------------------------------------------------------
-- Actions
--------------------------------------------------------------------------------

-- Creates a list of needed webpages.
wantWebpages :: Action ()
wantWebpages = do
  -- Right now, we only generate webpages from markdown.
  sourceFiles <- getDirectoryFiles Const.contentDirectory ["//*.md"]

  -- Ignore non-source files.
  let
    ignoreObsidianDirectory =
      filter (notElem ".obsidian" . splitDirectories)
    files = ignoreObsidianDirectory sourceFiles

  -- Mark each of the webpages as needed.
  let toOutputPath path = Const.outputDirectory </> path -<.> "html"
  need (toOutputPath <$> files)
