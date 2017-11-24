package wl.post.colorhilight;
import createjs.tweenjs.Ease;
import createjs.tweenjs.Tween;
import dat.gui.GUI;
import haxe.Resource;
import haxe.macro.Type;
import js.three.Color;
import js.three.Mesh;
import js.three.OrthographicCamera;
import js.three.PlaneBufferGeometry;
import js.three.Renderer;
import js.three.RenderTarget;
import js.three.Scene;
import js.three.ShaderMaterial;
import js.three.WebGLRenderTarget;
import js.three.WebGLRenderer;
import wl.core.Demo;
import wl.core.TimeSig;

/**
 * ...
 * @author Henri Sarasvirta
 */
class ColorHilight
{
	public var uniforms:Dynamic = {
		range: { type: 'f', value: 0.03 },
		value1: { type: 'f', value: 0.2 },
		value2: { type: 'f', value: 0.5 },
		amount: { type: 'f', value: 0.0 },
		original: { type: 'f', value: 1 },
		color1: { type: 'v4', value: [1.0,1.0,1.0,1] },
		color2: { type: 'v4', value: [1.0,1.0,1.0,1] },
		tile: { type: 'v2', value: [1.0,1.0] },
		tDiffuse: {type:"t"}
	};
	
	public var range(default, set):Float = 0.01;
	public function set_range(value:Float):Float { this.range = value; this.uniforms.range.value = value; return value; }
	public var value1(default, set):Float = 0.01;
	public function set_value1(value:Float):Float { this.value1 = value; this.uniforms.value1.value = value; return value; }
	public var value2(default, set):Float = 0.01;
	public function set_value2(value:Float):Float { this.value2 = value; this.uniforms.value2.value = value; return value; }
	public var amount(default, set):Float = 0.01;
	public function set_amount(value:Float):Float { this.amount = value; this.uniforms.amount.value = value; return value; }
	public var original(default, set):Float = 0.01;
	public function set_original(value:Float):Float { this.original = value; this.uniforms.original.value = value; return value; }
	public var color1(default, set):Int = 0xffffff;
	public function set_color1(value:Int):Int { this.color1 = value; this.uniforms.color1.value = [((value>>16)&0xff)/255, ((value>>8)&0xff)/255, (value&0xff)/255,1]; return value; }
	public var color2(default, set):Int = 0xffffff;
	public function set_color2(value:Int):Int { this.color2 = value; this.uniforms.color2.value =  [((value>>16)&0xff)/255, ((value>>8)&0xff)/255, (value&0xff)/255,1]; return value; }
	
	public function setupDatGui(folder:GUI):Void
	{
		var f:GUI = folder.addFolder("Color hilight");
		f.add(this, "range").step(0.0001).min( 0).max(1).onChange(function(value:Float):Void { this.range = value; } );
		f.add(this, "value1").step(0.0001).min( 0).max(1).onChange(function(value:Float):Void { this.value1 = value; } );
		f.add(this, "value2").step(0.0001).min( 0).max(1).onChange(function(value:Float):Void { this.value2 = value; } );
		f.add(this, "amount").step(0.0001).min( 0).max(1).onChange(function(value:Float):Void { this.amount = value; } );
		f.addColor(this, "color1").onChange(function(value:Int):Void { this.color1 = value; } );
		f.addColor(this, "color2").onChange(function(value:Int):Void { this.color2 = value; } );
		f.add(this, "original").min(0).max(1).onChange(function(value:Int):Void { this.original = value; } );
		f.add(this, "testSweep");
	}
	public var testSweep:Bool = false;
	public var enabled:Bool;
	public var renderToScreen:Bool;
	public var needsSwap:Bool;
	private var material:ShaderMaterial;
	public var targetVal:Float = 40;
	private var sweep:Float = 0;
	
	private var camera:OrthographicCamera = new OrthographicCamera( - 1, 1, 1, - 1, 0, 1 );
	private var scene:Scene  = new Scene();
	
	private var quad:Mesh = new Mesh( new PlaneBufferGeometry( 2, 2 ), null );
	
	public function new() 
	{
		this.enabled = true;
		
		this.material = new ShaderMaterial({
			uniforms:this.uniforms,
			fragmentShader:Resource.getString("colorhilight.frag"),
			vertexShader:Resource.getString("colorhilight.vert")
		});
		
		this.renderToScreen = false;
		this.needsSwap = true;
		
		this.quad.material = this.material;
		
		this.scene.add(this.quad);
	}
	
	public function render(renderer:WebGLRenderer, writeBuffer:WebGLRenderTarget, readBuffer:WebGLRenderTarget, delta:Float):Void
	{
		if (testSweep)
		{
			this.value1 = (Demo.instance.previousTS.toMilliseconds() / 1000) % 1;
			this.value2 = (0.5+Demo.instance.previousTS.toMilliseconds() / 1000) % 1;
			
		}
		this.uniforms.tDiffuse.value = readBuffer.texture;
		if (this.renderToScreen)
			renderer.render(scene, camera);
		else
			renderer.render(scene, camera, writeBuffer, false);
	}
	
	public function doSweep(time:Int):Void
	{
		this.sweep = 0;
	//	this.uniforms.amount.value = 4;// Math.min(1, sweep * 10);
		Tween.get(this, { onChange:sweepUpdate } ).to( { sweep: 1 }, time, Ease.quadInOut);// .call(function() { this.uniforms.amount.value = 0;// Math.min(1, sweep * 10);

	}
	
	private function sweepUpdate():Void
	{
		this.uniforms.amount.value = targetVal;// Math.min(1, sweep * 10);
		this.uniforms.value1.value = sweep;
		this.uniforms.value2.value = (sweep + 0.5) % 1;
		this.uniforms.original.value = 1;// - 0.2 * Math.sin(sweep * Math.PI);
	}
}