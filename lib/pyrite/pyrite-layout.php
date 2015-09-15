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

	function purl($resource = null) { echo $this->url($resource); }
}
?>
