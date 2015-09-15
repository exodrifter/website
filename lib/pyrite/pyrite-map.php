<?php namespace pyrite;
/**
 * Convenience map class.
 */
class map
{
	private $map;

	function __construct()
	{
		$this->map = [];
	}

	function set($key, $value)
	{
		$this->map[$key] = $value;
	}

	function get($key)
	{
		if (isset($this->map[$key])) {
			return $this->map[$key];
		}
		return null;
	}
}
?>
