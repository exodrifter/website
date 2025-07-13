-- Helpers for dealing with time.
--
-- Generally, all of the times are rendered in UTC on the website, but the
-- source files have a variety of times in different formats.
module Exo.Pandoc.Time
( Time.UTCTime
, parseTime
, reformatTime
, formatTime
) where

import qualified Data.Text as T
import qualified Data.Time as Time

-- My notes have accumulated a variety of different time formats over the years,
-- so this function tries several different formats until one of them works.
parseTime :: Text -> Either Text (Time.UTCTime, String)
parseTime text =
  let
    parseTimeM :: String -> String -> Either Text Time.UTCTime
    parseTimeM = Time.parseTimeM False Time.defaultTimeLocale

    tryParse :: (String, String) -> Either Text (Time.UTCTime, String)
    tryParse (inFormat, outFormat) = do
      time <- parseTimeM inFormat (T.unpack text)
      pure (time, outFormat)
  in
    firstRightOr
      ("Cannot parse time \"" <> text <> "\"")
      (tryParse <$> timeFormats)

-- Formats a time for the website. All times are rendered in UTC in as much
-- detail as is available.
formatTime :: (Time.UTCTime, String) -> Text
formatTime (time, outFormat) =
  T.pack (Time.formatTime Time.defaultTimeLocale outFormat time)

-- Reformats a time.
reformatTime :: Text -> Either Text Text
reformatTime = fmap formatTime . parseTime

-- The valid input time formats and their corresponding output formats.
timeFormats :: [(String, String)]
timeFormats =
  -- UTC Times
  [ ("%Y-%m-%dT%H:%M:%S%QZ", "%Y-%m-%d %H:%M:%S")
  , ("%Y-%m-%dT%H:%M:%SZ", "%Y-%m-%d %H:%M:%S")
  , ("%Y-%m-%dT%H:%MZ", "%Y-%m-%d %H:%M")

  -- Zoned Times
  , ("%Y-%m-%dT%H:%M:%S%z", "%Y-%m-%d %H:%M:%S")
  , ("%Y-%m-%dT%H:%M%z", "%Y-%m-%d %H:%M")
  , ("%Y-%m-%d %H:%M%z", "%Y-%m-%d %H:%M")

  -- Dates
  , ("%Y-%m-%d", "%Y-%m-%d")
  ]

--------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------

firstRightOr :: err -> [Either e a] -> Either err a
firstRightOr err results =
  case viaNonEmpty head (rights results) of
    Nothing -> Left err
    Just a -> Right a

