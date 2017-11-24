package wl.post.dof;
import dat.gui.GUI;
import haxe.Resource;
import js.three.Camera;
import js.three.EffectComposer;
import js.three.Mesh;
import js.three.OrthographicCamera;
import js.three.PerspectiveCamera;
import js.three.PlaneBufferGeometry;
import js.three.Renderer;
import js.three.Scene;
import js.three.ShaderMaterial;
import js.three.Texture;
import js.three.Three;
import js.three.WebGLRenderer;
import js.three.WebGLRenderTarget;
import js.three.Vector2;
import wl.core.Config;
import wl.core.Demo;
import wl.core.Graphics;

/**
 * ...
 * @author Henri Sarasvirta
 */
class DoF 
{
    public var uniforms:Dynamic = {
		"textureWidth":  	{ type:'f', value: 1.0 },
		"textureHeight":  	{ type:'f', value: 1.0 },

		"focalDepth":   	{ type:'f', value: 2.8 },
		"focalLength":   	{ type:'f', value: 35.0 },
		"fstop": 			{ type:'f', value: 2.2 },
		
		"tColor":   		{ type:'t', value: null },
		"tDepth":   		{ type:'t', value: null },
		
		"maxblur":  		{ type:'f', value: 1.0 },
		
		"depthblur":   		{ type:'b', value: 0 },
		
		"threshold":  		{ type:'f', value: 0.5 },
		"gain":  			{ type:'f', value: 2.0 },
		"bias":  			{ type:'f', value: 0.5 },
		"fringe":  			{ type:'f', value: 0.7 },
		
		"znear":  			{ type:'f', value: 0.1 },
		"zfar":  			{ type:'f', value: 100 },
		
		"noise":  			{ type:'b', value: 1 },
		"dithering":  		{ type:'f', value: 0.0001 },
		"pentagon": 		{ type:'b', value: 0 },

		"shaderFocus":  	{ type:'b',  value: 1 },
		"focusCoords":  	{ type:'v2', value: new Vector2(0.5,0.5) },
		
		/*
            "tColor":   { type: "t", value: null },
			"tDepth":   { type: "t", value: null },
			"focus":    { type: "f", value: 0.4 },
			"aspect":   { type: "f", value: 1.0 },
			"aperture": { type: "f", value: 0.001 },
			"maxblur":  { type: "f", value: 40.0 },
			"zfar": 	{ type: "f", value: 150.0 },
			"znear": 	{ type: "f", value: 10.0 },
			"x":  { type: "f", value: 0.0 },
			"resolution":  { type: "v2", value: new Vector2(1280,720) }*/
	};
	
	
	private var material:ShaderMaterial;
	
	public var enabled:Bool;
	public var renderToScreen:Bool;
	public var needsSwap:Bool;
	
	private var blurX:WebGLRenderTarget;
	
	private var camera:OrthographicCamera = new OrthographicCamera( - 1, 1, 1, - 1, 0, 1 );
	private var scene:Scene  = new Scene();
	
	private var quad:Mesh = new Mesh( new PlaneBufferGeometry( 2, 2 ), null );
	
	public var focalDepth(default, set):Float=0;
	public var focalLength(default,set):Float=90;
	public var fstop(default,set):Float=1;
	public var maxblur(default,set):Float=1;
	public var depthblur(default,set):Bool = false;
	public var threshold(default,set):Float=0;
	public var gain(default,set):Float=0;
	public var bias(default,set):Float=0;
	public var fringe(default,set):Float=0;
	public var noise(default,set):Bool=false;
	public var dithering(default,set):Float=0.00001;
	public var pentagon(default,set):Bool = false;
	public var shaderFocus(default, set):Bool = true;
	public var focusCoords(default,set):Vector2=new Vector2(0.5, 0.5);
	
