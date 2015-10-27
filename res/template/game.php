<?php
if(isset($_GET["game"])) {
	$shortname = $_GET["game"];
} else {
	include("404.php");
	return;
}
$url = $LAYOUT->base();

$db = new \SQLite3($LAYOUT->path("../db/posts.sqlite"), SQLITE3_OPEN_READONLY);
$gdb = new \SQLite3($LAYOUT->path("../db/games.sqlite"), SQLITE3_OPEN_READONLY);
$statement = $gdb->prepare("SELECT * FROM games WHERE shortname=(:shortname) ORDER BY date DESC");
$statement->bindValue(":shortname", $shortname);
$game = $statuses = $statement->execute()->fetchArray();

$parser = createBBCodeParser($LAYOUT);
if($game["about"]) {
	$parser->parse($game["about"]);
	$about = $parser->getAsHtml();
} else {
	include("404.php");
	return;
}

$youtube = "";
if($game["youtube"]) {
	$parser->parse("[youtube]{$game["youtube"]}[/youtube]");
	$youtube = $parser->getAsHtml();
}

$description = "";
if ($game["description"]) {
	$description = "<p><i>{$game["description"]}</i></p>";
}
$language = "";
if($game["language"]) {
	$language = "<p class='nospace'><b>Language:</b> {$game["language"]}</p>";
}
$engine = "";
if($game["engine"]) {
	$engine = "<p class='nospace'><b>Engine:</b> {$game["engine"]}</p>";
}

$posts = "";
if($game["id_tag"]) {
	$statement = $db->prepare("SELECT * FROM tags WHERE id_tag=(:id)");
	$statement->bindValue(":id",$game["id_tag"]);
	$name = $statement->execute()->fetchArray()["name"];
	$posts = "<p class='nospace'><a style='text-decoration:none' href='{$url}archive/tag/$name/'>Blog Posts</a></p>";
}

// Play links
$hadLinks = false;
$statement = $gdb->prepare("SELECT * FROM online WHERE id_game=(:id) ORDER BY date DESC");
$statement->bindValue(":id",$game["id_game"]);
$result = $statement->execute();
$playLinks = "";
if($online = $result->fetchArray()) {
	$hadLinks = true;
	$playLinks .= <<<EOT
	<hr class='divider' />
	<p class='nospace'><b>Play Links:</b></p>
	<div style="float: left"><p class='nospace'>Version</p></div>
	<div style="float: right"><p class='nospace'>Link</p></div>
	<div style='clear:both'></div>
EOT;
	do {
		$playLinks .= <<<EOT
		<div style="float: left"><p class='nospace'>{$online["version"]}</p></div>
		<div style="float: right"><p class='nospace'><a href='{$online["link"]}'>Play Now</a></p></div>
		<div style='clear:both'></div>
EOT;
	} while($online = $result->fetchArray());
}

// Downloads
$statement = $gdb->prepare("SELECT * FROM downloads WHERE id_game=(:id) ORDER BY date DESC");
$statement->bindValue(":id",$game["id_game"]);
$result = $statement->execute();
$downloadLinks = "";
if($download = $result->fetchArray()) {
	if($hadLinks) {
		$downloadLinks .= "<div style='padding:1em'></div>";
	} else {
		$downloadLinks .= "<hr class='divider' />";
	}
	$hadLinks = true;
	$downloadLinks .= <<<EOT
	<p class='nospace'><b>Downloads:</b></p>
	<div style="float: left"><p class='nospace'>Version</p></div>
	<div style="float: right"><p class='nospace'>Link</p></div>
	<div style='clear:both'></div>
EOT;
	do {
		$downloadLinks .= <<<EOT
		<div style="float: left"><p class='nospace'>{$download["version"]}</p></div>
		<div style="float: right"><p class='nospace'><a href='{$download["link"]}'>Download</a></p></div>
		<div style='clear:both'></div>
EOT;
	} while($download = $result->fetchArray());
}

// Sources
$statement = $gdb->prepare("SELECT * FROM sources WHERE id_game=(:id)");
$statement->bindValue(":id",$game["id_game"]);
$result = $statement->execute();
$sourceLinks = "";
if($source = $result->fetchArray()) {
	if($hadLinks) {
		$sourceLinks .= "<div style='padding:1em'></div>";
	} else {
		$sourceLinks .= "<hr class='divider' />";
	}
	$sourceLinks .= "<p class='nospace'><b>Source:</b> <a href='{$source["link"]}'>Access</a></p>";
}

$content = <<<EOT
<div class='container'><div class='focus'><div class='row'><section class='12u'>
<h1>{$game["name"]}</h1>
<img style="width: 100%; margin-bottom:1em" onerror='this.style.display="none"' src="{$url}res/img/game/{$game["shortname"]}/banner.png" />
</section></div>
<div class='row'>
<section class='9u'>
$youtube
<p>$about</p>
</section>
<section class='3u'>
<h2 class='sidebar-header'>Meta</h2>
$description
$language
$engine
$posts
$playLinks
$downloadLinks
$sourceLinks
</section></div></div></div>
EOT;

$LAYOUT->set("content", $content);
$LAYOUT->set("page", "post");
$LAYOUT->set("title", $game["name"]);
$LAYOUT->addcss("blog");

include $LAYOUT->path("template/base.php");

?>
