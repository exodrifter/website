<?php
$pageSize = 4;
if(isset($_GET["page"])) {
	$page = (int)$_GET["page"];
} else {
	$page = 0;
}
$name = $_GET["category"];

$db = new \SQLite3($LAYOUT->path("../db/posts.sqlite"), SQLITE3_OPEN_READONLY);

$statement = $db->prepare("SELECT COUNT(*) FROM posts WHERE id_category IN (SELECT id_category FROM categories WHERE name=(:name))");
$statement->bindValue(":name",$name);
$maxPosts = $statement->execute()->fetchArray()[0];

if ($maxPosts == 0) {
	include("404.php");
	return;
}

$statement = $db->prepare("SELECT * FROM categories WHERE name=(:name)");
$statement->bindValue(":name",$name);
$result = $statement->execute()->fetchArray();
$content = <<<EOT
	<div class="container"><div class="row"><div class="12u">
	<div style="background-color: #484848; padding: 1em; margin-bottom: 2em">
	<p style="padding: 0; margin-bottom: .5em">You are viewing posts in the category "{$result["name"]}".</p>
	<p style="padding: 0; margin: 0; font-style: italic">{$result["description"]}</p>
	</div>
EOT;

$statement = $db->prepare("SELECT * FROM posts WHERE id_category IN (SELECT id_category FROM categories WHERE name=(:name)) ORDER BY date DESC LIMIT (:start),(:limit)");
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
	$content .= "<p style=\"float: left;\"><a href=\"".$url."archive/category/$name/".($page+1)."\">&lt;- older</a></p>";
}
if($page > 0) {
	if($page == 1) {
		$content .= "<p style=\"float: right;\"><a href=\"".$url."archive/category/$name/\">newer -&gt;</a></p>";
	} else {
		$content .= "<p style=\"float: right;\"><a href=\"".$url."archive/category/$name/".($page-1)."\">newer -&gt;</a></p>";
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
	$content .= "if(e.keyCode=='37'){url='".$url."archive/category/$name/".($page+1)."';}";
}
if($page > 0) {
	if($page == 1) {
		$content .= "if(e.keyCode=='39'){url='".$url."archive/category/$name/';}";
	} else {
		$content .= "if(e.keyCode=='39'){url='".$url."archive/category/$name/".($page-1)."';}";
	}
}
$content .= "if (url) { window.location = url; } } </script>";

$LAYOUT->set("content", $content);
$LAYOUT->set("title", "Category \"$name\"");
$LAYOUT->addcss("blog");

include $LAYOUT->path("template/base.php");
?>