	private function set_focalDepth(value:Float):Float { this.focalDepth = value; uniforms.focalDepth.value = value; return value; }
	private function set_focalLength(value:Float):Float { this.focalLength = value; uniforms.focalLength.value = value; return value; }
	private function set_fstop(value:Float):Float { this.fstop = value; uniforms.fstop.value = value; return value; }
	private function set_maxblur(value:Float):Float { this.maxblur = value; uniforms.maxblur.value = value; return value; }
	private function set_depthblur(value:Bool):Bool { this.depthblur = value; uniforms.depthblur.value = value; return value; }
	private function set_threshold(value:Float):Float { this.threshold = value; uniforms.threshold.value = value; return value; }
	private function set_gain(value:Float):Float { this.gain = value; uniforms.gain.value = value; return value; }
	private function set_bias(value:Float):Float { this.bias = value; uniforms.bias.value = value; return value; }
	private function set_fringe(value:Float):Float { this.fringe = value; uniforms.fringe.value = value; return value; }
	private function set_noise(value:Bool):Bool { this.noise = value; uniforms.noise.value = value; return value; }
	private function set_dithering(value:Float):Float { this.dithering = value; uniforms.dithering.value = value; return value; }
	private function set_pentagon(value:Bool):Bool { this.pentagon = value; uniforms.pentagon.value = value; return value; }
	private function set_shaderFocus(value:Bool):Bool { this.shaderFocus = value; uniforms.shaderFocus.value = value; return value; }
	private function set_focusCoords(value:Vector2):Vector2 { this.focusCoords = value; uniforms.focusCoords.value = value; return value; }
	
	public function setupDatGui(folder:GUI):Void
	{
		var f:GUI = folder.addFolder("DoF");
		f.add(this, "focalDepth").step(0.01).onChange(function(value:Float) { focalDepth = value; } );
		f.add(this, "focalLength").step(0.01).onChange(function(value:Float) { focalLength = value; } );
		f.add(this, "fstop").step(0.01).onChange(function(value:Float) { fstop = value; } );
		f.add(this, "maxblur").step(0.01).onChange(function(value:Float) { maxblur = value; } );
		f.add(this, "depthblur").onChange(function(value:Bool) { depthblur = value; } );
		f.add(this, "threshold").step(0.01).onChange(function(value:Float) { threshold = value; } );
		f.add(this, "gain").step(0.01).onChange(function(value:Float) { gain = value; } );
		f.add(this, "bias").step(0.01).onChange(function(value:Float) { bias = value; } );
		f.add(this, "fringe").step(0.01).onChange(function(value:Float) { fringe = value; } );
		f.add(this, "noise").onChange(function(value:Bool) { noise = value; } );
		f.add(this, "dithering").step(0.01).onChange(function(value:Float) { dithering = value; } );
		f.add(this, "pentagon").onChange(function(value:Bool) { pentagon = value; } );
		f.add(this, "shaderFocus").onChange(function(value:Bool) { shaderFocus = value; } );
		
		f.add(this.focusCoords, "x").step(0.01).onChange(function(value:Float) { this.uniforms.focusCoords.value[0] = value; } );
		f.add(this.focusCoords, "y").step(0.01).onChange(function(value:Float) { this.uniforms.focusCoords.value[1] = value; } );
	}
	
	private var sceneCamera:PerspectiveCamera;
	
	public function new(depth:Texture, camera:Camera) 
	{
		this.sceneCamera = cast camera;
		var vert:String = Resource.getString("dof.vert");
		var frag:String = Resource.getString("dof.frag");
		
		this.uniforms.tDepth.value = depth;
		this.uniforms.textureWidth.value = Config.RESOLUTION[0];
		this.uniforms.textureHeight.value = Config.RESOLUTION[1];
		
		this.material = new ShaderMaterial( {
			uniforms: this.uniforms,
			vertexShader: vert,
			fragmentShader:frag
		} );
		this.enabled = true;
		this.renderToScreen = false;
		this.needsSwap = true;
		
		this.quad.material = material;
			
		this.scene.add( this.quad );
	}
	
	public function render(renderer:WebGLRenderer, writeBuffer:WebGLRenderTarget, readBuffer:WebGLRenderTarget, delta:Float)
	{
		this.uniforms.zfar.value = this.sceneCamera.far;
		this.uniforms.znear.value = this.sceneCamera.near;
		
		this.uniforms.tColor.value = readBuffer.texture;
		if (this.renderToScreen)
			renderer.render(scene, camera);
		else
			renderer.render(scene, camera, writeBuffer, false);
	}
}