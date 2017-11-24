package wl.util;
import dat.gui.GUI;
import js.three.Vector3;

/**
 * ...
 * @author Henri Sarasvirta
 */
class DatGuiHelper
{

	public function new() 
	{
		
	}
	
	public static function addVector(folder:GUI, vector:Vector3, ?step:Float, ?callback:Void->Void):Void
	{
		if (step == null) step = 0.1;
		folder.add(vector, "x").step(step).onChange(callback);
		folder.add(vector, "y").step(step).onChange(callback);
		folder.add(vector, "z").step(step).onChange(callback);
	}
	
}