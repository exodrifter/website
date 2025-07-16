<?php
namespace Pyrite;
require_once("pyrite.php");

// Get the mode
$mode = "";
if(isset($_GET["tag"])) {
	$mode = "t";
}
else if(isset($_GET["category"])) {
	$mode = "c";
}
else if(isset($_GET["post"])) {
	$mode = "p";
}
else if(isset($_GET["year"])) {
	$mode = "y";
}
else if(isset($_GET["wp"])) {
	openDBPosts();
	queryWordpressID($_GET["wp"]);
	putTemplate("archive-wp.php");
	die();
}

// Get the page
PyriteData::$pagination = 0;
if(isset($_GET["page"])) {
	PyriteData::$pagination = (int) $_GET["page"];
}

// Init
openDBPosts();
prepareBBCodeParser();

// Overall Query
queryMaxPosts();

if($mode==="p") {
	$result = false;
	if(isset($_GET["post"])) {
		$id_post = $_GET["post"];
		queryPost($id_post);
		$result = nextPost();
	}

	if(!$result) {
		setPageTitle("404");
		putTemplate("404.php");
	} else {
		setPageTitle(getPostTitle());
		putTemplate("archive-post.php");
	}
} else if($mode==="c") {
	$result = false;
	if(isset($_GET["category"])) {
		$category = $_GET["category"];
		queryPostsInCategory(ucfirst($category),PyriteData::$pagination*PyriteConfig::BLOG_INDEX_PAGINATION,PyriteConfig::BLOG_INDEX_PAGINATION);
		queryMaxPostsInCategory(ucfirst($category));
		$result = nextPost();
	}
	PyriteData::$temp = $category;

	if(!$result) {
		setPageTitle("404");
		putTemplate("404.php");
	} else {
		setPageTitle("Posts in category ".$category);
		putTemplate("archive-category.php");
	}
} else if($mode==="t") {
	$result = false;
	if(isset($_GET["tag"])) {
		$tag = $_GET["tag"];
		queryPostsWithTag($tag,PyriteData::$pagination*PyriteConfig::BLOG_INDEX_PAGINATION,PyriteConfig::BLOG_INDEX_PAGINATION);
		queryMaxPostsWithTag($tag);
		$result = nextPost();
	}
	PyriteData::$temp = $tag;

	if(!$result) {
		setPageTitle("404");
		putTemplate("404.php");
	} else {
		setPageTitle("Posts with tag ".$tag);
		putTemplate("archive-tag.php");
	}
} else if($mode==="y") {
	$result = false;
	if(isset($_GET["year"])) {
		$year = $_GET["year"];
		queryPostsInYear($year);
		queryMaxPostsInYear($year);
		$result = nextPost();
	}
	PyriteData::$temp = $year;

	if(!$result) {
		setPageTitle("404");
		putTemplate("404.php");
	} else {
		setPageTitle("Posts in year ".$year);
		putTemplate("archive-year.php");
	}
} else {
	setPageTitle("Archive");
	putTemplate("archive-none.php");
}
?>
