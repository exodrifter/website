<?php require_once("../pyrite.php"); require_once("util.php");
$LAYOUT = new \pyrite\layout("res/");

function getBaskivResults($db, $q) {
	$statement = $db->prepare("SELECT * FROM baskiv WHERE word=:word");
	$statement->bindValue(":word", $q, SQLITE3_TEXT);
	$results = $statement->execute();
	while($result = $results->fetchArray())
	{
		if(!isset($result["id"])) continue;

		$word = $result["word"];
		$id = $result["id"];
		$statement = $db->prepare(
			"SELECT english.word AS word FROM english
			 INNER JOIN wordpairs ON wordpairs.id_english=english.id
			 WHERE id_baskiv=:id");
		$statement->bindValue(":id", $id, SQLITE3_INTEGER);
		$items = $statement->execute();

		$itemStr = "";
		while($item = $items->fetchArray())
		{
			if(!isset($item["word"])) continue;
			$itemStr .= $item["word"] . ", ";
		}
		$itemStr = substr($itemStr, 0, strlen($itemStr)-2);

		$pro = romanizeBaskiv($word);
		return "<p><span class='baskiv'>$word</span> ($pro) - $itemStr</p>";
	}
}

function getEnglishResults($db, $q) {
	$statement = $db->prepare(
		"SELECT baskiv.word AS word FROM baskiv
		 INNER JOIN wordpairs ON wordpairs.id_baskiv=baskiv.id
		 INNER JOIN english ON wordpairs.id_english=english.id
		 WHERE english.word=:word");
	$statement->bindValue(":word", $q, SQLITE3_TEXT);
	$results = $statement->execute();
	$ret = "";
	while($result = $results->fetchArray())
	{
		if(!isset($result["word"])) continue;
		$ret .= getBaskivResults($db, $result["word"]);
	}
	return $ret;
}

$results = "";
if(isset($_GET["q"]))
{
	$db = new \SQLite3("dictionary.db", SQLITE3_OPEN_READONLY);

	$results .= getBaskivResults($db, $_GET["q"]);
	$results .= getEnglishResults($db, $_GET["q"]);
}

$content = <<<EOT
<div class='container'><div class='focus'><div class='row'>
<section class='12u'>
<p><a href="index.php">&lt;&lt; Back to index</a></p>
<h1 class='title' style='text-align:center;'>English-Baskiv Dictionary</h1>
<hr />
<form style='margin: 2em 0 2em 0' action='dictionary.php' method='get'>
<input style='width:100%' type='text' name='q' autofocus>
</form>
$results
</section>
</div></div></div>
EOT;

$LAYOUT->set("title", "English-Baskiv Dictionary");
$LAYOUT->set("content", $content);
$LAYOUT->addcss("baskiv");

include $LAYOUT->path("template/base.php");
?>
