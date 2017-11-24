package wl.demo;
import js.html.svg.Length;
import wl.core.TimeSig;

/**
 * ...
 * @author 
 */
class BoardItem 
{
	private var startTime:TimeSig;
	private var endTime:TimeSig;
	private var controller:IController;
	
	public function new(startTime:TimeSig, endTime:TimeSig, controller:IController) 
	{
		this.startTime = startTime;
		this.controller = controller;		
		this.endTime = endTime;
	}
	
	public function Run(ts:TimeSig){
		if (ts.isLargerThan(startTime) && ts.isSmallerThan(endTime)){
			var timespan = endTime.toMilliseconds() - startTime.toMilliseconds();
			var phase = (ts.toMilliseconds()-startTime.toMilliseconds()) / timespan;
			this.controller.update(phase);
		}
	}
}