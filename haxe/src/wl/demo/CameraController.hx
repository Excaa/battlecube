package wl.demo;

import js.three.BoxGeometry;
import js.three.Camera;
import js.three.CatmullRomCurve3;
import js.three.Curve;
import js.three.Geometry;
import js.three.Line;
import js.three.LineBasicMaterial;
import js.three.Material;
import js.three.Mesh;
import js.three.MeshBasicMaterial;
import js.three.Object3D;
import js.three.Scene;
import js.three.SplineCurve;
import js.three.SplineCurve3;
import js.three.Vector3;

/**
 * ...
 * @author Henri Sarasvirta
 */
class CameraController implements IController
{
	private static var STOPPED:Bool = false;
	public static function stopAllControl():Void { STOPPED = true; }
	
	public static var STATIC:String = "static";
	public static var LINEAR:String = "linear";
	public static var BEZIER:String = "bezier";
	public static var FOLLOW:String = "follow";
	
	private var camera:Object3D;
	private var mode(default, set):String;
	
	//Static
	public var position:Vector3;
	public var lookAt:Vector3;
	
	//Follow
	public var follow:Object3D;
	public var followOffset:Vector3;
	public var followLookOffset:Vector3;
	
	//Linear
	public var points:Array<Vector3>;
	public var lookAts:Array<Vector3>;
	
	//Bezier
	public var path:SplineCurve3;
	public var lookPath:SplineCurve3;
	
	public var updatePath:Bool=true;
	public var updateLook:Bool = true;
	
	public var ignoreStop:Bool = false;
	
	public function new(?camera:Object3D) 
	{
		if (camera != null) this.attachCamera(camera);
	}
	
	public function attachCamera(camera:Object3D):Void
	{
		this.camera = camera;
	}
	
	public function set_mode(mode:String):String
	{
		this.mode = mode;
		return mode;
	}
	
	public function initStatic(position:Vector3, lookAt:Vector3):Void
	{
		this.position = position;
		this.lookAt = lookAt;
		this.mode = STATIC;
	}
	
	public function initFollow(target:Object3D, ?followOffset:Vector3, ?followLookOffset:Vector3):Void
	{
		this.mode = FOLLOW;
		this.follow = target;
		this.followOffset = followOffset == null ? new Vector3(0,0,0) : followOffset;
		this.followLookOffset = followLookOffset == null ? new Vector3(0,0,0) : followLookOffset;
	}
	
	public function initLinear(points:Array<Vector3>, lookAts:Array<Vector3>)
	{
		this.mode = LINEAR;
		this.points = points;
		this.lookAts = lookAts;
	}
	
	public function initBezier(points:Array<Vector3>, lookAts:Array<Vector3>):Void
	{
		this.mode = BEZIER;
		this.points = points;
		this.lookAts = lookAts;
		this.path = new SplineCurve3(points);
		this.lookPath = new SplineCurve3(lookAts);
	//	untyped this.path.tension = 10;
	//	untyped this.lookPath.tension = 10;
	//	untyped this.path.type = 'centripetal';
	//	untyped this.lookPath.type = 'centripetal';
	}
	
	public function showbezierPaths(scene:Scene){
		for (p in this.points){
			var b = new Mesh(new BoxGeometry(2, 2, 2), new MeshBasicMaterial({color:0xff0000}));
			b.position.set(p.x, p.y, p.z);
			scene.add(b);
		}
		for (p in this.lookAts){
			var b = new Mesh(new BoxGeometry(2, 2, 2), new MeshBasicMaterial({color:0x0000ff}));
			b.position.set(p.x, p.y, p.z);
			scene.add(b);
		}
		var geometry = new Geometry();
		var linematerial = new LineBasicMaterial( { color: 0xff0000, linewidth: 4 } );
		var lookAtGeometry = new Geometry();
		var lookAtLineMaterial = new LineBasicMaterial({color:0x0000ff});
		var amount = 1200;
		for (k in 0...amount) {
						var p3:Vector3 = path.getPointAt(k / amount);
						geometry.vertices.push( cast p3.clone() );
						lookAtGeometry.vertices.push(lookPath.getPointAt(k / amount));
					}
		scene.add(new Line(geometry, linematerial));
		scene.add(new Line(lookAtGeometry, lookAtLineMaterial));
	}
	
	public function update(phase:Float)
	{
		if(CameraController.STOPPED && !ignoreStop)
			return;
		if(this.mode == CameraController.STATIC)
		{
			if (updatePath)
			{
				this.camera.position.x = this.position.x;
				this.camera.position.y = this.position.y;
				this.camera.position.z = this.position.z;
			}
			if (updateLook)
				this.camera.lookAt(this.lookAt);
		}
		else if(this.mode == CameraController.LINEAR)
		{
			if (updatePath)
			{
				var a:Vector3 = this.points[0];
				var b:Vector3 = this.points[1];
				var c:Vector3 = new Vector3();
				c.lerpVectors(a, b, phase);
				camera.position.x = c.x;
				camera.position.y = c.y;
				camera.position.z = c.z;
			}
			if (updateLook)
			{
				var a:Vector3 = this.lookAts[0];
				var b:Vector3 = this.lookAts[1];
				var c:Vector3 = new Vector3();
				c.lerpVectors(a, b, phase);
				this.camera.lookAt(c);
			}
		}
		else if(this.mode == CameraController.FOLLOW)
		{
			if (updatePath)
			{
				this.camera.position.x = this.follow.position.x + this.followOffset.x;
				this.camera.position.y = this.follow.position.y + this.followOffset.y;
				this.camera.position.z = this.follow.position.z + this.followOffset.z;
			}
			if(updateLook)
				this.camera.lookAt(cast this.follow.position.add( this.followLookOffset));
		}
		else if(this.mode == CameraController.BEZIER)
		{
			
			if(phase <0)
				phase=0;
			else if(phase>1)
				phase = 1;
			if (updatePath)
			{
				var p:Vector3 = this.path.getPointAt(phase);
				this.camera.position.x = p.x;
				this.camera.position.y = p.y;
				this.camera.position.z = p.z;
			}
			if (updateLook)
			{
				var p:Vector3 = this.lookPath.getPointAt(phase);
				this.camera.lookAt(p);
				this.lookAt = p;
			}
			this.position = this.camera.position;
		}
	}
}
