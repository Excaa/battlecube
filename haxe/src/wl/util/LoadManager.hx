package wl.util;
import js.three.Loader;
import js.three.LoadingManager;

/**
 * ...
 * @author Henri Sarasvirta
 */
@:expose("wl.util.LoadManafer")
class LoadManager
{
	public static var totalCount(get, null):Int;
	private static function get_totalCount():Int
	{
		return _totalCount + loadersWaiting.length;
	}
	private static var _totalCount:Int = 0;
	public static var onComplete:Void->Void;
	
	public static var loadingManager:LoadingManager = new LoadingManager(onload, onprogress, onerror);
	
	private static var loadersWaiting:Array<Dynamic> = [];
	private static var managerDone:Bool = false;
	
	private static function onload():Void
	{
		managerDone = true;
		checkAllDone();
	}
	private static function checkAllDone():Void
	{
		if (managerDone || _totalCount == 0 && loadersWaiting.length == 0)
		{
			onComplete();
		}
	}
	
	private static function onerror():Void
	{
		
	}
	
	private static function onprogress(s:String, p:Float,t:Float):Void
	{
		trace(s + "," + p + "," + t);
	}
	
	public static function addLoader(loaderClass:Class<Loader>):Loader
	{
		var ldr:Loader = Type.createInstance(loaderClass,[loadingManager]);
		_totalCount++;
		return ldr;
	}
	
	public static function addManualLoader(loader:Dynamic):Void
	{
		loadersWaiting.push(loader);
	}
	
	public static function manualLoaderComplete(loader:Dynamic):Void
	{
		loadersWaiting.remove(loader);
		checkAllDone();
	}
	
	public function new() 
	{
		
	}
	
}