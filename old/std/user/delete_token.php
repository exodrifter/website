<?php
include_once("../init.php");

if (!is_logged_in()) {
	header("Location:/std");
}

$db = init_db(SQLITE3_OPEN_READWRITE);
$username = $_SESSION['user']['name'];
$SUCCESS_DESTINATION = "Location:/std/u/".$username;

if (isset($_GET['del']))
{
	$token = $_GET['del'];
	$id_user = $_SESSION['user']['id'];

	$statement = $db->prepare (
		"DELETE FROM registration_token
		 WHERE token=(:token) AND id_user=(:id_user)"
	);
	$statement->bindValue(":token", $token, SQLITE3_TEXT);
	$statement->bindValue(":id_user", $id_user, SQLITE3_INTEGER);
	$statement->execute();
}

$db->close();
unset($db);
header($SUCCESS_DESTINATION);

?>
