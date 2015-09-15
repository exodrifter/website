<?php
$content = <<<EOT
	<div class="container">
		<div class="row">
			<div class="9u 12u$(medium) 12u$(small)">
				<h1>Heading One</h1>
				<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum ut volutpat ligula. Proin tincidunt, ante vel placerat porta, quam augue condimentum est, ut consectetur ligula lectus nec purus. Pellentesque quis dui magna. Maecenas molestie orci et dui consequat convallis. Sed tempus mollis finibus. Cras ut tortor varius, imperdiet nisi id, iaculis ex. Proin magna massa, tempor nec lectus sit amet, ornare consequat magna. Nam elementum auctor pellentesque. Nam porttitor viverra pulvinar. Aliquam sed purus in dui varius tristique. Aliquam sagittis malesuada est, non mollis tortor congue nec. Integer dui urna, dignissim quis enim vel, efficitur euismod justo. Proin at viverra libero, id accumsan lectus.</p>
				<p>Nullam volutpat enim libero, id malesuada lectus egestas non. Duis efficitur fermentum lorem eu pretium. Etiam dapibus tristique ligula, vitae ultrices nisi rutrum sit amet. Vivamus tempus eget massa at elementum. Aenean sit amet laoreet massa. Pellentesque cursus tellus non ligula porta, consectetur mollis nunc lacinia. Nullam non ornare ligula, eu elementum neque. Donec faucibus, velit at suscipit consectetur, sapien augue fringilla lorem, eu posuere leo tortor at turpis. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Quisque ex erat, imperdiet ut sapien eu, faucibus scelerisque eros. Integer ac faucibus erat, sit amet ornare odio.</p>
				<p>Praesent tempus aliquet massa id suscipit. Suspendisse ac mollis elit, vel vulputate mauris. In in tortor neque. Mauris auctor consequat mi sed ultricies. Etiam ornare, metus non tempor fermentum, nunc est finibus augue, quis vulputate magna velit in ligula. Morbi porta mi mauris, ut sollicitudin nunc efficitur et. Aliquam tempor vel odio a volutpat. Aenean non nibh magna. Maecenas eget leo dictum, fermentum est placerat, porta mi. Integer pretium enim sit amet turpis sodales volutpat eget eu massa. Nullam placerat nisl leo, quis molestie nisl ultricies in. Fusce mattis, nulla in tincidunt mollis, enim arcu sollicitudin sapien, quis porttitor nunc elit finibus urna. Quisque a vulputate ante, sit amet aliquam enim. Curabitur laoreet fringilla leo, eu placerat lacus.</p>
				<p>Donec pellentesque dictum massa, sed molestie orci interdum in. Proin faucibus eleifend turpis, ut semper justo tristique vitae. Phasellus neque mauris, congue vitae congue at, porttitor in lectus. Interdum et malesuada fames ac ante ipsum primis in faucibus. Morbi ultrices est ante, vitae congue velit iaculis quis. Phasellus ultrices, quam venenatis tempus laoreet, sem leo dapibus libero, id imperdiet arcu elit convallis magna. Vivamus bibendum vitae neque et ultricies. Proin imperdiet mattis tellus. Duis laoreet volutpat rhoncus. Quisque non porta ipsum, in scelerisque purus. Proin in dolor et metus fermentum placerat porttitor dapibus est. Proin lobortis pretium pretium. Donec quis tincidunt turpis, ut laoreet arcu. Mauris ornare non urna fermentum rhoncus.</p>
				<p>Praesent congue laoreet erat, et interdum nisi viverra in. Suspendisse tincidunt non purus pharetra hendrerit. Suspendisse euismod malesuada orci vel tristique. Aenean vehicula sapien ac justo finibus sodales. Nulla ac finibus lorem. Sed dolor leo, sodales ultrices cursus in, consequat sed nunc. Cras sed iaculis neque. Sed at sodales nisi. Vestibulum tempor felis id tristique sagittis. Nullam purus ex, fringilla vel ante in, gravida placerat eros. Praesent luctus posuere magna, ut pulvinar sem efficitur nec.</p>
			</div>
			<div class="3u 12u$(medium) 12u$(small)">
				<h1>Sidebar</h1>
				<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum ut volutpat ligula. Proin tincidunt, ante vel placerat porta, quam augue condimentum est, ut consectetur ligula lectus nec purus. Pellentesque quis dui magna. Maecenas molestie orci et dui consequat convallis. Sed tempus mollis finibus. Cras ut tortor varius, imperdiet nisi id, iaculis ex. Proin magna massa, tempor nec lectus sit amet, ornare consequat magna. Nam elementum auctor pellentesque. Nam porttitor viverra pulvinar. Aliquam sed purus in dui varius tristique. Aliquam sagittis malesuada est, non mollis tortor congue nec. Integer dui urna, dignissim quis enim vel, efficitur euismod justo. Proin at viverra libero, id accumsan lectus.</p>
			</div>
		</div>
	</div>

EOT;
$LAYOUT->set("content", $content);
$LAYOUT->set("page", "blog");

include $LAYOUT->path("template/base.php");
?>
