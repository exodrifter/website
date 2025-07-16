<?php
namespace Pyrite;

require_once("pyrite-cfg.php");
require_once("pyrite-url.php");

class PyriteData {
	public static $db_posts;
	public static $db_games;
	public static $data_post_result;
	public static $data_post;
	public static $data_category_result;
	public static $data_category;
	public static $data_years_result;
	public static $data_years;
	public static $data_tags_result;
	public static $data_tags;
	public static $data_tumblr;
	public static $data_wordpress;
	public static $data_maxPosts;

	public static $data_game_result;
	public static $data_game;
	public static $data_status_result;
	public static $data_status;

	public static $parser;

	public static $page_title;
	public static $pagination;
	public static $temp;
}

////
// Init Functions
////

function openDBPosts() {
	PyriteData::$db_posts = new \SQLite3(getPathDBPosts(), SQLITE3_OPEN_READONLY);
}

function openDBGames() {
	PyriteData::$db_games = new \SQLite3(getPathDBGames(), SQLITE3_OPEN_READONLY);
}

function prepareBBCodeParser() {
	require_once("lib/bbcode.php");
	PyriteData::$parser = createBBCodeParser();
}

////
// Query Functions
////

function queryMaxPosts() {
	$statement = PyriteData::$db_posts->prepare("SELECT COUNT(*) FROM posts");
	PyriteData::$data_maxPosts = $statement->execute()->fetchArray();
}

function queryPost($id) {
	$statement = PyriteData::$db_posts->prepare("SELECT * FROM posts WHERE id_post=(:id)");
	$statement->bindValue(":id",$id);
	PyriteData::$data_post_result = $statement->execute();
}

function queryYears() {
	$statement = PyriteData::$db_posts->prepare("SELECT DISTINCT strftime('%Y', date) as Year FROM posts ORDER BY date DESC");
	PyriteData::$data_years_result = $statement->execute();
}

function queryTags($id_post=false) {
	if(!$id_post) {
		$statement = PyriteData::$db_posts->prepare("SELECT * FROM tags ORDER BY name ASC");
	} else {
		$statement = PyriteData::$db_posts->prepare("SELECT * FROM tags WHERE id_tag IN (SELECT id_tag FROM tagpairs WHERE id_post=(:id)) ORDER BY name ASC");
		$statement->bindValue(":id",$id_post);
	}
	PyriteData::$data_tags_result = $statement->execute();
}

function queryCategory($id_post=false) {
	if(!$id_post) {
		$statement = PyriteData::$db_posts->prepare("SELECT * FROM categories ORDER BY name ASC");
	} else {
		$statement = PyriteData::$db_posts->prepare("SELECT * FROM categories WHERE id_category IN (SELECT id_category FROM posts WHERE id_post=(:id))");
		$statement->bindValue(":id",$id_post);
	}
	PyriteData::$data_category_result = $statement->execute();
}

function queryTumblrID($id_post) {
	$statement = PyriteData::$db_posts->prepare("SELECT * FROM ext_tumblr WHERE id_post=(:id)");
	$statement->bindValue(":id",$id_post);
	PyriteData::$data_tumblr = $statement->execute()->fetchArray();
}

function queryWordpressID($id_wp) {
	$statement = PyriteData::$db_posts->prepare("SELECT * FROM ext_wp WHERE id_wp=(:id)");
	$statement->bindValue(":id",$id_wp);
	PyriteData::$data_wordpress = $statement->execute()->fetchArray();
}

function queryStatus($id_game=false) {
	if(!$id_game) {
		$statement = PyriteData::$db_games->prepare("SELECT * FROM statuses ORDER BY priority ASC");
	} else {
		$statement = PyriteData::$db_games->prepare("SELECT * FROM statuses WHERE id_status IN (SELECT id_status FROM games WHERE id_game=(:id))");
		$statement->bindValue(":id",$id_game);
	}
	PyriteData::$data_status_result = $statement->execute();
}

function queryPosts($start,$limit) {
	$statement = PyriteData::$db_posts->prepare("SELECT * FROM posts ORDER BY date DESC LIMIT (:start),(:limit)");
	$statement->bindValue(":start",$start);
	$statement->bindValue(":limit",$limit);
	PyriteData::$data_post_result = $statement->execute();
}

function queryGames() {
	$statement = PyriteData::$db_games->prepare("SELECT * FROM games ORDER BY date DESC");
	PyriteData::$data_game_result = $statement->execute();
}

