-- Stores constants for building the website.
module Exo.Const
( outputDirectory
, contentDirectory
) where

-- The directory where the website will be generated.
outputDirectory :: FilePath
outputDirectory = "_site"

-- The directory where the website content is stored.
contentDirectory :: FilePath
contentDirectory = "content"
