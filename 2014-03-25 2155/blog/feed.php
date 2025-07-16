<?php
namespace Pyrite;
require_once("pyrite.php");

header('Content-Type: application/xml; charset=utf-8');
?>
<?xml version="1.0" encoding="UTF-8" ?>
<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
<channel>
	<title>@author dpek</title>
	<atom:link href="<?php echo getBlogURL() ?>rss.php" rel="self" type="application/rss+xml" />
	<link><?php echo getBlogURL() ?></link>
	<language>en-us</language>
	<description>Mostly musings about game development, programming, and other maybe less relevant things</description>
	<copyright>Darwin Pek 2014 All rights reserved</copyright>
<?php
openDB();
prepareBBCodeParser();
queryPosts(0,5);
while ($post = nextPost()) {
	echo("\t<item>\n");
	echo("\t\t<title><![CDATA[".getPostTitle()."]]></title>\n");
	echo("\t\t<pubDate>".getPostDate()."</pubDate>\n");
	echo("\t\t<guid isPermaLink=\"false\">net.darwinpek.blog.".getPostID()."</guid>\n");
	echo("\t\t<link>http://www.darwinpek.net/blog/archive.php?p=".getPostID()."</link>\n");
	echo("\t\t<description>Blog post from @author dpek</description>\n");
	echo("\t</item>\n");
}
?>
</channel>
</rss>