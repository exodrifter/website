<?php
function getNavigation($prev, $next) {
	$str = "";
	// Navigation
	if($prev)
		$str .= "<p style=\"float: left\"><a href='$prev.php'><- previous</a></p>";
	if($next)
		$str .= "<p style=\"float: right\"><a href='$next.php'>next -></a></p>";
	$str .= "<div clear:both; margin-bottom: 3em;'></div>";
	// Javascript key-bound browsing
	$str .= "<script>
	document.onkeydown = checkKey;

	function checkKey(e) {
		var url = false;
		e = e || window.event;";
		if($prev) {
			$str .= "	if(e.keyCode=='37'){url='$prev.php';}";
		}
		if($next) {
			$str .= "	if(e.keyCode=='39'){url='$next.php';}";
		}
		$str .= "
		if (url) {
			window.location = url;
		}
	}
	</script>
	";
	return $str;
}

function romanizeBaskiv($baskiv) {
	$chars = str_split($baskiv);
	$result = "";
	foreach ($chars as $ch) {
		if($ch === 'a') {
			$result .= "ah";
		} else if($ch === 'q') {
			$result .= "ae";
		} else if($ch === 'e') {
			$result .= "eh";
		} else if($ch === 'c') {
			$result .= "ee";
		} else if($ch === 'i') {
			$result .= "ih";
		} else if($ch === 'x') {
			$result .= "ai";
		} else if($ch === 'o') {
			$result .= "oh";
		} else if($ch === 'u') {
			$result .= "uh";
		} else if($ch === 'O') {
			$result .= "oo";
		} else {
			$result .= $ch;
		}
	}
	return $result;
}

function startWordTable() {
	return "<table style='width:90%; table-layout:fixed; margin-left:auto; margin-right:auto;'>";
}

function wordTableRow($english, $baskiv) {
	$str = "<tr><td style='width:40%'>$english</td>";
	$str .= "<td class='baskiv' style='width:40%'>$baskiv</td>";
	$str .= "<td style='width:20%'>".romanizeBaskiv($baskiv)."</td></tr>";
	return $str;
}

function endWordTable() {
	return "</table>";
}

function startTranslationTable() {
	$str = "<table style='width: 90%; margin-left:auto; margin-right:auto;'>";
	$str .= "<tr><td><u>English</u></td><td><u>Baskiv</u></td></tr>";
	return $str;
}

function translationTableRow($english, $baskiv) {
	$str = "<tr><td>$english</td>";
	$str .= "<td class='baskiv'>$baskiv</td></tr>";
	return $str;
}

function endTranslationTable() {
	return "</table>";
}
?>