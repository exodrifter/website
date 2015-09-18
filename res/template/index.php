<?php
$content = <<<EOT
<div style="text-align:center; width:100%; margin: 0 auto;">
	<h1 style="font-family: 'Orbitron', sans-serif;">exodrifter</h1>
	<p style="margin-top: 1em">a chilled blend of thoughts from ethereal dreams</p>
	<p class="index-links" >
	<div class="only-small">
		<p><a class="index-link" href="http://twitter.com/exodrifter">twitter</a></p>
		<p><a class="index-link" href="http://github.com/exodrifter">github</a></p>
		<p><a class="index-link" href="http://soundcloud.com/exodrifter">soundcloud</a></p>
	</div>
	<div class="not-small">
		<p style="margin-top: 1em">
		<a class="index-link" href="http://twitter.com/exodrifter">twitter</a> |
		<a class="index-link" href="http://github.com/exodrifter">github</a> |
		<a class="index-link" href="http://soundcloud.com/exodrifter">soundcloud</a>
		</p>
	</div>
	</p>
</div>

EOT;
$LAYOUT->set("content", $content);
$LAYOUT->set("page", "index");
$LAYOUT->set("css", "<link rel=\"stylesheet\" type=\"text/css\" href=\"".$LAYOUT->url("css/index.css")."\" />");

include $LAYOUT->path("template/base.php");
?>
