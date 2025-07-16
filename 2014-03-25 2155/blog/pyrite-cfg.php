<?php
namespace Pyrite;

class PyriteConfig {
	const URL_BASE = "http://www.darwinpek.net/";
	const TIMEZONE = "America/Chicago";
	
	// Blog
	const BLOG_NAME = "@author dpek";
	const BLOG_THEME = "pyrite";
	const BLOG_INDEX_PAGINATION = 5;
	
	// Paths
	const PATH_BLOG = "blog/";
	const PATH_THEME = "blog/theme/";
	const PATH_IMAGE = "img/";
	const PATH_DB = "db/";

	// Database
	const DB_POSTS = "posts.sqlite";
	const DB_GAMES = "games.sqlite";
}
?>
