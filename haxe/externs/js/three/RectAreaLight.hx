package js.three;

/**
 * ...
 * @author ...
 */

@:native("THREE.RectAreaLight")
extern class RectAreaLight extends Light
{

	function new(?hex:Int, ?intensity:Float, ?width:Float, ?height:Float) : Void;

	/**
	 * Light's intensity.
	 * Default — 1.0.
	 */
	var intensity : Float;
	
}