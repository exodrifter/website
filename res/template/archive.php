<?php
$db = new \SQLite3($LAYOUT->path("../db/posts.sqlite"), SQLITE3_OPEN_READONLY);

$content = <<<EOT
<div class="container"><div class="row"><div class="12u">
<h1>Archive</h1><hr />
EOT;

$statement = $db->prepare("SELECT * FROM categories ORDER BY name ASC");
$result = $statement->execute();
$str = "<p>";
while ($cat = $result->fetchArray()) {
	$str .= "<a href=\"tag/".strtolower($cat["name"])."\">".$cat["name"]."</a>, ";
}
$str = substr($str, 0, strlen($str)-2)."</p>";
$content .= <<<EOT
<h2>Categories</h2>$str
<p></p>
EOT;

$statement = $db->prepare("SELECT * FROM tags ORDER BY name ASC");
$result = $statement->execute();
$str = "<p>";
while ($tag = $result->fetchArray()) {
	$str .= "<a href=\"tag/".$tag["name"]."\">".$tag["name"]."</a>, ";
}
$str = substr($str, 0, strlen($str)-2)."</p>";
$content .= <<<EOT
<h2>Tags</h2>$str
<p></p>
EOT;

$statement = $db->prepare("SELECT DISTINCT strftime('%Y', date) as Year FROM posts ORDER BY date DESC");
$result = $statement->execute();
$str = "<p>";
while ($year = $result->fetchArray()["0"]) {
	$str .= "<a href=\"year/$year\">".$year."</a>, ";
}
$str = substr($str, 0, strlen($str)-2)."</p>";
$content .= <<<EOT
<h2>Years</h2>$str
EOT;

$content .= <<<EOT
</div></div></div>
EOT;

$LAYOUT->set("content", $content);
$LAYOUT->addcss("blog");

include $LAYOUT->path("template/base.php");
?>