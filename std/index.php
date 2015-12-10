<?php include_once("header.php");
echo("<h1>Games</h1>");

$db = init_db();
$statement = $db->prepare(
	"SELECT name, code FROM game ORDER BY name ASC"
);
$result = $statement->execute();

while($arr = $result->fetchArray(SQLITE3_ASSOC))
{
	$name = $arr["name"];
	$code = $arr["code"];

	echo ("<p><a href='/std/g/{$code}'>{$name}</a></p>");
}

include_once("footer.php");
?>