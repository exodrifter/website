<?php
$pageSize = 3;
if(isset($_GET["page"])) {
	$page = (int)$_GET["page"];
} else {
	$page = 0;
}

$db = new \SQLite3($LAYOUT->path("../db/posts.sqlite"), SQLITE3_OPEN_READONLY);

$statement = $db->prepare("SELECT COUNT(*) FROM posts");
$maxPosts = $statement->execute()->fetchArray()[0];

$statement = $db->prepare("SELECT * FROM posts ORDER BY date DESC LIMIT (:start),(:limit)");
$statement->bindValue(":start", $page*$pageSize);
$statement->bindValue(":limit", $pageSize);
$posts = $statement->execute();

$content = <<<EOT
<div class="container">
<div class="row">
<div class="9u 12u$(medium) 12u$(small)">

EOT;

while($post = $posts->fetchArray())
{
	$datetime = new \DateTime($post["date"]);
	$datetime->setTimezone(new \DateTimeZone("America/Chicago"));
	$date = $datetime->format("Y-m-d H:i:s T");

	// Parse post content
	$parser = createBBCodeParser($LAYOUT);
	$parser->parse($post["content"]);
	$text = $parser->getAsText();

	// Remove whitespace
	$patterns = array("/\s+/", "/\s([?.!])/");
	$replacer = array(" ","$1");
	$text = preg_replace($patterns, $replacer, $text);

	// Limit to 300 characters, but only cut at the nearest word
	$text = preg_replace('/\s+?(\S+)?$/', '', substr($text, 0, 300));

	$content .= <<<EOT
<div class="post">
	<h1><a href="{$LAYOUT->base()}archive/post/{$post["id_post"]}">{$post["title"]}</a></h1>
	<p class='date'>{$date}</p>
	<p class='summary'>{$text}
	<a style='text-decoration:none' href='{$LAYOUT->base()}archive/post/{$post["id_post"]}'>[...]</a></p>
</div>
EOT;
}

// Navigation
$url = $LAYOUT->base();
if($page*$pageSize < $maxPosts-$pageSize) {
	$content .= "<p style=\"float: left;\"><a href=\"".$url."archive/".($page+1)."\">&lt;- older</a></p>";
}
if($page > 0) {
	if($page == 1) {
		$content .= "<p style=\"float: right;\"><a href=\"".$url."blog/\">newer -&gt;</a></p>";
	} else {
		$content .= "<p style=\"float: right;\"><a href=\"".$url."archive/".($page-1)."\">newer -&gt;</a></p>";
	}
}

// Sidebar
$content .= <<<EOT
</div>
<div class="3u 12u$(medium) 12u$(small)">
	<h1>Meta</h1>
	<p><a href="{$LAYOUT->base()}archive/">Archive</a></p>
	<!--<p><a href="{$LAYOUT->base()}rss">RSS</a></p>-->
</div></div></div>

EOT;

// Key navigation
$content .= <<<EOT
<script>
document.onkeydown = checkKey;

function checkKey(e) {
	var url = false;
	e = e || window.event;

EOT;

if($page*$pageSize < $maxPosts-$pageSize) {
	$content .= "if(e.keyCode=='37'){url='".$url."archive/".($page+1)."';}";
}
if($page > 0) {
	if($page == 1) {
		$content .= "if(e.keyCode=='39'){url='".$url."blog/';}";
	} else {
		$content .= "if(e.keyCode=='39'){url='".$url."archive/".($page-1)."';}";
	}
}
$content .= "if (url) { window.location = url; } } </script>";

$LAYOUT->set("content", $content);
$LAYOUT->set("page", "blog");
$LAYOUT->addcss("blog");

include $LAYOUT->path("template/base.php");
?>
