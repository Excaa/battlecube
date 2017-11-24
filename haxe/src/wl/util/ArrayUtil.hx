package wl.util;

/**
 * ...
 * @author Henri Sarasvirta
 */
class ArrayUtil
{

	public function new() 
	{
		
	}
	
	public static function shuffle(array:Array<Dynamic>):Array<Dynamic>
	{
		var currentIndex:Int = array.length;
		var temporaryValue:Dynamic;
		var randomIndex:Int;

		while (0 != currentIndex) {
			// Pick a remaining element...
			randomIndex = Math.floor(Random.nextFloat() * currentIndex);
			currentIndex -= 1;
			
			// And swap it with the current element.
			temporaryValue = array[currentIndex];
			array[currentIndex] = array[randomIndex];
			array[randomIndex] = temporaryValue;
		}
		
		return array;
	}
	
}