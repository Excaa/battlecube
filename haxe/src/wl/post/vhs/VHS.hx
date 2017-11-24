package wl.post.vhs;
import dat.gui.GUI;
import haxe.Resource;
import js.three.Mesh;
import js.three.OrthographicCamera;
import js.three.PlaneBufferGeometry;
import js.three.Renderer;
import js.three.RenderTarget;
import js.three.Scene;
import js.three.ShaderMaterial;
import js.three.Texture;
import js.three.Vector2;
import js.three.WebGLRenderTarget;
import js.three.WebGLRenderer;
import js.three.Wrapping;
import wl.core.Assets;
import wl.core.Config;
import wl.core.Demo;
import wl.core.Graphics;

/**
 * ...
 * @author Henri Sarasvirta
 */
class VHS
{
	public var uniforms:Dynamic = {
			resolution: {type:"v2", value: new Vector2(1280,720)},
            tDiffuse: { type:"t" },
			tNoise: {type:"t"},
            intensity: { type:"f", value: 1 },
			jitter: {type:"f", value: 1},
			time: {type:"f", value: 1},
			size: {type:"f", value:0.97},
			holdTime: {type:"f", value:0.0},
			colorNoise: {type:"f", value:0.0},
	};
	
	public var enabled:Bool;
	public var renderToScreen:Bool;
	public var needsSwap:Bool;
	private var material:ShaderMaterial;
	private var holdTime:Float = 0;
	
	
	private var camera:OrthographicCamera = new OrthographicCamera( - 1, 1, 1, - 1, 0, 1 );
	private var scene:Scene  = new Scene();
	
	private var quad:Mesh = new Mesh( new PlaneBufferGeometry( 2, 2 ), null );
	public var jitter(default, set):Float = 1;
	public function set_jitter(value:Float):Float { this.jitter = value; this.uniforms.jitter.value = value; return value; }
	public var intensity(default, set):Float = 1;
	public function set_intensity(value:Float):Float { this.intensity = value; this.uniforms.intensity.value = value; return value; }
	public var size(default, set):Float = 0.97;
	public function set_size(value:Float):Float { this.size = value; this.uniforms.size.value = value; return value; }
	public var hold(default, set):Bool = false;
	public function set_hold(value:Bool):Bool{ this.hold = value; return value; }
	public var colorNoise(default, set):Float = 0.1;
	public function set_colorNoise(value:Float):Float { this.colorNoise = value; this.uniforms.colorNoise.value = value; return value; }

	
	public function setupDatGui(folder:GUI):Void
	{
		var f:GUI = folder.addFolder("VHS");
		f.add(this, "intensity").step(0.01).min(0).max(1).onChange(function(val:Float):Void { this.uniforms.intensity.value = this.intensity; } );
		f.add(this, "jitter").step(0.01).min(0).max(1).onChange(function(val:Float):Void { this.uniforms.jitter.value = this.jitter; } );
		f.add(this, "size").step(0.01).min(0).max(1).onChange(function(val:Float):Void { this.uniforms.size.value = this.size; } );
		f.add(this, "colorNoise").step(0.01).min(0).max(10).onChange(function(val:Float):Void { this.uniforms.colorNoise.value = this.colorNoise; } );
		f.add(this, "hold").onChange(function(val:Bool):Void{this.hold = val;});
	}
	
	public function new() 
	{
		this.enabled = true;
		
		this.material = new ShaderMaterial({
			uniforms:this.uniforms,
			vertexShader: Resource.getString("vhs.vert"),
			fragmentShader:Resource.getString("vhs.frag")
		});
		var t:Texture = Assets.getTexture("noise.png");
		t.wrapS = Wrapping.RepeatWrapping;
		t.wrapT =  Wrapping.RepeatWrapping;
		this.uniforms.tNoise.value = t;
		
		this.renderToScreen = false;
		this.needsSwap = true;
		
		this.quad.material = this.material;
		
		this.scene.add(this.quad);
	}
	
	public function render(renderer:WebGLRenderer, writeBuffer:WebGLRenderTarget, readBuffer:WebGLRenderTarget, delta:Float):Void
	{
		this.uniforms.tDiffuse.value = readBuffer.texture;
		
		var newtime = Demo.instance.previousTS.toMilliseconds();
		this.uniforms.time.value = newtime / 1000;
		
		if (hold){
			this.uniforms.holdTime.value = holdTime / 1000;
		}
		else{
			holdTime += Math.isNaN(Graphics.instance.delta) ? 0 : Graphics.instance.delta;
			this.uniforms.holdTime.value = holdTime / 1000;
		}
		
		if (this.renderToScreen)
			renderer.render(scene, camera);
		else
			renderer.render(scene, camera, writeBuffer, false);
	}
}
