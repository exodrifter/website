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
$statement->bindValue(":id",$id);
$post = $statement->execute()->fetchArray();

$content = <<<EOT
<div class='focus'>

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
/*echo("<p class='align-left'>");
$tags = "";
while(nextTag()) {
	$tag = getTagName();
	if($tags==="") {
		$tags .= "<a href='".getURLBlog()."archive/tag/".$tag."'>".$tag."</a>";
	} else {
		$tags .= ", <a href='".getURLBlog()."archive/tag/".$tag."'>".$tag."</a>";;
	}
}
echo "[<a href='".getURLBlog()."archive/category/".strtolower($cat)."'>".$cat."</a>] ".$tags;
echo "</p>\n";

// Tumblr link
if($id = getTumblrID())
{
	echo("<a href='http://dpek.tumblr.com/post/".$id."'>");
	echo("<div class='tumblr align-right' title='tumblr mirror' class=align-right></div>");
	echo("</a>\n");
}*/

// Navigation
$url = $LAYOUT->base();
if($id > 1) {
	$content .= "<p style=\"float: left;\"><a href=\"".$url."archive/post/".($id-1)."\">&lt;- older</a></p>";
}
if($id < $maxPosts) {
	$content .= "<p style=\"float: right;\"><a href=\"".$url."archive/post/".($id+1)."\">newer -&gt;</a></p>";
}

$content .= <<<EOT
<div style="clear:both;"></div></div></div>

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