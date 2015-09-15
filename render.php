<?php
include("pyrite.php");
$LAYOUT = new \pyrite\layout("res/");
include($LAYOUT->path("template/".$_GET["page"].".php"));
?>