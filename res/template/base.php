<?php
// Pre-process the title
$title = $LAYOUT->get("title");
if (null === $title) {
	$title = "exodrifter";
} else {
	$title = "exodrifter - ".$title;
}
?>
<!DOCTYPE HTML>
<html>
	<head>
		<title><?php echo $title ?></title>
		<link rel="shortcut icon" href="<?php $LAYOUT->purl("favicon.ico") ?>">
		<link rel="stylesheet" type="text/css" href="<?php $LAYOUT->purl("css/nav.css") ?>">
		<link rel="stylesheet" type="text/css" href="<?php $LAYOUT->purl("css/main.css") ?>">
<?php $LAYOUT->pget("css"); ?>
		<link href='http://fonts.googleapis.com/css?family=Orbitron' rel='stylesheet' type='text/css'>
		<link href='http://fonts.googleapis.com/css?family=Titillium+Web' rel='stylesheet' type='text/css'>
		<link href='http://fonts.googleapis.com/css?family=Iceland' rel='stylesheet' type='text/css'>
		<script src="<?php $LAYOUT->purl("js/skel.min.js") ?>"></script>
		<script src="<?php $LAYOUT->purl("js/skel.cfg.js") ?>"></script>
	</head>
	<body<?php if ($LAYOUT->get("page") !== "index") echo(" style=\"margin-bottom: 35%;\""); ?>>
<?php include $LAYOUT->path("template/navbar.php"); ?>
<?php $LAYOUT->pget("content"); ?>
	</body>
</html>
