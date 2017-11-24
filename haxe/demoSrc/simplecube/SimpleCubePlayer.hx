package simplecube;
import js.three.BoxGeometry;
import js.three.Color;
import js.three.Mesh;
import js.three.MeshBasicMaterial;
import js.three.Object3D;
import js.three.SphereGeometry;
import CubeData.Player;

/**
 * ...
 * @author 
 */
class SimpleCubePlayer extends Object3D
{
	public var PlayerName:String;
	public var moving:Bool;
	public function new(p:Player) 
	{
		super();
		PlayerName = p.name;
		var playermesh = new Mesh(new SphereGeometry(1), new MeshBasicMaterial({color:cast p.color}));
		this.add(playermesh);
	}
	
}