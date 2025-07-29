<?php
include_once("../init.php");
$db = init_db();

$MAX_TOKENS = 7;

// Check if a user was defined
if (!isset($_GET['user'])) {
	header("HTTP/1.0 404 Not Found");
}
$username = $_GET['user'];

$statement = $db->prepare(
	"SELECT id_user, username, first_name, last_name, middle_name, created,
	        last_seen
	 FROM user WHERE username=(:username)"
);
$statement->bindValue(":username", $username, SQLITE3_TEXT);
$result = $statement->execute();

if ($arr = $result->fetchArray(SQLITE3_ASSOC))
{
	$created = date("Y-M-d H:i:s T P", $arr['created']);
	$last_seen = date("Y-M-d H:i:s T P", $arr['last_seen']);

	$edit = null;
	$tokens = null;
	if (is_logged_in() && $_SESSION['user']['name'] === $username)
	{
		$edit = "<a href='/std/user/edit.php'>edit profile</a>";

		$statement = $db->prepare(
			"SELECT token FROM registration_token WHERE id_user=(:id_user)"
		);
		$statement->bindValue(":id_user", $_SESSION['user']['id'], SQLITE3_INTEGER);
		$result = $statement->execute();

		$tokens = "<h1 id='tokens'>Registration Tokens</h1>";
		if (isset($token_error)) {
			$tokens .= "<p class='error'>{$token_error}</p>";
		}
		$number = 0;
		while ($token = $result->fetchArray(SQLITE3_ASSOC))
		{
			$number++;
			$token = $token["token"];
			$tokens .= "<p>{$token} <a href='/std/user/delete_token.php?del={$token}'>delete</a></p>";
		}
		if ($number == 0) {
			$tokens .= "<p class='none'>no tokens</p>";
		}
		if ($number < $MAX_TOKENS) {
			$tokens .= "<form style='display:inline;'
				action='/std/user/generate_token.php'>
				<input type='submit' value='generate token'></form>";
		}
	}

	$db->close();
	unset ($db);

	$TITLE = $arr['username'];
	include_once("../header.php");

	echo("<h1>{$arr['username']}</h1>
	<p>{$edit}</p>
	<div style='margin-bottom:2em'>
	<p>first: {$arr['first_name']}</p>
	<p>last: {$arr['last_name']}</p>
	<p>middle: {$arr['middle_name']}</p>
	</div>
	<p>created: {$created}</p>
	<p>last seen: {$last_seen}</p>
	{$tokens}");

	include_once("../footer.php");
}
else
{
	$db->close();
	unset ($db);
	header("HTTP/1.0 404 Not Found");
}
?>