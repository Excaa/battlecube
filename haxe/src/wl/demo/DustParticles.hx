package wl.demo;

import js.Browser;
import js.html.CanvasElement;
import js.three.Blending;
import js.three.BoundingBox;
import js.three.CanvasTexture;
import js.three.Object3D;
import js.three.Sprite;
import js.three.SpriteMaterial;
import js.three.Vector2;
import wl.util.Random;

/**
 * ...
 * @author Petri Sarasvirta
 */
class DustParticles extends Object3D
{
	private var p:DustParameters;
	private var particleMaterial:SpriteMaterial;
	private var particles:Object3D;
	
	public function new(params:DustParameters) 
	{
		super();
		
		particles = new Object3D();
		p = params;
		particleMaterial = new SpriteMaterial( {
			map: new CanvasTexture( generateSprite() ),
			blending: Blending.AdditiveBlending,
			transparent:true
		} );
	
		for ( i in 0...p.amount) {
			var particle:Sprite = new Sprite( particleMaterial);
			particle.position.set(Random.range( p.minx, p.maxx), Random.range( p.miny, p.maxy), Random.range( -p.minz, p.maxz));
			particles.add( particle );
		}
		
		this.add(particles);
	}
	
	// Particles
	
	private function generateSprite():CanvasElement 
	{
		var canvas:CanvasElement = cast Browser.document.createElement( 'canvas' );
		canvas.width = cast p.particleSize.x;
		canvas.height = cast p.particleSize.y;
		var context = canvas.getContext( '2d' );
		var gradient = context.createRadialGradient( canvas.width / 2, canvas.height / 2, 0, canvas.width / 2, canvas.height / 2, canvas.width / 2 );
		gradient.addColorStop(untyped  0, 'rgba(255,255,255,1)' );
		gradient.addColorStop(untyped  0.2, 'rgba(0,255,255,1)' );
		gradient.addColorStop(untyped  0.4, 'rgba(0,0,64,1)' );
		gradient.addColorStop(untyped  1, 'rgba(0,0,0,1)' );
		context.fillStyle = gradient;
		context.fillRect( 0, 0, canvas.width, canvas.height );
		return canvas;
	}
	
	
	
}

class DustParameters{
	
	public function new(){
		
	}
	public var particleSize:Vector2;
	public var amount:Int;
	public var minx:Int;
	public var maxx:Int;
	public var miny:Int;
	public var maxy:Int;
	public var minz:Int;
	public var maxz:Int;
}