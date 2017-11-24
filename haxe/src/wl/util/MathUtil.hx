package wl.util;
import haxe.ds.Either;
import js.three.Vector3;

/**
 * ...
 * @author Henri Sarasvirta
 */
class MathUtil
{

	public function new() 
	{
		
	}
	
	public static function clamp(low:Float, high:Float, val:Float):Float
	{
		return val < low ? low : val > high ? high : val;
	}
	
	public static function FromVector3(position:Vector3, sphereRadius:Float):Array<Float>
    {
		var lat = 90 - (Math.acos(position.y / sphereRadius)) * 180 / Math.PI;
		var lon = ((270 + (Math.atan2(position.x , position.z)) * 180 / Math.PI) % 360) -180;
        //var lat:Float = Math.acos(position.y / sphereRadius); //theta
        //var lon:Float = Math.atan(position.x / position.z); //phi
        return [lon, lat];
    }
	
	public static function componentLerp(v1:Vector3, v2:Vector3, phase:Float, easex:Dynamic, easey:Dynamic, easez:Dynamic, ?setTo:Vector3):Vector3
	{
		setTo = setTo == null ? new Vector3() : setTo;
		setTo.set(
			easex( 1 - phase) * v1.x + easex(phase) * v2.x,
			easey( 1 - phase) * v1.y + easey(phase) * v2.y,
			easez( 1 - phase) * v1.z + easez(phase) * v2.z
		);
		return setTo;
	}
}