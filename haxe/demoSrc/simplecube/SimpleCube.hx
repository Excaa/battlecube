package simplecube;
import blank.BombV;
import createjs.tweenjs.Ease;
import createjs.tweenjs.Tween;
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
import CubeData.Bomb;
/**
 * ...
 * @author 
 */
class SimpleCube extends Part
{
	private var cube:Array < Array < Array<Mesh> >> = [];
	private var setupDone:Bool;
	private var tickSpeed:Int;
	
	private var players:Array<SimpleCubePlayer>;
	
	private var bombs:Array<Array<Array<BombV>>> = [];
	private var active:Array<BombV> = [];
	
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
					//this.scene.add(mesh);
				}
			}
		}
		var size:Int = CubeData.setup.edgeLength;
		for ( i in 0...size)
		{
			bombs[i] = [];
			for (j in 0...size)
			{
				bombs[i][j] = [];
				for (k in 0...size)
				{
					bombs[i][j][k] = null;
				}
			}
		}
		
		this.camera.position.z = -gridsize * 3;
		this.camera.position.x = 4;
		this.camera.position.y = 4;
		this.camera.lookAt(new Vector3(4,4,0));
		
		tickSpeed = setupdata.speed;
		setupDone = true;
	}
	
	private function initPlayers(inputPlayers:Array<Player>){
		for (p in inputPlayers){
			var savedPlayer =  players.filter(function (player:SimpleCubePlayer){return player.PlayerName == p.name; });
			
			var playah:SimpleCubePlayer;
			if (savedPlayer.length == 0){
				var newPlayer = new SimpleCubePlayer(p);
				newPlayer.position.set(p.position.x, p.position.y, p.position.z);
				players.push(newPlayer);
				this.scene.add(newPlayer);
				playah = newPlayer;
			}
			else{
				playah = savedPlayer[0];
			}
			if (!playah.moving && playah.position.x != p.position.x || playah.position.y != p.position.y || playah.position.z != p.position.z){
				Tween.removeTweens(playah.position);
				playah.moving = true;
				Tween.get(playah.position).to({x:p.position.x, y:p.position.y, z:p.position.z}, cast tickSpeed * 0.7, Ease.quadInOut).call(function (pll:Dynamic){pll.moving = false;});
			}
			
			
		}
	}
	
	public override function update(ts:TimeSig, partial:Float, frameTime:Float, delta:Float):Void {
		
		super.update(ts, partial, frameTime, delta);
		
		if (CubeData == null) return;
		if (!setupDone){
			setup(CubeData.setup);	
		}
		tickSpeed = CubeData.setup.speed;
		initPlayers(CubeData.players);
		
		
		for ( bomb in CubeData.bombs)
		{
			var b:BombV = bombs[bomb.x][bomb.y][bomb.z];
			if (b == null)
			{
				b = new BombV(tickSpeed);
				this.scene.add(b);
				b.x = bomb.x;
				b.y = bomb.y;
				b.z = bomb.z;
				b.position.x = b.x;
				b.position.y = b.y;
				b.position.z = b.z;
				bombs[b.x][b.y][b.z] = b;
				active.push(b);
			}
		}
		//Clear dead ones
		var remove:Array<BombV> = [];
		for ( b in active)
		{
			var isok:Bool = CubeData.bombs.filter(function(bd:Bomb):Bool { return bd.x == b.x && bd.y == b.y && bd.z == bd.z; } ).length > 0;
			if (!isok)
				remove.push(b);
		}
		for (b in remove)
		{
			active.remove(b);
			b.explode();
		}
		
	}
	
	
	override public function render(ts:TimeSig, frameTime:Float):Void {
		super.render(ts, frameTime);
	}
}