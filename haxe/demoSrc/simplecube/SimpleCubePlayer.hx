package simplecube;
import createjs.tweenjs.Tween;
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
	
	private var playermesh:Mesh;
	private var alive:Bool;
	public function new(p:Player) 
	{
		super();
		alive = true;
		PlayerName = p.name;
		playermesh = new Mesh(new BoxGeometry(0.6,0.6,0.6), new MeshBasicMaterial({color:cast p.color}));
		this.add(playermesh);
	}
	
	public function die():Void{
		trace("Die");
		if (alive){
			alive = false;
			Tween.get(playermesh.scale).to({x:0.1, y:0.1, z:0.1}, 500);
		}
		//playermesh.scale.set(0.3, 0.3, 0.3);
	}
	
	public function reset():Void{
		trace("reset player");
		playermesh.scale.set(1,1,1);
	}
}