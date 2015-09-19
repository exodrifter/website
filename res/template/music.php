<?php
$content = <<<EOT
<div class="container"><div class="row"><div class="12u">

<h1>Music</h1>
<p>I occassionally make music and you can get it at
<a href="http://deramico.com">Bandcamp</a> or see works in progress at
<a href="http://soundcloud.com/exodrifter">SoundCloud</a>. Before producing
music as Exodrifter, I used the artist name Deramico.</p>

<h1>Albums</h1>
<ul class="album-list">
<li class="album-item"><a href="http://deramico.com/album/light-pollution"><img alt="Light Pollution" class="album" src="http://f1.bcbits.com/img/a2402678436_16.jpg" /></a></li>
<li class="album-item"><a href="http://deramico.com/album/back-to-the-void"><img alt="Back to the Void" class="album" src="http://f1.bcbits.com/img/a2095359065_16.jpg" /></a></li>
<li class="album-item"><a href="http://deramico.com/album/window"><img alt="Window" class="album" src="http://f1.bcbits.com/img/a3837502658_16.jpg" /></a></li>
<li class="album-item"><a href="http://deramico.com/album/kinesis"><img alt="Kinesis" class="album" src="http://f1.bcbits.com/img/a1613192623_10.jpg" /></a></li>
<li class="album-item"><a href="http://deramico.com/album/rising"><img alt="Rising" class="album" src="http://f1.bcbits.com/img/a2364096999_16.jpg" /></a></li>
</ul>

<h1 style="clear: left;">Usage & Attribution</h1>
<p>All of my music on Bandcamp is available for free as long as it follows the
<a href="https://creativecommons.org/licenses/by-nc-sa/3.0/">by-nc-sa 3.0</a>
creative commons license unless otherwise noted. You can read more about the
license at the official site here. Please attribute the work by stating my
artist name, "Exodrifter", and by linking to the site exodrifter.space. It
would also be nice if you could also mention which album and song you used, so
that people can find what they are looking for more easily, but you don't have
to do that.</p>

<p>This means you can use my music in any non-commercial game, podcast, stream,
etc. without having to pay me anything or tell me about it, as long as you
follow the by-nc-sa 3.0 license.</p>

<p>If you would like to use my music commercially, feel free to contact me by
using the contact form on my bandcamp page.</p>

</div></div></div>
EOT;
$LAYOUT->set("content", $content);
$LAYOUT->set("page", "music");
$LAYOUT->addcss("music");

include $LAYOUT->path("template/base.php");
?>
