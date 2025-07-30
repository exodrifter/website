-- The build module is where the "glue" code is, and has all of the functions
-- for building the website with Shake. You can think of this module as the
-- static site generator.
module Exo.Build
( module X

-- Actions
, wantWebsite
, findSourceFiles
, buildTemplate
) where

import Development.Shake as X
import Development.Shake.FilePath as X
import Development.Shake.Util as X
import Exo.Build.Action as X
import Exo.Build.Const as X
import Exo.Build.Oracle as X
import Exo.Build.Shake as X
import qualified Data.Text as T
import qualified System.FilePath as FilePath
import qualified System.Directory.Extra as Directory
import qualified Text.DocTemplates as DocTemplates
import qualified Text.Pandoc as Pandoc

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
      outputDirectory </> X.dropDirectory1 path -<.> "html"
    webpages = toOutputPath <$> sourceFiles

    -- Feeds to generate.
    feedFiles =
      (outputDirectory </>) <$>
        [ "index.xml"
        , "blog/index.xml"
        , "entries/index.xml"
        , "notes/index.xml"
        ]

    -- Static files to copy.
    staticFiles =
      (outputDirectory </>) <$>
        [ "baskiv.ttf"
        , "favicon.png"
        , "keybase.txt"
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
  sourceFiles <- getDirectoryFiles (contentDirectory </> dir) ["//*.md"]

  let
    rebuildPath path =
      FilePath.normalise (contentDirectory </> dir </> path)
      -- ^ We need to normalize the path because you can pass "." as the `dir`.
    ignoreObsidianFiles = filter (notElem ".obsidian" . splitDirectories)
  pure (rebuildPath <$> ignoreObsidianFiles sourceFiles)

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
