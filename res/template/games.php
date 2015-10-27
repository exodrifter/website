<?php
$db = new \SQLite3($LAYOUT->path("../db/posts.sqlite"), SQLITE3_OPEN_READONLY);
$gdb = new \SQLite3($LAYOUT->path("../db/games.sqlite"), SQLITE3_OPEN_READONLY);
$statement = $gdb->prepare("SELECT * FROM statuses ORDER BY priority ASC");
$statuses = $statement->execute();
$url = $LAYOUT->base();

$content = "";
while($status = $statuses->fetchArray()) {
	$content .= <<<EOT
	<h1>{$status["name"]}</h1>
	<p><i>{$status["description"]}</i></p>
	<ul>
EOT;

	$statement = $gdb->prepare("SELECT * FROM games WHERE id_status=(:id_status) ORDER BY date DESC");
	$statement->bindValue(":id_status", $status["id_status"]);
	$games = $statement->execute();
	while($game = $games->fetchArray()) {
		$dash = false;

		if(1 === $game["featured"]) { $content .= "<li><b>{$game["name"]}</b>"; }
		else { $content .= "<li style='color: #aaa'>{$game["name"]}"; }

		if($game["about"]) {
			if(!$dash) { $dash=true; $content .= " - "; }
			$content .= "<a href='{$url}game/{$game["shortname"]}/'>About</a>";
		}
		if($game["id_tag"]) {
			if(!$dash) { $dash=true; $content .= " - "; }
			else { $content .= ", "; }
			$statement = $db->prepare("SELECT * FROM tags WHERE id_tag=(:id)");
			$statement->bindValue(":id",$game["id_tag"]);
			$name = $statement->execute()->fetchArray()["name"];
			$content .= "<a href='{$url}archive/tag/$name/'>Blog Posts</a>";
		}
		$content .= "</li>";
	}

	$content .= "</ul>";
}


$content = <<<EOT
<div class="container"><div class="row"><div class="12u">
$content
</div></div></div>
EOT;

$LAYOUT->set("content", $content);
$LAYOUT->set("page", "game");

include $LAYOUT->path("template/base.php");
?>
