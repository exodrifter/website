<?php namespace Pyrite;
putTemplate("header.php"); ?>
<div class='container'>
<div class='row'>
<section class='9u'>
<?php
$page = PyriteData::$pagination;
if($page!=0) {
	echo("<div class='notice-info'><div class='info align-left'></div><p class='nospace'>This is page ".$page." of the most recent blog posts.</p></div>\n");
}
// Posts
do {
	putTemplate("post-summary.php");
	echo("<hr class='divider'/>\n");
} while(nextPost());
// Navigation
if($page*PyriteConfig::BLOG_INDEX_PAGINATION < getMaxPosts()-PyriteConfig::BLOG_INDEX_PAGINATION) {
	echo("<p class=align-left><a href='".getURLBlog()."?page=".($page+1)."'>&lt;- older</a></p>");
}
if($page > 0) {
	echo("<p class=align-right><a href='".getURLBlog()."?page=".($page-1)."'>newer -&gt;</a></p>");
}
echo("<div style='clear:both;'></div>");
?>
</section>
<section class='3u'>
<?php putTemplate("sidebar.php"); ?>
</section>
</div>
</div>
<?php putTemplate("footer.php"); ?>