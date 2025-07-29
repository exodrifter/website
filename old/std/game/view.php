<?php
include_once("../init.php");
$db = init_db();

if (!isset($_GET['game'])) {
	header("HTTP/1.0 404 Not Found");
}
$code = validate("[A-Za-z0-9\-]+", $_GET["game"]);

$statement = $db->prepare(
	"SELECT id_game, game.created, name, description,
	        username as mod, first_name, last_name, middle_name
	 FROM game
	 INNER JOIN user ON id_user=id_mod
	 WHERE code=(:code)"
);
$statement->bindValue(":code", $code, SQLITE3_TEXT);
$result = $statement->execute()->fetchArray(SQLITE3_ASSOC);

$id_game = $result['id_game'];
$created = date("Y-M-d H:i:s T P", $result['created']);
$name = $result['name'];
$description = $result['description'];
$mod = $result['mod'];
$first_name = $result['first_name'];
$last_name = $result['last_name'];
$middle_name = $result['middle_name'];

$db->close();
unset($db);

include_once("../header.php");

echo("<h1>{$name}</h1>
<p>created: {$created}</p>
<p>mod: <a href='/std/u/{$mod}'>{$mod}</a></p>
<p>description: {$description}</p>
");

include_once("../footer.php");
?>