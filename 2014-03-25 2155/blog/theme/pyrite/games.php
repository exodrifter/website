<?php namespace Pyrite;
putTemplate("header.php");
openDBPosts();
?>
<div class='container'>
<div class='focus'>
<div class='row'>
<section class='12u'>
<h1>Games</h1>
<p>This is an exhaustive list of all games that I've worked on. If you'd
prefer to view a <i>portfolio</i> of what I consider to be my best work,
head over <a href='<?php echo(getURLBase()); ?>portfolio'>here</a>.</p>
<p>I split the list into three categories: Finished, In Development, and
In Limbo. In general, the most recently worked on games are first in the
list.</p>
<?php
// Posts
queryStatus();
while(nextStatus()) {
	queryGamesWithStatus(getStatusID());
	echo("<p><b>".getStatusName()."</b> - ".getStatusDescription()."</p>\n");
	echo("<ul>\n");
	while(nextGame()) {
		$dash = false;
		echo("<li>");
		echo(getGameName());
		if(getGameHasAbout()) {
			if(!$dash) { $dash=true; echo(" - "); }
			echo("<a href='".getURLBase()."games/".getGameShortName()."'>About</a> ");
		}
		if(getGameHasTag()) {
			if(!$dash) { $dash=true; echo(" - "); }
			$statement = PyriteData::$db_posts->prepare("SELECT * FROM tags WHERE id_tag=(:id)");
			$statement->bindValue(":id",getGameTag());
			$name = $statement->execute()->fetchArray();
			$name = $name["name"];
			echo("<a href='".getURLBlog()."archive/tag/".$name."'>Blog Posts</a> ");
		}
		echo("</li>");
	}
	echo("</ul>\n");
}
?>
</section>
</div>
</div>
</div>
<?php putTemplate("footer.php"); ?>
