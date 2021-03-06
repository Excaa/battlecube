package js.three;

import js.html.*;

@:native("THREE.VideoTexture")
extern class VideoTexture extends Texture
{
	function new(
		video: VideoElement,
		?mapping:Mapping,
		?wrapS:Wrapping,
		?wrapT:Wrapping,
		?magFilter:TextureFilter,
		?minFilter:TextureFilter,
		?format:PixelFormat,
		?type:TextureDataType,
		?anisotropy:Int
		) : Void;

	//var generateMipmaps : Bool;
}