package js.three;

import js.html.*;

@:native("THREE.MaterialLoader")
extern class MaterialLoader
{
	function new(?manager:LoadingManager) : Void;

	var manager : LoadingManager;
	var textures : Dynamic<Texture>;

	function load(url:String, onLoad:Material->Void) : Void;
	function setCrossOrigin(crossOrigin:String) : Void;
	function setTextures(textures:Dynamic<Texture>) : Void;
	function getTexture(name:String) : Texture;
	function parse(json:Dynamic) : Material;
}