<?php
include "pyrite.php";
$LAYOUT = new \pyrite\layout();

echo "<p><b>PHP: </b> ".phpversion()."</p>";
echo "<p><b>PATH: </b> ".$LAYOUT->path()."</p>";
echo "<p><b>URL: </b> ".$LAYOUT->url()."</p>";
?>
