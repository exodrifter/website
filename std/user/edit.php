<?php
include_once ("../init.php");
include_once ("fn.php");

if(!isloggedin()) {
	header("Location:/std");
}
$username = $_SESSION['user']['name'];
$id_user = $_SESSION['user']['id'];
$db = initdb(SQLITE3_OPEN_READWRITE);

// Check if we want to update the profile
$profile_msg = null;
if (isset($_POST["first_name"])
		&& isset($_POST["last_name"])
		&& isset($_POST["middle_name"])) {
	$first_name = validate_name($_POST["first_name"]);
	$last_name = validate_name($_POST["last_name"]);
	$middle_name = validate_name($_POST["middle_name"]);

	if (login($username, $_POST["password"])) {
		$statement = $db->prepare(
			"UPDATE user SET first_name=(:first_name),
			 last_name=(:last_name), middle_name=(:middle_name)
			 WHERE id_user=(:id_user)"
		);
		$statement->bindValue(":id_user", $id_user, SQLITE3_INTEGER);
		$statement->bindValue(":first_name", $first_name, SQLITE3_TEXT);
		$statement->bindValue(":last_name", $last_name, SQLITE3_TEXT);
		$statement->bindValue(":middle_name", $middle_name, SQLITE3_TEXT);
		if ($statement->execute()) {
			$profile_msg = "<p class='success'>updated profile</p>";
		} else {
			$profile_msg = "<p class='error'>failed to update profile</p>";
		}
	} else {
		$profile_msg = "<p class='error'>incorrect password</p>";
	}
}

// Check if we want to update the password
$password_msg = null;
if (isset($_POST["old"])
		&& isset($_POST["new1"])
		&& isset($_POST["new2"])) {
	$old = $_POST["old"];
	if ($_POST["new1"] === $_POST["new2"]) {
		$new = $_POST["new1"];
		if (update_password($username, $old, $new)) {
			$password_msg = "<p class='success'>updated password</p>";
		} else {
			$password_msg = "<p class='error'>failed to update password</p>";
		}
	} else {
		$password_msg = "<p class='error'>passwords don't match</p>";
	}
}

$statement = $db->prepare(
	"SELECT first_name, last_name, middle_name
	 FROM user WHERE username=(:username)"
);
$statement->bindValue(":username", $username, SQLITE3_TEXT);
$result = $statement->execute()->fetchArray(SQLITE3_ASSOC);

$first_name = $result['first_name'];
$last_name = $result['last_name'];
$middle_name = $result['middle_name'];

$db->close();
unset($db);

include_once ("../header.php");
echo ("
<h1>{$username}</h1>
<p><a href='/std/u/{$username}'><< back</a></p>
<h2>Edit Profile</h2>
{$profile_msg}
<div style='margin-bottom:2em'>
<p>first, middle, and last must match [A-Za-z\ \.]+</p>
<form action='edit.php' method='post'>
<p>first: <input type='text' name='first_name' value='{$first_name}' autofocus</p>
<p>last: <input type='text' name='last_name' value='{$last_name}'</p>
<p>middle: <input type='text' name='middle_name' value='{$middle_name}'</p>
<p>pass: <input type='password' name='password'></p>
<p><input type='submit' value='Update'></p>
</form>
<h2>Edit Password</h2>
{$password_msg}
<form action='edit.php' method='post'>
<p>old: <input type='password' name='old'</p>
<p>new: <input type='password' name='new1'</p>
<p>new: <input type='password' name='new2'</p>
<p><input type='submit' value='Update'></p>
</form>
</div>
");
include_once ("../footer.php");

?>
