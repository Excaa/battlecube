package wl.core;
import js.Browser;
import js.html.Element;
import js.html.Element;
import js.html.Performance;
import js.three.Camera;
import js.three.MeshDepthMaterial;
import js.three.MeshDepthMaterialParameters;
import js.three.PixelFormat;
import js.three.Scene;
import js.three.ShadowMapType;
import js.three.TextureFilter;
import js.three.WebGLRenderTargetCube;
import js.three.WebGLRenderer;
import js.three.WebGLRendererParameters;
import js.three.WebGLRenderTarget;
import js.three.WebGLRenderTargetOptions;

/**
 * ...
 * @author Henri Sarasvirta
 */
class Graphics
{
	public static var instance:Graphics;
	
	public var onRender:Signal;
	
	private var container:Element;
	private var stopped:Bool = true;
	private var last:Float = 0;
	private var interval:Float;
	public var delta:Float;
	public var canvas:Element;
	public var renderer:WebGLRenderer;
	public var depthMaterial:MeshDepthMaterial;
	
	public function new(?container:Element) 
	{
		
		if (instance == null) instance = this;
		else trace("Creating multiple Graphics instances. Are you sure?");
		
/*		if (renderPlugin == null)
			renderPlugin = new ThreeJSPlugin();*/
		
		this.initGraphics();
	}
	
	private function initGraphics():Void
	{
		this.onRender = new Signal();
		this.interval = 1000 / Config.FPS;
		
		var params:WebGLRendererParameters = { };
		params.antialias = Config.ANTIALIAS;
	//	untyped params.logarithmicDepthBuffer = true;
		this.renderer = new WebGLRenderer(params);
		renderer.setClearColor( Config.CLEAR_COLOR );
		renderer.autoClear = false;
		this.renderer.shadowMap.enabled = Config.ENABLE_SHADOWS;
		this.renderer.shadowMap.type = ShadowMapType.PCFSoftShadowMap;
	//	this.renderer.gammaOutput = true;
		untyped this.renderer.shadowMapCascade = true;
		this.renderer.setSize( Config.RESOLUTION[0], Config.RESOLUTION[1], true);
		this.canvas = this.renderer.domElement;
		this.canvas.id = "demoCanvas";
		this.depthMaterial = new MeshDepthMaterial();
	}
	
	public function start():Void
	{
		this.last = 0;
		this.stopped = false;
		renderLoop(0);
	}
	
	public function stop():Void
	{
		this.renderer.clear();
		this.stopped = true;
	}
    
    public function renderLoop(time:Float):Void
	{
		var now:Float = time;// Browser.window.performance.now();
		delta = now - this.last;
		if(Config.FPS <0 || delta >= this.interval)
		{
			this.last = now;
			this.onRender.emit(delta);
		}
		if(!this.stopped)
			Browser.window.requestAnimationFrame(renderLoop);
    };
	
	public function getRenderTarget(?format:PixelFormat):WebGLRenderTarget
	{
		var options:WebGLRenderTargetOptions = cast {};
		options.stencilBuffer = true;
		options.minFilter = TextureFilter.LinearFilter;
		options.magFilter = TextureFilter.LinearFilter;
		options.format =format == null ? cast PixelFormat.RGBAFormat : cast format;
		return new WebGLRenderTarget( Config.RESOLUTION[0], Config.RESOLUTION[1], options);
	}
	
	public function getRenderTargetCube():WebGLRenderTargetCube
	{
		var options:WebGLRenderTargetOptions = cast {};
		
		return new WebGLRenderTargetCube( 1024, 1024, options);
	}
	
}