function queryGamesWithStatus($status) {
	$statement = PyriteData::$db_games->prepare("SELECT * FROM games WHERE id_status=(:status) ORDER BY date DESC");
	$statement->bindValue(":status",$status);
	PyriteData::$data_game_result = $statement->execute();
}

function queryGamesWithShortname($shortname) {
	$statement = PyriteData::$db_games->prepare("SELECT * FROM games WHERE shortname=(:shortname)");
	$statement->bindValue(":shortname",$shortname);
	PyriteData::$data_game_result = $statement->execute();
}

function queryMaxPostsInCategory($name) {
	$statement = PyriteData::$db_posts->prepare("SELECT COUNT(*) FROM posts WHERE id_category IN (SELECT id_category FROM categories WHERE name=(:name))");
	$statement->bindValue(":name",$name);
	PyriteData::$data_maxPosts = $statement->execute()->fetchArray();
}

function queryPostsInCategory($name,$start,$limit) {
	$statement = PyriteData::$db_posts->prepare("SELECT * FROM posts WHERE id_category IN (SELECT id_category FROM categories WHERE name=(:name)) ORDER BY date DESC LIMIT (:start),(:limit)");
	$statement->bindValue(":name",$name);
	$statement->bindValue(":start",$start);
	$statement->bindValue(":limit",$limit);
	PyriteData::$data_post_result = $statement->execute();
}

function queryMaxPostsWithTag($name) {
	$statement = PyriteData::$db_posts->prepare("SELECT COUNT(*) FROM posts WHERE id_post IN (SELECT id_post FROM tagpairs WHERE id_tag IN (SELECT id_tag FROM tags WHERE name=(:name)))");
	$statement->bindValue(":name",$name);
	PyriteData::$data_maxPosts = $statement->execute()->fetchArray();
}

function queryPostsWithTag($name,$start,$limit) {
	$statement = PyriteData::$db_posts->prepare("SELECT * FROM posts WHERE id_post IN (SELECT id_post FROM tagpairs WHERE id_tag IN (SELECT id_tag FROM tags WHERE name=(:name))) ORDER BY date DESC LIMIT (:start),(:limit)");
	$statement->bindValue(":name",$name);
	$statement->bindValue(":start",$start);
	$statement->bindValue(":limit",$limit);
	PyriteData::$data_post_result = $statement->execute();
}

function queryMaxPostsInYear($year) {
	$statement = PyriteData::$db_posts->prepare("SELECT COUNT(*) FROM posts WHERE substr(date,1,4)=(:year) ORDER BY date DESC");
	$statement->bindValue(":year",$year);
	PyriteData::$data_maxPosts = $statement->execute()->fetchArray();
}

function queryPostsInYear($year,$start=false,$limit=false) {
	if(!$start || !$limit) {
		$limitQuery = "";
	} else {
		$limitQuery = "LIMIT (:start),(:limit)";
	}
	$statement = PyriteData::$db_posts->prepare("SELECT * FROM posts WHERE substr(date,1,4)=(:year) ORDER BY date DESC".$limitQuery);
	$statement->bindValue(":year",$year);
	if(!$start || !$limit) {
		$statement->bindValue(":start",$start);
		$statement->bindValue(":limit",$limit);
	}
	PyriteData::$data_post_result = $statement->execute();
}

function nextPost() {
	return PyriteData::$data_post = PyriteData::$data_post_result->fetchArray();
}

function nextGame() {
	return PyriteData::$data_game = PyriteData::$data_game_result->fetchArray();
}

function nextYear() {
	PyriteData::$data_years = PyriteData::$data_years_result->fetchArray();
	PyriteData::$data_years = PyriteData::$data_years["0"];
}

function nextTag() {
	return PyriteData::$data_tags = PyriteData::$data_tags_result->fetchArray();
}

function nextCategory() {
	return PyriteData::$data_category = PyriteData::$data_category_result->fetchArray();
}

function nextStatus() {
	return PyriteData::$data_status = PyriteData::$data_status_result->fetchArray();
}

////
// Special data init
////
function setPageTitle($title = "") {
	PyriteData::$page_title = PyriteConfig::BLOG_NAME;
	if(!empty($title)) {
		PyriteData::$page_title .= " - ".$title;
	}
}

////
// Getters
////

function getPostID() {
	return PyriteData::$data_post["id_post"];
}

function getPostTitle() {
	return PyriteData::$data_post["title"];
}

