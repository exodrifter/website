<?php
namespace Pyrite;
require_once("pyrite.php");

// Init
openDBGames();
prepareBBCodeParser();

if(isset($_GET["game"])) {
	$shortname = $_GET["game"];
	queryGamesWithShortname($shortname);
	$result = nextGame();
	if(!$result) {
		setPageTitle("404");
		putTemplate("404.php");
	} else {
		setPageTitle("Games");
		putTemplate("page-game.php");
	}
} else {
	setPageTitle("Games");
	putTemplate("games.php");
}
?>