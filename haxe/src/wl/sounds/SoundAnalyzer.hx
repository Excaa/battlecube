package wl.sounds;
import js.Lib;
import wl.sounds.SoundWL.FFT;

/**
 * ...
 * @author ...
 */
class SoundAnalyzer 
{
	public var filters:Array<SoundFilter>;
	public var historySize = 6;
	
	private var historyLeft:Array<Array<Float>>;
	private var historyRight:Array<Array<Float>>;
	
	public function new() 
	{
		this.filters = [];
		this.historyLeft = [];
		this.historyRight = [];
		for (i in 0...SoundWL.FFT_PRECISION)
		{
			this.historyLeft.push([]);
			this.historyRight.push([]);
		}
	}
	
	public function update():Void
	{
		//Clear filters 
		for (filter in filters)
		{
			filter.min = 1;
			filter.max = 0;
			filter.triggered = false;
			if (filter.channels == null) filter.channels = both;
		}
		var fft:FFT = SoundWL.getFFT();
		
		var sample:Float = SoundWL.sampleRate;
		var band:Float = sample / SoundWL.FFT_PRECISION;
		if (fft.frequencyLeft == null) return;
		for ( i in 0...fft.frequencyLeft.length)
		{
			var hL:Array<Float> = this.historyLeft[i];
			hL.push(fft.frequencyLeft[i] / 255);
			var hR:Array<Float> = this.historyRight[i];
			hR.push(fft.frequencyRight[i] / 255);
			
			while (hL.length > historySize)
			{
				hL.shift();
				hR.shift();
			}
			
			var sumL:Float = 0;
			for (v in hL) sumL += v;
			sumL /= this.historySize;
			
			var sumR:Float = 0;
			for (v in hR) sumR += v;
			sumR /= this.historySize;

			var hz:Float = band * i;
			var hzN:Float = band * (i + 1);
			for (filter in filters)
			{
				var active:Bool = filter.isolate ? (hz >= filter.lowLimit && hz <= filter.highLimit): //Isolation mode
					              hz > filter.highLimit || hz < filter.lowLimit;
				if (active)
				{
					var sum = filter.channels == Channels.both ? (sumL + sumR) / 2 : filter.channels == Channels.right ? sumR : sumL;
					filter.min = filter.min > sum ? sum : filter.min;
					filter.max = filter.max < sum ? sum : filter.max;
					filter.triggered = true;
				}
			}
		}
		for (f in filters) 
		{
			if (!f.triggered) 
			{
//				f.min = 0;
//				f.max = 0;
			}
		}
	}
}

typedef SoundFilter  =
{
	var highLimit:Int;
	var lowLimit:Int;
	var isolate:Bool;
	@:optional var channels:Channels;
	@:optional var min:Float;
	@:optional var max:Float;
	@:optional var triggered:Bool;
}

enum Channels
{
	left;
	right;
	both;
	
}