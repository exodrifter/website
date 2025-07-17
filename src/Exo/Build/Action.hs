-- Helper actions for building the website.
module Exo.Build.Action
( runEither
, decodeAeson
, decodeByteString
) where

import qualified Data.Aeson as Aeson
import qualified Data.ByteString.Lazy as BSL
import qualified Data.Text as T
import qualified Development.Shake as Shake

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
