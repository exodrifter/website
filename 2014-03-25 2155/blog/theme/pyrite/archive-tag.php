<?php namespace Pyrite;
putTemplate("header.php");
openDBGames();
queryGamesWithShortname(PyriteData::$temp);?>
<div class='container'>
<div class='row'>
<section class='9u'>
<?php
$game = nextGame();
if($game && getGameHasAbout()) {
	echo("<a href='".getURLBase()."games/".PyriteData::$temp."'><img class='banner' src='".getURLBase()."img/game/".getGameShortname()."/banner.png'></img></a>");
}
?>
<div class='notice-info'>
<div class='info align-left'></div>
<p class='nospace'>Showing posts tagged "<?php echo PyriteData::$temp ?>".
<?php
if($game && getGameHasAbout()) {
	echo("Read more about ".getGameName()." <a href='"
	      .getURLBase()."games/".PyriteData::$temp."'>here</a>.");
}
echo("</p></div>");

do {
	putTemplate("post-summary.php");
	echo("<hr class='divider'/>\n");
} while(nextPost());
// Navigation
$page = PyriteData::$pagination;
if($page*PyriteConfig::BLOG_INDEX_PAGINATION < getMaxPosts()-PyriteConfig::BLOG_INDEX_PAGINATION) {
	echo("<p class=align-left><a href='".getURLBlog()."archive/tag/".PyriteData::$temp."/".($page+1)."'>&lt;- older</a></p>");
}
if($page > 0) {
	echo("<p class=align-right><a href='".getURLBlog()."archive/tag/".PyriteData::$temp."/".($page-1)."'>newer -&gt;</a></p>");
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