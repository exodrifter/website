-- Stores constants for building the website.
module Exo.Const
( outputDirectory
, contentDirectory
, baseUrl
) where

-- The directory where the website will be generated.
outputDirectory :: FilePath
outputDirectory = "_site"

-- The directory where the website content is stored.
contentDirectory :: FilePath
contentDirectory = "content"

-- The base URL of the website.
baseUrl :: Text
baseUrl = "https://www.exodrifter.space"
