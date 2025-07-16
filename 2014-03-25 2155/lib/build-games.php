<?php
/**
 * Functions used to build the games template
 */

function games_path() {
	return "/games/";
}

function mkheader($name) {
	echo("<!DOCTYPE HTML>\n<html>\n<head>\n<title>".$name."</title>\n");
	echo("<meta http-equiv='Content-Type' content='text/html; charset=utf-8'>\n");
	echo("<script src='/js/skel-cfg.js'></script>\n");
	echo("<script src='/js/skel.min.js'></script>\n");
	echo("<script src='/js/ga.min.js'></script>\n");
	echo("</head>\n<body>\n");
}

function mkcon($prop="class=container") {
	echo("<div ".$prop.">\n");
}

function mkrow() {
	echo("<div class='row'>\n");
}

function mksec($size) {
	echo("<section class='".$size."u'>\n");
}

function mkendcon() {
	echo("</div>\n");
}

function mkendrow() {
	echo("</div>\n");
}

function mkendsec() {
	echo("</section>\n");
}

function mkfooter() {
	echo("</body>\n</html>");
}

?>
