package wl.core;


/**
 * ...
 * @author Henri Sarasvirta
 */
@:expose("wl.TimeSig")
class TimeSig
{
	public static var ABSOLUTE:String = "absolute";
	public static var RELATIVE:String = "relative";
	public static var PATTERN:String = "pattern";
	
	public var bar(default, set):Int;
	public var beat(default, set):Int;
	public var tick(default, set):Int;
	public var pattern:String;
	public var delay:Int = 0;
	public var triggered:Bool = false;
	
	public function set_beat(value:Int):Int
	{
		this.beat = value;
		adjust();
		return this.beat;
	}
	public function set_bar(value:Int):Int
	{
		this.bar = value;
		adjust();
		return this.bar;
	}
	public function set_tick(value:Int):Int
	{
		this.tick = value;
		adjust();
		return this.tick;
	}
	
	public function new(?bar:Int, ?beat:Int, ?tick:Int, ?delay:Int, ?pattern:String) 
	{
		this.bar = bar == null ? 0 : bar;
		this.beat = beat == null ? 0 : beat;
		this.tick = tick == null ? 0 : tick;
		this.delay = delay == null ? 0 : delay;
		this.pattern = pattern == null ? ABSOLUTE : pattern;
		
	}
	
	private function adjust():Void
	{
		
	}
	
	public function matchesPattern(time:TimeSig, begin:TimeSig):Bool
	{
		if (this.pattern == TimeSig.ABSOLUTE)
		{
			return this.equals(time);
		}
		else if (this.pattern == TimeSig.RELATIVE)
		{
//			var added:TimeSig = time.clone();
//			added.subtract(begin);
//			trace(added + " vs " + this);
//			return this.equals(added);
			return time.bar == begin.bar + this.bar &&
			       time.beat == begin.beat + this.beat &&
				   time.tick == begin.tick + this.tick;
		}
		else if (this.pattern == TimeSig.PATTERN)
		{
			return (this.bar == -1 || time.bar%this.bar == 0) &&
			       (this.beat == -1 || time.beat%Config.BEATS_PER_BAR == this.beat) &&
				   (this.tick == -1 || time.tick % Config.TICKS_PER_BEAT == this.tick);
		}
		return false;
	}
	
	public function add(ts:TimeSig):Void
	{
		this.addBars(ts.bar);
		this.addBeats(ts.beat);
		this.addTicks(ts.tick);
	}
	
	public function addBars(bars:Int):Void
	{
		this.bar+=bars;
	}
	
	public function addBeats(beats:Int):Void
	{
		this.beat+=beats;
		this.bar += Math.floor(this.beat/Config.BEATS_PER_BAR);
		this.beat %= Config.BEATS_PER_BAR;
	}
	
	public function addTicks(ticks:Int):Void
	{
		this.tick+=ticks;
		while(this.tick >= Config.TICKS_PER_BEAT)
		{
			this.tick -= Config.TICKS_PER_BEAT;
			this.beat++;
		}
		while(this.beat >= Config.BEATS_PER_BAR)
		{
			this.beat -= Config.BEATS_PER_BAR;
			this.bar++;
		}
	}
	
	public function subtract(ts:TimeSig):Void
	{
		this.subtractBars(ts.bar);
		this.subtractBeats(ts.beat);
		this.subtractTicks(ts.tick);
	}
	
	public function subtractBars(bars:Int):Void
	{
		this.bar-=bars;
	}
	
	public function subtractBeats(beats:Int):Void
	{
		this.beat-=beats;
		while(this.beat < 0)
		{
			this.bar--;
			this.beat += Config.BEATS_PER_BAR;
		}
	}
	
	public function subtractTicks(ticks:Int):Void
	{
		this.tick-=ticks;
		while(this.tick < 0)
		{
			this.tick += Config.TICKS_PER_BEAT;
			this.beat--;
		}
		while(this.beat < 0)
		{
			this.bar--;
			this.beat += Config.BEATS_PER_BAR;
		}
	}
	
