package wl.util;
import js.three.Face3;
import js.three.Geometry;
import js.three.Vector3;

/**
 * Modified from code by alteredq. Info for original below.
 * 
 * Make all faces use unique vertices
 * so that each face can be separated from others
 *
 * @author alteredq / http://alteredqualia.com/
 */
class ExplodeGeometry
{

	public function new() 
	{
		
	}
	
	static public function explode(geometry:Geometry):Void
	{
		var vertices:Array<Vector3> = [];
		for (i in 0...geometry.faces.length)
		{
			var n:Int = vertices.length;
			var face:Face3 = geometry.faces[i];
			
			var a:Int = face.a;
			var b:Int = face.b;
			var c:Int = face.c;
			
			var va:Vector3 = geometry.vertices[a];
			var vb:Vector3 = geometry.vertices[b];
			var vc:Vector3 = geometry.vertices[c];
			
			vertices.push(cast va.clone());
			vertices.push(cast vb.clone());
			vertices.push(cast vc.clone());
			
			face.a = n;
			face.b = n + 1;
			face.c = n + 2;
		}
		geometry.vertices = vertices;
	}
}