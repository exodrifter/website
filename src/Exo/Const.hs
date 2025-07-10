module Exo.Const
( outputDirectory
, contentDirectory
, staticDirectory
) where

-- The directory where the website will be generated.
outputDirectory :: FilePath
outputDirectory = "_site"

-- The directory where the website content is stored. This does not include
-- assets used to create the website, like templates or stylesheets, since
-- this folder is just where I store all of my notes and I don't normally want
-- to edit those kinds of files when I'm taking notes.
contentDirectory :: FilePath
contentDirectory = "content"

-- The directory where static website assets used to create the website is
-- stored, like templates or stylesheets.
staticDirectory :: FilePath
staticDirectory = "static"
