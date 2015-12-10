<?php
include_once("init.php");

if(isset($TITLE))
	$TITLE = "std - ".$TITLE;
else
	$TITLE = "std";

$username = get_username();

?>
<!DOCTYPE html>
<html>
<head>
<title><?=$TITLE?></title>
<link rel='stylesheet' type='text/css' href='/std/css/style.css'>
</head>
<body>
<div class='wrapper'>
<div class='header'>

<h1><a href='/std' style='text-decoration:none;color:initial'>
Super Terrible Decisions
</a></h1>
<p style='font-style:italic;font-size:1em'>
in which super terrible decisions are made
<span style='opacity:.5;font-size:.8em'>(like this website)</span>
</p>

<div class='navbar'>
<p style='padding:0 1.5em 0 1.5em;text-align:right;'>
<?php
if (is_logged_in()) {
	echo("<a class='nav' href='/std/register.php'>register</a>");
	echo("<a href='/std/u/{$username}'>{$username}</a>");
	echo(" | <a href='/std/user/logout.php'>logout</a>");
}
else {
	echo("<a href='/std/user/login.php'>login</a>");
}
?></p>
</div>
</div>
