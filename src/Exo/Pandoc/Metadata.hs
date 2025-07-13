-- Loads known metadata fields from Pandoc documents.
module Exo.Pandoc.Metadata
( Metadata(..)
, metaUpdated

-- Conversions
, extractMetadata
, toVariables
) where

import System.FilePath((</>), (-<.>))
import qualified Data.Map.Strict as Map
import qualified Data.Text as T
import qualified Development.Shake.FilePath as FilePath
import qualified Exo.Const as Const
import qualified Exo.Pandoc.Link as Link
import qualified Exo.Pandoc.Meta as Meta
import qualified Exo.Pandoc.Time as Time
import qualified Text.DocTemplates as DocTemplates
import qualified Text.Pandoc as Pandoc

data Metadata =
  Metadata
    { metaInputPath :: FilePath
    -- ^ The path to the input source file.
    , metaOutputPath :: FilePath
    -- ^ The path to the output source file.
    , metaCanonicalPath :: FilePath
    -- ^ The absolute path to the document on the website.
    , metaLink :: Text
    -- ^ The URL to the document on the website.

    , metaTitle :: Text
    -- ^ The title of the document.

    , metaCreated :: Maybe (Time.UTCTime, String)
    -- ^ The time the document was created. This time can be after the publish
    -- date, in which case it indicates that I wrote and published the
    -- document's content elsewhere before I migrated it to my personal site.
    , metaPublished :: Maybe (Time.UTCTime, String)
    -- ^ The time the document was published to the internet. This type of time
    -- is only used for documents like blog posts. It can be older than the
    -- creation time of the document, if the document was migrated from a
    -- different site.
    , metaModified :: Maybe (Time.UTCTime, String)
    -- ^ The time the document was modified. This indicates the time the content
    -- of the document was last edited. This time is not updated when the
    -- metadata of the document is edited or when the document's content does
    -- not meaningfully change (such as when link urls are updated to point to
    -- the new location of moved documents).

    , metaTags :: [Text]
    -- ^ The manually curated tags that have been added to this document, which
    -- are used for categorization and search.
    }
  deriving stock (Eq, Show)

metaUpdated :: Metadata -> Maybe (Time.UTCTime, String)
metaUpdated metadata =
  metaModified metadata <|> metaPublished metadata

--------------------------------------------------------------------------------
-- Conversions
--------------------------------------------------------------------------------

extractMetadata :: FilePath -> Pandoc.Pandoc -> Either Text Metadata
extractMetadata metaInputPath (Pandoc.Pandoc (Pandoc.Meta meta) _) = do
  -- Paths
  let
    path = FilePath.dropDirectory1 metaInputPath
    metaOutputPath = Const.outputDirectory </> path -<.> "html"
    metaCanonicalPath = Link.cleanLink path
    metaLink = Const.baseUrl <> T.pack metaCanonicalPath

  -- Title
  let baseName = FilePath.takeBaseName metaInputPath
  metaTitle <- Meta.lookupMetaString "title" meta <> pure (T.pack baseName)

  -- Times
  let extractTime k = fmap Just . Time.parseTime <=< Meta.lookupMetaString k
  metaCreated <- extractTime "created" meta <> pure Nothing
  metaPublished <- extractTime "published" meta <> pure Nothing
  metaModified <- extractTime "modified" meta <> pure Nothing

  -- Tags
  metaTags <- Meta.lookupMetaStrings "tags" meta <> pure []

  pure Metadata {..}

toVariables :: Metadata -> Map Text (DocTemplates.Val Text)
toVariables metadata =
  let
    toVal = maybe DocTemplates.NullVal DocTemplates.toVal
  in
    Map.fromList
      [ ("created", toVal (Time.formatTime <$> metaCreated metadata))
      , ("published", toVal (Time.formatTime <$> metaPublished metadata))
      , ("modified", toVal (Time.formatTime <$> metaModified metadata))
      ]
