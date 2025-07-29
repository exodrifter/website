{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE MultiParamTypeClasses #-}

-- Helpers for dealing with time.
--
-- Generally, all of the times are rendered in UTC on the website, but the
-- source files have a variety of times in different formats.
module Exo.Pandoc.Time
( Timestamp(..)
, Resolution(..)
, parseTime
) where

import qualified Data.Aeson as Aeson
import qualified Data.Text as T
import qualified Data.Time as Time
import qualified Text.DocTemplates as DocTemplates

--------------------------------------------------------------------------------
-- Timestamp
--------------------------------------------------------------------------------

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

instance DocTemplates.ToContext Text Timestamp where
  toVal timestamp =
    let
      formatTime :: Resolution -> Timestamp -> Text
      formatTime maxResolution Timestamp{..} =
        T.pack
          ( Time.formatTime
              Time.defaultTimeLocale
              (formatStr (min maxResolution timestampResolution))
              timestampUtcTime
          )

      toClampedVal :: Resolution -> DocTemplates.Val Text
      toClampedVal a = DocTemplates.toVal (formatTime a timestamp)

      items = fromList
        [ ("day", toClampedVal Day)
        , ("hour", toClampedVal Hour)
        , ("minute", toClampedVal Minute)
        , ("second", toClampedVal Second)
        , ("fraction", toClampedVal Fraction)
        ]

    in
      DocTemplates.MapVal (DocTemplates.Context items)

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

--------------------------------------------------------------------------------
-- Resolution
--------------------------------------------------------------------------------

-- The resolution of a timestamp.
data Resolution =
    Day
  | Hour
  | Minute
  | Second
  | Fraction
  deriving stock (Eq, Generic, Ord, Show)

instance Aeson.FromJSON Resolution
instance Aeson.ToJSON Resolution

-- Returns the format string for the specified resolution.
formatStr :: Resolution -> String
formatStr resolution =
  case resolution of
    Day -> "%Y-%m-%d"
    Hour -> "%Y-%m-%d %H"
    Minute -> "%Y-%m-%d %H:%M"
    Second -> "%Y-%m-%d %H:%M:%S"
    Fraction -> "%Y-%m-%d %H:%M:%S%Q"

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
