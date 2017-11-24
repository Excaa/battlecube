package js.three;

import js.html.*;

@:native("THREE.EquirectangularToCubemap")
extern class EquirectangularToCubemap
{
	function new(renderer:Renderer) : Void;

	function convert(source:Texture, size:Int):CubeTexture;
}
