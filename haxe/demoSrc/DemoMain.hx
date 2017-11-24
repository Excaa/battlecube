package;
import blank.Blank;
import js.Browser;
import js.Lib;
import js.html.Uint8Array;
import js.html.svg.FilterElement;
import js.three.Color;
import js.three.Colors;
import js.three.DataTexture;
import js.three.FontLoader;
import js.three.Mapping;
import js.three.PixelFormat;
import js.three.Ray;
import js.three.TextureDataType;
import js.three.TextureFilter;
import js.three.Wrapping;
import simplecube.SimpleCube;
import wl.core.Config;
import wl.core.Demo;
import wl.core.Part;
import wl.core.Signal;
import wl.core.TimeSig;
import wl.demo.TimeLine;

import wl.util.MathUtil;

/**
 * ...
 * @author Henri Sarasvirta
 */
class DemoMain
{
	public static var DEMO_READY:Signal = new Signal();
	
	public static var HILIGHT:Color = new Color(0xE83A25);
	public static var LIGHT:Color = new Color(0xFFE9A3);
	public static var GREEN:Color = new Color(0x263248);
	public static var BLUE:Color = new Color(0x004563);
	public static var BLUE_DARK:Color = new Color(0x191B28);
	
	public static var WHITE:Color = new Color(0xFFFFFF);
	public static var BLACK:Color = new Color(0x000000);
	
	public static var font2:Dynamic;
	
	public static var SOUNDTEXTURE:DataTexture;
	
	public function new() 
	{
	}
	
	public static function setup():Void
	{
		untyped Browser.window.cubeData = null;
		//This is called before preloading and other stuff. This should setup the config variables.
		Config.BEATS_PER_MINUTE = 173;
		
		//Config.MUSIC_BEGIN = 5200;
		Config.MUSIC_BEGIN = 0;
		Config.FPS = -1;
		Config.ENABLE_SHADOWS = true;
		Config.DEBUG = false;
		Config.CLEAR_COLOR = 0;
		Config.SHADOW_MAP_SIZE = [2048,2048];
		
		Config.ENABLE_FFT = true;

		Config.TIMELINE = [
			new TimeLine(new SimpleCube(), new TimeSig(0), new TimeSig(0), "blank", true),
			//new TimeLine(new Blank(), new TimeSig(0), new TimeSig(0), "blank", true),
		];
		/**/
		//Load font
		//font = untyped __js__('new THREE.Font( JSON.parse( window.demofont.substring( 65, window.demofont.length - 2 ) ));');
		
	}
	
	public static function update(ts:TimeSig, partial:Float, frameTime:Float, delta:Float):Void
	{
	}
}