{-# LANGUAGE TypeFamilies #-}

-- Oracles that we want to use when building the website.
module Exo.Shake.Oracle
( getOracleRules
, cacheJSON

, runEither
, decodeByteString
) where

import qualified Data.Aeson as Aeson
import qualified Data.Binary as Binary
import qualified Data.ByteString.Lazy as BSL
import qualified Data.Text as T
import qualified Development.Shake as Shake
import qualified Exo.Pandoc as Pandoc

-- If we use the same input type for multiple oracles, Shake will think that
-- the oracles are recursive.
newtype PandocOracle = PandocOracle FilePath
  deriving newtype (Binary.Binary, Eq, Hashable, NFData, Show)
newtype MetaOracle = MetaOracle FilePath
  deriving newtype (Binary.Binary, Eq, Hashable, NFData, Show)
newtype CommitHashOracle = CommitHashOracle FilePath
  deriving newtype (Binary.Binary, Eq, Hashable, NFData, Show)

getOracleRules :: Shake.Rules
    ( FilePath -> Shake.Action Pandoc.Pandoc
    , FilePath -> Shake.Action Pandoc.Metadata
    , FilePath -> Shake.Action Text
    )
getOracleRules = do
  -- Parse markdown files.
  getPandoc <- (. PandocOracle) <$> cacheJSON \(PandocOracle path) -> do
    Shake.need [path]
    md <- decodeByteString =<< readFileBS path
    runEither (Pandoc.parseMarkdown md)

  -- Parse metadata from markdown files.
  getMetadata <- (. MetaOracle) <$> cacheJSON \(MetaOracle path) -> do
    pandoc <- getPandoc path
    runEither (Pandoc.parseMetadata path pandoc)

  -- Get commit hash.
  getCommitHash <- (. CommitHashOracle) <$> cacheJSON \(CommitHashOracle path) -> do
    Shake.StdoutTrim result <- Shake.cmd
      ( "git rev-list" :: String )
      [ "--abbrev-commit"
      , "-1"
      , "HEAD"
      , "--"
      , path
      ]
    pure (T.pack result)

  pure (getPandoc, getMetadata, getCommitHash)

--------------------------------------------------------------------------------
-- Generic caching
--------------------------------------------------------------------------------

newtype Cache q = Cache q
  deriving newtype (Binary.Binary, Eq, Hashable, NFData, Show)

type instance Shake.RuleResult (Cache q) = ByteString

cacheOracle :: (Binary.Binary q, Hashable q, NFData q, Show q, Typeable q)
            => (q -> Shake.Action ByteString)
            -> (ByteString -> Shake.Action a)
            -> Shake.Rules (q -> Shake.Action a)
cacheOracle encode decode =
  let
    decodeCache :: (ByteString -> Shake.Action a)
            -> (Cache q -> Shake.Action ByteString)
            -> (q -> Shake.Action a)
    decodeCache fn runCache = \filepath -> fn =<< runCache (Cache filepath)
  in
    decodeCache decode <$> Shake.addOracleCache \(Cache q) -> encode q

-- Cache anything that can be serialized to JSON.
cacheJSON :: (Binary.Binary q, Hashable q, NFData q, Show q, Typeable q)
          => (Aeson.FromJSON a, Aeson.ToJSON a)
          => (q -> Shake.Action a)
          -> Shake.Rules (q -> Shake.Action a)
cacheJSON parse =
  cacheOracle
    (\path -> BSL.toStrict . Aeson.encode <$> parse path)
    (\bs ->
        case Aeson.eitherDecode (BSL.fromStrict bs) of
          Left err -> fail err
          Right a -> pure a
    )

--------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------

-- Fails the action if the Either is a Left.
runEither :: Either Text a -> Shake.Action a
runEither e =
  case e of
    Right a -> pure a
    Left err -> error err

decodeByteString :: ByteString -> Shake.Action Text
decodeByteString bs =
  runEither (first (T.pack . displayException) (decodeUtf8' bs))
