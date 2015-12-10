<?php
include_once("../header.php");

if (!isloggedin()) {
	include_once("../header.php");
	echo("<p class='error'>you must be logged in to access this page</p>");
	include_once("../footer.php");
	return;
}

$register_msg = "";
if (isset($_POST['name']) && isset($_POST['description']))
{
	$id_user = $_SESSION['user']['id'];
	$name = validate("[A-Za-z0-9\-\.\ ]+", $_POST['name']);
	$code = validate("[A-Za-z0-9\-]+", $_POST['code']);
	$description = $_POST['description'];
	if ("" == $description)
	{
		$description == null;
	}

	$db = initdb(SQLITE3_OPEN_READWRITE);
	$statement = $db->prepare(
		"INSERT INTO game (created, id_mod, name, code, description)
		 VALUES ((:created),(:id_mod),(:name),(:code),(:description))"
	);
	$statement->bindValue(":created", time(), SQLITE3_INTEGER);
	$statement->bindValue(":id_mod", $id_user, SQLITE3_INTEGER);
	$statement->bindValue(":code", $code, SQLITE3_TEXT);
	$statement->bindValue(":name", $name, SQLITE3_TEXT);
	$statement->bindValue(":description", $description, SQLITE3_TEXT);
	if ($statement->execute()) {
		header("Location: /std/g/{$code}");
	} else {
		$register_msg = "<p class='error'>cannot register game; code probably in use</p>";
	}
}
?>
<h1>Register Board Game</h1>
<form action='register.php' method='post'>
<div style='margin-bottom:2em'>
<p>name*: <input type='text' name='name' autofocus></p>
<p class='desc'>the name of the game. [A-Za-z0-9\-\.\ ]+</p>
</div>
<div style='margin-bottom:2em'>
<p>code*: <input type='text' name='code' autofocus></p>
<p class='desc'>the code of the game used to uniquely identify it. [A-Za-z0-9\-]+</p>
</div>
<div style='margin-bottom:2em'>
<p>description:</p>
<textarea name='description' rows=10 style='width: 100%'></textarea>
<p class='desc'>the description of the game</p>
</div>
<p><input type='submit' value='Submit'></p>
</form>

<?php
include_once("../footer.php");
?>