{-# LANGUAGE DeriveGeneric #-}

-- Helpers for dealing with time.
--
-- Generally, all of the times are rendered in UTC on the website, but the
-- source files have a variety of times in different formats.
module Exo.Pandoc.Time
( Timestamp(..)
, Resolution(..)
, parseTime
, formatTime
) where

import qualified Data.Aeson as Aeson
import qualified Data.Text as T
import qualified Data.Time as Time

-- Source files have a variety of different resolutions and I would like to
-- maintain that resolution when times are shown on the website. I don't want to
-- say, for example, imply that a note was updated at midnight if the time is
-- missing
data Timestamp =
  Timestamp
    { timestampUtcTime :: Time.UTCTime
    , timestampResolution :: Resolution
    }
  deriving stock (Eq, Generic, Show)

instance Ord Timestamp where
  compare = comparing timestampUtcTime

instance Aeson.FromJSON Timestamp
instance Aeson.ToJSON Timestamp

-- The highest resolution available for a timestamp.
data Resolution =
    Day
  | Hour
  | Minute
  | Second
  | Fraction
  deriving stock (Eq, Generic, Show)

instance Aeson.FromJSON Resolution
instance Aeson.ToJSON Resolution

-- My notes have accumulated a variety of different time formats over the years,
-- so this function tries several different formats until one of them works.
parseTime :: Text -> Either Text Timestamp
parseTime text =
  let
    parseTimeM :: String -> String -> Either Text Time.UTCTime
    parseTimeM = Time.parseTimeM False Time.defaultTimeLocale

    tryParse :: (String, Resolution) -> Either Text Timestamp
    tryParse (inFormat, resolution) = do
      time <- parseTimeM inFormat (T.unpack text)
      pure (Timestamp time resolution)
  in
    firstRightOr
      ("Cannot parse time \"" <> text <> "\"")
      (tryParse <$> timeFormats)

-- Formats a time for the website. All times are rendered in UTC in as much
-- detail as is available.
formatTime :: Timestamp -> Text
formatTime Timestamp{..} =
  let
    formatStr =
      case timestampResolution of
        Day -> "%Y-%m-%d"
        Hour -> "%Y-%m-%d %H"
        Minute -> "%Y-%m-%d %H:%M"
        Second -> "%Y-%m-%d %H:%M:%S"
        Fraction -> "%Y-%m-%d %H:%M:%S%Q"
  in
    T.pack (Time.formatTime Time.defaultTimeLocale formatStr timestampUtcTime)

-- The valid input time formats and their corresponding output formats.
timeFormats :: [(String, Resolution)]
timeFormats =
  -- UTC Times
  [ ("%Y-%m-%dT%H:%M:%S%QZ", Fraction)
  , ("%Y-%m-%dT%H:%M:%SZ", Second)
  , ("%Y-%m-%dT%H:%MZ", Minute)

  -- Zoned Times
  , ("%Y-%m-%dT%H:%M:%S%z", Second)
  , ("%Y-%m-%dT%H:%M%z", Minute)
  , ("%Y-%m-%d %H:%M%z", Minute)

  -- Dates
  , ("%Y-%m-%d", Day)
  ]

--------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------

firstRightOr :: err -> [Either e a] -> Either err a
firstRightOr err results =
  case viaNonEmpty head (rights results) of
    Nothing -> Left err
    Just a -> Right a

