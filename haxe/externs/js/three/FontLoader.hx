package js.three;

/**
 * ...
 * @author Henri Sarasvirta
 */
@:native("THREE.FontLoader")
extern class FontLoader
{

	function new(?manager:Dynamic):Void;
	
	function load(url:String, onLoad:Dynamic, onProgress:Dynamic, onError:Dynamic):Void;
	
}