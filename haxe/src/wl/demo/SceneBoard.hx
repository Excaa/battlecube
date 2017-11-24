package wl.demo;
import js.html.CanvasRenderingContext2D;
import wl.core.TimeSig;

/**
 * ...
 * @author 
 */
class SceneBoard 
{
	private var startTime:TimeSig= new TimeSig();//Set new for preloading hack
	private var BoardItems:Array<BoardItem>;

	public function new() 
	{
		BoardItems = new Array<BoardItem>();
	}
	
	public function add(startTime:TimeSig, endTime:TimeSig, controller:IController){
		var item:BoardItem = new BoardItem(startTime, endTime, controller);
		BoardItems.push(item);
	}
	
	public function start(ts:TimeSig){
		startTime = ts.clone();
	}
	
	public function update(ts:TimeSig, partial:Float, frameTime:Float, delta:Float):Void {
		for (b in BoardItems){
			var ts2 = ts.clone();
			ts2.subtract(startTime);
			b.Run(ts2);
		}
	}
}