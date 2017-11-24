package wl.debug;
import createjs.tweenjs.Tween;
import dat.gui.GUI;
import js.Browser;
import js.html.KeyboardEvent;
import js.html.Window;
import js.jquery.JQuery;
import js.three.EffectComposer;
import wl.core.Config;
import wl.core.Demo;
import wl.core.Graphics;
import wl.core.Part;
import wl.core.TimeSig;
import wl.demo.TimeLine;


/**
 * ...
 * @author Henri Sarasvirta
 */
class Debug
{
	private static var debugDiv:JQuery;
	public static var paused:Bool = false;
	private static var stats:Dynamic;
	private static var debugTimeSig:JQuery;
	public static var gui:GUI;
	
	public function new() 
	{
		
	}
	
	public static function init(demo:Demo):Void
	{
		gui = new GUI();
		Browser.document.addEventListener('keydown', onKeyDown);
		debugDiv = new JQuery(".debug");
		debugTimeSig = debugDiv.find("#debug_timesig");
		
		var tldiv:JQuery = debugDiv.find("#timeline_parts");
		for (tl in Config.TIMELINE)
		{
			var tlel = new JQuery("<li>" + tl + "</li>");
			tldiv.append(tlel);
			tlel.click(tlClick(tl));
			
			Debug.datGuiPart(tl.part);
		}
		
		stats = untyped __js__( "new Stats()");
		stats.showPanel(1);
		stats.dom.style.position = "absolute";
		stats.dom.style.bottom = "0px";
		stats.dom.style.top = null;
		debugDiv.eq(0).append(stats.dom);
		stats.begin();
		
		
	}
	
	private static var usedFolderNames:Array<String> = [];
	private static function datGuiPart(part:Part):Void
	{
		var name:String = part.name;
		while (usedFolderNames.indexOf(name) >= 0) name = name+">";
		var folder:GUI = gui.addFolder(name);
		usedFolderNames.push(name);
		//Add composers automatically
		var composer:EffectComposer = Reflect.field(part, "composer");
		if (composer != null)
		{
			for (pass in composer.passes)
			{
				if (pass.setupDatGui != null)
					pass.setupDatGui(folder);
			}
		}
		var occlusioncomposer:EffectComposer = Reflect.field(part, "occlusionComposer");
		if (occlusioncomposer != null)
		{
			for (pass in occlusioncomposer.passes)
			{
				if (pass.setupDatGui != null)
					pass.setupDatGui(folder);
			}
		}
		
		part.setupDatGui(folder);
	}
	
	private static function tlClick(tl:TimeLine):Dynamic
	{
		return function() {

		}
	}
	
	public static function onupdate():Void
	{
	}
	
	public static function onrender():Void
	{
		stats.update();
		ManualControl.update();
	}
	
	private static function onKeyDown(e:KeyboardEvent):Void
	{
		//trace(e.keyCode);
		if (e.keyCode == 90)
		{
			trace("Time captured: " + Demo.instance.previousTS);
		}
		if (e.keyCode == 109 || e.keyCode == 188)
		{
			// minus / .
		}
		if (e.keyCode == 107 || e.keyCode == 190)
		{
			// plus / ,
		}
		if (e.keyCode == 32)
		{
			paused = !paused;
			untyped SoundWL.instance.paused = paused;
			untyped Tween.removeAllTweens();
		}
	}
}
/*	
	var debugLoop = function(){
		var timesig = kvg.sound.getPosition();
		$("#debug_timesig").html(timesig.toString()+"<br/>"+Math.round(timesig.toMilliseconds()/100)/10+"s");
		for(n in kvg.core.demo.parts)
		{
			var p = kvg.core.demo.parts[n];
			if(p && p.running)
			{
				$("#debug_parts div").filter(function(){ return $(this).text()===n;}).addClass("running");
			}
			else
			{
				$("#debug_parts div").filter(function(){ return $(this).text()===n;}).removeClass("running");
			}
		}
	}
	
	var initPartDebug = function(d)
	{
		//Build debug webgl context.
		var count = 0;
		for(name in d.parts)
		{
			var item = $('<div id="debug_'+name+'">'+name+'</div>')
			$("#debug_parts").append(item);
			item.mouseover(forceRender);
			item.mouseout(renderOut);
		}
		
		//Listen to raf from graphics
		kvg.core.graphics.onRender.add(renderLoop);
	}
	
	var forceRender = function(e){
		var name = $(e.currentTarget).text();
		var p = kvg.core.demo.parts[name];
		for(n in kvg.core.demo.parts)
		{
			//Reset others
			kvg.core.demo.parts[n]._debug_renderToScreen = false;
		}
		if(p)
		{
			p._debug_renderToScreen = true;
			//Use false so nothing gets messed with internals. Part swaps internal to true when debug switch is seen.
			p.setRenderToScreen(false);
		}
	}
	
	var renderOut = function(e){
		for(n in kvg.core.demo.parts)
		{
			if(kvg.core.demo.parts[n])
			{
				//Only update debug as engine handles rendering now.
				kvg.core.demo.parts[n]._debug_renderToScreen = false;
			}
		}
	}
	
	var renderLoop = function(){
		//render all targets
	}
	
*/