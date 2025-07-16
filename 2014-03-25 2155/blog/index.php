<?php
namespace Pyrite;
require_once("pyrite.php");

// Init
openDBPosts();
prepareBBCodeParser();
if(isset($_GET["page"])) {
	PyriteData::$pagination = (int)$_GET["page"];
}

// Query
queryPosts(PyriteData::$pagination*PyriteConfig::BLOG_INDEX_PAGINATION,PyriteConfig::BLOG_INDEX_PAGINATION);
queryMaxPosts();
$result = nextPost();

if(!$result) {
	setPageTitle("404");
	putTemplate("404.php");
} else {
	setPageTitle();
	putTemplate("index.php");
}

?>