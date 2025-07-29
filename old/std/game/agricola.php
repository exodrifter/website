<?php $TITLE="agricola";
include_once("../header.php");
include_once("../fn.php");

/*
if (isset($_GET["user"]) && username_exists($_GET["user"]))
{
	$username = $_GET["user"];

	echo("<h1>Agricola - {$username}</h1>");
	$db = initdb(SQLITE3_OPEN_READONLY);

	$statement = $db->prepare(
		"SELECT COUNT(*) as count FROM agricola_scores
		 INNER JOIN users on users.id_user=agricola_scores.id_user
		 WHERE username=(:username)"
	);
	$statement->bindValue(":username", $username, SQLITE3_TEXT);
	$num_played = $statement->execute()->fetchArray()[0];

	echo("<p>Games Recorded: {$num_played}</p>");
}
else
*/
{
	echo("<h1>Agricola</h1>");
	$db = initdb(SQLITE3_OPEN_READONLY);

	$statement = $db->prepare("SELECT COUNT(*) as count FROM agricola");
	$num_played = $statement->execute()->fetchArray()[0];

	echo("<p>Games Recorded: {$num_played}</p>");

	// Get game ids
	$statement = $db->prepare("SELECT id_game FROM agricola ORDER BY id_game DESC");
	$games = $statement->execute();

	while ($id = $games->fetchArray(SQLITE3_ASSOC)["id_game"])
	{
		// Get game information
		$statement = $db->prepare(
			"SELECT agricola.id_game, agricola.date, variant_name,
				COUNT(*) AS count FROM agricola_scores
			 INNER JOIN agricola on agricola.id_game=agricola_scores.id_game
			 INNER JOIN agricola_variant on agricola.id_variant=agricola_variant.id_variant
			 WHERE agricola.id_game=(:id)"
		);
		$statement->bindValue(":id", $id, SQLITE3_INTEGER);
		$game = $statement->execute()->fetchArray(SQLITE3_ASSOC);

		// Print game metadata
		echo("<hr />");
		echo("<p>ID: {$game["id_game"]}</p>");
		echo("<p>Date: {$game["date"]}</p>");
		echo("<p>Num Players: {$game["count"]}</p>");
		echo("<p>Variation: {$game["variant_name"]}</p>");

		// Get winners
		$statement = $db->prepare(
			"SELECT first_name, last_name, middle_name, username
			 FROM agricola_scores
			 INNER JOIN users on agricola_scores.id_user=users.id_user
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
			$name = "<a href='?user={$winner["username"]}'>{$name}</a>";

			$winners[$i] = $name;
			$i++;
		}
		$winners = join("; ", $winners);
		if (empty($winners)) { $winners = "None"; }
		echo("<p>Winner(s): {$winners}</p>");

		// Prepare table data
		$num_users = $game["count"];
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
			 INNER JOIN users on agricola_scores.id_user=users.id_user
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
			$name = "<a href='?user={$player["username"]}'>{$name}</a>";

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
	include_once("../footer.php");
}
?>