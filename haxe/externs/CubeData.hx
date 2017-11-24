
/**
 * ...
 * @author Henri Sarasvirta
 */
@:native("cubeData")
extern class CubeData
{
	public static var players:Array<Player>;
	public static var bombs:Array<Bomb>;
	public static var setup:Array<Setup>;
}

typedef Player = {
	public var name:String;
	public var url:String;
	public var color:String;
	public var status:Int;
	public var score:Int;
	public var wins:Int;
}

typedef Bomb = {
	public var x:Int;
	public var y:Int;
	public var z:Int;
	public var type:String;
}

typedef Setup = {
	public var edgeLength:Int;
	public var maxNumOfticks:Int;
	public var numOfTasksPerTick:Int;
	public var speed:Int;
}