package blank;
import createjs.tweenjs.Tween;
import js.three.Geometry;
import js.three.Mesh;
import js.three.MeshBasicMaterial;
import js.three.Object3D;
import js.three.TorusGeometry;
import CubeData.setup;

/**
 * ...
 * @author Henri Sarasvirta
 */
class BombV extends Object3D
{
	private var mesh:Mesh;
	
	private var mat:MeshBasicMaterial;
	private static var geo:Geometry;
	
	public var x:Int;
	public var y:Int;
	public var z:Int;
	
	private var exploded:Bool = false;
	private var speed:Int;
	
	public function new(speed:Int) 
	{
		super();
		if(geo ==null)
			geo = new TorusGeometry(0.5, 0.2);
		if(mat == null)
			mat = new MeshBasicMaterial( { color:0xff0000,transparent:true } );
			
		this.speed = speed;
		this.mesh = new Mesh(geo, mat);
		this.add(mesh);
		Tween.get(this.rotation,{loop:true}).to( { x:Math.PI }, 5000);
		Tween.get(this.mesh.scale, {loop:true}).to( { x:1.2,y:1.2, z:1.2 }, 150).to({x:1, y:1,z:1}, 150);
	}
	
	public function explode():Void
	{
		if (exploded) return;
		exploded = true;
		Tween.removeTweens(this.mesh.scale);
		trace("EXPLODE: " + explode);
		Tween.get(this.mesh.scale).to( { x:2.5, y:2.5, z:2.5 }, speed);
		Tween.get(this.mesh.material).to( { opacity:0 }, speed).call(function() {
			this.parent.remove(this);
		} );
	}
	
	public function spawn():Void
	{
		
	}
	
}