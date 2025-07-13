module Exo.Pandoc.Link
( cleanLink
) where

import System.FilePath ((</>))
import qualified System.FilePath as FilePath

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
