<?php $TITLE="register";
include_once("../init.php");
include_once("fn.php");

$SUCCESS_DESTINATION = "Location:/std/user/login.php?registered=true";

// Check if the user is already logged in
if (is_logged_in()) {
	header($SUCCESS_DESTINATION);
	return;
}

// Attempt registration if the username and password input is set
$attempted_register = false;
$error = 'missing fields';
if (isset($_POST["username"])
	&& isset($_POST["password1"])
	&& isset($_POST["password2"])
	&& isset($_POST["token"]) )
{
	$attempted_register = true;
	$error = 'passwords do not match';

	if ($_POST["password1"] === $_POST["password2"])
	{
		$username = validate_username($_POST["username"]);
		$password = $_POST["password1"];
		$token = $_POST["token"];

		$error = 'username must match [A-Za-z0-9\-\_\.]+';
		if (null !== $username)
		{
			$error = 'passwords must match [A-Za-z0-9_!@#$%^&*()]{4,30}';
			if (preg_match('/^[A-Za-z0-9_!@#$%^&*()]{4,30}$/',$password))
			{
				$error = 'username already in use';
				if (!username_exists($username))
				{
					$error = 'could not register; token may be invalid';
					if (register($username, $password, $token)) {
						header($SUCCESS_DESTINATION);
						return;
					}
				}
			}
		}
	}
}

include_once("../header.php");

echo("<h1>Register</h1>");

echo("<p>Have an account? Log in <a href='/std/user/login.php'>here</a>.</p>");

if ($attempted_register) {
	echo("<p class='error'>could not register ({$error}). try again.</p>");
}

// Show the login form
$username = null;
if (isset($_POST["username"])) {
	$username = $_POST["username"];
}
$token = null;
if (isset($_POST["token"])) {
	$token = $_POST["token"];
}

$user_focus = "";
$pass_focus = "";
if (isset($username)) {
	$pass_focus = " autofocus";
} else {
	$user_focus = " autofocus";
}
echo("
<form action='register.php' method='post'>
	<p>user: <input type='text' name='username' value='{$username}'{$user_focus}></p>
	<p>pass: <input type='password' name='password1'{$pass_focus}></p>
	<p>pass: <input type='password' name='password2'></p>
	<p>token: <input type='text' name='token' value='{$token}'></p>
	<p><input type='submit' value='Login'></p>
</form>");

include_once("../footer.php");

?>
