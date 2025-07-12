-- Helpers for sorting Pandocs.
module Exo.Pandoc.Sort
( sortPandocsNewestFirst
) where

import qualified Exo.Pandoc.Meta as Meta
import qualified Text.Pandoc as Pandoc

-- It's tedious to implement a sort which can fail, so I've decided that the
-- sort never fails. For this reason, we use the filepath of each Pandoc
-- document as a fallback.
--
-- Although some files in the source directory use timestamps in their
-- filenames, we would prefer to have the timestamp in the metadata of the
-- file.
type Pandocs = [(FilePath, Pandoc.Pandoc)]

-- Sorts Pandocs from "newest" to "oldest".
sortPandocsNewestFirst :: Pandocs -> Pandocs
sortPandocsNewestFirst pandocs =
  flip sortBy pandocs \(lf, l) (rf, r) ->
      comparing (Down . rightToMaybe . Meta.getPublished) l r
    <> comparing (Down . rightToMaybe . Meta.getLastUpdated) l r
    <> compare (Down lf) (Down rf)
