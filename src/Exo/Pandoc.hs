-- Pure, bespoke functions for building the website with Pandoc.
module Exo.Pandoc
( module X
, parseMarkdown
, makeHtml
) where

import Text.Pandoc as X
import Text.Pandoc.Walk as X
import qualified Data.Map as Map
import qualified Data.Text as T
import qualified Data.Time as Time
import qualified Network.URI as URI
import qualified System.FilePath as FilePath
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

-- Makes an HTML document just the way I want it.
--
-- In particular, all links use "clean" URLs for paths leading to HTML files,
-- which means URLs will not contain the ".html" extension or end in "index".
makeHtml :: FilePath -> Template Text -> Pandoc -> Either Text Text
makeHtml path template pandoc =
  let
    variables :: Map Text (DocTemplates.Val Text)
    variables =
      Map.fromList
        [ ("breadcrumb", DocTemplates.toVal (makeBreadcrumbs path))
        , ("crosspost", makeCrossposts pandoc)
        ]
    writerOptions = def
      { writerTemplate = Just template
      , writerVariables = DocTemplates.toContext variables
      , writerTableOfContents = True
      , writerExtensions = getDefaultExtensions "html"
      }
  in
    runPandoc (writeHtml5String writerOptions (preparePandoc pandoc))

-- Does all of the transformations needed to prepare a Pandoc for being written
-- to HTML.
preparePandoc :: Pandoc -> Pandoc
preparePandoc =
    convertVideoEmbeds
  . updateLinks

-- All of the linked markdown will be converted to HTML, so we also want to
-- update markdown links to clean links.
updateLinks :: Pandoc -> Pandoc
updateLinks =
  walk \inline ->
    case inline of
      (Link a i (u, t)) ->
        case FilePath.splitExtension (T.unpack u) of
          (path, ".md") -> Link a i (T.pack path, t)
          _ -> inline
      _ -> inline

-- Pandoc doesn't have a type which represents embeds, so we need to convert
-- those links to their respective embed codes.
convertVideoEmbeds :: Pandoc -> Pandoc
convertVideoEmbeds =
  walk \inline ->
    case inline of
      (Image _ _ (u, _)) ->
        -- TODO: Oops, I need to actually implement this. Also, I should use a
        -- URI parser.
        if "http" `T.isPrefixOf` u
        then RawInline (Format "html") u
        else inline
      _ -> inline

-- Creates a list of breadcrumbs. Each breadcrumb is a link to that respective
-- location, except for the last one (since you are already at that location).
--
-- A breadcrumb is a navigational element that:
-- * Shows users their current position in a hierarchical structure
-- * Helps users navigate to different parts of a hierarchical structure
makeBreadcrumbs :: FilePath -> [Text]
makeBreadcrumbs path =
  -- Make a list of (crumb, path) tuples
  let
    pieces =
        fmap FilePath.dropExtension
      . filter (/= "index.md") -- Drop index for clean URLs
      $ FilePath.splitDirectories path
    crumbs = ("home", []) :| zip pieces [take n pieces | n <- [1..]]

    -- Make every breadcrumb into a link except for the last element
    mkA (crumb, p) =
      "<a href=/" <> FilePath.joinPath p <> ">" <> crumb <> "</a>"
    mkP (crumb, _) =
      "<p>" <> crumb <> "</p>"
  in T.pack <$> ((mkA <$> init crumbs) <> [mkP (last crumbs)])

-- Creates a list of crossposts.
makeCrossposts :: Pandoc -> DocTemplates.Val Text
makeCrossposts (Pandoc (Meta meta) _) =
  let
    toTextValWith :: (Text -> Text)
                  -> Maybe MetaValue
                  -> DocTemplates.Val Text
    toTextValWith fn m =
      case m of
        Just (MetaInlines [Str text]) ->
          DocTemplates.toVal (fn text)
        _ ->
          DocTemplates.NullVal

    extractSite :: Text -> Text
    extractSite text =
      let
        auth = URI.parseURI (T.unpack text) >>= URI.uriAuthority
      in
        case URI.uriRegName <$> auth of
          Nothing -> "unknown"
          Just "bsky.app" -> "bsky"
          Just "cohost.org" -> "cohost!"
          Just "exodrifter.itch.io" -> "itch.io"
          Just "forum.tsuki.games" -> "t/suki"
          Just "ko-fi.com" -> "ko-fi"
          Just "music.exodrifter.space" -> "bandcamp"
          Just "soundcloud.com" -> "soundcloud"
          Just "store.steampowered.com" -> "steam"
          Just "twitter.com" -> "twitter"
          Just "www.patreon.com" -> "patreon"
          Just "www.youtube.com" -> "youtube"
          Just "x.com" -> "twitter"
          Just "steamcommunity.com" -> "steam"
          Just a -> T.pack a

    convertCrosspost :: MetaValue -> Maybe (DocTemplates.Val Text)
    convertCrosspost c =
      case c of
        MetaMap m ->
          let
            crosspost :: Map Text (DocTemplates.Val Text)
            crosspost = Map.fromList
              [ ("url", toTextValWith identity (Map.lookup "url" m))
              , ("site", toTextValWith extractSite (Map.lookup "url" m))
              , ("time", toTextValWith formatTime (Map.lookup "time" m))
              ]
          in
            Just (DocTemplates.toVal crosspost)
        _ ->
          Nothing
  in
    case Map.lookup "crossposts" meta of
      Just (MetaList arr) ->
        DocTemplates.ListVal (mapMaybe convertCrosspost arr)
      _ ->
        DocTemplates.NullVal

-- Formats a time for the website. All times are rendered in UTC in as much
-- detail as is available.
--
-- My notes have accumulated a variety of different time formats over the years,
-- so this function tries several different formats until one of them works.
formatTime :: Text -> Text
formatTime text =
  let
    validFormats =
      [ ("%Y-%m-%dT%H:%M:%SZ", "%Y-%m-%d %H:%M:%S")
      , ("%Y-%m-%dT%H:%MZ", "%Y-%m-%d %H:%M")
      ]
    locale = Time.defaultTimeLocale

    tryParse :: String -> Maybe Time.UTCTime
    tryParse format = Time.parseTimeM False locale format (T.unpack text)

    tryFormat :: (String, String) -> Maybe Text
    tryFormat (parseFormat, format) =
      T.pack . Time.formatTime locale format <$> tryParse parseFormat
  in
    -- TODO: Instead of using the raw text, it would be nice if we failed
    -- so I can know which formats need to be handled by this function.
    fromMaybe text (viaNonEmpty head (mapMaybe tryFormat validFormats))

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
