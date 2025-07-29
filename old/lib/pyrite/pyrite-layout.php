<?php namespace pyrite;
/**
 * Class used for layout operations.
 */
class layout
{
	private $map;
	private $folder;

	function __construct($folder = null)
	{
		$this->map = new \pyrite\map();
		$this->folder = $folder;
	}

	function set($key, $value) { $this->map->set($key, $value); }
	function get($key) { return $this->map->get($key); }
	function pget($key) { echo $this->get($key); }

	function addcss($style)
	{
		$url = $this->url("css/".$style.".css");
		$css = $this->get("css");
		$css .= "<link rel=\"stylesheet\" type=\"text/css\" href=\"".$url."\" />";
		$this->set("css", $css);
	}

	/**
	 * Returns the filesystem path to the root of the layout.
	 *
	 * \param  resource
	 *           if non-null, the resource to get the URL to
	 */
	function path($resource = null)
	{
		$folder = $this->folder;
		if (null === $folder) {
			$folder = "";
		}
		if (null === $resource) {
			$resource = "";
		}

		return \pyrite\cfg::$root.$folder.$resource;
	}

	/**
	 * Returns the URL to the root of the layout.
	 *
	 * \param  resource
	 *           if non-null, the resource to get the URL to
	 */
	function url($resource = null)
	{
		$folder = $this->folder;
		if (null === $folder) {
			$folder = "";
		}
		if (null === $resource) {
			$resource = "";
		}

		if(file_exists (\pyrite\cfg::$root.".git/")) {
			return \pyrite\cfg::$url_test.$folder.$resource;
		} else {
			return \pyrite\cfg::$url_live.$folder.$resource;
		}
	}

	/**
	 * Returns the URL to the root url of the website.
	 *
	 * \param  resource
	 *           if non-null, the resource to get the URL to
	 */
	function base($resource = null)
	{
		if (null === $resource) {
			$resource = "";
		}

		if(file_exists (\pyrite\cfg::$root.".git/")) {
			return \pyrite\cfg::$url_test.$resource;
		} else {
			return \pyrite\cfg::$url_live.$resource;
		}
	}

	function purl($resource = null) { echo $this->url($resource); }
}
?>
