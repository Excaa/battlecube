package wl.core;
import wl.demo.TimeLine;

/**
 * ...
 * @author Henri Sarasvirta
 */
@:expose("wl.Config")
class Config
{
	/*
	 * Music configurations
	 * */
	public static var BEATS_PER_MINUTE:Int = 104; //EDIT THESE IN DEMOMAIN.HX!!
	public static var BEATS_PER_BAR:Int = 4; //EDIT THESE IN DEMOMAIN.HX!!
	public static var TICKS_PER_BEAT:Int = 12; //EDIT THESE IN DEMOMAIN.HX!!
	public static var MUSIC_BEGIN:Float = 500; //EDIT THESE IN DEMOMAIN.HX!!
	
	public static var SONG_PATH:String = "bg.ogg"; //EDIT THESE IN DEMOMAIN.HX!!
	public static var ENABLE_FFT:Bool = false; //EDIT THESE IN DEMOMAIN.HX!!
	public static var MUTED:Bool = false; //EDIT THESE IN DEMOMAIN.HX!!
	
	/*
	 * Visual configuration
	 * */
	public static var FPS:Int = 24; //EDIT THESE IN DEMOMAIN.HX!!
	public static var RESOLUTION:Array<Int> = [1280, 720]; //EDIT THESE IN DEMOMAIN.HX!!
	public static var RATIO:Float = 1280 / 720; //EDIT THESE IN DEMOMAIN.HX!!
	public static var ANTIALIAS:Bool = true; //EDIT THESE IN DEMOMAIN.HX!!
	public static var ENABLE_SHADOWS:Bool = false; //EDIT THESE IN DEMOMAIN.HX!!
	public static var CLEAR_COLOR:Int = 0; //EDIT THESE IN DEMOMAIN.HX!!
	public static var SHADOW_MAP_SIZE:Array<Int> = [512, 512]; //EDIT THESE IN DEMOMAIN.hx
	
	/*
	 * Logic configurations
	 * */
	public static var SEED:Int = 123; //EDIT THESE IN DEMOMAIN.HX!!
	public static var DEBUG:Bool = false; /*TODO - compile constant this */ //EDIT THESE IN DEMOMAIN.HX!!
	
	/*
	 * Demo config. These should be overriden from demo config.
	 * */
	public static var TIMELINE:Array<TimeLine> = 
	[
	//	new TimeLine("corepart", new TimeSig(0), new TimeSig(100), true, false) //EDIT THESE IN DEMOMAIN.HX!!
	];
	
	public function new() 
	{
		throw "Config is static only.";
	}
}