<?php namespace pyrite;
require_once("lib/pyrite/pyrite-cfg.php");
require_once("lib/pyrite/pyrite-map.php");
require_once("lib/pyrite/pyrite-layout.php");
require_once("lib/bbcode.php");

// Configuration
\pyrite\cfg::$root = dirname(__FILE__)."/";
\pyrite\cfg::$url_test = "http://localhost/";
\pyrite\cfg::$url_live = "http://exodrifter.space/";
?>
