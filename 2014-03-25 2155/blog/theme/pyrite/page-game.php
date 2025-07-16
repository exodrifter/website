<?php namespace Pyrite;
putTemplate("header.php");
openDBPosts();
?>
<div class='container'>
<div class='focus'>
<div class='row'><section class='12u'>
<h1><?php echo(getGameName()); ?></h1>
<img class='banner' onerror='this.style.display="none";' src='<?php echo(getURLBase()."img/game/".getGameShortname()); ?>/banner.png'></img>
</section></div>
<div class='row'>
<section class='9u'>
<?php
if(getGameHasYoutube()) {
	PyriteData::$parser->parse("[youtube]".getGameYoutube()."[/youtube]");
	echo(PyriteData::$parser->getAsHtml());
}
putGameAbout();
?>
</section>
<section class='3u'>
<h2 class='sidebar-header'>Meta</h2>
<?php
if(getGameHasDescription()) {
	echo("<p><i>".getGameDescription()."</i></p>");
}
if(getGameHasLanguage()) {
	echo("<p class='nospace'><b>Language:</b> ".getGameLanguage()."</p>");
}
if(getGameHasEngine()) {
	echo("<p class='nospace'><b>Engine:</b> ".getGameEngine()."</p>");
}
if((getGameHasEngine() || getGameHasLanguage()) && getGameHasTag()) {
	//echo("<hr class='divider' />");
}
if(getGameHasTag()) {
	$statement = PyriteData::$db_posts->prepare("SELECT * FROM tags WHERE id_tag=(:id)");
	$statement->bindValue(":id",getGameTag());
	$name = $statement->execute()->fetchArray();
	$name = $name["name"];
	echo("<p class='nospace'><a style='text-decoration:none' href='".getURLBlog()."archive/tag/".$name."'>Blog Posts</a></p>");
}
// Play links
$hadLinks = false;
$statement = PyriteData::$db_games->prepare("SELECT * FROM online WHERE id_game=(:id) ORDER BY date DESC LIMIT 3");
$statement->bindValue(":id",getGameID());
$results = $statement->execute();
if($row = $results->fetchArray()) {
	$hadLinks = true;
	echo("<hr class='divider' />");
	echo("<p class='nospace'><b>Play Links:</b></p>");
	echo("<div class='align-left'><p class='nospace'>Version</p></div>");
	echo("<div class='align-right'><p class='nospace'>Link</p></div>");
	echo("<div style='clear:both'></div>");
	do {
		echo("<div class='align-left'><p class='nospace'>".$row["version"]."</p></div>");
		echo("<div class='align-right'><p class='nospace'><a href='".$row["link"]."'>Play Now</a></p></div>");
		echo("<div style='clear:both'></div>");
	} while($row = $results->fetchArray());
}
// Downloads
$statement = PyriteData::$db_games->prepare("SELECT * FROM downloads WHERE id_game=(:id) ORDER BY date DESC LIMIT 3");
$statement->bindValue(":id",getGameID());
$results = $statement->execute();
if($row = $results->fetchArray()) {
	if($hadLinks) {
		echo("<div style='padding:1em'></div>");
	} else {
		echo("<hr class='divider' />");
	}
	$hadLinks = true;
	echo("<p class='nospace'><b>Downloads:</b></p>");
	echo("<div class='align-left'><p class='nospace'>Version</p></div>");
	echo("<div class='align-right'><p class='nospace'>Link</p></div>");
	echo("<div style='clear:both'></div>");
	do {
		echo("<div class='align-left'><p class='nospace'>".$row["version"]."</p></div>");
		echo("<div class='align-right'><p class='nospace'><a href='".$row["link"]."'>Download</a></p></div>");
		echo("<div style='clear:both'></div>");
	} while($row = $results->fetchArray());
}
// Sources
$statement = PyriteData::$db_games->prepare("SELECT * FROM sources WHERE id_game=(:id)");
$statement->bindValue(":id",getGameID());
$results = $statement->execute();
if($row = $results->fetchArray()) {
	if($hadLinks) {
		echo("<div style='padding:1em'></div>");
	} else {
		echo("<hr class='divider' />");
	}
	echo("<p class='nospace'><b>Source:</b> <a href='".$row["link"]."'>Access</a></p>");
}
?>
</section>
</div>
</div>
</div>
<?php putTemplate("footer.php"); ?>
