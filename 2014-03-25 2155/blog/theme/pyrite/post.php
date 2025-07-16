<?php namespace Pyrite;
// Additional queries
queryCategory(getPostID());
queryTags(getPostID());
queryTumblrID(getPostID());
?>
<div class='post'>
<h1><?php putPostTitle(); ?></h1>
<p class='date'><?php putPostDate(); ?></p>
<?php putPostContent(); ?>
<p class='align-left'><?php
$tags = "";
while(nextTag()) {
	$tag = getTagName();
	if($tags==="") {
		$tags .= "<a href='".getURLBlog()."archive/tag/".$tag."'>".$tag."</a>";
	} else {
		$tags .= ", <a href='".getURLBlog()."archive/tag/".$tag."'>".$tag."</a>";;
	}
}
nextCategory();
$cat = getCategoryName();
echo "[<a href='".getURLBlog()."archive/category/".strtolower($cat)."'>".$cat."</a>] ".$tags;
?></p>
<?php
if($id = getTumblrID())
{
	echo("<a href='http://dpek.tumblr.com/post/".$id."'>");
	echo("<div class='tumblr align-right' title='tumblr mirror' class=align-right></div>");
	echo("</a>\n");
}
?>
<div style='clear:both;'></div>
</div>