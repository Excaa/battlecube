package blank;

import js.three.Mesh;
import wl.core.Part;
import wl.core.TimeSig;

/**
 * ...
 * @author 
 */
class Blank extends Part 
{
	private var cube:Array < Array < Array<Mesh> >> = [];

	public function new() 
	{
		super();
		
	}
	
	override public function init():Void 
	{
		super.init();
		this.initStandardScene();
		this.initComposer(this.getComposerList({
			bloom:true,
			distortedTV:true,
			rgbShift:true,
			standard:true
		}));
		
		
	}
	
	public override function update(ts:TimeSig, partial:Float, frameTime:Float, delta:Float):Void {
		super.update(ts, partial, frameTime, delta);
	}
	
	override public function render(ts:TimeSig, frameTime:Float):Void {
		super.render(ts, frameTime);
	}
}