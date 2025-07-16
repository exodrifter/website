{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE MultiParamTypeClasses #-}

module Exo.Pandoc.Link
( PathInfo(pathFile)
, pathInfoFromInput
, pathInfoFromOutput

, pathInput
, pathOutput
, pathCanonical
, pathLink

, cleanLink
) where

import System.FilePath ((</>), (-<.>))
import qualified Data.Aeson as Aeson
import qualified Data.Map.Strict as Map
import qualified Data.Text as T
import qualified Development.Shake.FilePath as FilePath
import qualified Exo.Const as Const
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

pathLink :: PathInfo -> Text
pathLink pathInfo = Const.baseUrl <> T.pack (pathCanonical pathInfo)

--------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------

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
