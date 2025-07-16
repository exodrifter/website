<?php namespace Pyrite;
// Additional queries
queryCategory(getPostID());
queryTags(getPostID());
queryTumblrID(getPostID());
?>
<div class='post'>
<h1><a style='text-decoration:none' href='<?php echo getURLBlog(); ?>archive/post/<?php echo getPostID(); ?>'><?php putPostTitle(); ?></a></h1>
<p class='date'><?php putPostDate(); ?></p>
<p class='summary'><?php
// Limit to 300 characters, but only cut at the nearest word
$text = preg_replace('/\s+?(\S+)?$/', '', substr(getPostContent(), 0, 300));
echo($text);
?> <a style='text-decoration:none' href='<?php echo getURLBlog(); ?>archive/post/<?php echo getPostID(); ?>'>[Read more...]</a></p>
</div>
