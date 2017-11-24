package wl.core;
import dat.gui.GUI;
import js.three.Color;
import js.three.Camera;
import js.three.CopyShader;
import js.three.EffectComposer;
import js.three.MeshBasicMaterial;
import js.three.PerspectiveCamera;
import js.three.PixelFormat;
import js.three.PixelType;
import js.three.RenderPass;
import js.three.Scene;
import js.three.ShaderPass;
import js.three.TextureDataType;
import js.three.Three;
import js.three.WebGLRenderTarget;
import js.three.Vector3;
import wl.core.Part.PostProcessing;
import wl.debug.ManualControl;
import wl.demo.TimeLine;
import wl.post.cga.CGA;
import wl.post.bloom.Bloom;
import wl.post.colorhilight.ColorHilight;
import wl.post.displacement.Displacement;
import wl.post.distortedTv.DistortedTv;
import wl.post.dof.DoF;
import wl.post.gray.Gray;
import wl.post.aspect.Aspect;
import wl.post.pixelate.Pixelate;
import wl.post.rgbshift.RGBShift;
import wl.post.vhs.VHS;

import wl.post.standard.StandardShader;

/**
 * ...
 * @author Henri Sarasvirta
 */
class Part
{
	public var name:String;
	//Current active timeline. If multiple, only latest is used. TODO - update this to support multiple?
	public var timeline:TimeLine;
	public var isActive:Bool = false;
	public var running:Bool = false;
	public var inTransition:Bool = false;
	public var renderToScreen:Bool = false;
	public var generateDepthMap:Bool = true;
	public var triggers:Map<TimeSig, Array<Dynamic>>;
	public var clearColor:Int=0;
	
	public var autoClear:Bool = true;
	public var effects:Array<Dynamic> = []; //TODO - replace with effect base class
	public var renderTo:WebGLRenderTarget;
	public var depthMap:WebGLRenderTarget;
	public var copyPass:ShaderPass;
	
	public var scene:Scene;
	public var camera:PerspectiveCamera;
	private var composer:EffectComposer;
	
	private var renderPass:RenderPass;
	private var postProcessing:PostProcessing = { };
	private var renderFormat:PixelFormat;
	
	public function new() 
	{
		
	}
	
	public function init():Void
	{
		this.triggers = new Map<TimeSig, Array<Dynamic>>();
		if(this.generateDepthMap)
		{
			this.depthMap = Graphics.instance.getRenderTarget();
		}
		this.renderTo = Graphics.instance.getRenderTarget(this.renderFormat);
		this.effects = [];
	}
	
	public function postInit():Void
	{
	}
	
	public function setupDatGui(folder:GUI):Void
	{
		if (this.camera != null)
		{
			var cam:GUI = folder.addFolder("camera");
			cam.add(camera, "fov").onChange(this.camera.updateProjectionMatrix);
			cam.add(camera, "near").onChange(this.camera.updateProjectionMatrix);
			cam.add(camera, "far").onChange(this.camera.updateProjectionMatrix);
		}
	}
	
	public function start(ts:TimeSig):Void
	{
		this.running = true;
	}
	
	public function stop():Void
	{
		this.running = false;		
	}
	
	public function setRenderToScreen(value:Bool):Void
	{
		this.renderToScreen = value;
	}
	
	public function update(ts:TimeSig, partial:Float, frameTime:Float, delta:Float):Void
	{
		
	}
	
	public function render(ts:TimeSig, frameTime:Float):Void
	{
		var r = Graphics.instance.renderer;
		
		//Generate depthmap if dof is used (or depthmap is wanted by part).
		if(this.generateDepthMap)
		{
			r.autoClear = true;
			r.setClearColor(0,1.0);
			this.scene.overrideMaterial = Graphics.instance.depthMaterial;
			Graphics.instance.renderer.render(this.scene, this.camera, this.depthMap);
			this.scene.overrideMaterial = null;
		}
		
		r.autoClear = this.autoClear;
		r.setClearColor(this.clearColor,1.0);
		
		//use composer if setup or pure render to target otherwise
		if(this.composer != null)
		{
			this.composer.render();
		}
		else
		{
			Graphics.instance.renderer.render(this.scene, this.camera, /*this.renderToScreen ? null :*/ this.renderTo);
		}
	}
	
