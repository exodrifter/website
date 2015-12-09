<?php
function username_exists($username)
{
	$db = new \SQLite3(__DIR__."/std.sqlite", SQLITE3_OPEN_READONLY);

	$statement = $db->prepare(
		"SELECT COUNT(*) FROM users WHERE username=(:username)"
	);
	$statement->bindValue(":username", $username, SQLITE3_TEXT);
	$count = $statement->execute()->fetchArray()[0];

	$db->close();
	unset ($db);
	return $count > 0;
}
?>