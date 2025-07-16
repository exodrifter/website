<?php namespace Pyrite; ?>
<!DOCTYPE html>
<html>
<head>
<title><?php putPageTitle(); ?></title>
<meta charset='utf-8'>
<script><?php include(getPathTheme()."skel-cfg.php"); ?></script>
<script src='<?php echo getURLBlog(); ?>js/skel.min.js'></script>
<!--<script src='/js/ga.min.js'></script>-->
<link rel='alternate' type='application/rss+xml' title='@author dpek Global Feed' href='<?php echo getURLBlog(); ?>feed'>
</head>
<body>
<div id='header'>
<div class='container'>
<div class='row'>
<div class='6u'>
<a style='text-decoration:none' href='<?php echo(getURLBase());?>'><h1 class='title'><?php putBlogName(); ?></h1></a>
</div>
<div class='6u nav'>
<a class='nav' href='<?php echo(getURLBlog());?>'>Blog</a>
<a class='nav' href='<?php echo(getURLBase());?>portfolio'>Portfolio</a>
<a class='nav' href='<?php echo(getURLBase());?>games'>Games</a>
<a class='nav' href='<?php echo(getURLBase());?>music'>Music</a>
</div>
</div>
</div>
</div>
