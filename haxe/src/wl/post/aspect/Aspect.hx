package wl.post.aspect;
import dat.gui.GUI;
import haxe.Resource;
import js.three.Mesh;
import js.three.OrthographicCamera;
import js.three.PlaneBufferGeometry;
import js.three.Renderer;
import js.three.RenderTarget;
import js.three.Scene;
import js.three.ShaderMaterial;
import js.three.Vector2;
import js.three.WebGLRenderTarget;
import js.three.WebGLRenderer;
import wl.core.Config;

/**
 * ...
 * @author Henri Sarasvirta
 */
class Aspect
{
	public static var CROP:Int = 0;
	public static var FILL:Int = 1;
	
	
	public var uniforms:Dynamic = {
			resolution: {type:"v2", value: new Vector2(1280,720)},
            tDiffuse: {type:"t"},
            type: { type:"i", value: 0 },
			aspect:{type:"f", value: 16/9}
	};
	
	public var enabled:Bool;
	public var renderToScreen:Bool;
	public var needsSwap:Bool;
	private var material:ShaderMaterial;
	private var camera:OrthographicCamera = new OrthographicCamera( - 1, 1, 1, - 1, 0, 1 );
	private var scene:Scene  = new Scene();
	
	private var quad:Mesh = new Mesh( new PlaneBufferGeometry( 2, 2 ), null );
	public var type(default, set):Int = 0;
	public function set_type(value:Int):Int { this.type = value; this.uniforms.type.value = value; return value; }
	
	public var aspect(default, set):Float = 16/9;
	public function set_aspect(value:Float):Float { this.aspect = value; this.uniforms.aspect.value = value; return value; }
	
	public function setupDatGui(folder:GUI):Void
	{
		var f:GUI = folder.addFolder("Aspect");
		f.add(this, "type").step(1).min(0).max(2).onChange(function(val:Int):Void { this.uniforms.type.value = this.type; } );
		f.add(this, "aspect").step(0.1).min(1).max(4).onChange(function(val:Float):Void { this.uniforms.aspect.value = this.aspect; } );
	}
	
	public function new() 
	{
		this.enabled = true;
		
		this.material = new ShaderMaterial({
			uniforms:this.uniforms,
			vertexShader: Resource.getString("aspect.vert"),
			fragmentShader:Resource.getString("aspect.frag")
		});
		
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
