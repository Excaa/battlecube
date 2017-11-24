package wl.core;

/**
 * ...
 * @author ...
 */
class Signal
{
	private var callbacks:Array<Dynamic> =[];

	public function new() 
	{
		
	}
	
	public function connect(callback:Dynamic):Void
	{
		callbacks.push(callback);
	}
	public function disconnect(callback:Dynamic):Void
	{
		callbacks.remove(callback);
	}
	
	public function emit(?param:Dynamic):Void
	{
		for (cb in callbacks)
		{
			cb(param);
		}
	}
}