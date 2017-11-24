package blank;

import haxe.ds.Vector;
import js.three.BoxGeometry;
import js.three.Mesh;
import js.three.MeshBasicMaterial;
import js.three.Object3D;
import js.three.Vector3;
import wl.core.Part;
import wl.core.TimeSig;
import CubeData.Setup;
import CubeData.Bomb;

/**
 * ...
 * @author 
 */
class Blank extends Part 
{
	private var cube:Mesh;
	private var setupdone:Bool = false;
	
	private var bombs:Array<Array<Array<BombV>>> = [];
	
	private var itemcontainer:Object3D;
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
		
		
	}
	private function setupCube():Void
	{
		var size:Int = CubeData.setup.edgeLength;
		this.itemcontainer = new Object3D();
		this.itemcontainer.position.x = -size / 2;
		this.itemcontainer.position.y = -size / 2;
		this.itemcontainer.position.z = -size / 2;
		
		var boxGeo:BoxGeometry = new BoxGeometry(10,10,10);
		var mat:MeshBasicMaterial = new MeshBasicMaterial({wireframe:true, color:0xffffff});
		this.cube = new Mesh( boxGeo, mat);
		this.scene.add(cube);
		this.camera.position.z = -30;
		this.camera.lookAt(new Vector3());
		this.setupdone = true;
		this.cube.add(this.itemcontainer);
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
		trace("setup done");
	}
	
	public override function update(ts:TimeSig, partial:Float, frameTime:Float, delta:Float):Void {
		if (CubeData == null) return;
		if (CubeData != null && !setupdone)
		{
			setupCube();
		}
		
		for ( bomb in CubeData.bombs)
		{
			var b:BombV = bombs[bomb.x][bomb.y][bomb.z];
			if (b == null)
			{
				b = new BombV();
				this.itemcontainer.add(b);
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
		
		super.update(ts, partial, frameTime, delta);
	}
	
	override public function render(ts:TimeSig, frameTime:Float):Void {
		super.render(ts, frameTime);
	}
}