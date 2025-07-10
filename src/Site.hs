module Site
( main
) where

import Exo.Shake ((<//>), (</>), (-<.>), (|%>), (%>))
import qualified Exo.Shake as Shake
import qualified Exo.Const as Const

import qualified Data.Text as T
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
          { Pandoc.readerExtensions = Pandoc.getDefaultExtensions "markdown"
          }
        inputPath =
              Const.contentDirectory
          </> Shake.dropDirectory1 out -<.> "md"
      md <- T.pack <$> readFile' inputPath
      pandoc <-
            convertVideoEmbeds
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
        writerOpts = Pandoc.def
          { Pandoc.writerTemplate = Just template
          , Pandoc.writerTableOfContents = True
          , Pandoc.writerExtensions = Pandoc.getDefaultExtensions "html"
          }
      html <- runPandoc (Pandoc.writeHtml5String writerOpts pandoc)
      Shake.writeFileChanged out (T.unpack html)

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
