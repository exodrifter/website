<?php require_once("../../pyrite.php"); require_once("../util.php");
$LAYOUT = new \pyrite\layout("res/");
$nav = getNavigation("alphabet", "names");

$nouns = startWordTable();
$nouns .= wordTableRow("greeting", "nal");
$nouns .= wordTableRow("goodbye", "hqs");
$nouns .= wordTableRow("morning", "sil");
$nouns .= wordTableRow("noon", "al");
$nouns .= wordTableRow("evening", "elwol");
$nouns .= wordTableRow("night", "gul");
$nouns .= endWordTable();
$suffixes = startWordTable();
$suffixes .= wordTableRow("verb (subject)", "-va");
$suffixes .= wordTableRow("verb (object)", "-mana");
$suffixes .= wordTableRow("adjective/adverb", "-ko");
$suffixes .= endWordTable();
$pronouns = startWordTable();
$pronouns .= wordTableRow("I, me", "sol");
$pronouns .= wordTableRow("you", "fq");
$pronouns .= endWordTable();
$ex1 = startTranslationTable();
$ex1 .= translationTableRow("Good morning.", "silko nalva.");
$ex1 .= translationTableRow("Good afternoon.", "alko nalva.");
$ex1 .= translationTableRow("Good evening.", "elwolko nalva.");
$ex1 .= translationTableRow("Good night.", "gulko nalva.");
$ex1 .= endTranslationTable();

$content = <<<EOT
<div class='container'><div class='focus'><div class='row'>
<section class='12u'>
<p><a href="../">&lt;&lt; Back to index</a></p>
<h1>Greetings and Goodbyes</h1>
<p><i>Nouns:</i></p>
$nouns
<p><i>Suffixes:</i></p>
$suffixes
<p><i>Pronouons:</i></p>
$pronouns
<hr class='divider'/>
<p>Baskiv sentences use Subject-Object-Verb (SOV) order. For example, the
equivalent of the English sentence "I love you" in SOV order is "I you love".
There are also more complex sentence structures that Baskiv uses, but these will
be covered in later lessons.</p>
<p>In the Baskiv language, there are no words that are only verbs, adjectives,
or adverbs. Instead, nouns are converted to verbs, adjectives, or adverbs by
using the corresponding suffix. For example, the word in Baskiv for "greeting"
can be changed to a verb by appending the verb suffix
<span class='baskiv'>-va</span>.</p>
<p>So, to say hello to someone:</p>
<p class='block baskiv'>sol fq nalva!</p>
<p>And to say goodbye:</p>
<p class='block baskiv'>sol fq hqsva!</p>
<p>It is important to recognize the distinction between the suffix
<span class='baskiv'>-va</span> and <span class='baskiv'>-mana</span>.
<span class='baskiv'>-va</span> is used when the subject, in this case the
speaker, is doing the action. Because of this, it is possible to say hello to
someone by only saying <span class='baskiv'>nalva</span>; it will be inferred
that the speaker is greeting someone or something. On the other hand, if
<span class='baskiv'>nalmana</span> is said instead, it will be inferred that
the speaker is describing a person or thing that is greeting the speaker.</p>
<p>In Baskiv, the words for morning, afternoon, evening, and night can be
changed into an adverb to describe a verb with the suffix <span class='baskiv'>
-ko</span>. For example, to say good morning, good afternoon, good evening, or
good night:</p>
$ex1
<p>It should be noted that the above sentences make the assumption that the
speaker is saying hello to whomever they are talking to. Additionally, the
phrase for good night in the above table does not imply sleep; it is just a
greeting given at night. To bid someone farewell at night, you would instead
say <span class='baskiv'>gulko hqsva</span>.</p>
$nav
</section>
</div></div></div>
EOT;

$LAYOUT->set("title", "Baskiv: Greetings and Goodbyes");
$LAYOUT->set("content", $content);
$LAYOUT->addcss("baskiv");

include $LAYOUT->path("template/base.php");
?>
