<?php
function printLink($text, $link, $page, $small)
{
	$style = "";
	if ($small) {
		$style = " style=\"float: none; display: block;\"";
	}

	$selected = "";
	if ($link === $page && !$small) {
		$link = "";
		$selected = " class=\"selected\"";
	}
	else {
		$link = " href=\"".$link."\"";
	}

	echo <<<EOT
		<li><a{$link}{$style} {$selected}>{$text}</a></li>

EOT;
}

function printLogo($page, $url, $small)
{
	$li = "";
	$style = "";
	if ($small) {
		$style = "float: none; display: block";
	} else {
		$li = " style=\"float: left;\"";
	}

	$link = "/";
	$selected = "";
	if ("index" === $page && !$small) {
		$link = "";
		$selected .= " class=\"selected\"";
	}
	else {
		$link = " href=\"".$link."\"";
	}

	echo <<<EOT
		<li{$li}><a{$link}{$selected} style="font-family: 'Orbitron', sans-serif;{$style}">
				<img src="{$url}" />
				exodrifter
			</a>
		</li>

EOT;
}
?>

<div class="only-small" style="display:flex">
	<ul class="nav" style="padding: 0 10%;">
		<?php printLogo($LAYOUT->get("page"), $LAYOUT->url("logo.png"), true); ?>
		<?php printLink("blog", "blog", $LAYOUT->get("page"), true); ?>
		<?php printLink("games", "game", $LAYOUT->get("page"), true); ?>
		<?php printLink("music", "music", $LAYOUT->get("page"), true); ?>
	</ul>
</div>
<div class="not-small" style="display:flex">
	<ul class="nav" style="padding: 0 10%">
		<?php printLogo($LAYOUT->get("page"), $LAYOUT->url("logo.png"), false); ?>
		<?php printLink("blog", "blog", $LAYOUT->get("page"), false); ?>
		<?php printLink("games", "game", $LAYOUT->get("page"), false); ?>
		<?php printLink("music", "music", $LAYOUT->get("page"), false); ?>
	</ul>
</div>