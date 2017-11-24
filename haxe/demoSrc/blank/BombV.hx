package blank;
import js.three.Geometry;
import js.three.Mesh;
import js.three.MeshBasicMaterial;
import js.three.Object3D;
import js.three.TorusGeometry;

/**
 * ...
 * @author Henri Sarasvirta
 */
class BombV extends Object3D
{
	private var mesh:Mesh;
	
	private static var mat:MeshBasicMaterial;
	private static var geo:Geometry;
	
	public var x:Int;
	public var y:Int;
	public var z:Int;
	
	public function new() 
	{
		super();
		if(geo ==null)
			geo = new TorusGeometry(0.5, 0.2);
		if(mat == null)
			mat = new MeshBasicMaterial( { color:0xff0000 } );
			
		this.mesh = new Mesh(geo, mat);
		this.add(mesh);
		
	}
	
	public function explode():Void
	{
		
	}
	
}