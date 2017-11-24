package wl.demo;
import haxe.ds.Vector;
import js.Browser;
import js.html.LocalMediaStream;
import js.three.Box3;
import js.three.Camera;
import js.three.Object3D;
import js.three.Vector3;
import wl.core.TimeSig;
import wl.util.Random;

/**
 * ...
 * @author Henri Sarasvirta
 */
class RandomCameraController
{
	private var camera:Camera;
	private var follow:Array<Object3D>;
	private var random:Random;
	private var ccs:Array<CameraController>;
	private var current:Int = 0;
	private var cameraSwap:Float = 0;
	private var distanceRange:Array<Int> = [];
	private var bounds:Box3;
	
	private var md:Int;
	private var rnd:Int;
	
	public function new(camera:Camera, cameraAmount:Int, follow:Array<Object3D>, seed:Int, allowTypes:Array<String>, distanceRange:Array<Int>, bounds:Box3) 
	{
		if (allowTypes.length == 0) throw "Random camera requires at least 1 type";
		md = distanceRange[0];
		this.bounds = bounds;
		rnd = distanceRange[1] - distanceRange[0];
		this.distanceRange = distanceRange;
		this.random = new Random(seed);
		this.follow = follow;
		this.camera = camera;
		this.ccs = [];
		for (i in 0...cameraAmount)
		{
			var cc:CameraController = new CameraController(this.camera);
			var type:String = allowTypes[random.Next() % allowTypes.length];
			if (type == CameraController.FOLLOW)
			{
				this.initFollow(cc);
			}
			else if (type == CameraController.LINEAR)
			{
				this.initLinear(cc);
			}
			else if (type == CameraController.STATIC)
			{
				this.initStatic(cc);
			}
			else if (type == CameraController.BEZIER)
			{
				this.initBezier(cc);
			}
			this.ccs.push(cc);
		}
	}
	public function start():Void
	{
		this.cameraSwap = Date.now().getTime();
	}
	
	public function swap():Void
	{
		this.cameraSwap = Date.now().getTime();
		current = (current + 1) % this.ccs.length;
	}
	
	/**
	 * Update by [0,1] manually.
	 * @param	val
	 */
	public function updatePartial(val:Float):Void
	{
		this.ccs[current].update(val);
	}
	
	/**
	 * Update by amount of time. The starting point is previous swap.
	 * @param	time
	 */
	public function updateLength(time:Float):Void
	{
		var partial:Float = ( Date.now().getTime() - this.cameraSwap) / time;
		this.ccs[current].update(partial);
		//trace(partial + ": " + this.camera.position.x + " , " + this.camera.position.y + ", " + this.camera.position.z);
		
	}
	
	private function getRndPoint():Vector3
	{
		var v:Vector3 =cast bounds.min.clone();
		v=v.addScaledVector(cast bounds.max.clone().sub(bounds.min), random.NextFloat());
		return v;
	}
	
	private function initFollow(cc:CameraController):Void
	{
		var obj:Object3D = this.follow.length > 0 ? this.follow[random.Next() % follow.length] : new Object3D();
		
		var dir:Vector3 = new Vector3(random.NextFloat() - 0.5, random.NextFloat() - 0.5, random.NextFloat() - 0.5);
		dir.normalize();
		dir.multiplyScalar(random.NextFloat() * rnd + md);
		
		cc.initFollow(obj, dir,
		new Vector3(random.NextFloat() * md/10, random.NextFloat() * md/10, random.NextFloat() * md/10));
	}
	private function initStatic(cc:CameraController):Void
	{
		var obj:Object3D = this.follow.length > 0 ? this.follow[random.Next() % follow.length] : new Object3D();
		
		var startp:Vector3 = getRndPoint();
		cc.initStatic(startp, obj.position);
	}
	
	private function initLinear(cc:CameraController):Void
	{
		var obj:Object3D = this.follow.length > 0 ? this.follow[random.Next() % follow.length] : new Object3D();
		
		var startp:Vector3 = getRndPoint();
		
		var endp:Vector3 = getRndPoint();
		cc.initLinear( [
		startp, endp
		], [
		cast obj.position.clone(),
		cast obj.position.clone().add(new Vector3(random.NextFloat() * 20 - 10, random.NextFloat() * 20 - 10, random.NextFloat() * 20 - 10))
		]);
	}
	
	private function initBezier(cc:CameraController):Void
	{
		var obj:Object3D = this.follow.length > 0 ? this.follow[random.Next() % follow.length] : new Object3D();
		var start:Vector3 = getRndPoint();
		
		var end:Vector3 = getRndPoint();
		
		var pos:Array<Vector3> = [start];
		var looks:Array<Vector3> = [cast obj.position.clone(), cast obj.position.clone()];
		
		var dx:Float = end.x - start.x;
		var dy:Float = end.y - start.y;
		var dz:Float = end.z - start.z;
		
		for (i in 1...6)
		{
			looks.push(cast obj.position.clone());
			pos.push(new Vector3(
				random.NextFloat() * dx / 10 - dx / 20 + i / 6 * dx+start.x,
				random.NextFloat() * dy / 10 - dy / 20 + i / 6 * dy+start.y,
				random.NextFloat() * dz / 10 - dz / 20 + i / 6 * dz+start.z)
				
			);
		}
		
		pos.push(end);
		cc.initBezier(pos,looks);
	}
}