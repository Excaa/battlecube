package wl.post.cga;
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
import js.three.Vector3;
import js.three.WebGLRenderTarget;
import js.three.WebGLRenderer;
import wl.core.Config;

/**
 * ...
 * @author Henri Sarasvirta
 */
class CGA
{
	public var uniforms:Dynamic = {
			resolution: {type:"v2", value: new Vector2(1280,720)},
            tDiffuse: {type:"t"},
			amount: { type:"f", value: 0 },
			colors: { type:"v3v", value:[
				new Vector3(0,0,0),
				new Vector3(0.35,0.35, 0.35),
				new Vector3(0.,0.,0.66),
				new Vector3(0.35, 0.35, 1.),
				new Vector3(0., 0.66,0.),
				new Vector3(0.35, 0.66,0.35),
				new Vector3(0., 0.66, 0.66),
				new Vector3(0.35, 1., 1.),
				new Vector3(0.66, 0., 0.),
				new Vector3(1., 0.35, 0.35),
				new Vector3(0.66, 0., 0.66),
				new Vector3(1., 0.35, 1.),
				new Vector3(0.66, 0.35, 0.0),
				new Vector3(1., 1., 0.35),
				new Vector3(0.66, 0.66, 0.66),
				new Vector3(1., 1., 1.)
			]}
	};
	
	public var enabled:Bool;
	public var renderToScreen:Bool;
	public var needsSwap:Bool;
	private var material:ShaderMaterial;
	private var camera:OrthographicCamera = new OrthographicCamera( - 1, 1, 1, - 1, 0, 1 );
	private var scene:Scene  = new Scene();
	
	private var quad:Mesh = new Mesh( new PlaneBufferGeometry( 2, 2 ), null );
	
	public var amount(default, set):Float = 0;
	public function set_amount(value:Float):Float { this.amount = value; this.uniforms.amount.value = value; return value; }
	
	public function setupDatGui(folder:GUI):Void
	{
		var f:GUI = folder.addFolder("CGA");
		f.add(this, "amount").step(0.1).min(0).max(1).onChange(function(val:Float):Void { this.uniforms.amount.value = this.amount; } );
	}
	
	public function new() 
	{
		this.enabled = true;
		
		this.material = new ShaderMaterial({
			uniforms:this.uniforms,
			vertexShader: Resource.getString("cga.vert"),
			fragmentShader:Resource.getString("cga.frag")
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
