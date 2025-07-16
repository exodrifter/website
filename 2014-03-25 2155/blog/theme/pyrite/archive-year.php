<?php namespace Pyrite;
putTemplate("header.php"); ?>
<div class='container'>
<div class='row'>
<section class='9u'>
<h1 style='margin-bottom:.5em;'><?php echo PyriteData::$temp ?></h1>
<?php
do {
	echo("<p><b>".getPostDate()."</b> <a href='".getURLBlog()."archive/post/".getPostID()."'>".getPostTitle()."</a></p>\n");
} while(nextPost());
?>
</section>
<section class='3u'>
<?php putTemplate("sidebar.php"); ?>
</section>
</div>
</div>
<?php putTemplate("footer.php"); ?>