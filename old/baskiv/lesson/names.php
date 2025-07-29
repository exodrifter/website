<?php require_once("../../pyrite.php"); require_once("../util.php");
$LAYOUT = new \pyrite\layout("res/");
$nav = getNavigation("greetings", "counting");

$nouns = startWordTable();
$nouns .= wordTableRow("name", "xvO");
$nouns .= wordTableRow("is, equation", "ro");
$nouns .= wordTableRow("It (gender neutral noun)", "til");
$nouns .= wordTableRow("He (male noun)", "bo");
$nouns .= wordTableRow("She (female noun)", "rq");
$nouns .= endWordTable();
$query = startWordTable();
$query .= wordTableRow("who", "dxme");
$query .= wordTableRow("what", "tome");
$query .= endWordTable();

$content = <<<EOT
<div class='container'><div class='focus'><div class='row'>
<section class='12u'>
<p><a href="../">&lt;&lt; Back to index</a></p>
<h1>Names</h1>
<p><i>Nouns:</i></p>
$nouns
<p><i>Query:</i></p>
$query
<hr class='divider'/>
<p>If your name is Stacey (<span class="baskiv">stqsc</span>), then you can say
what your name is with the following:</p>
<p class='baskiv block'>sol stqsc rova.</p>
<p>The literal interpretation of this sentence is "I am Stacey". It is ambiguous
whether or not the second word in the sentence is a name or just another object.
Therefore, the meaning of this sentence depends on context. However, if you
wanted to be more specific about it, you could say this:</p>
<p class='baskiv block'>sol xvOko stqsc rova.</p>
<p>Roughly translated, this means "I am named Stacey." Being specific can be
useful if your name could potentially be assumed for something else. For
example...</p>
<p class='baskiv block'>sol bo rova.</p>
<p>...could mean "I am male". However, if you name was <i>actually</i>
<span class="baskiv">bo</span>, you could make this clear by saying this
instead:</p>
<p class='baskiv block'>sol xvOko bo rova.</p>
<hr class='divider'/>
<p>In order to ask a question, it is sufficient to add the correct query word
at the beginning of the sentence. For example, to ask for someone's name:</p>
<p class='baskiv block'>tome xvO rova?</p>
<p>The literal interpretation of this sentence is something along the lines of
"What are you named?". As you can see, the subject of the sentence was
assumed to be "you". All query words will change the assumed subject to the
person or thing that the speaker is talking to.</p>
<p>If you wanted to ask who someone was, you could say:</p>
<p class='baskiv block'>dxme til rova?</p>
<p>Roughly translated, this means "Who are you?". In this sentence, it is not
necessary to say the second word, <span class="baskiv">til</span>.</p>
<hr class='divider' />
<p>You can say what someone else's name is by using the correct pronoun as the
subject of the sentence. For example...</p>
<p class='baskiv block'>til xvOko stqsc rova.</p>
<p>...means "He/She is named Stacey". Unlike English, use of the gender-neutral
pronoun is not considered offensive or derogatory. If you know the gender of the
person, you can say "He is named Stacey" or "She is named Stacey", respectively:
</p>
<p class='baskiv block'>bo xvOko stqsc rova.</p>
<p class='baskiv block'>rq xvOko stqsc rova.</p>
<hr class='divider' />
<h2>Example</h2>
<p style="margin-bottom:.5em" class='baskiv block'>jon: silko nalva!</p>
<p style="margin-bottom:.5em" class='baskiv block'>stqsc: nalva!</p>
<p style="margin-bottom:.5em" class='baskiv block'>jon: jon rova. tome xvO rova?</p>
<p style="margin-bottom:.5em" class='baskiv block'>stqsc: xvOko stqsc rova.</p>
<p style="margin-bottom:.5em" class='baskiv block'>kodc: tome til xvO rova?</p>
<p style="margin-bottom:.5em" class='baskiv block'>jon: rq stqsc rova.</p>
</p>
<p style="margin-bottom:.5em" class='block'>John: Good morning!</p>
<p style="margin-bottom:.5em" class='block'>Stacey: Hello!</p>
<p style="margin-bottom:.5em" class='block'>John: I'm John. What is your name?</p>
<p style="margin-bottom:.5em" class='block'>Stacey: My name is Stacey.</p>
<p style="margin-bottom:.5em" class='block'>Cody: What is their name?</p>
<p style="margin-bottom:.5em" class='block'>John: She is named Stacey.</p>
</p>
$nav
</section>
</div></div></div>
EOT;

$LAYOUT->set("title", "Baskiv: Names");
$LAYOUT->set("content", $content);
$LAYOUT->addcss("baskiv");

include $LAYOUT->path("template/base.php");
