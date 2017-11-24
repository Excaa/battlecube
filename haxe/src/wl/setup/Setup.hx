package wl.setup;
import haxe.Timer;
import js.Browser;
import js.html.Element;
import js.html.Image;
import js.html.ImageElement;
import js.jquery.Event;
import js.jquery.JQuery;
import wl.core.Assets;
import wl.core.Config;
import wl.core.Demo;
import wl.core.Graphics;

/**
 * ...
 * @author Henri Sarasvirta
 */
class Setup
{
	private static var demo:Demo;
	
	
	public function new() 
	{
		throw "Setup is static only.";
	}
	
	public static function init(demo:Demo):Void
	{
		Setup.demo = demo;
		startClickHandler(null);
	}
	
	private static function hideSetup():Void
	{
	}
	
	private static function startRun():Void
	{
		var mute:Bool =true;
		if(mute){
        	Config.MUTED = true;
        }
		var debug:Bool = false;
		Config.DEBUG = debug;
        
		demo.init(null, function() { demo.start(); } );
		untyped Browser.window.DEMO_CANVAS = demo.graphics.canvas;
		var demodiv:Element = Browser.document.getElementById("cube-container");
		demodiv.appendChild(demo.graphics.canvas);
		demo.graphics.canvas.addEventListener("click", fullScreenClickHandler);
	}
	private static var loadImg:Image;
	
	private static function fullScreenClickHandler(e:Event):Void
	{
		
		hideSetup();
		try
		{
			Graphics.instance.canvas.requestFullscreen();
			Timer.delay(function() {
				var w:Float = Math.min(Browser.window.innerWidth, Browser.window.innerHeight);
			Graphics.instance.canvas.style.left = "0px";
			Graphics.instance.canvas.style.bottom = "0px";
			Graphics.instance.canvas.style.width = w+"px";
			Graphics.instance.canvas.style.height = w+"px";
			
			
					untyped Graphics.instance.canvas.width = w;
		untyped Graphics.instance.canvas.height =w;
		Graphics.instance.renderer.setViewport(0, 0,w,w);
			},50);
		}
		catch (e:Dynamic)
		{
			throw "Full screen could not be initialized. Please reload and try again.";
		}
	}
	private static function startClickHandler(e:Event):Void
	{
		
		new JQuery("#demo").css("transform", "")
				  .css("-webkit-transform", "");
		var lockAspect = new JQuery("#aspectLock input").val()=="on";
		var mute = new JQuery('#muted input').is(':checked');
		
		var resolutionType = new JQuery("#resolution .active input[name='options']").val();
		hideSetup();
		
		//Default is 720p
		var w:Int = 1024;
		var h:Int = 1024;
		if(resolutionType == "b")
		{
			//1080p
			w = 1920;
			h = 1080;
		}
		else if(resolutionType == "c")
		{
			//Fit to screen
			w = Browser.window.innerWidth;
			h = Browser.window.innerHeight;
			var ratio = Config.RATIO;
			if(lockAspect && w*1/ratio < h)
				h = cast w * 1 / ratio;
			else if(lockAspect && h<w*1/ratio)
				w =cast h * ratio;
		}
		Config.RESOLUTION[0] = 1024;
		Config.RESOLUTION[1] = 1024;
		
		Timer.delay(startRun, 50);
	}
}