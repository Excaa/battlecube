package wl.core;
import createjs.easeljs.Ticker;
import createjs.tweenjs.Tween;
import haxe.Timer;
import haxe.ds.StringMap;
import js.Browser;
import js.jquery.JQuery;
import js.html.Element;
import js.three.BoxGeometry;
import js.three.Camera;
import js.three.Clock;
import js.three.CopyShader;
import js.three.EffectComposer;
import js.three.Mesh;
import js.three.MeshBasicMaterial;
import js.three.OrthographicCamera;
import js.three.PlaneGeometry;
import js.three.RenderPass;
import js.three.Scene;
import js.three.ShaderPass;
import js.three.Side;
import js.three.Vector3;
import wl.debug.Debug;
import wl.debug.ManualControl;
import wl.demo.TimeLine;
import wl.post.standard.StandardShader;

import wl.util.Random;


/**
 * ...
 * @author Henri Sarasvirta
 */
@:expose("Demo")
class Demo
{
	public static var instance:Demo;
	public var graphics:Graphics;
	
	
	public var previousTS:TimeSig;
	
	public var overlay:Scene;
	public var overlayCamera:OrthographicCamera;
	
	private var parts:Array<Part>;
	private var partMap:StringMap<Part> = new StringMap<Part>();
	private var previousUpdate:Float = 0;
	
	private var demoComposer:EffectComposer;
	private var texturePass:Dynamic;
	private var allowUpdate:Bool = false;
	
	private var waitingFirstFrame:Bool = true;
	private var startTime:Float;
	
	public function new() 
	{
		instance = this;
	}
	
	public function getPart(name:String):Part
	{
		return partMap.get(name);
	}
	
	public function init(container:Element,callback:Dynamic):Void
	{
		Random.init(Config.SEED);
		this.graphics = new Graphics();
		
		Timer.delay(function(){
			this.previousTS = TimeSig.create(0);
			this.graphics.onRender.connect(this.onRender);
			this.initializeParts();
			if (Config.DEBUG)
			{
				initializeDebug();
			}
			
			Ticker.setPaused(true);
			this.initDemoComposer();
			callback();
		},100);
	}
	
	private function initDemoComposer():Void
	{
		this.overlay = new Scene();
		var aspect:Float = Config.RESOLUTION[1] / Config.RESOLUTION[0];
		this.overlayCamera = new OrthographicCamera( 0,1,0,1*aspect, 1, 1000);
		this.demoComposer = new EffectComposer(graphics.renderer, graphics.getRenderTarget());
		//TODO - build an extern
		this.texturePass = untyped __js__("new THREE.TexturePass(null,1)");
		this.demoComposer.addPass(this.texturePass);
	//	var rp:RenderPass = new RenderPass(this.overlay, this.overlayCamera);
	//	rp.clear = false;
	//	rp.needsSwap = true;
	//	this.demoComposer.addPass(rp);
	//	this.demoComposer.addPass(new StandardShader(2.2));
	
		var copyPass = new ShaderPass(untyped THREE.CopyShader);
		copyPass.renderToScreen = true;// this.renderToScreen;
		this.demoComposer.addPass(copyPass);
		
		this.overlayCamera.position.z = 10;
		this.overlayCamera.lookAt(new Vector3());
		
		/*
		var koheaspect:Float = 1094 / 253;
		var box:Mesh = new Mesh(new PlaneGeometry(Config.RESOLUTION[1]* 0.3*koheaspect, Config.RESOLUTION[1]*0.3), new MeshBasicMaterial( {transparent: true, color:0xffffff, map:Assets.getTexture("koherent.png"), side:Side.DoubleSide } ));
		box.rotation.z = 0;// Math.PI / 3;
		
		overlay.add(box);*/
	}
	
	private function onSoundEnd():Void
	{
		this.end();
	}
	
	private function initializeDebug():Void
	{
		Debug.init(this);
		ManualControl.init();
	}
	
	private function initializeParts():Void
	{
		this.parts = [];
		for (tl in Config.TIMELINE)
		{
			//TODO - check if part exists
			//tl.part = DemoMain.getPart(tl.partName);
			var id = tl.partId == null ? Type.getClassName(Type.getClass(tl.part)) : tl.partId;
			tl.part.name = id;
			partMap.set(tl.partId, tl.part);
			this.parts.push(tl.part);
		}
		for(part in this.parts)
		{
			part.init();
		}
		
		//Render the parts once before starting in order to remove lag during transitions and to make sure each part has something in their rendertarget.
		for(part in this.parts)
		{
			part.render(this.previousTS, 0);
		}
		//Post init. Use this to get previous parts rts & stuff like that.
		for(part in this.parts)
		{
			part.postInit();
		}
		
	}
	
