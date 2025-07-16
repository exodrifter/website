<?php
namespace Pyrite;

function getURLBase() {
	return PyriteConfig::URL_BASE;
}

function getURLBlog() {
	return getURLBase().PyriteConfig::PATH_BLOG;
}

function getURLTheme() {
	return getURLBase().PyriteConfig::PATH_THEME.PyriteConfig::BLOG_THEME."/";
}

function getURLImage() {
	return getURLBase().PyriteConfig::PATH_IMAGE;
}

function getPathBase() {
	return dirname(dirname(__FILE__)).DIRECTORY_SEPARATOR;
}

function getPathDB() {
	return getPathBase().PyriteConfig::PATH_DB;
}

function getPathDBPosts() {
	return getPathDB().PyriteConfig::DB_POSTS;
}

function getPathDBGames() {
	return getPathDB().PyriteConfig::DB_GAMES;
}

function getPathTheme() {
	return getPathBase().PyriteConfig::PATH_THEME.PyriteConfig::BLOG_THEME.DIRECTORY_SEPARATOR;
}

?>