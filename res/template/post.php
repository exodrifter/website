<?php
$pageSize = 3;
if(isset($_GET["id"])) {
	$id = (int)$_GET["id"];
} else {
	$id = 0;
}
$db = new \SQLite3($LAYOUT->path("../db/posts.sqlite"), SQLITE3_OPEN_READONLY);

$statement = $db->prepare("SELECT COUNT(*) FROM posts");
$maxPosts = $statement->execute()->fetchArray()[0];

$statement = $db->prepare("SELECT * FROM posts WHERE id_post=(:id)");
$statement->bindValue(":id", $id);
$post = $statement->execute()->fetchArray();

$content = <<<EOT
<div class="container">
<div class="row">
<div class="12u">

EOT;

$datetime = new \DateTime($post["date"]);
$datetime->setTimezone(new \DateTimeZone("America/Chicago"));
$date = $datetime->format("Y-m-d H:i:s T");

// Parse post content
$parser = createBBCodeParser($LAYOUT);
$parser->parse($post["content"]);
$paragraphs = explode("\n", $parser->getAsHtml());

$text = "";
foreach($paragraphs as $p) {
	if(substr($p,0,2) === "<p" || substr($p,0,3) === "<ul") {
		$text .= $p."\n";
	} else if(!empty($p) && !ctype_space($p)) {
		$text .= "<p>".$p."</p>\n";
	}
}

$content .= <<<EOT
<div class="post">
	<h1>{$post["title"]}</h1>
	<p class='date'>{$date}</p>
	{$text}
</div>
EOT;

// Category and tags
$statement = $db->prepare("SELECT * FROM categories WHERE id_category IN (SELECT id_category FROM posts WHERE id_post=(:id))");
$statement->bindValue(":id",$id);
$cat = $statement->execute()->fetchArray()["name"];

$statement = $db->prepare("SELECT * FROM tags WHERE id_tag IN (SELECT id_tag FROM tagpairs WHERE id_post=(:id)) ORDER BY name ASC");
$statement->bindValue(":id", $id);
$tagResults = $statement->execute();

$tags = "";
while($tag = $tagResults->fetchArray()["name"]) {
	if($tags==="") {
		$tags .= "<a href='".$LAYOUT->base("archive/tag/".$tag)."/'>".$tag."</a>";
	} else {
		$tags .= ", <a href='".$LAYOUT->base("archive/tag/".$tag)."/'>".$tag."</a>";;
	}
}

$content .= <<<EOT
<p style="float: left;">
	[<a href="{$LAYOUT->base("archive/category/".strtolower($cat))}/">{$cat}</a>] {$tags}
</p>

EOT;

// Tumblr link
$statement = $db->prepare("SELECT * FROM ext_tumblr WHERE id_post=(:id)");
$statement->bindValue(":id",$id);
if($idtumblr = $statement->execute()->fetchArray()["id_tumblr"])
{
	$content .= <<<EOT
	<a href="http://dpek.tumblr.com/post/{$idtumblr}">
	<div class='tumblr' title='tumblr mirror' style="float: right;"></div>
	</a>

EOT;
}

$content .= "<div style=\"clear: both; margin-bottom: 3em;\"></div>";

// Navigation
$url = $LAYOUT->base();
if($id > 1) {
	$content .= "<p style=\"float: left;\"><a href=\"".$url."archive/post/".($id-1)."\">&lt;- older</a></p>";
}
if($id < $maxPosts) {
	$content .= "<p style=\"float: right;\"><a href=\"".$url."archive/post/".($id+1)."\">newer -&gt;</a></p>";
}

$content .= <<<EOT
<div style="clear:both; margin-bottom: 3em;"></div></div></div>

EOT;

// Key navigation
$content .= <<<EOT
<script>
document.onkeydown = checkKey;

function checkKey(e) {
	var url = false;
	e = e || window.event;

EOT;

if($id > 1) {
	$content .= "if(e.keyCode=='37'){url='".$url."archive/post/".($id-1)."';}";
}
if($id < $maxPosts) {
	$content .= "if(e.keyCode=='39'){url='".$url."archive/post/".($id+1)."';}";
}
$content .= "if (url) { window.location = url; } } </script>";

$LAYOUT->set("content", $content);
$LAYOUT->set("page", "post");
$LAYOUT->addcss("blog");

include $LAYOUT->path("template/base.php");

?>
</div>