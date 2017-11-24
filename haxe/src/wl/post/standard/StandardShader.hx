package wl.post.standard;
import dat.gui.GUI;
import haxe.Resource;
import js.three.Mesh;
import js.three.OrthographicCamera;
import js.three.PlaneBufferGeometry;
import js.three.Renderer;
import js.three.RenderTarget;
import js.three.Scene;
import js.three.ShaderMaterial;
import js.three.WebGLRenderTarget;
import js.three.WebGLRenderer;

/**
 * ...
 * @author Henri Sarasvirta
 */
class StandardShader
{
	public var uniforms:Dynamic = {
        brightness: {type:"f", value: 0.0},
        gamma: {type:"f", value: 0.0},
		tDiffuse: {type:"t"}
	};
	
	public var brightness(default, set):Float=0;
	public var gamma(default, set):Float=1;
	private function set_brightness(val:Float):Float { return this.uniforms.brightness.value = val; }
	private function set_gamma(val:Float):Float { return this.uniforms.gamma.value = val; }
	
	public function setupDatGui(folder:GUI):Void
	{
			var f:GUI = folder.addFolder("Standard");
			f.add(this, "brightness").onChange(function(val:Float):Void { this.uniforms.brightness.value = this.gamma; } );
			f.add(this, "gamma").onChange(function(val:Float):Void { this.uniforms.gamma.value = this.gamma; } );
	}
	
	
	public var enabled:Bool;
	public var renderToScreen:Bool;
	public var needsSwap:Bool;
	private var material:ShaderMaterial;
	
	
	private var camera:OrthographicCamera = new OrthographicCamera( - 1, 1, 1, - 1, 0, 1 );
	private var scene:Scene  = new Scene();
	
	private var quad:Mesh = new Mesh( new PlaneBufferGeometry( 2, 2 ), null );
	
	public function new(?gamma:Float) 
	{
		if (gamma == null) gamma = 1;
		this.gamma = gamma;
		this.enabled = true;
		
		this.material = new ShaderMaterial({
			uniforms:this.uniforms,
			vertexShader: Resource.getString("standard.vert"),
			fragmentShader:Resource.getString("standard.frag")
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