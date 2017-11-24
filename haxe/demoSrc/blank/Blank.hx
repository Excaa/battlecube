package blank;

import haxe.ds.Vector;
import js.three.BoxGeometry;
import js.three.Mesh;
import js.three.MeshBasicMaterial;
import js.three.Vector3;
import wl.core.Part;
import wl.core.TimeSig;
import CubeData.Setup;

/**
 * ...
 * @author 
 */
class Blank extends Part 
{
	private var cube:Mesh;
	private var setupdone:Bool = false;
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
		var boxGeo:BoxGeometry = new BoxGeometry(10,10,10);
		var mat:MeshBasicMaterial = new MeshBasicMaterial({wireframe:true, color:0xffffff});
		this.cube = new Mesh( boxGeo, mat);
		this.camera.position.z = -30;
		this.camera.lookAt(new Vector3());
	}
	
	public override function update(ts:TimeSig, partial:Float, frameTime:Float, delta:Float):Void {
		if (CubeData != null && !setupdone)
		{
			
		}
		super.update(ts, partial, frameTime, delta);
	}
	
	override public function render(ts:TimeSig, frameTime:Float):Void {
		super.render(ts, frameTime);
	}
}