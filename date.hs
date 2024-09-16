#!/usr/bin/env stack
{- stack runghc
    --resolver lts-21.1
    --package aeson
    --package aeson-pretty
    --package bytestring
    --package containers
    --package filemanip
    --package non-empty-text
    --package relude
    --package req
    --package safe
    --package text
    --package timespan
    --package turtle
    --package tz
-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# OPTIONS_GHC -Wall #-}

import Relude

import Control.Monad.Catch (MonadThrow)
import Data.Aeson ((.:), (.=))
import Network.HTTP.Req ((/:), (=:))
import System.FilePath.Find ((==?))
import qualified Data.Aeson as Aeson
import qualified Data.Aeson.Encode.Pretty as Aeson
import qualified Data.ByteString.Char8 as BS8
import qualified Data.ByteString.Lazy as LBS
import qualified Data.NonEmptyText as NET
import qualified Data.Set as Set
import qualified Data.Text as T
import qualified Data.Text.IO as TIO
import qualified Data.Text.Encoding as TE
import qualified Data.Time as Time
import qualified Data.Time.TimeSpan as TimeSpan
import qualified Network.HTTP.Client as HTTP
import qualified Network.HTTP.Client.TLS as HTTP
import qualified Network.HTTP.Req as Req
import qualified Safe
import qualified Turtle
import qualified System.FilePath.Find as Find
import qualified System.FilePath as FilePath

toBS :: Text -> BS8.ByteString
toBS = TE.encodeUtf8

toLBS :: Text -> LBS.ByteString
toLBS = LBS.fromStrict . TE.encodeUtf8

fromLBS :: LBS.ByteString -> Text
fromLBS = TE.decodeUtf8 . LBS.toStrict

showText :: Show a => a -> Text
showText = T.pack . show

main :: IO ()
main = do
  files <- Find.find (pure True) (Find.extension ==? ".md") "content/entries"
  traverse_ migrateFile files

migrateFile :: FilePath -> IO ()
migrateFile filepath = do
  let file = T.pack (FilePath.dropExtension (FilePath.takeFileName filepath))
  case toTimestamp file of
    Just created -> do
      fileContents <- TIO.readFile filepath
      TIO.writeFile filepath (
        "---\n" <>
        "created: " <> created <> "\n" <>
        "---\n\n" <>
        fileContents)
    Nothing -> do
      die $ "Cannot determine time for " <> filepath

toTimestamp :: T.Text -> Maybe T.Text
toTimestamp text =
  case T.split (== '_') text of
    [date, time] | T.length time == 4 ->
      Just (
        slice 0 4 date <> "-" <> slice 4 6 date <> "-" <> slice 6 8 date <> "T" <>
        slice 0 2 time <> ":" <> slice 2 4 time <> "Z"
      )
    [date, time] | T.length time == 6 ->
      Just (
        slice 0 4 date <> "-" <> slice 4 6 date <> "-" <> slice 6 8 date <> "T" <>
        slice 0 2 time <> ":" <> slice 2 4 time <> ":" <> slice 4 6 time <> "Z"
      )
    _ ->
      Nothing

slice :: Int -> Int -> T.Text -> T.Text
slice start end text =
  T.take (end - start) (T.drop start text)
