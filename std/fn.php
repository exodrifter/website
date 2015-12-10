<?php
/**
 * Returns true if the specified username exists, or if the username is null.
 */
function username_exists($username)
{
	if (null === $username) {
		return true;
	}

	$db = new \SQLite3(__DIR__."/std.sqlite", SQLITE3_OPEN_READONLY);

	$statement = $db->prepare(
		"SELECT COUNT(*) FROM user WHERE username=(:username)"
	);
	$statement->bindValue(":username", $username, SQLITE3_TEXT);
	$count = $statement->execute()->fetchArray()[0];

	$db->close();
	unset ($db);
	return $count > 0;
}
?>