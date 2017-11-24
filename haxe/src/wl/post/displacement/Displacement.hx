package wl.post.displacement;
import createjs.tweenjs.Ease;
import createjs.tweenjs.Tween;
import dat.gui.GUI;
import haxe.Resource;
import haxe.macro.Type;
import js.three.Color;
import js.three.Mesh;
import js.three.Object3D;
import js.three.OrthographicCamera;
import js.three.PlaneBufferGeometry;
import js.three.Renderer;
import js.three.RenderTarget;
import js.three.Scene;
import js.three.ShaderMaterial;
import js.three.Texture;
import js.three.Vector3;
import js.three.WebGLRenderTarget;
import js.three.WebGLRenderer;
import js.three.Wrapping;
import wl.core.Demo;
import wl.core.TimeSig;

/**
 * ...
 * @author Henri Sarasvirta
 */
class Displacement
{
	public var uniforms:Dynamic = {
		scaleX: { type: 'f', value: 0.03 },
		scaleY: { type: 'f', value: 0.03 },
		zoom: { type:'f', value: 1},
		tDiffuse: { type:"t" },
		tDispMap: { type:"t" },
		offset: {type:'f2', value:[0,0]}
	};
	
	public var scaleX(default, set):Float = 0.01;
	public function set_scaleX(value:Float):Float { this.scaleX = value; this.uniforms.scaleX.value = value; return value; }
	public var scaleY(default, set):Float = 0.01;
	public function set_scaleY(value:Float):Float { this.scaleY = value; this.uniforms.scaleY.value = value; return value; }
	public var zoom(default, set):Float = 0.01;
	public function set_zoom(value:Float):Float { this.zoom = value; this.uniforms.zoom.value = value; return value; }
	
	public function setupDatGui(folder:GUI):Void
	{
		var f:GUI = folder.addFolder("displacement (post)");
		f.add(this, "scaleX").step(0.0001).min( 0).max(1).onChange(function(value:Float):Void { this.scaleX = value; } );
		f.add(this, "scaleY").step(0.0001).min( 0).max(1).onChange(function(value:Float):Void { this.scaleY = value; } );
		f.add(this, "zoom").step(0.0001).min( 0).max(100).onChange(function(value:Float):Void { this.zoom = value; } );
		
	}
	public var enabled:Bool;
	public var renderToScreen:Bool;
	public var needsSwap:Bool;
	private var material:ShaderMaterial;
	
	private var camera:OrthographicCamera = new OrthographicCamera( - 1, 1, 1, - 1, 0, 1 );
	private var scene:Scene  = new Scene();
	
	private var quad:Mesh = new Mesh( new PlaneBufferGeometry( 2, 2 ), null );
	
	public function new(dispmap:Texture ) 
	{
		dispmap.wrapS = Wrapping.RepeatWrapping;
		dispmap.wrapT = Wrapping.RepeatWrapping;
		
		this.enabled = true;
		
		this.material = new ShaderMaterial({
			uniforms:this.uniforms,
			fragmentShader:Resource.getString("displacement.frag"),
			vertexShader:Resource.getString("displacement.vert")
		});
		this.uniforms.tDispMap.value = dispmap;
		this.renderToScreen = false;
		this.needsSwap = true;
		
		this.quad.material = this.material;
		
		this.scene.add(this.quad);
	}
	
	public function render(renderer:WebGLRenderer, writeBuffer:WebGLRenderTarget, readBuffer:WebGLRenderTarget, delta:Float):Void
	{
		this.uniforms.tDiffuse.value = readBuffer.texture;
		
		if (this.renderToScreen)
			renderer.render(scene, camera);
		else
			renderer.render(scene, camera, writeBuffer, false);
	}
}
