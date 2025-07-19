-- Pure, bespoke functions for building the website with Pandoc.
module Exo.Pandoc
( module X
, TemplateArgs(..)
, parseMarkdown
, makeHtml
) where

import System.FilePath((</>))
import Exo.Pandoc.Link as X
import Exo.Pandoc.Meta as X
import Exo.Pandoc.Time as X
import Text.Pandoc as X
import Text.Pandoc.Walk as X
import qualified Codec.Picture as Picture
import qualified Data.Map as Map
import qualified Data.Text as T
import qualified Development.Shake.FilePath as FilePath
import qualified Network.URI as URI
import qualified Text.DocTemplates as DocTemplates

--------------------------------------------------------------------------------
-- Markdown
--------------------------------------------------------------------------------

-- Parses a markdown document just the way I want it.
--
-- In general, this function will tend towards maintaining compatability with
-- Obsidian, since that's the note-taking application I personally use.
parseMarkdown :: Text -> Either Text Pandoc
parseMarkdown markdown = do
  let
    readerOptions = def
      { readerExtensions =
            enableExtension Ext_lists_without_preceding_blankline
            -- ^ I have a lot of lists that don't have a preceding blankline,
            -- because Obsidian allows that.
          . enableExtension Ext_hard_line_breaks
            -- ^ Obsidian treats all newlines as line breaks.
          . disableExtension Ext_smart
            -- ^ Some data in my YAML frontmatter have character sequences that
            -- will become invalid if they are converted by this extension. For
            -- example, some URLs have two consecutive dashes.
            -- TODO: Figure out how to store the data in a way that it won't be
            -- affected by this extension.
          . disableExtension Ext_citations
            -- ^ For some reason, this breaks bsky links in my YAML frontmatter,
            -- probably because of the `@` character.
            -- TODO: Figure out how to enable this extension without breaking
            -- anything.
          $ getDefaultExtensions "markdown"
      }

  pandoc <- runPandoc (readMarkdown readerOptions markdown)
  pure
    ( convertTextLinks
    . convertCleanLinks
    $ pandoc
    )

-- All of the linked markdown will be converted to HTML, so we also want to
-- update markdown links to clean links.
convertCleanLinks :: Pandoc -> Pandoc
convertCleanLinks =
  walk \inline ->
    case inline of
      (Link a i (u, t)) ->
        Link a i (T.pack (cleanLink (T.unpack u)), t)
      _ -> inline

-- Convert text that contains an HTTP or HTTPS link into a link.
convertTextLinks :: Pandoc -> Pandoc
convertTextLinks =
  walk \inline ->
    case inline of
      Str url
        | "http:" `T.isPrefixOf` url ->
            Link nullAttr [Str url] (url, "")
        | "https:" `T.isPrefixOf` url ->
            Link nullAttr [Str url] (url, "")
        | otherwise ->
            inline
      _ -> inline

--------------------------------------------------------------------------------
-- HTML
--------------------------------------------------------------------------------

data TemplateArgs = TemplateArgs
  { metadata :: Metadata
    -- ^ The metadata extracted from the Pandoc.
  , commitHash :: Text
    -- ^ The current git commit hash.
  , indexListing :: [Metadata]
    -- ^ If this file is an index, then this is a list of all of the other files
    -- in the index.
  , taggedListing :: [Metadata]
    -- ^ If this file is a tag page, then this is a list of all of the other
    -- files with this tag.
  , backlinks :: [Metadata]
    -- ^ All of the backlinked files.
  , referencedImages :: Map Text Picture.DynamicImage
    -- ^ The images that this document references.
  , logoSource :: Text
    -- ^ This is the SVG source of the logo. We have to include this directly
    -- into the source of the generated HTML in order for the logo to respond to
    -- the user's color scheme, because of WebKit bug 199134 "SVG images don't
    -- support prefers-color-scheme adjustments when embedded in a page".
    -- https://bugs.webkit.org/show_bug.cgi?id=199134
  }

