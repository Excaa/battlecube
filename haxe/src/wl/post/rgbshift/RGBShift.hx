package wl.post.rgbshift;

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
class RGBShift
{
	public var uniforms:Dynamic = {
		gshift: {type:"f", value: 0.04},
        rshift: {type:"f", value: 0.04},
        bshift: {type:"f", value: 0.0},
        tDiffuse: {type:"t"},
  	};
	
	public var enabled:Bool;
	public var renderToScreen:Bool;
	public var needsSwap:Bool;
	
	private var material:ShaderMaterial;
	private var camera:OrthographicCamera = new OrthographicCamera( - 1, 1, 1, - 1, 0, 1 );
	private var scene:Scene  = new Scene();
	private var quad:Mesh = new Mesh( new PlaneBufferGeometry( 2, 2 ), null );
	
	public var gshift(default, set):Float = 0.0;
	public function set_gshift(value:Float):Float { this.gshift = value; this.uniforms.gshift.value = value; return value; }
	public var rshift(default, set):Float = 0.0;
	public function set_rshift(value:Float):Float { this.rshift = value; this.uniforms.rshift.value = value; return value; }
	public var bshift(default, set):Float = 0.0;
	public function set_bshift(value:Float):Float { this.bshift = value; this.uniforms.bshift.value = value; return value; }
	
	public function setupDatGui(folder:GUI):Void
	{
		var f:GUI = folder.addFolder("RGB");
		f.add(this, "rshift").step(0.0001).min( -1).max(1).onChange(function(value:Float):Void { this.rshift = value; } );
		f.add(this, "gshift").step(0.0001).min( -1).max(1).onChange(function(value:Float):Void { this.gshift = value; } );
		f.add(this, "bshift").step(0.0001).min( -1).max(1).onChange(function(value:Float):Void { this.bshift = value; } );
	}
	
	public function new(?rshift:Float, ?gshift:Float, ?bshift:Float) 
	{
		if (rshift != null) this.rshift = rshift;
		else this.rshift = this.rshift;
		if (gshift != null) this.gshift = gshift;
		else this.gshift = this.gshift;
		if (bshift != null) this.bshift = bshift;
		else this.bshift = this.bshift;
		
		this.enabled = true;
		
		this.material = new ShaderMaterial({
			uniforms:this.uniforms,
			vertexShader: Resource.getString("rgbshift.vert"),
			fragmentShader:Resource.getString("rgbshift.frag")
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