function getPostDate($format="Y-m-d H:i:s T") {
	$datetime = new \DateTime(PyriteData::$data_post["date"]);
	$datetime->setTimezone(new \DateTimeZone(PyriteConfig::TIMEZONE));
	return $datetime->format($format);
}

function getTumblrID() {
	return PyriteData::$data_tumblr["id_tumblr"];
}

function getWordpressID() {
	return PyriteData::$data_wordpress["id_post"];
}

function getMaxPosts() {
	return PyriteData::$data_maxPosts[0];
}

function getCategoryName() {
	return PyriteData::$data_category["name"];
}

function getCategoryDescription() {
	return PyriteData::$data_category["description"];
}

function getTagName() {
	return PyriteData::$data_tags["name"];
}

function getTagDescription() {
	return PyriteData::$data_tags["description"];
}

function getPostContent() {
	PyriteData::$parser->parse(PyriteData::$data_post["content"]);
	$str = PyriteData::$parser->getAsText();

	// Remove whitespace
	$patterns = array("/\s+/", "/\s([?.!])/");
	$replacer = array(" ","$1");
	$str = preg_replace($patterns, $replacer, $str);

	return $str;
}

function getGameAbout() {
	PyriteData::$parser->parse(PyriteData::$data_game["about"]);
	$str = PyriteData::$parser->getAsText();

	// Remove whitespace
	$patterns = array("/\s+/", "/\s([?.!])/");
	$replacer = array(" ","$1");
	$str = preg_replace($patterns, $replacer, $str);

	return $str;
}

function getGameID() {
	return PyriteData::$data_game["id_game"];
}

function getGameShortname() {
	return PyriteData::$data_game["shortname"];
}

function getGameDescription() {
	return PyriteData::$data_game["description"];
}
function getGameHasDescription() {
	return !empty(PyriteData::$data_game["description"]);
}

function getGameYoutube() {
	return PyriteData::$data_game["youtube"];
}

function getGameName() {
	return PyriteData::$data_game["name"];
}

function getGameTag() {
	return PyriteData::$data_game["id_tag"];
}

function getGameHasAbout() {
	return !empty(PyriteData::$data_game["about"]);
}

function getGameHasYoutube() {
	return !empty(PyriteData::$data_game["youtube"]);
}

function getGameHasTag() {
	return !empty(PyriteData::$data_game["id_tag"]);
}

function getGameHasLanguage() {
	return !empty(PyriteData::$data_game["language"]);
}

function getGameLanguage() {
	return PyriteData::$data_game["language"];
}

function getGameHasEngine() {
	return !empty(PyriteData::$data_game["engine"]);
}

function getGameEngine() {
	return PyriteData::$data_game["engine"];
}

function getStatusID() {
	return PyriteData::$data_status["id_status"];
}

function getStatusName() {
	return PyriteData::$data_status["name"];
}

function getStatusDescription() {
	return PyriteData::$data_status["description"];
}

////
// Put functions
////

function putTemplate($template) {
	require(getPathTheme().$template);
}

function putBlogName() {
	echo PyriteConfig::BLOG_NAME;
}

function putPageTitle() {
	echo PyriteData::$page_title;
}

function putPostTitle() {
	echo getPostTitle();
}

function putPostDate($format="Y-m-d H:i:s T") {
	$datetime = new \DateTime(PyriteData::$data_post["date"]);
	$datetime->setTimezone(new \DateTimeZone(PyriteConfig::TIMEZONE));
	echo $datetime->format($format);
}

function putPostContent() {
	PyriteData::$parser->parse(PyriteData::$data_post["content"]);
	$paragraphs = explode("\n", PyriteData::$parser->getAsHtml());
	
	foreach($paragraphs as $p) {
		if(substr($p,0,2) === "<p" || substr($p,0,3) === "<ul") {
			echo($p."\n");
		} else if(!empty($p) && !ctype_space($p)) {
			echo("<p>".$p."</p>\n");
		}
	}
}

function putGameAbout() {
	PyriteData::$parser->parse(PyriteData::$data_game["about"]);
	$paragraphs = explode("\n", PyriteData::$parser->getAsHtml());
	
	foreach($paragraphs as $p) {
		if(substr($p,0,2) === "<p" || substr($p,0,3) === "<ul") {
			echo($p."\n");
		} else if(!empty($p) && !ctype_space($p)) {
			echo("<p>".$p."</p>\n");
		}
	}
}
?>
