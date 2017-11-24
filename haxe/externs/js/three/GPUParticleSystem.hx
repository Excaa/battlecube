package js.three;

import js.html.*;

/**
 * This light's color gets applied to all the objects in the scene globally.
 *
 * # example
 *     light = new THREE.AmbientLight( 0x404040 ); // soft white light
 *     scene.add( light );
 *
 * @source https://github.com/mrdoob/three.js/blob/master/src/lights/AmbientLight.js
 */
@:native("THREE.GPUParticleSystem")
extern class GPUParticleSystem extends Object3D
{
	/**
	 * This creates a Ambientlight with a color.
	 * @param hex Numeric value of the RGB component of the color.
	 */
	function new(options:GPUParticleSystemOptions) : Void;
	
	function update(time:Float):Void;
	function spawnParticle(options:GPUParticleOptions):Void;
	function trigger(active:Bool):Void;
}