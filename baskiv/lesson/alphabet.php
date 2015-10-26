<?php require_once("../../pyrite.php"); require_once("../util.php");
$LAYOUT = new \pyrite\layout("res/");
$nav = getNavigation(null, "greetings");
$content = <<<EOT
<div class='container'><div class='focus'><div class='row'>
<section class='12u'>
<p><a href="../">&lt;&lt; Back to index</a></p>
<h1>Alphabet</h1>
<p>
The Baskiv alphabet is composed of 27 characters. All of the consonants are
roughly equivalent to English letters, but vowels are more specific. Here is a
chart of English sounds to Baskiv letters:
</p>
<p><b>Consonants:</b></p>
<table style='width: 90%; text-align:center; table-layout: fixed; margin-left:auto; margin-right:auto;'>
<tr>
<td>b</td><td>d</td><td>f</td><td>g</td><td>h</td>
<td>j</td><td>k</td><td>l</td><td>m</td></tr>
<tr class='baskiv'>
<td>b</td><td>d</td><td>f</td><td>g</td><td>h</td>
<td>j</td><td>k</td><td>l</td><td>m</td></tr>
<tr>
<td>n</td><td>p</td><td>r</td><td>s</td><td>t</td>
<td>v</td><td>w</td><td>y</td><td>z</td></tr>
<tr class='baskiv'>
<td>n</td><td>p</td><td>r</td><td>s</td><td>t</td>
<td>v</td><td>w</td><td>y</td><td>z</td></tr>
</table>
<p><b>Vowels:</b></p>
<table style='width:90%; text-align:center; table-layout:fixed; margin-left:auto; margin-right:auto;'>
<tr>
<td>ah</td><td>ae</td><td>eh</td><td>ee</td><td>ih</td>
<td>ai</td><td>oh</td><td>uh</td><td>oo</td></tr>
<tr class='baskiv'>
<td>a</td><td>q</td><td>e</td><td>c</td><td>i</td>
<td>x</td><td>o</td><td>u</td><td>O</td></tr>
</table>
<hr class='divider'/>
<p>In Baskiv, words are broken up into syllables. For example, the English word
"home" would be pronounced as one syllable in English. To say the same sound in
Baskiv, it would be pronounced as two seperate syllables: "ho-me".<p>
<p>Vowels are also more specific than English. Here is a chart that describes
what each vowel sounds like:</p>
<table style='width:90%; margin-left:auto; margin-right:auto;'>
<tr><td>Baskiv</td><td>English</td></tr>
<tr><td class='baskiv'>a</td><td>Pronounced like the "a" in <b>a</b>lways</td></tr>
<tr><td class='baskiv'>q</td><td>Pronounced like the "a" in m<b>a</b>ybe</td></tr>
<tr><td class='baskiv'>e</td><td>Pronounced like the "e" in b<b>e</b>t</td></tr>
<tr><td class='baskiv'>c</td><td>Pronounced like the "e" in <b>ee</b>l</td></tr>
<tr><td class='baskiv'>i</td><td>Pronounced like the "i" in <b>i</b>nto</td></tr>
<tr><td class='baskiv'>x</td><td>Pronounced like the word <b>eye</b></td></tr>
<tr><td class='baskiv'>o</td><td>Pronounced like the "o" in <b>o</b>n</td></tr>
<tr><td class='baskiv'>u</td><td>Pronounced like the "u" in <b>u</b>ndo</td></tr>
<tr><td class='baskiv'>O/oo</td><td>Pronounced like the "o" in c<b>oo</b>l</td></tr>
</table>
<p>As a side note, you may notice in the above chart that <span class='baskiv'>
O</span> may also be written as two <span class='baskiv'>o</span>'s.</p>
<p>Other than these few points, you can in general pronounce words like you
would in English.</p>
<p>Throughout the lessons we will be using the alphabet chart of English sounds
to Baskiv letters as guidance for pronunciation.</p>
$nav
</section>
</div></div></div>
EOT;

$LAYOUT->set("title", "Baskiv: Alphabet");
$LAYOUT->set("content", $content);
$LAYOUT->addcss("baskiv");

include $LAYOUT->path("template/base.php");
?>
