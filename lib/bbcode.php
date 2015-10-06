<?php
require_once("jbbcode-1.2.0/Parser.php");

class CodeDefinition extends \JBBCode\CodeDefinition {

	public function __construct() {
		parent::__construct();
		$this->setTagName("code");
	}

	public function asHtml(\JBBCode\ElementNode $el)
	{
		$pre = "<div class='line'>";
		$post = "</div>";
		$content = "";
		foreach($el->getChildren() as $child) {
			foreach(explode("\n",rtrim($child->getAsText())) as $p) {
				if($content === "") {
					if($p !== "" && !ctype_space($p)) {
						$content .= $pre.htmlspecialchars($p,ENT_NOQUOTES).$post;
					}
				}
				else {
					if($p === "") {
						$content .= $pre."&#10;".$post;
					}
					else {
						$content .= $pre.htmlspecialchars($p,ENT_NOQUOTES).$post;
					}
				}
			}
		}
		return "<div class='code'>".$content."</div>";
	}
}

class CodeLineDefinition extends \JBBCode\CodeDefinition {

	public function __construct() {
		parent::__construct();
		$this->setTagName("code");
		$this->setUseOption(true);
	}

	public function asHtml(\JBBCode\ElementNode $el)
	{
		$pre = "<div class='line'><div class='line-numbers'></div>";
		$post = "</div>";
		$plain = rtrim($el->getAsBBCode());
		$plain = preg_replace('/^.+\n/', '', $plain);
		$plain = substr($plain, 0, strrpos($plain, "\n"));
		$content = "";
		foreach(explode("\n",$plain) as $p) {
			if($content === "") {
				if(!ctype_space($p)) {
					$content .= $pre.htmlspecialchars($p,ENT_NOQUOTES).$post;
				}
			}
			else {
				$content .= $pre.htmlspecialchars($p,ENT_NOQUOTES).$post;
			}
		}
		return "<div class='code-line' style='counter-reset: lineNumber ".$el->getAttribute()."'>".$content."</div>";
	}
}

class ScriptDefinition extends \JBBCode\CodeDefinition {

	public function __construct() {
		parent::__construct();
		$this->setTagName("script");
	}

	public function asHtml(\JBBCode\ElementNode $el)
	{
		$content = "";
		foreach($el->getChildren() as $child) {
			foreach(explode("\n",$child->getAsText()) as $p) {
				if($content === "") {
					if(!ctype_space($p)) {
						$content .= str_replace(array("\n","\r"),'',htmlspecialchars($p,ENT_NOQUOTES));
					}
				}
				else {
					$content .= "&#x0A;".str_replace(array("\n","\r"),'',htmlspecialchars($p,ENT_NOQUOTES));
				}
			}
		}
		return "<p class='script'>".rtrim($content)."</p>";
	}
}

class QuoteDefinition extends \JBBCode\CodeDefinition {

	public function __construct() {
		parent::__construct();
		$this->setTagName("quote");
	}

	public function asHtml(\JBBCode\ElementNode $el)
	{
		$content = "";
		foreach($el->getChildren() as $child) {
			foreach(explode("\n",$child->getAsText()) as $p) {
				if($content === "") {
					if(!ctype_space($p)) {
						$content .= htmlspecialchars($p,ENT_NOQUOTES);
					}
				}
				else {
					$content .= htmlspecialchars($p,ENT_NOQUOTES);
				}
			}
		}
		return "<p class='quote'>".$content."</p>";
	}
}

class UListDefinition extends \JBBCode\CodeDefinition {

	public function __construct() {
		parent::__construct();
		$this->setTagName("ul");
		$this->nestLimit = -1;
	}

	public function asHtml(\JBBCode\ElementNode $el)
	{
		$content = '';
		foreach ($el->getChildren() as $child) {
			$content .= $child->getAsHTML();
		}

		$listPieces = explode("[*]", $content);
		unset($listPieces[0]);
		$listPieces = array_map(function($li) { return "<li>".str_replace("\n","",$li)."</li>"; }, $listPieces);
		return "<ul>".implode("", $listPieces)."</ul>\n";
	}
}

