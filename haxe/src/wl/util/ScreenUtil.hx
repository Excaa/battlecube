package wl.util;
import js.three.Camera;
import js.three.Vector2;
import js.three.Vector3;
import wl.core.Config;

/**
 * ...
 * @author ...
 */
class ScreenUtil 
{

	public function new() 
	{
		
	}
	
	public static function projectToNormalizedScreenPosition(position:Vector3, camera:Camera) {
		var widthHalf = Config.RESOLUTION[0]*0.5;
		var heightHalf = Config.RESOLUTION[1]*0.5;
        var p:Vector3 = cast position.clone();
        var vector = p.project(camera);

		var r = new Vector2();
        r.x = (vector.x * widthHalf) + widthHalf;
        r.y = -(vector.y * heightHalf) + heightHalf;
		r.x = r.x / (widthHalf*2);
		r.y = r.y / (heightHalf*2);
		//untyped console.log(r);
		
        return r;
    }
	
}