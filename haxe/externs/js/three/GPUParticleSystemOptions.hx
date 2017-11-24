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
class GPUParticleSystemOptions
{
	public var maxParticles:Int;
	public var containerCount:Int;
	public var particleNoiseTex:Texture;
	public var particleSpriteTex:Texture;
	
	/**
	 * This creates a Ambientlight with a color.
	 * @param hex Numeric value of the RGB component of the color.
	 */
	public function new(?maxParticles:Int, ?containerCount:Int, ?particleNoiseTex:Texture, ?particleSpriteTex:Texture) : Void
	{
		this.maxParticles = maxParticles;
		this.containerCount = containerCount;
		this.particleNoiseTex = particleNoiseTex;
		this.particleSpriteTex = particleSpriteTex;
	}

}