function createBBCodeParser($layout) {
	$parser = new \JBBCode\Parser();
	$parser->addCodeDefinition(new CodeDefinition());
	$parser->addCodeDefinition(new CodeLineDefinition());
	$parser->addCodeDefinition(new UListDefinition());
	$parser->addCodeDefinition(new QuoteDefinition());
	$parser->addCodeDefinition(new ScriptDefinition());

	$builder = new \JBBCode\CodeDefinitionBuilder("h1", "<h1>{param}</h1>");
	$parser->addCodeDefinition($builder->build());

	$builder = new \JBBCode\CodeDefinitionBuilder("h1", "<h1 id='{option}'>{param}</h1>");
	$builder->setUseOption(true);
	$parser->addCodeDefinition($builder->build());

	$builder = new \JBBCode\CodeDefinitionBuilder("h2", "<h2>{param}</h2>");
	$parser->addCodeDefinition($builder->build());

	$builder = new \JBBCode\CodeDefinitionBuilder("h2", "<h2 id='{option}'>{param}</h2>");
	$builder->setUseOption(true);
	$parser->addCodeDefinition($builder->build());

	$builder = new \JBBCode\CodeDefinitionBuilder("h3", "<h3>{param}</h3>");
	$parser->addCodeDefinition($builder->build());

	$builder = new \JBBCode\CodeDefinitionBuilder("h3", "<h3 id='{option}'>{param}</h3>");
	$builder->setUseOption(true);
	$parser->addCodeDefinition($builder->build());

	$builder = new \JBBCode\CodeDefinitionBuilder("h4", "<h4>{param}</h4>");
	$parser->addCodeDefinition($builder->build());

	$builder = new \JBBCode\CodeDefinitionBuilder("h4", "<h4 id='{option}'>{param}</h4>");
	$builder->setUseOption(true);
	$parser->addCodeDefinition($builder->build());

	$builder = new \JBBCode\CodeDefinitionBuilder("h5", "<h5>{param}</h5>");
	$parser->addCodeDefinition($builder->build());

	$builder = new \JBBCode\CodeDefinitionBuilder("h5", "<h5 id='{option}'>{param}</h5>");
	$builder->setUseOption(true);
	$parser->addCodeDefinition($builder->build());

	$builder = new \JBBCode\CodeDefinitionBuilder("h6", "<h6>{param}</h6>");
	$parser->addCodeDefinition($builder->build());

	$builder = new \JBBCode\CodeDefinitionBuilder("h6", "<h6 id='{option}'>{param}</h6>");
	$builder->setUseOption(true);
	$parser->addCodeDefinition($builder->build());

	$builder = new \JBBCode\CodeDefinitionBuilder("jump", "<a href='#{option}'>{param}</a>");
	$builder->setUseOption(true);
	$parser->addCodeDefinition($builder->build());

	$builder = new \JBBCode\CodeDefinitionBuilder("center", "<p class='center'>{param}</p>");
	$parser->addCodeDefinition($builder->build());

	$builder = new \JBBCode\CodeDefinitionBuilder("pre", "<span class='pre'>{param}</span>");
	$parser->addCodeDefinition($builder->build());

	$builder = new \JBBCode\CodeDefinitionBuilder("b", "<b>{param}</b>");
	$parser->addCodeDefinition($builder->build());

	$builder = new \JBBCode\CodeDefinitionBuilder("i", "<em>{param}</em>");
	$parser->addCodeDefinition($builder->build());

	$builder = new \JBBCode\CodeDefinitionBuilder("u", "<u>{param}</u>");
	$parser->addCodeDefinition($builder->build());

	$builder = new \JBBCode\CodeDefinitionBuilder("s", "<del>{param}</del>");
	$parser->addCodeDefinition($builder->build());

	$builder = new \JBBCode\CodeDefinitionBuilder("color", "<span style='color:{option}'>{param}</span>");
	$builder->setUseOption(true);
	$parser->addCodeDefinition($builder->build());

	$builder = new \JBBCode\CodeDefinitionBuilder("post", "<a href='".$layout->url()."archive/post/{option}'>{param}</a>");
	$builder->setUseOption(true);
	$parser->addCodeDefinition($builder->build());

	$builder = new \JBBCode\CodeDefinitionBuilder("game", "<a href='".$layout->url()."games/{option}'>{param}</a>");
	$builder->setUseOption(true);
	$parser->addCodeDefinition($builder->build());

	$builder = new \JBBCode\CodeDefinitionBuilder("img", "<img src='".$layout->url()."img/{option}' title=\"{param}\" />");
	$builder->setUseOption(true);
	$parser->addCodeDefinition($builder->build());

	$builder = new \JBBCode\CodeDefinitionBuilder("youtube", "<div class='video'><iframe width='420' height='315' src='//www.youtube.com/embed/{param}?rel=0' frameborder='0' allowfullscreen></iframe></div>");
	$parser->addCodeDefinition($builder->build());

	$builder = new \JBBCode\CodeDefinitionBuilder("url", "<a href='{option}' target='_blank'>{param}</a>");
	$builder->setUseOption(true);
	$parser->addCodeDefinition($builder->build());

	return $parser;
}

?>
