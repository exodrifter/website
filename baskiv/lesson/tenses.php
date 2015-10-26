<?php require_once("../../pyrite.php"); require_once("../util.php");
$LAYOUT = new \pyrite\layout("res/");
$nav = getNavigation(null, null);
$prefixes = startWordTable();
$prefixes .= wordTableRow("present tense", "-va");
$prefixes .= wordTableRow("past tense", "-vasa");
$prefixes .= wordTableRow("future tense", "-vaya");
$prefixes .= wordTableRow("present tense", "-mana");
$prefixes .= wordTableRow("past tense", "-manasa");
$prefixes .= wordTableRow("future tense", "-manaya");
$prefixes .= endWordTable();
$ex1 = startTranslationTable();
$ex1 .= translationTableRow("I count one.", "sol ane jinva.");
$ex1 .= translationTableRow("I counted two.", "sol fen jinva.");
$ex1 .= translationTableRow("I will count three.", "sol bq jinva.");
$ex1 .= endTranslationTable();
$content = <<<EOT
<div class='container'><div class='focus'><div class='row'>
<section class='12u'>
<p><a href="../">&lt;&lt; Back to index</a></p>
<h1>Past and Future Tense</h1>
<p><i>Prefixes:</i></p>
$prefixes
<hr class='divider'/>
<p>Up until this point, all examples have used present tense. It is possible to
specify when something had or will happen. To say something will happen in the
past, you add the <span class='baskiv'>-sa</span> suffix to the end of an
existing suffix. To say something will happen in the future, you add the
<span class='baskiv'>-ya</span> suffix to the end of an existing suffix.</p>
<p>For example:</p>
$ex1
$nav
</section>
</div></div></div>
EOT;

$LAYOUT->set("title", "Baskiv: Past and Future Tense");
$LAYOUT->set("content", $content);
$LAYOUT->addcss("baskiv");

include $LAYOUT->path("template/base.php");

?>
