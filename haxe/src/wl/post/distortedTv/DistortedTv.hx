package wl.post.distortedTv;
import dat.gui.GUI;
import haxe.Resource;
import js.three.Mesh;
import js.three.OrthographicCamera;
import js.three.PlaneBufferGeometry;
import js.three.Scene;
import js.three.ShaderMaterial;
import js.three.WebGLRenderTarget;
import js.three.WebGLRenderer;
import wl.core.Demo;

/**
 * ...
 * @author Petri Sarasvirta
 */
class DistortedTv
{
	public var uniforms:Dynamic = {
		distortAmount: { type: 'f', value: 100.1 },
		tDiffuse: {type:"t"},
		greenamplify:{type:"f", value:1},
		blueamplify:{type:"f", value:1},
		vignAmount:{type:"f",value:1.00},
		time: { type:'f', value:0.0 },
		offsetAmount: { type:'f', value:0.0 },
		
		brightMultiplier: { type:'f', value:1.0 },
		brightLimit: { type:'f', value:1.0 },
		
	};
	public var distortAmount(default, set):Float = 100;
	public function set_distortAmount(value:Float):Float { this.distortAmount = value; this.uniforms.distortAmount.value = value; return value; }
	public var greenamplify(default, set):Float = 1.0;
	public function set_greenamplify(value:Float):Float { this.greenamplify = value; this.uniforms.greenamplify.value = value; return value; }
	public var blueamplify(default, set):Float = 1.0;
	public function set_blueamplify(value:Float):Float { this.blueamplify = value; this.uniforms.blueamplify.value = value; return value; }
	public var vignAmount(default, set):Float = 1.00;
	public function set_vignAmount(value:Float):Float { this.vignAmount = value; this.uniforms.vignAmount.value = value; return value; }
	public var offsetAmount(default, set):Float = 0.00;
	public function set_offsetAmount(value:Float):Float { this.offsetAmount = value; this.uniforms.offsetAmount.value = value; return value; }
	
	public var brightMultiplier(default, set):Float = 1.00;
	public function set_brightMultiplier(value:Float):Float { this.brightMultiplier = value; this.uniforms.brightMultiplier.value = value; return value; }
	public var brightLimit(default, set):Float = 1.00;
	public function set_brightLimit(value:Float):Float { this.brightLimit = value; this.uniforms.brightLimit.value = value; return value; }
	
	public function setupDatGui(folder:GUI):Void
	{
		var f:GUI = folder.addFolder("Distorted tv");
		f.add(this, "distortAmount").step(0.01).onChange(function(value:Float):Void { this.distortAmount = value; } );
		f.add(this, "greenamplify").step(0.01).onChange(function(value:Float):Void { this.greenamplify = value; trace("green change " + value); } );
		f.add(this, "blueamplify").step(0.01).onChange(function(value:Float):Void { this.blueamplify = value; } );
		f.add(this, "vignAmount").step(0.01).onChange(function(value:Float):Void { this.vignAmount = value; } );
		f.add(this, "offsetAmount").step(0.01).onChange(function(value:Float):Void { this.offsetAmount = value; } );
		
		f.add(this, "brightMultiplier").step(0.01).onChange(function(value:Float):Void { this.brightMultiplier = value; } );
		f.add(this, "brightLimit").step(0.01).onChange(function(value:Float):Void { this.brightLimit = value; } );
		
	}
	public var enabled:Bool;
	public var renderToScreen:Bool;
	public var needsSwap:Bool;
	
	private var material:ShaderMaterial;
	
	private var camera:OrthographicCamera = new OrthographicCamera( - 1, 1, 1, - 1, 0, 1 );
	private var scene:Scene  = new Scene();
	
	private var quad:Mesh = new Mesh( new PlaneBufferGeometry( 2, 2 ), null );
	
	public function new() 
	{
		this.enabled = true;
		
		this.material = new ShaderMaterial({
			uniforms:this.uniforms,
			fragmentShader:Resource.getString("distortedTv.frag"),
			vertexShader:Resource.getString("distortedTv.vert")
		});
		
		this.renderToScreen = false;
		this.needsSwap = true;
		
		this.quad.material = this.material;
		
		this.scene.add(this.quad);
	}
	
	public function setTime(t:Float):Void{
		this.uniforms.time.value = t;
	}
	
	public function setDistortion(t:Float):Void{
		this.uniforms.distortAmount.value = t;
	}
	
	public function render(renderer:WebGLRenderer, writeBuffer:WebGLRenderTarget, readBuffer:WebGLRenderTarget, delta:Float):Void
	{
		setTime(Demo.instance.previousTS.toMilliseconds() / 1000);
	//	this.uniforms.blueamplify.value = blueAmount;
	//	this.uniforms.greenamplify.value = greenAmount;
	//	this.uniforms.vignAmount.value = vignent;
		this.uniforms.tDiffuse.value = readBuffer.texture;
		if (this.renderToScreen)
			renderer.render(scene, camera);
		else
			renderer.render(scene, camera, writeBuffer, false);
	}
}