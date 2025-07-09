import Hakyll
import qualified System.FilePath as FilePath
import qualified Data.Text as T
import qualified Data.Text.Lazy as TL
import qualified Text.Blaze.Html.Renderer.Text as Blaze
import qualified Text.Pandoc as Pandoc
import qualified Text.Pandoc.Writers.Shared as Pandoc

main :: IO ()
main = do
  hakyll $ do
    let
      defaultRoute = customRoute (dropDirectory . toFilePath)

    -- Compile site resources

    match "style/*.css" do
      route defaultRoute
      compile copyFileCompiler

    match "style/*.svg" do
      route defaultRoute
      compile copyFileCompiler

    match "templates/*" do
      compile templateBodyCompiler

    -- Compile site content

    match "content/**.jpg" do
      route defaultRoute
      compile copyFileCompiler

    match "content/**.png" do
      route defaultRoute
      compile copyFileCompiler

    match "content/**.svg" do
      route defaultRoute
      compile copyFileCompiler

    match "content/**.md" do
      route (defaultRoute `composeRoutes` setExtension "html")

      compile $ do
        let
          ropts = defaultHakyllReaderOptions
          wopts = defaultHakyllWriterOptions

        breadcrumbs <- makeBreadcrumbField
        toc <- makeTocField ropts wopts
        tags <- makeTagsField ropts

        let
          ctx :: Context String
          ctx =
               breadcrumbs
            <> toc
            <> tags
            <> defaultContext

        document <- getResourceBody >>= readPandocWith ropts
        writePandocWith wopts document
            &   loadAndApplyTemplate "templates/post.html" ctx
            >>= loadAndApplyTemplate "templates/default.html" ctx
            >>= remapUrls
            >>= relativizeUrls

-- Creates a list of breadcrumb pieces to the current file.
makeBreadcrumbField :: Compiler (Context a)
makeBreadcrumbField = do
  identifier <- getUnderlying

  -- Drop "." and "content"
  path <- dropDirectory . dropDirectory <$> getResourceFilePath

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

    html = (mkA <$> init crumbs) <> [mkP (last crumbs)]
    items = Item identifier <$> html

  pure (listField "breadcrumb" defaultContext (pure items))

-- Creates a Table of Contents from a Pandoc document only if there are at least
-- two sections.
makeTocField :: Pandoc.ReaderOptions -> Pandoc.WriterOptions -> Compiler (Context String)
makeTocField ropts wopts = do
  toc <- compileToc ropts wopts
  pure (maybe mempty (constField "toc") toc)

compileToc :: Pandoc.ReaderOptions -> Pandoc.WriterOptions -> Compiler (Maybe String)
compileToc ropts wopts = do
  document <- getResourceBody >>= readPandocWith ropts
  pure (extractToc wopts (itemBody document))

extractToc :: Pandoc.WriterOptions -> Pandoc.Pandoc -> Maybe String
extractToc wopts (Pandoc.Pandoc meta blocks) =
  let
    toc = Pandoc.toTableOfContents wopts blocks
    toHtml = fmap Blaze.renderHtml . runPandocPure . Pandoc.writeHtml5 wopts
    html =
      case toHtml (Pandoc.Pandoc meta [toc]) of
        Left _ -> Nothing
        Right text -> Just (TL.unpack text)

    shouldMakeToc :: Bool -> Pandoc.Block -> Bool
    shouldMakeToc topLevel t =
      case t of
        Pandoc.BulletList [] -> False
        Pandoc.BulletList [b] -> not topLevel || any (shouldMakeToc False) b
        Pandoc.BulletList _ -> True
        _ -> False
  in
    if shouldMakeToc True toc
    then html
    else Nothing

-- Create a list of tags
makeTagsField :: Pandoc.ReaderOptions -> Compiler (Context String)
makeTagsField ropts = do
  (Item identifier (Pandoc.Pandoc meta _)) <-
    getResourceString >>= readPandocWith ropts
      { Pandoc.readerExtensions =
            Pandoc.enableExtension Pandoc.Ext_yaml_metadata_block
          $ Pandoc.readerExtensions ropts
      }

  let
    extractMetaStrings :: Pandoc.MetaValue -> [String]
    extractMetaStrings m =
      case m of
        Pandoc.MetaList l -> concatMap extractMetaStrings l
        Pandoc.MetaString s -> [T.unpack s]
        Pandoc.MetaInlines [Pandoc.Str s] -> [T.unpack s]
        _ -> []

  case Pandoc.lookupMeta "tags" meta of
    Nothing ->
      pure mempty
    Just m ->
      case extractMetaStrings m of
        [] -> pure mempty
        arr ->
          let items = Item identifier <$> arr
          in  pure (listField "tags" defaultContext (pure items))

--------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------

runPandocPure :: Pandoc.PandocPure a -> Either String a
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
      Left err -> Left (T.unpack (Pandoc.renderError err))

remapUrls :: Item String -> Compiler (Item String)
remapUrls item = do
  let
    xform p
      | FilePath.takeExtension p == ".md" = FilePath.replaceExtension p ".html"
      | otherwise = p

  r <- getRoute $ itemIdentifier item
  pure $ case r of
    Nothing -> item
    Just _ ->
      withUrls xform <$> item

dropDirectory :: FilePath -> FilePath
dropDirectory = FilePath.joinPath . drop 1 . FilePath.splitDirectories