-- Makes an HTML document just the way I want it.
--
-- In particular, all links use "clean" URLs for paths leading to HTML files,
-- which means URLs will not contain the ".html" extension or end in "index".
makeHtml :: TemplateArgs -> Template Text -> Pandoc -> Either Text Text
makeHtml TemplateArgs{..} template pandoc = do
  let
    variables :: Map Text (DocTemplates.Val Text)
    variables = do
      Map.fromList
        [ ("logo", DocTemplates.toVal logoSource)
        , ("breadcrumb", makeBreadcrumbs (metaCanonicalPath metadata))
        , ("file", makeFileListing (metaInputPath metadata) indexListing)
        , ("tagged", makeFileListing (metaInputPath metadata) taggedListing)
        , ("date", makeDateItems metadata)
        , ("crosspost", makeCrossposts (metaCrossposts metadata))
        , ("backlinks", DocTemplates.toVal backlinks)
        , ("commitHash", DocTemplates.toVal commitHash)
        ]

    writerOptions = def
      { writerTemplate = Just template
      , writerVariables = DocTemplates.toContext variables
      , writerTableOfContents = True
      , writerExtensions = getDefaultExtensions "html"
      }

    newPandoc = preparePandocForHTML referencedImages pandoc
  runPandoc (writeHtml5String writerOptions newPandoc)

-- Does all of the transformations needed to prepare a Pandoc for being written
-- to HTML.
preparePandocForHTML :: Map Text Picture.DynamicImage -> Pandoc -> Pandoc
preparePandocForHTML referencedImages =
    embedImageRatios referencedImages
  . convertVideoEmbeds

-- Pandoc doesn't have a type which represents embeds, so we need to convert
-- those links to their respective embed codes.
convertVideoEmbeds :: Pandoc -> Pandoc
convertVideoEmbeds =
  walk \inline ->
    case inline of
      (Image _ _ (u, _)) -> do
        let getHost = fmap URI.uriRegName . URI.uriAuthority
        case URI.parseURI (T.unpack u) of
          Just req

            -- Youtube embeds
            | getHost req `elem` (Just <$> ["youtube.com", "www.youtube.com"])
            , let q = T.stripPrefix "?v=" (T.pack (URI.uriQuery req)) ->
                case q of
                  Just v ->
                    RawInline (Format "html") (makeYoutubeEmbed v)
                  Nothing ->
                    inline

            -- Vimeo embeds
            | getHost req `elem` (Just <$> ["vimeo.com", "www.vimeo.com"])
            , let v = T.drop 1 (T.pack (URI.uriPath req)) ->
                RawInline (Format "html") (makeVimeoEmbed v)

          _ -> inline

      _ -> inline

embedImageRatios :: Map Text Picture.DynamicImage -> Pandoc -> Pandoc
embedImageRatios images =
  walk \inline ->
    case inline of
      (Image (n, c, kvps) i (url, t)) ->
        let
          style w h = "--ratio:calc(" <> show w <> "/" <> show h <> ")"
          embedRatio w h =
            Image (n, c, ("style", style w h):kvps) i (url, t)

        in
          case Map.lookup url images of
            Just (Picture.ImageY8 image) ->
              embedRatio (Picture.imageWidth image) (Picture.imageHeight image)
            Just (Picture.ImageY16 image) ->
              embedRatio (Picture.imageWidth image) (Picture.imageHeight image)
            Just (Picture.ImageY32 image) ->
              embedRatio (Picture.imageWidth image) (Picture.imageHeight image)
            Just (Picture.ImageYF image) ->
              embedRatio (Picture.imageWidth image) (Picture.imageHeight image)
            Just (Picture.ImageYA8 image) ->
              embedRatio (Picture.imageWidth image) (Picture.imageHeight image)
            Just (Picture.ImageYA16 image) ->
              embedRatio (Picture.imageWidth image) (Picture.imageHeight image)
            Just (Picture.ImageRGB8 image) ->
              embedRatio (Picture.imageWidth image) (Picture.imageHeight image)
            Just (Picture.ImageRGB16 image) ->
              embedRatio (Picture.imageWidth image) (Picture.imageHeight image)
            Just (Picture.ImageRGBF image) ->
              embedRatio (Picture.imageWidth image) (Picture.imageHeight image)
            Just (Picture.ImageRGBA8 image) ->
              embedRatio (Picture.imageWidth image) (Picture.imageHeight image)
            Just (Picture.ImageRGBA16 image) ->
              embedRatio (Picture.imageWidth image) (Picture.imageHeight image)
            Just (Picture.ImageYCbCr8 image) ->
              embedRatio (Picture.imageWidth image) (Picture.imageHeight image)
            Just (Picture.ImageCMYK8 image) ->
              embedRatio (Picture.imageWidth image) (Picture.imageHeight image)
            Just (Picture.ImageCMYK16 image) ->
              embedRatio (Picture.imageWidth image) (Picture.imageHeight image)
            Nothing ->
              inline

      _ -> inline

