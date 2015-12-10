<?php
include_once("../fn.php");

function validate_username($username)
{
	$regex = '(^[A-Za-z0-9\-\_\.]+$)';
	if (1 === preg_match ($regex, $username))
		return $username;
	return null;
}

function login($username, $password)
{
	$db = new \SQLite3("../std.sqlite", SQLITE3_OPEN_READWRITE);

	$statement = $db->prepare(
		"SELECT id_user, hash FROM user WHERE username=(:username)"
	);
	$statement->bindValue(":username", $username, SQLITE3_TEXT);
	$result = $statement->execute()->fetchArray(SQLITE3_ASSOC);

	$id_user = $result["id_user"];
	$hash = $result["hash"];

	if (password_verify($password, $hash))
	{
		// Check if the password needs a rehash
		if (password_needs_rehash($hash, PASSWORD_DEFAULT))
		{
			$hash = password_hash($password, PASSWORD_DEFAULT);
			$statement = $db->prepare(
				"UPDATE user SET hash=(:hash) WHERE username=(:username)"
			);
			$statement->bindValue(":hash", $hash);
			$statement->bindValue(":username", $username);
			$statement->execute();
		}

		// Set session information
		$_SESSION['user'] = [
			'id' => $id_user,
			'name' => $username,
		];

		$db->close();
		unset ($db);
		return true;
	}
	
	$db->close();
	unset ($db);
	return false;
}

function register($username, $password, $token)
{
	$db = new \SQLite3("../std.sqlite", SQLITE3_OPEN_READWRITE);

	// Delete the registration token if it exists
	$statement = $db->prepare(
		"DELETE FROM registration_token WHERE token=(:token)"
	);
	$statement->bindValue(":token", $token, SQLITE3_TEXT);
	$statement->execute();
	if ($db->changes() <= 0) {
		$db->close();
		unset ($db);
		return false;
	}

	$hash = password_hash($password, PASSWORD_DEFAULT);
	$time = time();

	$statement = $db->prepare(
		"INSERT INTO user (username, hash, registered, last_seen)
		 VALUES ((:username), (:hash), (:registered), (:last_seen))"
	);
	$statement->bindValue(":username", $username, SQLITE3_TEXT);
	$statement->bindValue(":hash", $hash, SQLITE3_TEXT);
	$statement->bindValue(":registered", $time, SQLITE3_INTEGER);
	$statement->bindValue(":last_seen", $time, SQLITE3_INTEGER);
	$result = $statement->execute();

	$db->close();
	unset ($db);
	return $result;
}
?>