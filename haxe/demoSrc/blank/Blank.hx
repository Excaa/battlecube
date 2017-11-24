package blank;

import wl.core.Part;
import wl.core.TimeSig;

/**
 * ...
 * @author 
 */
class Blank extends Part 
{

	public function new() 
	{
		super();
		
	}
	
	override public function init():Void 
	{
		super.init();
		this.initStandardScene();
		this.initComposer();
	}
	
	public override function update(ts:TimeSig, partial:Float, frameTime:Float, delta:Float):Void {
		super.update(ts, partial, frameTime, delta);
	}
	
	override public function render(ts:TimeSig, frameTime:Float):Void {
		super.render(ts, frameTime);
	}
}