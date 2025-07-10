module Site
( main
) where

import Exo.Shake ((<//>), (</>), (-<.>), (|%>), (%>))
import qualified Exo.Shake as Shake
import qualified Exo.Const as Const

import qualified System.FilePath as FilePath
import qualified Data.Map as Map
import qualified Data.Text as T
import qualified Data.Time as Time
import qualified Network.URI as URI
import qualified Text.Pandoc as Pandoc
import qualified Text.Pandoc.Walk as Pandoc
import qualified Text.DocTemplates as DocTemplates

main :: IO ()
main = do
  let

  Shake.runShake $ do

    Shake.cleanPhony
    Shake.serverPhony

    Shake.action Shake.wantWebsite

    -- Copy static files.
    Const.outputDirectory </> "*.css" %> \out -> do
      let
        inputPath =
              Const.staticDirectory
          </> "style"
          </> Shake.dropDirectory1 out
      Shake.copyFileChanged inputPath out

    Const.outputDirectory </> "*.txt" %> \out -> do
      let inputPath = Const.staticDirectory </> Shake.dropDirectory1 out
      Shake.copyFileChanged inputPath out

    -- Copy website assets.
    let copyExtensions = [ "*.gif", "*.mp4", "*.png", "*.jpg", "*.svg" ]
    (Const.outputDirectory <//>) <$> copyExtensions |%> \out -> do
      let inputPath = Const.contentDirectory </> Shake.dropDirectory1 out
      Shake.copyFileChanged inputPath out

    -- Generate website pages.
    Const.outputDirectory <//> "*.html" %> \out -> do
      -- Read the markdown
      let
        readerOpts = Pandoc.def
          { Pandoc.readerExtensions =
                Pandoc.enableExtension Pandoc.Ext_lists_without_preceding_blankline
              . Pandoc.disableExtension Pandoc.Ext_citations
              $ Pandoc.getDefaultExtensions "markdown"
          }
        canonicalPath = Shake.dropDirectory1 out
        inputPath = Const.contentDirectory </> canonicalPath -<.> "md"
      md <- T.pack <$> readFile' inputPath
      pandoc <-
            convertVideoEmbeds
          . updateLinks
        <$> runPandoc (Pandoc.readMarkdown readerOpts md)

      -- Find dependencies
      let workingDirectory = Shake.takeDirectory out
      needImageDependencies workingDirectory pandoc

      -- Generate the HTML
      template <- buildTemplate (Const.staticDirectory </> "templates/default.html")
      Shake.need
        [ Const.outputDirectory </> "style.css"
        , Const.outputDirectory </> "logo.svg"
        ]
      let
        variables :: Map Text (DocTemplates.Val Text)
        variables =
          Map.fromList
            [ ("breadcrumb", DocTemplates.toVal (makeBreadcrumbs canonicalPath))
            , ("crosspost", makeCrossposts pandoc)
            ]
        writerOpts = Pandoc.def
          { Pandoc.writerTemplate = Just template
          , Pandoc.writerVariables = DocTemplates.toContext variables
          , Pandoc.writerTableOfContents = True
          , Pandoc.writerExtensions = Pandoc.getDefaultExtensions "html"
          }
      html <- runPandoc (Pandoc.writeHtml5String writerOpts pandoc)
      Shake.writeFileChanged out (T.unpack html)

updateLinks :: Pandoc.Pandoc -> Pandoc.Pandoc
updateLinks =
  let
    updateLink :: Pandoc.Inline -> Pandoc.Inline
    updateLink inline =
      case inline of
        (Pandoc.Link a i (u, t)) ->
          case FilePath.splitExtension (T.unpack u) of
            (path, ".md") -> Pandoc.Link a i (T.pack path, t)
            _ -> inline
        _ -> inline
  in
    Pandoc.walk updateLink

convertVideoEmbeds :: Pandoc.Pandoc -> Pandoc.Pandoc
convertVideoEmbeds =
  let
    convertVideoEmbed :: Pandoc.Inline -> Pandoc.Inline
    convertVideoEmbed i =
      case i of
        (Pandoc.Image _ _ (u, _)) ->
          if "http" `T.isPrefixOf` u
          then Pandoc.RawInline (Pandoc.Format "html") u
          else i
        _ -> i
  in
    Pandoc.walk convertVideoEmbed

needImageDependencies :: FilePath -> Pandoc.Pandoc -> Shake.Action ()
needImageDependencies dir pandoc =
  let
    extractUrl :: Pandoc.Inline -> [FilePath]
    extractUrl i =
      case i of
        (Pandoc.Image _ _ (u,_)) -> [dir </> T.unpack u]
        _ -> []
  in
    Shake.need (Pandoc.query extractUrl pandoc)

-- Creates a list of breadcrumb pieces to the current file.
makeBreadcrumbs :: FilePath -> [Text]
makeBreadcrumbs path =
  -- Make a list of (crumb, path) tuples
  let
    pieces =
        fmap FilePath.dropExtension
      . filter (/= "index.md")
      $ FilePath.splitDirectories path
    crumbs =
         ("home", [])
      :| zip pieces [take n pieces | n <- [1..]]

    -- Make every breadcrumb into a link except for the last element
    mkA (crumb, p) =
      "<a href=/" <> FilePath.joinPath p <> ">" <> crumb <> "</a>"
    mkP (crumb, _) =
      "<p>" <> crumb <> "</p>"

  in T.pack <$> ((mkA <$> init crumbs) <> [mkP (last crumbs)])

-- Creates a list of crossposts.
makeCrossposts :: Pandoc.Pandoc -> DocTemplates.Val Text
makeCrossposts (Pandoc.Pandoc (Pandoc.Meta meta) _) =
  let
    toTextValWith :: (Text -> Text)
                  -> Maybe Pandoc.MetaValue
                  -> DocTemplates.Val Text
    toTextValWith fn m =
      case m of
        Just (Pandoc.MetaInlines [Pandoc.Str text]) ->
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

    convertCrosspost :: Pandoc.MetaValue -> Maybe (DocTemplates.Val Text)
    convertCrosspost c =
      case c of
        Pandoc.MetaMap m ->
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
      Just (Pandoc.MetaList arr) ->
        DocTemplates.ListVal (mapMaybe convertCrosspost arr)
      _ ->
        DocTemplates.NullVal

--------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------

buildTemplate :: DocTemplates.TemplateTarget a => FilePath -> Shake.Action (Pandoc.Template a)
buildTemplate path = do
  result <- liftIO (DocTemplates.compileTemplateFile path)
  case result of
    Left err -> error (T.pack err)
    Right a -> pure a

runPandoc :: Pandoc.PandocPure a -> Shake.Action a
runPandoc pandoc =
  case runPandocPure pandoc of
    Right a -> pure a
    Left err -> error err

runPandocPure :: Pandoc.PandocPure a -> Either Text a
runPandocPure pandoc =
  let
    result =
        runIdentity
      . flip evalStateT Pandoc.def
      . flip evalStateT Pandoc.def
      . runExceptT
      $ Pandoc.unPandocPure pandoc
  in
    case result of
      Right a -> Right a
      Left err -> Left (Pandoc.renderError err)

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
    fromMaybe text (viaNonEmpty head (mapMaybe tryFormat validFormats))
