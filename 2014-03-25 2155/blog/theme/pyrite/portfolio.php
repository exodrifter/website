<?php namespace Pyrite;
putTemplate("header.php");
?>
<div class='container'>
<div class='focus'>
<div class='row'>
<section class='12u'>
<h1>Portfolio</h1>
<p>This is a list of a few video game projects I’ve worked on that I’m
particularly proud of. If you’d like to see all of the projects I’ve ever
worked on, you can see a full list <a href='<?php echo(getURLBase()); ?>games'>here</a>.</p>
<?php
// Games
$arr = array("spacemin", "asterble", "teknedia");
foreach($arr as $shortname) {
	echo("<hr class='divider'/>\n");
	queryGamesWithShortname($shortname);
	nextGame();
	echo("<div class='row'><section class='12u'>\n");
	echo("<h2>".getGameName()."</h2>\n");
	echo("<img class='banner' src='".getURLBase()."img/game/$shortname/banner.png'></img>\n");
	echo("</section></div>\n");
	if(getGameHasAbout()) {
		// Limit to 300 characters, but only cut at the nearest word
		$text = preg_replace('/\s+?(\S+)?$/', '', substr(getGameAbout(), 0, 300));
		echo("<p class='summary'>$text <a style='text-decoration:none' href='".getURLBase()."games/$shortname'>[Read more...]</a></p>");
	}
}
?>
</section>
</div>
</div>
</div>
<?php putTemplate("footer.php"); ?>