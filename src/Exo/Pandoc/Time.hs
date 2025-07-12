-- Helpers for dealing with time.
--
-- Generally, all of the times are rendered in UTC on the website, but the
-- source files have a variety of times in different formats.
module Exo.Pandoc.Time
( Time.UTCTime
, parseTime
, reformatTime

-- Helpers
, parseTimeM
, formatTime
) where

import qualified Data.Text as T
import qualified Data.Time as Time

-- My notes have accumulated a variety of different time formats over the years,
-- so this function tries several different formats until one of them works.
parseTime :: Text -> Either Text Time.UTCTime
parseTime text =
  firstRightOr
    ("Cannot parse time \"" <> text <> "\"")
    (flip parseTimeM text . fst <$> timeFormats)

-- Reformats a time for the website. All times are rendered in UTC in as much
-- detail as is available.
reformatTime :: Text -> Either Text Text
reformatTime text =
  let
    tryReformat :: (Text, Text) -> Either Text Text
    tryReformat (inFormat, outFormat) = do
      time <- parseTimeM inFormat text
      pure (formatTime outFormat time)
  in
    firstRightOr
      ("Cannot parse time \"" <> text <> "\"")
      (tryReformat <$> timeFormats)

-- The valid input time formats and their corresponding output formats.
timeFormats :: [(Text, Text)]
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

parseTimeM :: Text -> Text -> Either Text Time.UTCTime
parseTimeM format =
  Time.parseTimeM False Time.defaultTimeLocale (T.unpack format) . T.unpack

formatTime :: Text -> Time.UTCTime -> Text
formatTime format =
  T.pack . Time.formatTime Time.defaultTimeLocale (T.unpack format)
