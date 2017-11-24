package wl.util;

/**
 * ...
 * @author Henri Sarasvirta
 */
class Random
{
	private static var instance:Random = new Random(123);
	private var seed:Int = 123;

	public static function init(seed:Int):Void { instance.Init(seed); }
	public function Init(seed:Int):Void
	{
		this.seed = seed;
	}
	
	public static function next():Int { return instance.Next(); }
	public function Next():Int
	{
		var a:Int    = 16807;      //ie 7**5
		var m:Int    = 2147483647; //ie 2**31-1
		var q:Int = 127773;
		var r:Int = 2836;
		var hi:Int =Math.floor( seed / q);
		var lo:Int =Math.floor( seed % q);
		var test:Int = a * lo - r * hi;
		if (test < 0) test += m;
		this.seed = test;
		return this.seed;		
		
	}
	
	public static function nextFloat():Float { return instance.NextFloat(); }
	public function NextFloat():Float
	{
		return this.Next()/2147483647;
	}
	
	public static function range(low:Int, high:Int):Int { return instance.Range(low, high); }
	public function Range(low:Int, high:Int):Int
	{
		var rnd = this.NextFloat();
		return Math.floor(rnd*(high-low)+low);
	}
	
	public function new(seed:Int) 
	{
		this.Init(seed);
	}
	
}