-- Same as the official YouTube embed code, with the styling removed.
makeYoutubeEmbed :: Text -> Text
makeYoutubeEmbed v =
  "<iframe src=\"https://www.youtube.com/embed/" <> v <> "\" \
    \title=\"YouTube video player\" \
    \frameborder=\"0\" \
    \allow=\"accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share\" \
    \referrerpolicy=\"strict-origin-when-cross-origin\" \
    \allowfullscreen>\
  \</iframe>"

-- Almost the same as the official Vimeo embed code with the styling removed;
-- the only difference is that when you generate Vimeo embeds online, it uses
-- the name of the video as the title attribute for the iframe.
makeVimeoEmbed :: Text -> Text
makeVimeoEmbed v =
  "<iframe src=\"https://player.vimeo.com/video/" <> v <> "?title=0&amp;byline=0&amp;portrait=0&amp;badge=0&amp;autopause=0&amp;player_id=0&amp;app_id=58479\" \
    \frameborder=\"0\" \
    \allow=\"autoplay; fullscreen; picture-in-picture; clipboard-write; encrypted-media; web-share\" \
    \title=\"Vimeo video player\">\
  \</iframe>\
  \<script src=\"https://player.vimeo.com/api/player.js\">\
  \</script>"

-- Creates a list of breadcrumbs. Each breadcrumb is a link to that respective
-- location, except for the last one (since you are already at that location).
--
-- A breadcrumb is a navigational element that:
-- * Shows users their current position in a hierarchical structure
-- * Helps users navigate to different parts of a hierarchical structure
makeBreadcrumbs :: FilePath -> DocTemplates.Val Text
makeBreadcrumbs canonical =
  -- Make a list of (crumb, path) tuples
  let
    pieces = drop 1 (FilePath.splitDirectories canonical)
    crumbs = ("home", []) :| zip pieces [take n pieces | n <- [1..]]

    -- Make every breadcrumb into a link except for the last element
    mkA (crumb, p) =
         "<a href=\""
      <> ("/" </> FilePath.addTrailingPathSeparator (FilePath.joinPath p))
      <> "\">"
      <> crumb
      <> "</a>"
    mkP (crumb, _) =
      "<p>" <> crumb <> "</p>"
    breadcrumbs = (mkA <$> init crumbs) <> [mkP (last crumbs)]

  in
    DocTemplates.toVal (T.pack <$> breadcrumbs)

makeDateItems :: Metadata -> DocTemplates.Val Text
makeDateItems Metadata{..} = do
  let
    makeDateItem t d =
      Map.fromList
        [ ("type" :: Text, t)
        , ("time", formatTime d)
        ]
  DocTemplates.toVal $ catMaybes
    [ makeDateItem "published" <$> metaPublished
    , Just (makeDateItem "created" metaCreated)
    , makeDateItem "migrated" <$> metaMigrated
    , makeDateItem "modified" <$> metaModified
    ]

-- Creates a list of crossposts.
makeCrossposts :: [Crosspost] -> DocTemplates.Val Text
makeCrossposts crossposts =
  let
    makeCrosspost Crosspost{..} =
      Map.fromList
        [ ("url" :: Text, crosspostUrl)
        , ("site", crosspostSite)
        , ("time", formatTime crosspostTime)
        ]
  in
    DocTemplates.toVal (makeCrosspost <$> crossposts)

-- Makes a listing of files that doesn't include the current file
makeFileListing :: FilePath -> [Metadata] -> DocTemplates.Val Text
makeFileListing inputFile metas =
  let
    isNotInputFile meta = metaInputPath meta /= inputFile
  in
    DocTemplates.toVal (filter isNotInputFile metas)

--------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------

runPandoc :: PandocPure a -> Either Text a
runPandoc pandoc =
  let
    result =
        runIdentity
      . flip evalStateT def
      . flip evalStateT def
      . runExceptT
      $ unPandocPure pandoc
  in
    case result of
      Right a -> Right a
      Left err -> Left (renderError err)
