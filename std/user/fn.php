<?php
if (session_status() == PHP_SESSION_NONE) {
	session_start();
}

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
		"SELECT id_user, hash FROM users WHERE username=(:username)"
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
				"UPDATE users SET hash=(:hash) WHERE username=(:username)"
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
?>