<?php
function initdb($mode=SQLITE3_OPEN_READONLY)
{
	return new \SQLite3(__DIR__."/std.sqlite", $mode);
}

function isloggedin()
{
	return isset($_SESSION['user']);
}

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
if (isloggedin())
{
	$db = initdb(SQLITE3_OPEN_READWRITE);
	$statement = $db->prepare(
		"UPDATE user SET last_seen=(:time) WHERE username=(:username)"
	);
	$statement->bindValue(":time", time(), SQLITE3_INTEGER);
	$statement->bindValue(":username", $_SESSION['user']['name'], SQLITE3_TEXT);
	$statement->execute();
	$db->close();
	unset($db);
}
?>
