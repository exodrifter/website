<?php
echo("<!DOCTYPE html>
<html>
<head>
<style>
.wrapper {
	padding: 0 2em 5em 2em;
}
body {
	width: 1000px;
	max-width: 100%;
	margin: 0 auto;
}
table {
	border-collapse: collapse;
}
th {
	border-bottom: 1px solid #ddd;
	background-color: #444;
	color: white;
	text-weight: bold;
}
th a {
	color: white;
	text-weight: bold;
	text-decoration: none;
}
tr {
	border-bottom: 1px solid #ddd;
	text-align: center;
}
tr:nth-last-child(1) {
	background-color: #ffc !important;
}
tr:nth-child(even) {
	background-color: #eee;
}
td:nth-child(1) {
	font-style: italic;
}
th, td {
	padding: .3em 1em .3em 1em;
}
</style>
</head>
<body><div class='wrapper'>");
echo("<h1>Agricola</h1>");
$db = new \SQLite3("std.sqlite", SQLITE3_OPEN_READONLY);

$statement = $db->prepare("SELECT COUNT(*) as count FROM agricola");
$num_played = $statement->execute()->fetchArray()[0];

echo("<p>Games Recorded: {$num_played}</p>");

// Get game ids
$statement = $db->prepare("SELECT id_game FROM agricola ORDER BY id_game DESC");
$games = $statement->execute();

while ($id = $games->fetchArray(SQLITE3_ASSOC)["id_game"])
{
	// Get number of players
	$statement = $db->prepare(
		"SELECT agricola.id_game, agricola.date, variation_name,
			COUNT(*) AS count FROM agricola_scores
		 INNER JOIN agricola on agricola.id_game=agricola_scores.id_game
		 INNER JOIN agricola_variations on agricola.id_variation=agricola_variations.id_variation
		 WHERE agricola.id_game=(:id)"
	);
	$statement->bindValue(":id", $id, SQLITE3_INTEGER);
	$game = $statement->execute()->fetchArray(SQLITE3_ASSOC);

	// Print game metadata
	echo("<hr />");
	echo("<p>ID: {$game["id_game"]}</p>");
	echo("<p>Date: {$game["date"]}</p>");
	echo("<p>Num Players: {$game["count"]}</p>");
	echo("<p>Variation: {$game["variation_name"]}</p>");

	// Get winners
	$statement = $db->prepare(
		"SELECT players.id_player, first_name, last_name, middle_name
		 FROM agricola_scores
		 INNER JOIN players on agricola_scores.id_player=players.id_player
		 WHERE agricola_scores.id_game=(:id) AND agricola_scores.winner=1"
	);
	$statement->bindValue(":id", $id, SQLITE3_INTEGER);
	$results = $statement->execute();
	$winners = array();
	$i = 0;
	while ($winner = $results->fetchArray(SQLITE3_ASSOC))
	{
		$name = $winner["first_name"];
		if (strlen($winner["middle_name"])) {
			$name .= " ".substr($winner["middle_name"], 0, 1).".";
		}
		$name .= " ".$winner["last_name"];
		$name = "<a href='/std/player.php?id={$winner["id_player"]}'>{$name}</a>";

		$winners[$i] = $name;
		$i++;
	}
	$winners = join("; ", $winners);
	if (empty($winners)) { $winners = "None"; }
	echo("<p>Winner(s): {$winners}</p>");

	// Prepare table data
	$num_players = $game["count"];
	$table = [
		"name" => [],
		"fields" => [],
		"pastures" => [],
		"grain" => [],
		"vegetables" => [],
		"sheep" => [],
		"boar" => [],
		"cattle" => [],
		"unused" => [],
		"stables" => [],
		"clay_hut" => [],
		"stone_hut" => [],
		"family" => [],
		"cards" => [],
		"bonus" => [],
		"score" => [],
	];

	$statement = $db->prepare(
		"SELECT *, (fields+pastures+grain+vegetables+sheep+boar+cattle
			+unused+stables+clay_hut+stone_hut+family+cards+bonus) AS score 
		 FROM agricola_scores
		 INNER JOIN players on agricola_scores.id_player=players.id_player
		 INNER JOIN agricola on agricola_scores.id_game=agricola.id_game
		 WHERE agricola.id_game=(:id)
		 ORDER BY score DESC"
	);
	$statement->bindValue(":id", $id, SQLITE3_INTEGER);
	$results = $statement->execute();

	$i = 0;
	while ($player = $results->fetchArray(SQLITE3_ASSOC))
	{
		$name = $player["last_name"].", ".$player["first_name"];
		if (strlen($player["middle_name"])) {
			$name .= " ".substr($player["middle_name"], 0, 1).".";
		}
		$name = "<a href='/std/player.php?id={$player["id_player"]}'>{$name}</a>";

		$table["name"][$i] = $name;
		$table["fields"][$i] = $player["fields"];
		$table["pastures"][$i] = $player["pastures"];
		$table["grain"][$i] = $player["grain"];
		$table["vegetables"][$i] = $player["vegetables"];
		$table["sheep"][$i] = $player["sheep"];
		$table["boar"][$i] = $player["boar"];
		$table["cattle"][$i] = $player["cattle"];
		$table["unused"][$i] = $player["unused"];
		$table["stables"][$i] = $player["stables"];
		$table["clay_hut"][$i] = $player["clay_hut"];
		$table["stone_hut"][$i] = $player["stone_hut"];
		$table["family"][$i] = $player["family"];
		$table["cards"][$i] = $player["cards"];
		$table["bonus"][$i] = $player["bonus"];
		$table["score"][$i] = $player["score"];
		$i++;
	}

	reset($table);
	$first = key($table);
	echo("<table>");
	foreach ($table as $key => $row) {
		$cs = "<td>";
		$ce = "</td>";
		if ($first === $key) {
			$cs = "<th>";
			$ce = "</th>";
		}
		echo("<tr>{$cs}{$key}{$ce}");
		foreach($row as $value) {
			echo("{$cs}{$value}{$ce}");
		}
		echo("</tr>");
	}
	echo("</table>");
}
echo("</div></body>")
?>