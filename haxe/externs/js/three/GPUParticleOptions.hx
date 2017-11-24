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
class GPUParticleOptions
{
	public var position:Vector3 = new Vector3();
	public var velocity:Vector3 = new Vector3();
	public var positionRandomness:Float = 0;
	public var velocityRandomness:Float = 0;
	public var color:Int = 0xFFFFFF;
	public var colorRandomness:Float=0;
	public var turbulence:Float=0;
	public var lifetime:Float=0;
	public var size:Float = 0;
	public var sizeRandomness:Float = 0;
	public var triggerVelocity:Vector3;
	public var triggerRandomness:Float;
	public var triggerTurbulence:Float;
	/**
	 * This creates a Ambientlight with a color.
	 * @param hex Numeric value of the RGB component of the color.
	 */
	public function new() : Void
	{
	}

}