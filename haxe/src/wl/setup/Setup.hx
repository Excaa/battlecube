package wl.setup;
import haxe.Timer;
import js.Browser;
import js.html.Image;
import js.html.ImageElement;
import js.jquery.Event;
import js.jquery.JQuery;
import wl.core.Assets;
import wl.core.Config;
import wl.core.Demo;

/**
 * ...
 * @author Henri Sarasvirta
 */
class Setup
{
	private static var setupDiv:JQuery;
	private static var resolution:JQuery;
	private static var demo:Demo;
	private static var demoDiv:JQuery;
	
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
		setupDiv.remove();
	}
	
	private static function startRun():Void
	{
		var mute:Bool = setupDiv.find('#muted').find("input").is(':checked');
		if(mute){
        	Config.MUTED = true;
        }
		var debug:Bool = setupDiv.find('#debug').find("input").is(':checked');
		Config.DEBUG = debug;
		if (debug)
			new JQuery(".debug").css("display", "block");
        else
			new JQuery(".debug").css("display", "none");
        
		demo.init(demoDiv[0], function() { loadImg.remove(); demo.start(); } );
		demoDiv.append(cast demo.graphics.canvas);
		
		//Special hack for kapital
		Browser.document.getElementById("demo").style.display = "block";
		
	}
	private static var loadImg:Image;
	
	private static function fullScreenClickHandler(e:Event):Void
	{
		hideSetup();
		try
		{
			demoDiv[0].requestFullscreen();
		}
		catch (e:Dynamic)
		{
			throw "Full screen could not be initialized. Please reload and try again.";
		}
		
		//Fit to screen
		var w:Int = Browser.window.screen.width;
		var h:Int = Browser.window.screen.height;	

		var ratio = Config.RATIO;
		var lockAspect = new JQuery("#aspectLock input").val()=="on";
		if(lockAspect && w*1/ratio < h)
			h = cast w*720/1280
		else if(lockAspect && h<w*1/ratio)
			w = cast h * 1280 / 720;
		Config.RESOLUTION[0] = Math.floor(w);
		Config.RESOLUTION[1] = Math.floor(h);
		demoDiv.css("background", "black");
		
		//Delay start for the message to go away
		Timer.delay(startRun, 5000);
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
		var w:Int = 1280;
		var h:Int = 720;
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
		Config.RESOLUTION[0] = w;
		Config.RESOLUTION[1] = h;
		demoDiv.css("width", w+"px").css("height", h+"px");
		
		Timer.delay(startRun, 50);
	}
}