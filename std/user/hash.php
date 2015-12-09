<?php
$hash = password_hash($_GET["pass"], PASSWORD_DEFAULT);
var_dump($hash);
?>
