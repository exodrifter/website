<?php
$pageSize = 4;
if(isset($_GET["page"])) {
	$page = (int)$_GET["page"];
} else {
	$page = 0;
}
$name = $_GET["tag"];

$db = new \SQLite3($LAYOUT->path("../db/posts.sqlite"), SQLITE3_OPEN_READONLY);

$statement = $db->prepare("SELECT COUNT(*) FROM posts WHERE id_post IN (SELECT id_post FROM tagpairs WHERE id_tag IN (SELECT id_tag FROM tags WHERE name=(:name)))");
$statement->bindValue(":name",$name);
$maxPosts = $statement->execute()->fetchArray()[0];

if ($maxPosts == 0) {
	include("404.php");
	return;
}

$gdb = new \SQLite3($LAYOUT->path("../db/games.sqlite"), SQLITE3_OPEN_READONLY);
$statement = $gdb->prepare("SELECT * FROM games WHERE shortname=(:shortname) ORDER BY date DESC");
$statement->bindValue(":shortname",$name);
$game = $statement->execute()->fetchArray();
$url = $LAYOUT->base();
if ($game && $game["about"]) {
	$content = <<<EOT
	<div class="container"><div class="row"><div class="12u">
	<a href="{$url}game/$name"><img style="width:100%" src="{$url}res/img/game/$name/banner.png" /></a>
	<div style="background-color: #484848; padding: 1em; margin-bottom: 2em">
	<p style="padding: 0; margin: 0">You are viewing posts tagged "$name".
	Read more about {$game["name"]} <a href="{$url}game/$name">here</a>.</p>
	</div>
EOT;
} else {
	$content = <<<EOT
	<div class="container"><div class="row"><div class="12u">

	<div style="background-color: #484848; padding: 1em; margin-bottom: 2em">
	<p style="padding: 0; margin: 0">You are viewing posts tagged "$name".</p>
	</div>
EOT;
}

$statement = $db->prepare("SELECT * FROM posts WHERE id_post IN (SELECT id_post FROM tagpairs WHERE id_tag IN (SELECT id_tag FROM tags WHERE name=(:name))) ORDER BY date DESC LIMIT (:start),(:limit)");
$statement->bindValue(":name", $name);
$statement->bindValue(":start", $page*$pageSize);
$statement->bindValue(":limit", $pageSize);
$result = $statement->execute();

while ($post = $result->fetchArray()) {
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
	$content .= "<p style=\"float: left;\"><a href=\"".$url."archive/tag/$name/".($page+1)."\">&lt;- older</a></p>";
}
if($page > 0) {
	if($page == 1) {
		$content .= "<p style=\"float: right;\"><a href=\"".$url."archive/tag/$name/\">newer -&gt;</a></p>";
	} else {
		$content .= "<p style=\"float: right;\"><a href=\"".$url."archive/tag/$name/".($page-1)."\">newer -&gt;</a></p>";
	}
}

$content .= <<<EOT
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
	$content .= "if(e.keyCode=='37'){url='".$url."archive/tag/$name/".($page+1)."';}";
}
if($page > 0) {
	if($page == 1) {
		$content .= "if(e.keyCode=='39'){url='".$url."archive/tag/$name/';}";
	} else {
		$content .= "if(e.keyCode=='39'){url='".$url."archive/tag/$name/".($page-1)."';}";
	}
}
$content .= "if (url) { window.location = url; } } </script>";

$LAYOUT->set("content", $content);
$LAYOUT->set("title", "Tag \"$name\"");
$LAYOUT->addcss("blog");

include $LAYOUT->path("template/base.php");
?>