<?php
namespace Pyrite;
require_once("pyrite.php");

// Init
openDBGames();
prepareBBCodeParser();

setPageTitle("Portfolio");
putTemplate("portfolio.php");
?>