	public function addTrigger(timesig:TimeSig, handler)
	{
		if(this.triggers.exists(timesig))
			this.triggers.get(timesig).push(handler);
		else 
			this.triggers.set(timesig,[handler]);
	}
	
	public function removeTrigger(handler,?timesig:TimeSig) {
		if (timesig != null && this.triggers.exists(timesig)) {
			this.triggers.get(timesig).remove(handler);
		}
		else {
			for (t in triggers) {
				while(t.indexOf(handler) >= 0)
					t.remove(handler);
			}
		}
	}
	
	public function addEffect(effect):Void
	{
		this.effects.push(effect);
	}
	
	public function initStandardScene()
	{
		this.scene = new Scene();
        this.camera = new PerspectiveCamera(30, Config.RESOLUTION[0] / Config.RESOLUTION[1], 0.1, 1000 );
        this.camera.position.y = 0;
		this.camera.position.x = 0;
        this.camera.position.z = 500;
		//this.camera.part = this;
        this.camera.lookAt(new Vector3(0,0,0));
        this.scene.autoUpdate = true;
        this.scene.add(this.camera);
		ManualControl.attachPart(this);
	}
	
	public function getComposerList(post:EnableProcessing):Array<Dynamic>
	{
		var list:Array<Dynamic> = [];
		if (post.cga) list.push(postProcessing.cga = new CGA());
		if (post.dof) list.push(postProcessing.dof = new DoF(this.depthMap.texture, this.camera));
		if (post.bloom) list.push(postProcessing.bloom = new Bloom());
		if (post.gray) list.push(postProcessing.gray = new Gray(0));
		if (post.rgbShift) list.push(postProcessing.rgbShift = new RGBShift());
		if (post.colorHilight) list.push(postProcessing.colorHilight = new ColorHilight());
		if (post.pixelate) list.push(postProcessing.pixelate = new Pixelate());		
		if (post.distortedTV) list.push(postProcessing.distortedTV = new DistortedTv());		
		if (post.vhs) list.push(postProcessing.vhs = new VHS());
		if (post.standard) list.push(postProcessing.standard = new StandardShader());
		if (post.displacement) list.push(postProcessing.displacement = new Displacement(Assets.getTexture("perlin-512.png")));
		if (post.aspect) list.push(postProcessing.aspect = new Aspect());
		
		return list;
	}
	
	public function initComposer(?postprocessingList:Array<Dynamic>, ?preventCopy:Bool, ?preventRender:Bool)
	{
		if(postprocessingList == null)
			postprocessingList = getComposerList( { } );
		var g:Graphics = Graphics.instance;
		this.composer = new EffectComposer(g.renderer, this.renderTo);
		
		if (!preventRender)
		{
			this.renderPass = new RenderPass(this.scene, this.camera, null, new Color(this.clearColor),1);
			this.composer.addPass(renderPass);
        }
		for (pass in postprocessingList)
		{
			this.composer.addPass(pass);
		}
		
		if (!preventCopy)
		{
			//copyPass as last to do actual rendering to screen / rt.
			this.copyPass = new ShaderPass(untyped THREE.CopyShader);
			this.copyPass.renderToScreen = false;// this.renderToScreen;
			this.composer.addPass(this.copyPass);
		}
	}
}

typedef PostProcessing = 
{
	@:optional var dof:DoF;
	@:optional var bloom:Bloom;
	@:optional var colorHilight:ColorHilight;
	@:optional var pixelate:Pixelate;
	@:optional var rgbShift:RGBShift;
	@:optional var distortedTV:DistortedTv;
	@:optional var standard:StandardShader;
	@:optional var displacement:Displacement;
	@:optional var gray:Gray;
	@:optional var aspect:Aspect;
	@:optional var vhs:VHS;
	@:optional var cga:CGA;
}

typedef EnableProcessing = 
{
	@:optional var dof:Bool;
	@:optional var bloom:Bool;
	@:optional var colorHilight:Bool;
	@:optional var pixelate:Bool;
	@:optional var rgbShift:Bool;
	@:optional var distortedTV:Bool;
	@:optional var standard:Bool;
	@:optional var displacement:Bool;
	@:optional var gray:Bool;
	@:optional var vhs:Bool;
	@:optional var cga:Bool;
	@:optional var aspect:Bool;
}