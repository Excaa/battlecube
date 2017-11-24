package blank;

import haxe.Resource;
import haxe.ds.Vector;
import js.three.BoxGeometry;
import js.three.Mesh;
import js.three.MeshBasicMaterial;
import js.three.Object3D;
import js.three.ShaderMaterial;
import js.three.ShaderMaterialParameters;
import js.three.Side;
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
	
	private var itemcontainer:Object3D;
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
				b = new BombV(500);
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
		public static function getMaterial():ShaderMaterial
	{
		var params:ShaderMaterialParameters = { };
		params.fragmentShader = Resource.getString("LinePlane.frag");
		params.vertexShader = Resource.getString("LinePlane.vert");
		trace("SHADERS");
		trace(params.fragmentShader);
		params.uniforms = { 
			fftMap: { type:"t", value:null },
			time: { type:"f", value:0 },
			speed: { type:"f", value:0 },
			mountains: { type:"f", value:0 },
			fft: { type:"f2", value:[1, 1] },
			wallX: { type:"f", value:0.042 },
			sizeX: { type:"f", value:0.2*0.25 },
			
			wallY: { type:"f", value:0.042 },
			sizeY: {type:"f", value:0.2}
		};
		var mat:ShaderMaterial = new ShaderMaterial(params);
		mat.side = Side.BackSide;
		Blank.mat = mat;
		return mat;
	}
	
	public static var mat:ShaderMaterial;
	public static function updatemat():Void
	{
		if (mat != null)
		{
			mat.uniforms.sizeX.value = 0.5/ CubeData.setup.edgeLength;
			mat.uniforms.sizeY.value = 0.5 / CubeData.setup.edgeLength;
			mat.uniforms.wallX.value = 0.2 / CubeData.setup.edgeLength;
			mat.uniforms.wallY.value = 0.2 / CubeData.setup.edgeLength;
			
		}
	}
}