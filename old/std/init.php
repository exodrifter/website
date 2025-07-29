<?php
/**
 * Returns a new instance of the database
 */
function init_db($mode=SQLITE3_OPEN_READONLY)
{
	return new \SQLite3(__DIR__."/std.sqlite", $mode);
}

/**
 * Returns true if the user is logged in.
 */
function is_logged_in()
{
	return isset($_SESSION['user']);
}

/**
 * Returns the username of the logged in user or null if there is no user
 * logged in.
 */
function get_username()
{
	if (is_logged_in()) return $_SESSION['user']['name'];
	return null;
}

/**
 * Returns the user id of the logged in user or null if there is no user logged
 * in.
 */
function get_userid()
{
	if (is_logged_in()) return $_SESSION['user']['id'];
	return null;
}

/**
 * Returns true if the specified username either exists or is null.
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

/**
 * Returns the passed text if it matches the specified regex, otherwise it
 * returns null.
 */
function validate($regex, $text)
{
	$regex = '(^'.$regex.'$)';
	if (1 === preg_match ($regex, $text))
		return $text;
	return null;
}

// Check for a session
if (session_status() == PHP_SESSION_NONE) {
	session_start();
}

// Set the default timezone
date_default_timezone_set ("America/Chicago");

// Update last seen
if (is_logged_in())
{
	$db = init_db(SQLITE3_OPEN_READWRITE);
	$statement = $db->prepare(
		"UPDATE user SET last_seen=(:time) WHERE username=(:username)"
	);
	$statement->bindValue(":time", time(), SQLITE3_INTEGER);
	$statement->bindValue(":username", get_username(), SQLITE3_TEXT);
	$statement->execute();
	$db->close();
	unset($db);
}
?>
