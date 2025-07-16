<?php
namespace Pyrite;
putTemplate("header.php");
// Additional queries
queryYears();
queryCategory();
queryTags();
?>
<div class='container'>
<div class='row'>
<section class='9u'>
<h1 style='margin-bottom:.5em;'>Years</h1>
<?php
echo("<p>\n");
while($year = nextYear()) {
	echo("<a href='".getURLBlog()."archive/year/".$year."'>".$year."</a> \n");
}
echo("</p>\n");
?>
<h1 style='margin-bottom:.5em;'>Categories</h1>
<?php
echo("<p>\n");
while(nextCategory()) {
	echo("<a href='".getURLBlog()."archive/category/".strtolower(getCategoryName())."'>".getCategoryName()."</a> \n");
}
echo("</p>\n");
?>
<h1 style='margin-bottom:.5em;'>Tags</h1>
<?php
echo("<p>\n");
while(nextTag()) {
	echo("<a href='".getURLBlog()."archive/tag/".getTagName()."'>".getTagName()."</a> \n");
}
echo("</p>\n");
?>
</section>
<section class='3u'>
<?php putTemplate("sidebar.php"); ?>
</section>
</div>
</div>
<?php putTemplate("footer.php"); ?>

