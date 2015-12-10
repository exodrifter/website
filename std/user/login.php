<?php $TITLE="login";
include_once("../init.php");
include_once("fn.php");

$SUCCESS_DESTINATION = "Location:/std";

// Check if the user is already logged in
if (isloggedin()) {
	header($SUCCESS_DESTINATION);
	return;
}

// Check if we should remember the username
if (isset($_POST['remember'])) {
	if ($_POST['remember']) {
		setcookie("username", $_POST['username'], time()+(86400*30));
	}
	else {
		setcookie("username", "", time()-3600);
	}
}

// Attempt login if the username and password input is set
$attempted_login = false;
if (isset($_POST["username"]) && isset($_POST["password"]))
{
	$attempted_login = true;

	$username = validate_username($_POST["username"]);
	$password = $_POST["password"];

	if (login($username, $password))
	{
		header($SUCCESS_DESTINATION);
		return;
	}
}

include_once("../header.php");

echo("<h1>Login</h1>");

if (isset($_GET["registered"]) && "true" === $_GET["registered"])
{
	echo ("<p class='success'>Registered! Please log in.</p>");
}

echo("<p>No account? Register <a href='/std/user/register.php'>here</a>.</p>");

if ($attempted_login) {
	echo("<p class='error'>could not login. try again.</p>");
}

// Show the login form
$username = null;
if (isset($_POST["username"])) {
	$username = $_POST["username"];
} else if(isset($_COOKIE["username"])) {
	$username = $_COOKIE["username"];
}

$user_focus = "";
$pass_focus = "";
$remember_checked = "";
if (isset($username)) {
	$pass_focus = " autofocus";
	$remember_checked = " checked";
} else {
	$user_focus = " autofocus";
	$remember_checked = " checked";
}
echo("
<form action='login.php' method='post'>
	<p>user: <input type='text' name='username' value='{$username}'{$user_focus}></p>
	<p>pass: <input type='password' name='password'{$pass_focus}></p>
	<p>remember? <input type='checkbox' name='remember'{$remember_checked}></p>
	<p><input type='submit' value='Login'></p>
</form>");

include_once("../footer.php");

?>
