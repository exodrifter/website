<?php namespace Pyrite; require_once("pyrite.php");?>
<?php putTemplate("header.php"); ?>
<div class='container'>
<div class='row'>
<section class='12u'>
<div class='focus'>
<h1>Music</h1>
<p>I make music under the name Deramico and you can get my music at
<a href='http://deramico.com/'>Bandcamp</a> or see my works in progress
at <a href='https://soundcloud.com/deramico'>SoundCloud</a>.</p>
<p>Here's my most recent album:</p>
<div style='margin-bottom:1.5em'><iframe style="border: 0; width: 100%; height: 120px;" src="http://bandcamp.com/EmbeddedPlayer/album=3367837472/size=large/bgcol=ffffff/linkcol=0687f5/tracklist=false/artwork=small/transparent=true/" seamless><a href="http://deramico.com/album/light-pollution">Light Pollution by Deramico</a></iframe></div>
<div class='space'></div>
<h2>Usage &amp; Attribution</h2>
<p>All of my music on Bandcamp is available for free as long as it
follows the creative commons license “by-nc-sa 3.0″ unless otherwise
noted. You can read more about the license at the official site
<a href='http://creativecommons.org/licenses/by-nc-sa/3.0/'>here</a>.
Please attribute the work by stating my artist name, “Deramico”,
and by linking to the page <a href="http://www.deramico.com">deramico.com</a>.
It would also be nice if you could also mention which album and song
you used, so that people can find what they are looking for more easily,
but you don’t have to do that.</p>
<p>This means you can use my music in any non-commercial game, podcast,
stream, etc. without having to pay me anything or tell me about it, as
long as you follow the by-nc-sa 3.0 license.</p>
<div class='space'></div>
<!--
<h2>Music Contact Form</h2>
<p>You can use the contact form to contact me for just about anything music
related. Let me know if you use my music so I can check out what you did with
it! I’d love to see it :)</p>
<p><i>All fields are required</i></p>
<form id='contactform' method='post' action='<?php //echo(getURLBlog()); ?>contact-music.php'>
	<div><label for='name'>
		<span>Name:</span>
		<input type='text' name='name' maxlength='80' tabindex='1' placeholder='Please enter your name'>
	</label></div>
	<div><label for='email'>
		<span>Email Address:</span>
		<input type='email' name='email' maxlength='80' tabindex='2' placeholder='Please enter your email address'>
	</label></div>
	<div><label for='subject'>
		<span>Subject:</span>
		<input type='text' name='subject' maxlength='80' tabindex='3' placeholder='Please enter the subject'></p>
	</label></div>
	<div><label for='message'>
		<span>Message:</span>
		<textarea name='message' rows='6' tabindex='4' placeholder='Please enter a message'></textarea></p>
	</label></div>
	<div><button name="submit" type='submit'>Send Email</button></div>
</form>
-->
</div>
</section>
</div>
</div>
<?php putTemplate("footer.php"); ?>