	public function start():Void
	{
		previousRts = parts[0];
		this.graphics.start();
		
		Timer.delay(function() {
			this.startTime = Date.now().getTime();
			//SoundWL.start();
			this.allowUpdate = true;
			waitingFirstFrame = false;
			trace("allow upds.");
		}, 400);
		
	}
	
	public function end():Void
	{
		//if (Config.DEBUG) return;
		this.graphics.stop();
		
	}
	
	//TODO - pause
	private var previousRts:Part;
	private function onRender(time:Float):Void
	{
		//Render related stuff
		this.graphics.renderer.clear();
		//Tween updates
		Tween.tick(cast time, false);
		var rts:Part = null;
		var debugRts:Part = null;
		for(p in parts)
		{
			//Render the effect during it's transition phases. When in transition, it's rts is not in effect.
			if(p.inTransition)
				p.render(this.previousTS, time);
			else if(p.running)
			{
				//Check if part renders to screen. Only render first occurence of RTS to screen. Others can still have renderTo used by others, so they can't be dropped.
				if(rts == null && p.renderToScreen)
					rts = p;
				else
					p.render(this.previousTS, time);
			}
			//Debug rendering happens always last.
		//	if(p._debug_renderToScreen)
		//		debugRts = p;
		}
		//Use last render if none is set
		if (rts == null) rts = previousRts;
		if (rts != null)
		{
			previousRts = rts;
			rts.render(this.previousTS, time);
		}
		this.texturePass.setTexture(rts.renderTo);
		
		//graphics.renderer.autoClear = false;
		this.demoComposer.render();
		this.graphics.renderer.autoClearColor = false;
		this.graphics.renderer.render(this.overlay, this.overlayCamera);
		this.graphics.renderer.autoClearColor = true;
		//graphics.renderer.autoClear = true;
		
		//if(debugRts != null)
		//	debugRts.render(this.previousTS, time);
		if (Config.DEBUG)
		{
			Debug.onrender();
		}
		if(allowUpdate)
			update(); 
		
	}
	private var curts:TimeSig = new TimeSig();
	private function update():Void
	{
		//Logic handling.
		 curts.fromTime((Date.now().getTime() - startTime)/1000);//todo - get from sound.
		var ts:TimeSig = curts;
		if (ts.toMilliseconds() < 0) return;
		
		var ms:Float = ts.toMilliseconds();
		var frameTime:Float = ms - previousUpdate;
		var delta:Float = frameTime / (1000 / 60);
		previousUpdate = ms;
		//if (ms <= 0/* || ms > sound length*/) //No updates if there's nothing to do.
		//	return;
		//trace(ms);
		for ( i in 0...Config.TIMELINE.length)
		{
			var tl:TimeLine = Config.TIMELINE[i];
			if (ts.isInside(tl.runOn, tl.runOff))
			{
				//Part is active
				var p:Part = tl.part;
				p.timeline = tl;
				var inTransition:Bool = ts.isInside(tl.runOn, tl.rtsOn) || ts.isInside(tl.rtsOff, tl.runOff);
				p.setRenderToScreen(tl.renderToScreen && !inTransition);
				if (!p.running)
				{
					//Start the part.
					p.start(ts);
				}
				p.isActive = true;
			}
		}

		DemoMain.update(ts, 0, Debug.paused?0: frameTime, delta);
		//Go through all parts.
		for ( p in this.parts)
		{
			if (p.isActive)
			{
				var timespan = p.timeline.runOff.toMilliseconds() - p.timeline.runOn.toMilliseconds();
				var partial = (ts.toMilliseconds() - p.timeline.runOn.toMilliseconds()) / timespan;
				p.update(ts, partial,Debug.paused ? 0 : frameTime,delta );
			//	for (effect in p.effects)
			//		effect.update(ts, partial, frameTime);
			}
			else if (p.running)
			{
				p.stop();
				if (!Config.DEBUG)
				{
				//	this.parts.remove(p);
				//	this.partMap.remove(p.name);
				}
			}
			//Mark activity to false for next update.
			p.isActive = false;
		}
		
		//Calculate triggers and avoid missing them by stepping forward tick at a time.
		//Handle triggers by stepping current time forward so no trigger is skipped.
		while(this.previousTS.isSmallerThan(ts))
		{
			for(p in this.parts)
			{
				if(p.running)
				{
					for (key in p.triggers.keys())
					{
						var matches:Bool = key.matchesPattern(this.previousTS, p.timeline.runOn);
						if (matches && !key.triggered)
						{
							var triggers:Array<Dynamic> = p.triggers.get(key);
							key.triggered = true;
							for ( toCall in triggers)
							{
								toCall(this.previousTS);
							}
						}
						else if (!matches)
							key.triggered = false;
					}
				}
			}
			this.previousTS.addTicks(1);
		}
		if (Config.DEBUG)
			Debug.onupdate();
	}
}