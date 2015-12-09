<?php
$db = new \SQLite3("std.sqlite", SQLITE3_OPEN_READONLY);

// Check if a user was defined
if (!isset($_GET['user'])) {
	header("HTTP/1.0 404 Not Found");
}
$username = $_GET['user'];

$statement = $db->prepare(
	"SELECT username, first_name, last_name, middle_name, created, last_seen
	 FROM users WHERE username=(:username)"
);
$statement->bindValue(":username", $username, SQLITE3_TEXT);
$result = $statement->execute();

if ($arr = $result->fetchArray(SQLITE3_ASSOC))
{
	$db->close();
	unset ($db);

	$created = date("Y-M-d H:i:s T P", $arr['created']);
	$last_seen = date("Y-M-d H:i:s T P", $arr['last_seen']);

	$TITLE = $arr['username'];
	include_once("header.php");

	echo("<h1>{$arr['username']}</h1>
	<div style='margin-bottom:2em'>
	<p>first: {$arr['first_name']}</p>
	<p>last: {$arr['last_name']}</p>
	<p>middle: {$arr['middle_name']}</p>
	</div>
	<p>created: {$created}</p>
	<p>last seen: {$last_seen}</p>");

	include_once("footer.php");
}
else
{
	$db->close();
	unset ($db);
	header("HTTP/1.0 404 Not Found");
}
?>