	public function fromTime(time:Float):TimeSig
	{
		var totalBeats = Config.BEATS_PER_MINUTE * time;
		var comp:Float->Int = time < 0 ? Math.ceil : Math.floor;
		this.bar = comp( totalBeats/Config.BEATS_PER_BAR);
		this.beat = comp( totalBeats % Config.BEATS_PER_BAR);
		this.tick = comp((totalBeats-comp(totalBeats))* Config.TICKS_PER_BEAT);
		this.delay = 0;
		var offset = time*60*1000 - this.toMilliseconds();
		var tickTime = 60*1000 / Config.BEATS_PER_MINUTE / Config.TICKS_PER_BEAT;
		
		this.delay = Math.floor((255*offset/tickTime)%255);
		
		return this;
	}
	
	public static function create(time:Float):TimeSig
	{
		return new TimeSig().fromTime(time);
	}

	public function isInside(begin:TimeSig, end:TimeSig):Bool
	{
		return (this.isSmallerThan(end) && this.isLargerThan(begin));
	}
	
	public function isSmallerThan(other:TimeSig):Bool
	{
		var ticks = this.bar * Config.BEATS_PER_BAR * Config.TICKS_PER_BEAT + this.beat * Config.TICKS_PER_BEAT + this.tick;
		var tickso = other.bar * Config.BEATS_PER_BAR * Config.TICKS_PER_BEAT + other.beat * Config.TICKS_PER_BEAT + other.tick;
		return ticks < tickso || ticks == tickso && this.delay < other.delay;
	}
	
	public function isLargerThan(other:TimeSig):Bool
	{
		var ticks = this.bar * Config.BEATS_PER_BAR * Config.TICKS_PER_BEAT + this.beat * Config.TICKS_PER_BEAT + this.tick;
		var tickso = other.bar * Config.BEATS_PER_BAR * Config.TICKS_PER_BEAT + other.beat * Config.TICKS_PER_BEAT + other.tick;
		return ticks > tickso || ticks == tickso && this.delay >= other.delay;	
	}
	
	public function toMilliseconds():Float
	{
		var tickTime = 60*1000 / Config.BEATS_PER_MINUTE / Config.TICKS_PER_BEAT;
		
		return (this.bar * Config.BEATS_PER_BAR / Config.BEATS_PER_MINUTE + this.beat/Config.BEATS_PER_MINUTE + this.tick/Config.TICKS_PER_BEAT / Config.BEATS_PER_MINUTE)*60*1000 + Math.floor(this.delay/255 *tickTime);
	}
	
	public function equals(other:TimeSig):Bool
	{
		var ticks = this.bar * Config.BEATS_PER_BAR * Config.TICKS_PER_BEAT + this.beat * Config.TICKS_PER_BEAT + this.tick;
		var tickso = other.bar * Config.BEATS_PER_BAR * Config.TICKS_PER_BEAT + other.beat * Config.TICKS_PER_BEAT + other.tick;
		return ticks == tickso;// && this.delay == other.delay;
	}
	
	public function clone():TimeSig
	{
		return new TimeSig(this.bar, this.beat, this.tick, this.delay,this.pattern );
	}
	
	public function toString(?full:Bool):String
	{
		return this.bar+":"+this.beat+":"+this.tick +(full? " / " + this.delay + "\n["+this.pattern+"]":"");
	}
	
	public static function milliseconds(bar:Int, beat:Int, tick:Int, delay:Int):Int
	{
		var tickTime = 60*1000 / Config.BEATS_PER_MINUTE / Config.TICKS_PER_BEAT;
		
		return cast (bar * Config.BEATS_PER_BAR / Config.BEATS_PER_MINUTE + beat/Config.BEATS_PER_MINUTE + tick/Config.TICKS_PER_BEAT / Config.BEATS_PER_MINUTE)*60*1000 + Math.floor(delay/255 *tickTime);
	}
}