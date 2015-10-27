<?php
$content = <<<EOT
<div class='container'><div class='row'>
<section class='9u'>
<h1>404</h1>
<p>Sorry, that resource could not be found.</p>
</section>
</div></div>

EOT;
$LAYOUT->set("content", $content);
$LAYOUT->set("title", "404");

include $LAYOUT->path("template/base.php");
?>
