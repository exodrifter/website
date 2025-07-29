<?php require_once("../pyrite.php");
$LAYOUT = new \pyrite\layout("res/");
$content = <<<EOT
<div class='container'><div class='focus'><div class='row'>
<section class='12u'>
<h1 class='title baskiv' style='text-align:center;'>Baskiv</h1>
<hr />
<p>
Here you can find resources about Baskiv and lessons on how to read and speak
it.
</p>
<h1>Resources</h1>
<ul>
<li>About Baskiv</li>
<li><a href='dictionary.php'>English-Baskiv Dictionary</a></li>
</ul>
<h1>Lessons</h1>
<ul>
<li><a href='lesson/alphabet.php'>Alphabet</a></li>
<li><a href='lesson/greetings.php'>Greetings and Goodbyes</a></li>
<li><a href='lesson/names.php'>Names</a></li>
<li><a href='lesson/counting.php'>Counting</a></li>
<li>Colors</li>
<li>Telling time</li>
<li><a href='lesson/tenses.php'>Past and Future Tense</a></li>
</ul>
</section>
</div></div></div>
EOT;
$LAYOUT->set("title", "Baskiv");
$LAYOUT->set("content", $content);
$LAYOUT->addcss("baskiv");

include $LAYOUT->path("template/base.php");
?>
