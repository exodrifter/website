module Exo.Parser.Frontmatter
( parseFrontmatter
) where

import qualified Data.Aeson as Aeson
import qualified Data.Attoparsec.Text as Atto
import qualified Data.Text as T
import qualified Data.Text.Encoding as TE
import qualified Data.Yaml as Yaml
import Control.Monad.Catch

parseFrontmatter :: (MonadThrow m, Aeson.FromJSON a) => Text -> m (a, Text)
parseFrontmatter md =
  let
    delimiter = Atto.string "---" >> Atto.endOfLine
    frontMatter = do
      yaml <- delimiter *> Atto.manyTill Atto.anyChar delimiter
      rest <- Atto.takeText
      Atto.endOfInput
      pure (T.pack yaml, rest)
  in
    case Atto.parseOnly frontMatter md of
      Left err -> error (T.pack err)
      Right (yaml, rest) ->
        case Yaml.decodeEither' (TE.encodeUtf8 yaml) of
          Left reason -> error (T.pack (displayException reason))
          Right a -> pure (a, rest)
