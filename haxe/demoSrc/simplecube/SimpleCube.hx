package simplecube;
import haxe.ds.Vector;
import js.three.BoxGeometry;
import js.three.Geometry;
import js.three.Mesh;
import js.three.MeshBasicMaterial;
import js.three.Vector3;
import wl.core.Part;
import wl.core.TimeSig;
import CubeData.Setup;
import CubeData.Player;

/**
 * ...
 * @author 
 */
class SimpleCube extends Part
{
	private var cube:Array < Array < Array<Mesh> >> = [];
	private var setupDone:Bool;
	
	private var players:Array<SimpleCubePlayer>;
	private var bombs:Array<Mesh>;
	
	public function new() 
	{
		super();
		
	}
	
	override public function init():Void 
	{
		super.init();
		this.initStandardScene();
		this.initComposer(this.getComposerList({
			bloom:true,
			distortedTV:true,
			rgbShift:true,
			standard:true
		}));
		
		players = [];
	}
	
	private function setup(setupdata:Setup):Void{
		trace("setup");
		var gridsize = setupdata.edgeLength;
		var gridMat = new MeshBasicMaterial({color:0xff0000, wireframe:true});
		var gridGeo = new BoxGeometry(1, 1, 1);
		for (z in 0...gridsize){
			for (x in 0...gridsize){
				for (y in 0...gridsize){
					var mesh = new Mesh(gridGeo, gridMat);
					mesh.position.set(x, y, z);
					this.scene.add(mesh);
				}
			}
		}
		
		this.camera.position.z = -gridsize * 3;
		this.camera.position.x = 4;
		this.camera.position.y = 4;
		this.camera.lookAt(new Vector3(4,4,0));
	
		setupDone = true;
	}
	
	private function initPlayers(inputPlayers:Array<Player>){
		for (p in inputPlayers){
			var savedPlayer =  players.filter(function (player:SimpleCubePlayer){return player.PlayerName == p.name; });
			
			if (savedPlayer.length == 0){
				var newPlayer = new SimpleCubePlayer(p);
				newPlayer.position.set(p.position.x, p.position.y, p.position.z);
				players.push(newPlayer);
				this.scene.add(newPlayer);
			}
			
			
		}
	}
	
	public override function update(ts:TimeSig, partial:Float, frameTime:Float, delta:Float):Void {
		trace("ASRR");
		super.update(ts, partial, frameTime, delta);
		trace(CubeData);
		
		if (CubeData == null) return;
		if (!setupDone){
			setup(CubeData.setup);	
		}
		initPlayers(CubeData.players);
		
		
		
	}
	
	
	override public function render(ts:TimeSig, frameTime:Float):Void {
		super.render(ts, frameTime);
	}
}