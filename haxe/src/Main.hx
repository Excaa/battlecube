package;

import js.Browser;
import js.jquery.Event;
import js.jquery.JQuery;
import js.Lib;
import wl.core.Config;
import wl.core.Demo;
import wl.core.Graphics;
import wl.core.TimeSig;
import wl.demo.CameraController;
import wl.setup.Setup;
import wl.sounds.SoundWL;
import wl.util.LoadManager;

/**
 * ...
 * @author Henri Sarasvirta
 */
class Main 
{
	static var demo:Demo;
	static var assetsLoaded:Bool;
	static var soundLoaded:Bool;
	
	static function main() 
	{
		new JQuery(Browser.window).ready(windowReady);
	}
	static function windowReady(e:Event):Void
	{
		LoadManager.onComplete = onAssetsLoaded;
		DemoMain.setup();
		
		new JQuery("#setup").css("display", "none");
		demo = new Demo();
		if (!Config.DEBUG)
		{
			new JQuery(".debug").css("display", "none");
			new JQuery("#debug").find("input").attr("checked", null);
			new JQuery(".checkbox").css("display", "none");
		}
		
		if (LoadManager.totalCount == 0) assetsLoaded = true;
		
		SoundWL.onSoundLoaded.connect(onSoundLoaded);
		SoundWL.init();
		onSoundLoaded();
	}
	
	static private function onAssetsLoaded():Void
	{
		assetsLoaded = true;
		loadReady();
	}
	
	static private function onSoundLoaded():Void
	{
		soundLoaded = true;
		loadReady();
	}
	
	static private function loadReady():Void
	{
		if (assetsLoaded && soundLoaded)
		{
			new JQuery("#setup").css("display", "");
			Setup.init(demo);		
		}
	}
}