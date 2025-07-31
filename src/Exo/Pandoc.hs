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
import Text.Pandoc.Shared as X
import Text.Pandoc.Writers.Shared as X
import Text.Pandoc.Walk as X
import qualified Codec.Picture as Picture
import qualified Data.List.Extra as List
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
  , rssPath :: Maybe FilePath
    -- ^ The canonical path to the RSS feed associated with this page.
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
    maybeToVal = maybe DocTemplates.NullVal DocTemplates.toVal

    variables :: Map Text (DocTemplates.Val Text)
    variables = do
      Map.fromList
        [ ("meta", DocTemplates.toVal metadata)
        , ("commitHash", DocTemplates.toVal commitHash)
        , ("breadcrumb", makeBreadcrumbs (metaCanonicalPath metadata))
        , ("list"
          , DocTemplates.toVal $ catMaybes
            [ makeFileListing "files"  (metaInputPath metadata) indexListing
            , makeFileListing "tagged" (metaInputPath metadata) taggedListing
            ]
          )
        , ("backlink", DocTemplates.toVal backlinks)
        , ("rss", maybeToVal (T.pack <$> rssPath))
        , ("toc", maybeToVal (makeToc pandoc))
        , ("logo", DocTemplates.toVal logoSource)
        ]

    writerOptions = def
      { writerTemplate = Just template
      , writerVariables = DocTemplates.toContext variables
      , writerExtensions = getDefaultExtensions "html"
      }

    newPandoc = preparePandocForHTML writerOptions referencedImages pandoc
  runPandoc (writeHtml5String writerOptions newPandoc)

-- Generates an HTML table of contents for a Pandoc document, but only if there
-- are two or more items.
makeToc :: Pandoc -> Maybe Text
makeToc (Pandoc m blocks) =
  let
    toc = toTableOfContents def blocks
    toHtml = runPure . writeHtml5String def
    html =
      case toHtml (Pandoc m [toc]) of
        Left _ -> Nothing -- TODO: Propogate error instead
        Right a -> Just a

    shouldMakeToc :: Bool -> Block -> Bool
    shouldMakeToc topLevel t =
      case t of
        BulletList [] -> False
        BulletList [b] -> not topLevel || any (shouldMakeToc False) b
        BulletList _ -> True
        _ -> False

  in
    if shouldMakeToc True toc
    then html
    else Nothing

-- Does all of the transformations needed to prepare a Pandoc for being written
-- to HTML.
preparePandocForHTML :: WriterOptions -> Map Text Picture.DynamicImage -> Pandoc -> Pandoc
preparePandocForHTML writerOptions referencedImages =
    embedImageRatios referencedImages
  . convertFootnotes writerOptions
  . convertEntryReference
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

-- Because of my note-taking style, a common pattern on the website is to
-- reference an entry as a source for some information. These references are
-- embedded as footnotes, but rendering them this way means that the user has to
-- click twice to get to the entry. And, since we often re-use references in the
-- same document, this can also make the footnote section very noisy due to a
-- limitation in Pandoc's AST which causes them to be duplicated. Instead, it
-- would be nice to inline the references.
convertEntryReference :: Pandoc -> Pandoc
convertEntryReference pandoc =
  let
    links =
      flip query pandoc \inline ->
        case inline of
          Note [Para [l@(Link _ _ _)]] -> [l]
          _ -> []
    refs =
      fromList (zip (List.nubOrd links) (show <$> [1 :: Int ..]))
  in
    flip walk pandoc \inline ->
      case inline of
        Note [Para [l@(Link attr inlines target)]] ->
          Link
            attr
            [ Superscript
              [ RawInline (Format "html") "<i class=\"ri-triangle-fill\"></i>"
              , Str (fromMaybe (stringify inlines) (Map.lookup l refs))
              ]
            ]
            target
        _ -> inline

-- Converts footnotes into sidenotes.
convertFootnotes :: WriterOptions -> Pandoc -> Pandoc
convertFootnotes wOpts pandoc =
  let
    toHtml = runPure . writeHtml5String wOpts { writerTemplate = Nothing }
    toRawHtml blocks =
      case toHtml (Pandoc mempty blocks) of
        Left _ -> stringify blocks -- TODO: Propogate error instead
        Right a -> a
  in
    flip walk pandoc \inline ->
      case inline of
        Note inlines ->
          RawInline
            (Format "html")
            ("<aside class=\"sidenote\">" <> toRawHtml inlines <> "</aside>")
        _ ->
          inline

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

-- Makes a listing of files that doesn't include the current file
makeFileListing :: Text -> FilePath -> [Metadata] -> Maybe (Map Text (DocTemplates.Val Text))
makeFileListing name inputFile metas =
  let
    -- Pandoc doesn't let us check the name of variables, but it does let us
    -- check for the existence of them. So, we can add the type as a variable.
    -- The value doesn't matter, but it needs to be non-empty for it to exist.
    typeMap = Map.fromList [(name, name)]
    isNotInputFile meta = metaInputPath meta /= inputFile
  in
    case metas of
      [] -> Nothing
      _ ->
        Just $ fromList
          [ ("type", DocTemplates.toVal typeMap)
          , ("name", DocTemplates.toVal name)
          , ("file", DocTemplates.toVal (filter isNotInputFile metas))
          ]

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
