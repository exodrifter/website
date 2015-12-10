<?php
include_once("../init.php");

$MAX_TOKENS = 7;

if (!isloggedin()) {
	header("Location:/std");
}

$db = initdb(SQLITE3_OPEN_READWRITE);
$username = $_SESSION['user']['name'];
$SUCCESS_DESTINATION = "Location:/std/u/".$username;

// Check if more tokens can be added
$id_user = $_SESSION['user']['id'];
$statement = $db->prepare (
	"SELECT COUNT(*) FROM registration_token
	 WHERE id_user=(:id_user)"
);
$statement->bindValue(":id_user", $id_user, SQLITE3_TEXT);
$count = $statement->execute()->fetchArray()[0];

if ($count >= $MAX_TOKENS) {
	$db->close();
	unset($db);
	return;
}

// Add the token
else {
	$token = md5(uniqid(rand(), true));
	$token = substr($token, 0, 15);

	$statement = $db->prepare (
		"INSERT INTO registration_token (id_user, token)
		 VALUES ((:id_user), (:token))"
	);
	$statement->bindValue(":id_user", $id_user, SQLITE3_TEXT);
	$statement->bindValue(":token", $token, SQLITE3_TEXT);
	$statement->execute();
}

$db->close();
unset($db);
header($SUCCESS_DESTINATION);

?>
