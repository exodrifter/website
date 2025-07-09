-- Helpers for using Shake.
module Exo.Shake
( module X

, outputDirectory
, contentDirectory
, runShake

-- Rules
, cleanPhony
, wantWebpages
) where

import Data.List ((\\))
import Development.Shake as X
import Development.Shake.FilePath as X
import Development.Shake.Util as X
import System.Directory.Extra

-- The directory where the website will be generated.
outputDirectory :: FilePath
outputDirectory = "_site"

-- The directory where the website content is stored. This does not include
-- assets used to create the website, like templates or stylesheets, since
-- this folder is just where I store all of my notes and I don't normally want
-- to edit those kinds of files when I'm taking notes.
contentDirectory :: FilePath
contentDirectory = "content"

runShake :: Rules () -> IO ()
runShake rules = do
  -- Rebuild all of the files if the build system has changed.
  sourceFiles <- listFilesRecursive "src"
  ver <- getHashedShakeVersion sourceFiles
  let
    options :: ShakeOptions
    options = shakeOptions { shakeVersion = ver }

    -- Prune stale files in the output folder.
    pruner :: [FilePath] -> IO ()
    pruner live = do
        present <- listFilesRecursive outputDirectory
        let toRemove = present \\ live
        traverse_ removeFile toRemove

  shakeArgsPrune options pruner rules

--------------------------------------------------------------------------------
-- Rules
--------------------------------------------------------------------------------

-- Deletes the output directory.
cleanPhony :: Rules ()
cleanPhony =
  phony "clean" do
    putInfo ("Deleting " <> outputDirectory)
    removeFilesAfter outputDirectory ["//*"]

-- Creates a list of needed webpages.
wantWebpages :: Rules ()
wantWebpages =
  action $ do
    -- Right now, we only generate webpages from markdown.
    sourceFiles <- getDirectoryFiles contentDirectory ["//*.md"]

    -- Ignore non-source files.
    let
      ignoreObsidianDirectory =
        filter (notElem ".obsidian" . splitDirectories)
      files = ignoreObsidianDirectory sourceFiles

    -- Mark each of the webpages as needed.
    let toOutputPath path = outputDirectory </> path -<.> "html"
    need (toOutputPath <$> files)
