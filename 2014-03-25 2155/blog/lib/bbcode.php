<?php
namespace Pyrite;
require_once("jbbcode-1.2.0/Parser.php");

class CodeDefinition extends \JBBCode\CodeDefinition {
	
	public function __construct() {
		parent::__construct();
		$this->setTagName("code");
	}

	public function asHtml(\JBBCode\ElementNode $el)
	{
		$content = "";
		foreach($el->getChildren() as $child) {
			foreach(explode("\n",$child->getAsText()) as $p) {
				if(!ctype_space($p)) {
					if($content === "") {
						$content .= htmlspecialchars($p,ENT_NOQUOTES);
					} else {
						$content .= "<br/>".htmlspecialchars($p,ENT_NOQUOTES);
					}
				}
			}
		}
		return "<p class='code'>".$content."</p>";
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

function createBBCodeParser() {
	$parser = new \JBBCode\Parser();
	$parser->addCodeDefinition(new CodeDefinition());
	$parser->addCodeDefinition(new UListDefinition());

	$builder = new \JBBCode\CodeDefinitionBuilder("center", "<p id='center'>{param}</p>");
	$parser->addCodeDefinition($builder->build());

	$builder = new \JBBCode\CodeDefinitionBuilder("quote", "<p id='quote'>{param}</p>");
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

	$builder = new \JBBCode\CodeDefinitionBuilder("post", "<a href='".getURLBlog()."archive/post/{option}'>{param}</a>");
	$builder->setUseOption(true);
	$parser->addCodeDefinition($builder->build());

	$builder = new \JBBCode\CodeDefinitionBuilder("game", "<a href='".getURLBase()."games/{option}'>{param}</a>");
	$builder->setUseOption(true);
	$parser->addCodeDefinition($builder->build());

	$builder = new \JBBCode\CodeDefinitionBuilder("img", "<img src='".getURLImage()."{option}' title=\"{param}\" />");
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