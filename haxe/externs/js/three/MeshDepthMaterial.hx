package js.three;

import js.html.*;

@:native("THREE.MeshDepthMaterial")
extern class MeshDepthMaterial extends Material
{
	function new(?parameters:MeshDepthMaterialParameters) : Void;

	var wireframe : Bool;
	var wireframeLinewidth : Float;

	@:overload(function():MeshDepthMaterial{})
	override function clone() : Material;
	function copy(source:MeshDepthMaterial) : MeshDepthMaterial;
}