<?php
function printLink($text, $link, $selected, $small)
{
	$style = "";
	if ($small) {
		$style = " style=\"float: none; display: block;\"";
	}

	if ($selected && !$small) {
		$link = "";
		$selected = " class=\"selected\"";
	}
	else {
		$link = " href=\"".$link."\"";
	}

	echo "<li style=\"margin-bottom: 0; margin-left: 0; list-style-type: none;\"><a$link$style $selected>$text</a></li>";
}

function printLogo($image, $link, $selected, $small)
{
	$li = "margin-bottom: 0; margin-left: 0; list-style-type: none;";
	$style = "";
	if ($small) {
		$style = "float: none; display: block";
	} else {
		$li .= " float: left;";
	}

	if ($selected && !$small) {
		$link = "";
		$selected = " class=\"selected\"";
	}
	else {
		$link = " href=\"".$link."\"";
		$selected = "";
	}

	echo "<li style=\"$li\"><a$link$selected style=\"font-family: 'Orbitron', sans-serif;$style\">";
	echo "<img src=\"$image\" />exodrifter</a></li>";
}

// Get navbar parameters
$indexSelected = "index" === $LAYOUT->get("page");
$blogSelected  = "blog"  === $LAYOUT->get("page");
$gameSelected  = "game"  === $LAYOUT->get("page");
$musicSelected = "music" === $LAYOUT->get("page");

$img = $LAYOUT->url("logo.png");

$indexUrl = $LAYOUT->base();
$musicUrl = $LAYOUT->base()."music/";
$gameUrl  = $LAYOUT->base()."game/";
$blogUrl  = $LAYOUT->base()."blog/";

// Print navbar ?>
<div class="only-small" style="display:flex">
	<ul class="nav" style="padding: 0 10%;">
		<?php printLogo($img,    $indexUrl, $indexSelected, true); ?>
		<?php printLink("blog",  $blogUrl,  $blogSelected,  true); ?>
		<?php printLink("games", $gameUrl,  $gameSelected,  true); ?>
		<?php printLink("music", $musicUrl, $musicSelected, true); ?>
	</ul>
</div>
<div class="not-small" style="display:flex">
	<ul class="nav" style="padding: 0 10%">
		<?php printLogo($img,    $indexUrl, $indexSelected, false); ?>
		<?php printLink("music", $musicUrl, $musicSelected, false); ?>
		<?php printLink("games", $gameUrl,  $gameSelected,  false); ?>
		<?php printLink("blog",  $blogUrl,  $blogSelected,  false); ?>
	</ul>
</div>
