package js.three;

import js.html.*;

@:native("THREE.MeshStandardMaterial")
extern class MeshStandardMaterial extends Material
{
	function new(?parameters:MeshStandardMaterialParameters) : Void;

	var color : Color;// diffuse
	var emissive : Color;
	var roughness : Color;
	var metalness : Float;
	var metal : Bool;
	var map : Texture;
	var lightMap : Texture;
	var lightMapIntensity : Float;
	var aoMap : Texture;
	var aoMapIntensity : Float;
	var emissiveMap : Texture;
	var bumpMap : Texture;
	var bumpScale : Float;
	var normalMap : Texture;
	var normalScale : Vector2;
	var displacementMap : Texture;
	var displacementScale : Float;
	var displacementBias : Float;
	var specularMap : Texture;
	var alphaMap : Texture;
	var envMap : Texture;
	var combine : Combine;
	var reflectivity : Float;
	var refractionRatio : Float;
	var fog : Bool;
	var shading : Shading;
	var wireframe : Bool;
	var wireframeLinewidth : Float;
	var wireframeLinecap : String;
	var wireframeLinejoin : String;
	var vertexColors : Colors;
	var skinning : Bool;
	var morphTargets : Bool;
	var morphNormals : Bool;

	@:overload(function():MeshStandardMaterial{})
	override function clone() : Material;
	function copy(source:MeshStandardMaterial) : MeshStandardMaterial;
}