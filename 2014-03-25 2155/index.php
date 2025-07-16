<?php namespace Pyrite;
require_once("blog/pyrite.php");
putTemplate("header.php");
openDBGames();
$statement = PyriteData::$db_games->prepare("SELECT shortname FROM games WHERE featured='1' ORDER BY RANDOM() LIMIT 1");
$name = $statement->execute()->fetchArray();
$name = $name["shortname"];
?>
<div style='
	background-image:url(<?php echo(getURLImage()); ?>game/<?php echo($name); ?>/feature.png);
	background-size:cover;
	background-position:center;
	overflow:hidden;
	position:absolute;
	top:0;
	left:0;
	width:100%;
	height:100%;
	z-index:-99;'>
</div>
<?php putTemplate("footer.php"); ?>
