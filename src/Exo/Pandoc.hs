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
import Exo.Pandoc.Metadata as X
import Exo.Pandoc.Sort as X
import Exo.Pandoc.Time as X
import Text.Pandoc as X
import Text.Pandoc.Walk as X
import qualified Data.Map as Map
import qualified Data.Text as T
import qualified Development.Shake.FilePath as FilePath
import qualified Network.URI as URI
import qualified Text.DocTemplates as DocTemplates

-- Parses a markdown document just the way I want it.
--
-- In general, this function will tend towards maintaining compatability with
-- Obsidian, since that's the note-taking application I personally use.
parseMarkdown :: Text -> Either Text Pandoc
parseMarkdown markdown =
  let
    readerOptions = def
      { readerExtensions =
            enableExtension Ext_lists_without_preceding_blankline
            -- ^ I have a lot of lists that don't have a preceding blankline,
            -- because Obsidian allows that.
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
  in
    runPandoc (readMarkdown readerOptions markdown)

--------------------------------------------------------------------------------
-- HTML
--------------------------------------------------------------------------------

data TemplateArgs = TemplateArgs
  { canonicalPath :: FilePath
    -- ^ The path of this file on the website.
  , inputPath :: FilePath
    -- ^ The path to this file's source.
  , indexListing :: [(FilePath, Pandoc)]
    -- ^ If this file is an index, then this is a list of all of the other files
    -- in the index.
  , taggedListing :: [Metadata]
    -- ^ If this file is a tag page, then this is a list of all of the other
    -- files with this tag.
  }

-- Makes an HTML document just the way I want it.
--
-- In particular, all links use "clean" URLs for paths leading to HTML files,
-- which means URLs will not contain the ".html" extension or end in "index".
makeHtml :: TemplateArgs -> Template Text -> Pandoc -> Either Text Text
makeHtml args template pandoc = do

  -- Make additional template variables
  crossposts <- makeCrossposts pandoc
  created <-
    -- TODO: Assert that this exists on all files and add missing data.
    if hasMetaKey "created" pandoc
    then DocTemplates.toVal <$> getCreatedText pandoc
    else Right DocTemplates.NullVal
  published <-
    if hasMetaKey "published" pandoc
    then DocTemplates.toVal <$> getPublishedText pandoc
    else Right DocTemplates.NullVal
  modified <-
    if hasMetaKey "modified" pandoc
    then DocTemplates.toVal <$> getModifiedText pandoc
    else Right DocTemplates.NullVal
  let
    variables :: Map Text (DocTemplates.Val Text)
    variables = do
      Map.fromList
        [ ("breadcrumb", makeBreadcrumbs (canonicalPath args))
        , ("file", makeFileListing (inputPath args) (indexListing args))
        , ("tagged", makeFileListing' (inputPath args) (taggedListing args))
        , ("created", created)
        , ("published", published)
        , ("modified", modified)
        , ("crosspost", crossposts)
        ]

    writerOptions = def
      { writerTemplate = Just template
      , writerVariables = DocTemplates.toContext variables
      , writerTableOfContents = True
      , writerExtensions = getDefaultExtensions "html"
      }

  runPandoc (writeHtml5String writerOptions (preparePandoc pandoc))

-- Does all of the transformations needed to prepare a Pandoc for being written
-- to HTML.
preparePandoc :: Pandoc -> Pandoc
preparePandoc =
    convertVideoEmbeds
  . convertCleanLinks

-- All of the linked markdown will be converted to HTML, so we also want to
-- update markdown links to clean links.
convertCleanLinks :: Pandoc -> Pandoc
convertCleanLinks =
  walk \inline ->
    case inline of
      (Link a i (u, t)) ->
        Link a i (T.pack (cleanLink (T.unpack u)), t)
      _ -> inline

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

-- Same as the official YouTube embed code
makeYoutubeEmbed :: Text -> Text
makeYoutubeEmbed v =
  "<iframe width=\"560\" height=\"315\" \
    \src=\"https://www.youtube.com/embed/" <> v <> "\" \
    \title=\"YouTube video player\" \
    \frameborder=\"0\" \
    \allow=\"accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share\" \
    \referrerpolicy=\"strict-origin-when-cross-origin\" \
    \allowfullscreen>\
  \</iframe>"

-- Almost the same as the official Vimeo embed code; the only difference is that
-- when you generate Vimeo embeds online, it uses the name of the video as the
-- title attribute for the iframe.
makeVimeoEmbed :: Text -> Text
makeVimeoEmbed v =
  "<div style=\"padding:56.25% 0 0 0;position:relative;\">\
  \<iframe src=\"https://player.vimeo.com/video/" <> v <> "?title=0&amp;byline=0&amp;portrait=0&amp;badge=0&amp;autopause=0&amp;player_id=0&amp;app_id=58479\" \
    \frameborder=\"0\" \
    \allow=\"autoplay; fullscreen; picture-in-picture; clipboard-write; encrypted-media; web-share\" \
    \style=\"position:absolute;top:0;left:0;width:100%;height:100%;\" \
    \title=\"Vimeo video player\">\
  \</iframe>\
  \</div>\
  \<script src=\"https://player.vimeo.com/api/player.js\">\
  \</script>"

-- Creates a list of breadcrumbs. Each breadcrumb is a link to that respective
-- location, except for the last one (since you are already at that location).
--
-- A breadcrumb is a navigational element that:
-- * Shows users their current position in a hierarchical structure
-- * Helps users navigate to different parts of a hierarchical structure
makeBreadcrumbs :: FilePath -> DocTemplates.Val Text
makeBreadcrumbs path =
  -- Make a list of (crumb, path) tuples
  let
    pieces =
        fmap FilePath.dropExtension
      . filter (/= "index.html") -- Drop index for clean URLs
      $ FilePath.splitDirectories path
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

-- Creates a list of crossposts.
makeCrossposts :: Pandoc -> Either Text (DocTemplates.Val Text)
makeCrossposts (Pandoc (Meta meta) _) =
  let
    toTextValWith :: (Text -> Either Text Text)
                  -> Text
                  -> Map Text MetaValue
                  -> Either Text (DocTemplates.Val Text)
    toTextValWith fn key m = do
      text <- lookupMetaString key m
      DocTemplates.toVal <$> fn text

    extractSite :: Text -> Either Text Text
    extractSite text = do
      uri <- justElse
        ("Key \"url\" is not a URI! Saw: \"" <> text <> "\"")
        (URI.parseURI (T.unpack text))
      auth <- justElse
        ("Key \"url\" does not have an authority! Saw: \"" <> text <> "\"")
        (URI.uriAuthority uri)
      case URI.uriRegName auth of
        "bsky.app" -> Right "bsky"
        "cohost.org" -> Right "cohost!"
        "exodrifter.itch.io" -> Right "itch.io"
        "forum.tsuki.games" -> Right "t/suki"
        "ko-fi.com" -> Right "ko-fi"
        "music.exodrifter.space" -> Right "bandcamp"
        "soundcloud.com" -> Right "soundcloud"
        "store.steampowered.com" -> Right "steam"
        "twitter.com" -> Right "twitter"
        "www.patreon.com" -> Right "patreon"
        "www.youtube.com" -> Right "youtube"
        "x.com" -> Right "twitter"
        "steamcommunity.com" -> Right "steam"
        a -> Right (T.pack a)

    withMetaMap :: MetaValue -> Either Text (Map Text MetaValue)
    withMetaMap v =
      case v of
        MetaMap m -> Right m
        _ -> Left "metadata is not a map!"

    convertCrosspost :: MetaValue -> Either Text (DocTemplates.Val Text)
    convertCrosspost c = do
      m <- withMetaMap c
      url <- toTextValWith pure "url" m
      site <- toTextValWith extractSite "url" m
      time <- toTextValWith reformatTime "time" m

      pure . DocTemplates.toVal $ Map.fromList
        [ ("url" :: Text, url)
        , ("site", site)
        , ("time", time)
        ]
  in
    case Map.lookup "crossposts" meta of
      Just (MetaList arr) ->
        DocTemplates.ListVal <$> traverse convertCrosspost arr
      Just _ ->
        Left "\"crossposts\" metadata is not a list!"
      Nothing ->
        Right DocTemplates.NullVal

-- Makes a listing of files that doesn't include the current file
makeFileListing :: FilePath -> [(FilePath, Pandoc)] -> DocTemplates.Val Text
makeFileListing inputFile files =
  let
    make :: (FilePath, Pandoc) -> DocTemplates.Val Text
    make (file, pandoc) = do
      let
        path = "/" </> FilePath.dropDirectory1 file
        name =
          fromRight
            (T.pack (FilePath.takeBaseName path))
            (getTitle pandoc)
      DocTemplates.toVal $ Map.fromList
        [ ("path" :: Text, T.pack (cleanLink path))
        , ("name", name)
        ]

    isNotInputFile (file, _) = file /= inputFile
  in
    DocTemplates.ListVal (make <$> filter isNotInputFile files)

-- Makes a listing of files that doesn't include the current file
makeFileListing' :: FilePath -> [Metadata] -> DocTemplates.Val Text
makeFileListing' inputFile metas =
  let
    make :: Metadata -> DocTemplates.Val Text
    make meta = do
      DocTemplates.toVal $ Map.fromList
        [ ("path" :: Text, T.pack ("/" </> metaCanonicalPath meta))
        , ("name", metaTitle meta)
        ]

    isNotInputFile meta = metaInputPath meta /= inputFile
  in
    DocTemplates.ListVal (make <$> filter isNotInputFile metas)

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

justElse :: e -> Maybe a -> Either e a
justElse err ma =
  case ma of
    Just a -> Right a
    Nothing -> Left err
