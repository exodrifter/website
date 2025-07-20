{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE MultiParamTypeClasses #-}

module Exo.Pandoc.Link
( PathInfo(pathFile)
, pathInfoFromInput
, pathInfoFromOutput

, pathInput
, pathInputFolder
, pathOutput
, pathCanonical
, pathCanonicalFolder
, pathLink

, canonicalizeLink
, cleanLink
) where

import System.FilePath ((</>), (-<.>))
import qualified Data.Aeson as Aeson
import qualified Data.Map.Strict as Map
import qualified Data.Text as T
import qualified Development.Shake.FilePath as FilePath
import qualified Exo.Build.Const as Const
import qualified Text.DocTemplates as DocTemplates

-- Each source file gets associated with multiple different kinds of paths:
-- the input path, output path, canonical path, and link. However, we often only
-- have either the input path or the output path. This helps simplify the code
-- that has to map between path types and reduce errors resulting from improper
-- path manipulation logic.
--
-- Internally, the PathInfo type itself stores the input path, and can return
-- any one of the four desired paths on demand.
data PathInfo =
  PathInfo
    { pathDirectory :: FilePath
    , pathFile :: FilePath
    , pathExtension :: FilePath
    }
  deriving stock (Eq, Generic, Show)

instance Aeson.FromJSON PathInfo
instance Aeson.ToJSON PathInfo

instance DocTemplates.ToContext Text PathInfo where
  toVal path =
    let
      items = Map.fromList
        [ ("input" :: Text, T.pack (pathInput path))
        , ("output", T.pack (pathOutput path))
        , ("canonical", T.pack (pathCanonical path))
        , ("canonicalFolder", T.pack (pathCanonicalFolder path))
        , ("url", pathLink path)
        ]
    in
      DocTemplates.toVal items

-- Parses path info from a path pointing to a source file in the contents
-- folder.
pathInfoFromInput :: FilePath -> PathInfo
pathInfoFromInput path =
  let
    splitParts = fmap FilePath.splitExtension . FilePath.splitFileName
  in
    case splitParts (FilePath.dropDirectory1 path) of
      (pathDirectory, (pathFile, pathExtension)) ->
        PathInfo {..}

-- Parses path info from a path pointing to a source file in the output folder.
pathInfoFromOutput :: FilePath -> PathInfo
pathInfoFromOutput path =
  let
    info = pathInfoFromInput path
  in
    info
      { pathExtension =
          case pathExtension info of
            ".html" -> ".md"
            a -> a
      }

--------------------------------------------------------------------------------
-- Accessors
--------------------------------------------------------------------------------

pathInput :: PathInfo -> FilePath
pathInput PathInfo{..} =
  FilePath.normalise
    (Const.contentDirectory </> pathDirectory </> pathFile -<.> pathExtension)

pathInputFolder :: PathInfo -> FilePath
pathInputFolder PathInfo{..} =
  FilePath.normalise (Const.contentDirectory </> pathDirectory)

pathOutput :: PathInfo -> FilePath
pathOutput PathInfo{..} =
  let
    newExtension =
      case pathExtension of
        ".md" -> ".html"
        a -> a
  in
    FilePath.normalise
      (Const.outputDirectory </> pathDirectory </> pathFile -<.> newExtension)

pathCanonical :: PathInfo -> FilePath
pathCanonical PathInfo{..} =
  FilePath.normalise $
    "/" </>
      case (pathFile, pathExtension) of
        ("index", ".md") -> FilePath.addTrailingPathSeparator pathDirectory
        (_, ".md") -> pathDirectory </> pathFile
        _ -> pathDirectory </> pathFile -<.> pathExtension

pathCanonicalFolder :: PathInfo -> FilePath
pathCanonicalFolder = FilePath.takeDirectory . pathCanonical

pathLink :: PathInfo -> Text
pathLink pathInfo = Const.baseUrl <> T.pack (pathCanonical pathInfo)

--------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------

-- Makes a relative link into a canonical one.
--
-- FilePath utilities don't let us normalise special directories, because of
-- symlinks. But, since these actually represent URLs instead of symlinks
-- and we don't have any symlinks, I think it's fine for us to normalise
-- special directories.
canonicalizeLink :: PathInfo -> FilePath -> FilePath
canonicalizeLink currentPath link =
  let
    pieces =
      FilePath.splitDirectories (pathCanonicalFolder currentPath </> link)
    processSpecial =
      foldl'
        (\acc d ->
          case d of
            ".." -> take (length acc - 1) acc
            "." -> acc
            _ -> acc <> [d]
        )
        []
  in
    FilePath.joinPath (processSpecial pieces)

-- Removes the extension from all markdown links and remaps index links to the
-- parent directory, so that they match the canonical URLs of the HTML pages
-- that will be generated.
cleanLink :: FilePath -> FilePath
cleanLink path =
  case FilePath.splitExtension <$> FilePath.splitFileName path of
    (folder, ("index", ".md")) ->
      FilePath.addTrailingPathSeparator folder
    (folder, (file, ".md")) ->
      folder </> file
    _ -> path
