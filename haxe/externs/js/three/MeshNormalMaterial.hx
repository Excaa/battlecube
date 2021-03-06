package js.three;

import js.html.*;

@:native("THREE.MeshNormalMaterial")
extern class MeshNormalMaterial extends Material
{
	function new(?parameters:MeshNormalMaterialParameters) : Void;

	var wireframe : Bool;
	var wireframeLinewidth : Float;
	var morphTargets : Bool;

	@:overload(function():MeshNormalMaterial{})
	override function clone() : Material;
	function copy(source:MeshNormalMaterial) : MeshNormalMaterial;
}