-- Helpers for using Shake.
module Exo.Shake
( module X
, runShake

-- Rules
, cleanPhony
, serverPhony
, wantWebsite
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
      -- The directory might not exist if we ran the clean action
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
-- Actions
--------------------------------------------------------------------------------

-- Creates a list of needed files for the website.
wantWebsite :: Action ()
wantWebsite = do
  let
    wantedStaticFiles =
      (Const.outputDirectory </>) <$>
        [ "keybase.txt"
        ]
  wantedWebpages <- determineWebpages

  need . concat $
    [ wantedStaticFiles
    , wantedWebpages
    ]

-- Creates a list of webpages needed for the website.
determineWebpages :: Action [FilePath]
determineWebpages = do
  -- Right now, we only generate webpages from markdown.
  sourceFiles <- getDirectoryFiles Const.contentDirectory ["//*.md"]

  -- Ignore non-source files.
  let
    ignoreObsidianDirectory =
      filter (notElem ".obsidian" . splitDirectories)
    files = ignoreObsidianDirectory sourceFiles

  let toOutputPath path = Const.outputDirectory </> path -<.> "html"
  pure (toOutputPath <$> files)
