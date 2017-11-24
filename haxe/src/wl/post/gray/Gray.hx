package wl.post.gray;
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
class Gray
{
	public var uniforms:Dynamic = {
            tDiffuse: { type:"t" },
			gray: {type:'f'}
	};
	
	public var enabled:Bool;
	public var renderToScreen:Bool;
	public var needsSwap:Bool;
	private var material:ShaderMaterial;
	
	
	
	private var camera:OrthographicCamera = new OrthographicCamera( - 1, 1, 1, - 1, 0, 1 );
	private var scene:Scene  = new Scene();
	
	private var quad:Mesh = new Mesh( new PlaneBufferGeometry( 2, 2 ), null );
	
	public var gray(default, set):Float = 0;
	public function set_gray(value:Float):Float { this.gray = value; this.uniforms.gray.value = value; return value; }
	
	public function setupDatGui(folder:GUI):Void
	{
		var f:GUI = folder.addFolder("Gray");
		f.add(this, "gray").step(0.01).min(0).max(1).onChange(function(val:Float):Void { this.uniforms.gray.value = this.gray; } );
	}
	
	public function new(?gray:Float) 
	{
		if(gray != null)
			this.gray = gray;
		this.enabled = true;
		
		this.material = new ShaderMaterial({
			uniforms:this.uniforms,
			vertexShader: Resource.getString("gray.vert"),
			fragmentShader:Resource.getString("gray.frag")
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
