<?php namespace Pyrite;
putTemplate("header.php"); ?>
<div class='container'>
<div class='row'>
<section class='12u'>
<div class='focus'>
<div class='notice-info'><div class='info align-left'></div><p class='nospace'>You are viewing a single post</p></div>
<?php
putTemplate("post.php");
// Navigation
if(getPostID() > 1) {
	echo("<p class=align-left><a href='".getURLBlog()."archive/post/".(getPostID()-1)."'><- older</a></p>");
}
if(getPostID() < getMaxPosts()) {
	echo("<p class=align-right><a href='".getURLBlog()."archive/post/".(getPostID()+1)."'>newer -></a></p>");
}
echo("<div style='clear:both;'></div>");
// Javascript key-bound browsing
echo("<script>
document.onkeydown = checkKey;

function checkKey(e) {
	var url = false;
	e = e || window.event;");
	if(getPostID() > 1) {
		echo("	if(e.keyCode=='37'){url='".getURLBlog()."archive/post/".(getPostID()-1)."';}");
	}
	if(getPostID() < getMaxPosts()) {
		echo("	if(e.keyCode=='39'){url='".getURLBlog()."archive/post/".(getPostID()+1)."';}");
	}
	echo("	if (url) {
		window.location = url;
	}
}
</script>
");
?>
</div>
</section>
</div>
</div>
<?php putTemplate("footer.php"); ?>