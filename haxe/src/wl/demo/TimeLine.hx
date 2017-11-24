package wl.demo;
import wl.core.Part;
import wl.core.TimeSig;

/**
 * ...
 * @author Henri Sarasvirta
 */
class TimeLine
{
	public var part:Part;
	public var partId:String;
	public var instance:Part;
	
	/**
	 * When the part starts running
	 */
	public var runOn:TimeSig;
	/**
	 * When the part becomes active part. As in rts has effect.
	 */
	public var rtsOn:TimeSig;
	/**
	 * When the part stops using rts
	 */
	public var rtsOff:TimeSig;
	/**
	 * When the part actually ends updates
	 */
	public var runOff:TimeSig;
	
	public var renderToScreen:Bool;
	
	public var forceNewPart:Bool;
	
	public var extra:Dynamic;
	
	public function new(instance:Part, runOn:TimeSig, runOff:TimeSig, ?partId:String, ?renderToScreen:Bool, ?rtsOn:TimeSig, ?rtsOff:TimeSig, ?forceNewPart, ?extra:Dynamic) 
	{
		this.part = instance;
		this.partId = partId;
		this.runOn = runOn;
		this.runOff = runOff;
		this.rtsOn = rtsOn == null ? runOn.clone() : rtsOn;
		this.rtsOff = rtsOff == null ? runOff.clone() : rtsOff;
		this.renderToScreen = renderToScreen==null ? true : renderToScreen;
		this.forceNewPart = forceNewPart == null ? false : forceNewPart;
		this.extra = extra;
	}
	
	public function toString():String
	{
		return part.name+":" + this.rtsOn.toString() + " - " + this.rtsOff.toString();
	}
}