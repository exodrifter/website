{-# LANGUAGE TypeFamilies #-}

-- Oracles that we want to use when building the website, exposed as simple
-- Haskell functions without the additional Oracle boilerplate code.
--
-- Note that oracles are written to cache their results when possible and that
-- this is done by relying on the JSON serialization for some types. We use
-- JSON serialization because its' widely available, and this lets us avoid
-- needing to implement the other classes necessary for caching.
module Exo.Shake.Oracle
( oracleRules
, getPandoc
, getMetadata
, getCommitHash

-- Generic caching
, cacheJSON

-- Helpers
, runEither
, decodeByteString
) where

import qualified Data.Aeson as Aeson
import qualified Data.Binary as Binary
import qualified Data.ByteString.Lazy as BSL
import qualified Data.Text as T
import qualified Development.Shake as Shake
import qualified Exo.Pandoc as Pandoc

-- Adds all of the oracle rules so that they can be used.
oracleRules :: Shake.Rules ()
oracleRules = do
  -- Instead of returning the query functions created by the oracle functions,
  -- we will use `askOracle` instead, allowing us to avoid having to carry the
  -- results of these calls everywhere. This works because we define each oracle
  -- with its own unique input and output types with `RuleResult`.
  void $ Shake.addOracleCache pandocOracle
  void $ Shake.addOracleCache metaOracle
  void $ Shake.addOracle commitHashOracle

-- Parses a markdown file into a Pandoc document.
newtype PandocOracle = PandocOracle FilePath
  deriving newtype (Binary.Binary, Eq, Hashable, NFData, Show)
type instance Shake.RuleResult PandocOracle = ByteString

getPandoc :: FilePath -> Shake.Action Pandoc.Pandoc
getPandoc = decodeAeson <=< Shake.askOracle . PandocOracle

pandocOracle :: PandocOracle -> Shake.Action ByteString
pandocOracle (PandocOracle path) = do
  Shake.need [path]
  md <- decodeByteString =<< readFileBS path
  pandoc <- runEither (Pandoc.parseMarkdown md)
  pure (BSL.toStrict (Aeson.encode pandoc))

-- Parses metadata from a Pandoc document.
newtype MetaOracle = MetaOracle FilePath
  deriving newtype (Binary.Binary, Eq, Hashable, NFData, Show)
type instance Shake.RuleResult MetaOracle = ByteString

getMetadata :: FilePath -> Shake.Action Pandoc.Metadata
getMetadata = decodeAeson <=< Shake.askOracle . MetaOracle

metaOracle :: MetaOracle -> Shake.Action ByteString
metaOracle (MetaOracle path) = do
  pandoc <- getPandoc path
  meta <- runEither (Pandoc.parseMetadata path pandoc)
  pure (BSL.toStrict (Aeson.encode meta))

-- Gets the latest commit hash for a file.
newtype CommitHashOracle = CommitHashOracle FilePath
  deriving newtype (Binary.Binary, Eq, Hashable, NFData, Show)
type instance Shake.RuleResult CommitHashOracle = Text

getCommitHash :: FilePath -> Shake.Action Text
getCommitHash = Shake.askOracle . CommitHashOracle

commitHashOracle :: CommitHashOracle -> Shake.Action Text
commitHashOracle (CommitHashOracle path) = do
  Shake.StdoutTrim result <-
    Shake.cmd
      (Shake.Traced "")
      ("git rev-list" :: String)
      ["--abbrev-commit", "-1", "HEAD", "--", path]
  pure (T.pack result)

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

runEitherWith :: (err -> Text) -> Either err a -> Shake.Action a
runEitherWith fn e = runEither (first fn e)

decodeByteString :: ByteString -> Shake.Action Text
decodeByteString bs =
  runEitherWith (T.pack . displayException) (decodeUtf8' bs)

decodeAeson :: Aeson.FromJSON a => ByteString -> Shake.Action a
decodeAeson bs =
  runEitherWith T.pack (Aeson.eitherDecode (BSL.fromStrict bs))
