package wl.post.pixelate;
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
class Pixelate
{
	public var uniforms:Dynamic = {
			resolution: {type:"v2", value: new Vector2(1280,720)},
            tDiffuse: {type:"t"},
            pixelamount: {type:"v2", value: new Vector2(128,72)},
	};
	
	public var enabled:Bool;
	public var renderToScreen:Bool;
	public var needsSwap:Bool;
	private var material:ShaderMaterial;
	
	
	
	private var camera:OrthographicCamera = new OrthographicCamera( - 1, 1, 1, - 1, 0, 1 );
	private var scene:Scene  = new Scene();
	
	private var quad:Mesh = new Mesh( new PlaneBufferGeometry( 2, 2 ), null );
	public var pixelamount(default, set):Vector2 = new Vector2(128,72);
	public function set_pixelamount(value:Vector2):Vector2 { this.pixelamount = value; this.uniforms.pixelamount.value = value; return value; }
	
	public function setupDatGui(folder:GUI):Void
	{
		var f:GUI = folder.addFolder("Pixelate");
		f.add(this.pixelamount, "x").step(1).min(1).max(Config.RESOLUTION[0]).onChange(function(val:Float):Void { this.uniforms.pixelamount.value = this.pixelamount; } );
		f.add(this.pixelamount, "y").step(1).min(1).max(Config.RESOLUTION[1]).onChange(function(val:Float):Void { this.uniforms.pixelamount.value = this.pixelamount; } );
	}
	
	public function new(?pixelamount:Array<Float>) 
	{
		if (pixelamount != null) this.uniforms.pixelamount.value = pixelamount;
		this.enabled = true;
		
		this.material = new ShaderMaterial({
			uniforms:this.uniforms,
			vertexShader: Resource.getString("pixelate.vert"),
			fragmentShader:Resource.getString("pixelate.frag")
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
