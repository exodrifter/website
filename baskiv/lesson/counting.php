<?php require_once("../../pyrite.php"); require_once("../util.php");
$LAYOUT = new \pyrite\layout("res/");
$nav = getNavigation("names", null);
$words = startWordTable();
$words .= wordTableRow("Zero", "zet");
$words .= wordTableRow("One", "ane");
$words .= wordTableRow("Two", "fen");
$words .= wordTableRow("Three", "bq");
$words .= wordTableRow("Four", "sta");
$words .= wordTableRow("Five", "dqk");
$words .= wordTableRow("Six", "ino");
$words .= wordTableRow("Seven", "tan");
$words .= wordTableRow("Eight", "cl");
$words .= wordTableRow("Nine", "nov");
$words .= wordTableRow("Ten", "deka");
$words .= wordTableRow("Hundred", "hekto");
$words .= wordTableRow("Thousand", "kclo");
$words .= wordTableRow("Million", "mega");
$words .= wordTableRow("Billion", "giga");
$words .= wordTableRow("Quantity", "jin");
$words .= endWordTable();
$prefixes = startWordTable();
$prefixes .= wordTableRow("Place", "-sta");
$prefixes .= endWordTable();
$numbers = startTranslationTable();
$numbers .= translationTableRow("0", "0");
$numbers .= translationTableRow("1", "1");
$numbers .= translationTableRow("2", "2");
$numbers .= translationTableRow("3", "3");
$numbers .= translationTableRow("4", "4");
$numbers .= translationTableRow("5", "5");
$numbers .= translationTableRow("6", "6");
$numbers .= translationTableRow("7", "7");
$numbers .= translationTableRow("8", "8");
$numbers .= translationTableRow("9", "9");
$numbers .= endTranslationTable();
$ex1 = startTranslationTable();
$ex1 .= translationTableRow("Eleven", "ane deka ane");
$ex1 .= translationTableRow("Twenty Two", "fen deka fen");
$ex1 .= translationTableRow("Three hundred and eighty nine", "bq hekto cl nov");
$ex1 .= translationTableRow("Seven thousand, Six hundred and fourty five", "tan kclo ino sta dqk");
$ex1 .= endTranslationTable();
$ex2 = startTranslationTable();
$ex2 .= translationTableRow("Three hundred and nine", "bq hekto nov");
$ex2 .= translationTableRow("Seven thousand and six", "tan kclo ino");
$ex2 .= translationTableRow("Seven thousand, Six hundred and five", "tan kclo ino zet dqk");
$ex2 .= translationTableRow("Seven thousand, Six hundred and five", "tan kclo ino hekto dqk");
$ex2 .= endTranslationTable();
$ex3 = startTranslationTable();
$ex3 .= translationTableRow("Three hundred and eighty", "bq hekto cl deka");
$ex3 .= translationTableRow("Seven thousand and sixty", "tan kclo ino hekto");
$ex3 .= endTranslationTable();
$ex4 = startTranslationTable();
$ex4 .= translationTableRow("First", "anesta");
$ex4 .= translationTableRow("Second", "fensta");
$ex4 .= translationTableRow("Third", "bqsta");
$ex4 .= endTranslationTable();
$ex5 = startTranslationTable();
$ex5 .= translationTableRow("Three hundred and eighty nine", "bq hekto cl deka nov");
$ex5 .= translationTableRow("Seven thousand, six hundred and fourty five", "tan kclo ino hekto sta deka dqk");
$ex5 .= endTranslationTable();
$examples = startTranslationTable();
$examples .= translationTableRow("49", "49");
$examples .= translationTableRow("557", "557");
$examples .= translationTableRow("Five hundred and fifty seven", "dqk hekto dqk tan");
$examples .= translationTableRow("Six million, four thousand, and five", "ino mega sta kclo dqk");
$examples .= endTranslationTable();
$content = <<<EOT
<div class='container'><div class='focus'><div class='row'>
<section class='12u'>
<p><a href="../">&lt;&lt; Back to index</a></p>
<h1>Counting</h1>
<p><i>Nouns:</i></p>
$words
<p><i>Prefixes:</i></p>
$prefixes
<hr class='divider'/>
<p>Numbers can either be spelled out or defined numerically. The table for
Baskiv numbers follows:</p>
$numbers
<hr class='divider'/>
<p>To say a number, there are several formats. In order to specify a quantity
larger than 9, it is required to provide the word for that quantity. Because of
this, words such as "ten" or "hundred" in Baskiv are considered <i>quantity</i>
words rather than numbers. Because of this, they cannot be used by themselves.
For example:</p>
<?php startTranslationTable();
translationTableRow("Ten", "ane deka");
translationTableRow("Twenty", "fen deka");
translationTableRow("One hundred", "ane hekto");
translationTableRow("Three hundred", "bq hekto");
endTranslationTable(); ?>
<p>Specifying a quanity is sufficient enough to state the rest of the numbers.
For example:</p>
$ex1
<p>If a number contains a zero inside it, the number must have a corresponding
quantity or be assumed to be less than ten. Alternatively, the zero may be
stated. For example:</p>
$ex2
<p>If a number contains any number of zeroes at the end, it is sufficient to
state the quantity of the last non-zero number. For example:</p>
$ex3
<p>You can use a number to indicate place by adding the prefix "<span class='baskiv'>-sta</span>".
For example:</p>
$ex4
<p>Lastly, for emphasis and clarification, it is allowed to state the quantity
of a number at any time. For example:</p>
$ex5
<hr class='divider'/>
<p>Examples:</p>
$examples
$nav
</section>
</div></div></div>
EOT;

$LAYOUT->set("title", "Baskiv: Counting");
$LAYOUT->set("content", $content);
$LAYOUT->addcss("baskiv");

include $LAYOUT->path("template/base.php");

?>
