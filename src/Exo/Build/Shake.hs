-- Used as the main entry point for the static site generator. While it does not
-- itself define how to build the website, it handles several things for us:
-- * Adds a command for cleaning the build folder
-- * Adds a command for running the webserver
-- * Prunes stale files
module Exo.Build.Shake
( runShake
) where

import Data.List ((\\))
import qualified Development.Shake as Shake
import qualified Development.Shake.Util as Util
import qualified Exo.Const as Const
import qualified Exo.Scotty as Scotty
import qualified System.Directory.Extra as Directory

-- Runs our static site generator. It needs two things:
--
-- * An action that marks the necessary output files as needed, so that the
--   server can request those files to be built if the server is requested.
-- * The rules that are used to actually build the website.
runShake :: Shake.Action () -> Shake.Rules () -> IO ()
runShake wantWebsite buildRules = do
  -- Rebuild all of the files if the build system has changed.
  sourceFiles <- Directory.listFilesRecursive "src"
  ver <- Shake.getHashedShakeVersion sourceFiles
  let
    options :: Shake.ShakeOptions
    options = Shake.shakeOptions { Shake.shakeVersion = ver }

    -- Prune stale files in the output folder.
    pruner :: [FilePath] -> IO ()
    pruner live = do
      -- The directory might not exist if we ran the clean action.
      directoryExists <- Directory.doesDirectoryExist Const.outputDirectory
      when directoryExists do
        present <- Directory.listFilesRecursive Const.outputDirectory
        let toRemove = present \\ live
        traverse_ Directory.removeFile toRemove

  Util.shakeArgsPrune options pruner do
    buildRules

    -- Add some default rules.
    cleanPhony
    serverPhony wantWebsite

--------------------------------------------------------------------------------
-- Rules
--------------------------------------------------------------------------------

-- Deletes the output directory.
cleanPhony :: Shake.Rules ()
cleanPhony =
  Shake.phony "clean" do
    Shake.putInfo ("Deleting " <> Const.outputDirectory)
    Shake.removeFilesAfter Const.outputDirectory ["//*"]

-- Runs a server for testing purposes.
serverPhony :: Shake.Action () -> Shake.Rules ()
serverPhony wantWebsite =
  Shake.phony "server" do
    wantWebsite
    Shake.runAfter (Scotty.runServer Const.outputDirectory)
