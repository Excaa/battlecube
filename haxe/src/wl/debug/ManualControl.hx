package wl.debug;
import js.Browser;
import js.html.CanvasElement;
import js.html.KeyboardEvent;
import js.html.MouseEvent;
import js.three.Camera;
import js.three.FirstPersonControls;
import js.three.Object3D;
import js.three.Vector3;
import wl.core.Config;
import wl.core.Graphics;
import wl.core.Part;
import wl.demo.CameraController;
import wl.util.MathUtil;

/**
 * ...
 * @author Henri Sarasvirta
 */
class ManualControl
{
	public function new() 
	{
		throw "Manual control is static";
	}
	
	private static var inited:Bool;
	private static var ctrlDown:Bool;
	private static var parts:Array<Part> = [];
	private static var storedPoints:Dynamic = [];
	
	private static var mouseTarget:Vector3;
	private static var fpsControls:Array<FirstPersonControls> = [];
		
	public static function init():Void
	{
		if (inited) return;
		inited = true;
		Browser.document.addEventListener("keydown", onKeyDown);
		Browser.document.getElementById("demo").addEventListener("mousedown", onMouseDown);
		
	}
	
	private static function onMouseDown(event:MouseEvent):Void
	{
		trace("mouse down");
		var canvas:CanvasElement = cast  Browser.document.getElementById("demo").childNodes[0];
		canvas.requestPointerLock();
		Browser.document.addEventListener("mouseup", onMouseUp);
		Browser.document.getElementById("demo").addEventListener("mouseup", onMouseUp);
		event.preventDefault();
		event.stopPropagation();
		for (i in 0...parts.length)
		{
			var p:Part = parts[i];
			var control:FirstPersonControls = fpsControls[i];
			var lookingTo:Vector3 = new Vector3(0,0,-1);
			lookingTo = p.camera.getWorldDirection();
			control.enabled = p.running;
			var x = lookingTo.x;
			var y = lookingTo.y;
			var z = lookingTo.z;
			var lat = 90 - (Math.acos(y / 1)) * 180 / Math.PI;
			var lon = ((270 + (Math.atan2(x , z)) * 180 / Math.PI) % 360) -180;
			control.lat = lat;
			control.lon = lon;
		}
	}
	
	private static function onMouseUp(event:MouseEvent):Void
	{
		trace("Mouse up");
		Browser.document.exitPointerLock();
		for (i in 0...fpsControls.length)
		{
			var control:FirstPersonControls = fpsControls[i];
			control.enabled = false;
			control.movementSpeed = 1;
		}
		Browser.document.removeEventListener("mouseup", onMouseUp);
		Browser.document.getElementById("demo").removeEventListener("mouseup", onMouseUp);
	}
	
	private static function onKeyDown(event:KeyboardEvent):Void
	{
		ctrlDown = event.shiftKey;
		for ( i in 0...parts.length)
		{
			var p:Part = parts[i];
			
			if (!p.running) continue;
			var control:FirstPersonControls = fpsControls[i];
			var camera:Camera = p.camera;
			var camdir = new Vector3(0,0,-100);
			camdir.applyQuaternion(camera.quaternion);
			
			control.movementSpeed = event.shiftKey ? 0.1 : 1;
			
			if(event.keyCode == 80) //'p''
			{
				CameraController.stopAllControl();
				trace("--- "+ camera.name + " ---");
				trace("Pos: x: " + camera.position.x + " y: " + camera.position.y + " z: " + camera.position.z );
				trace("Dir: " + camdir.x + ", " +camdir.y + ", "+ camdir.z);
				trace("Look at: ");
				var la:Vector3 = cast camera.position.clone().add(camdir);
				trace( la.x + ", " + la.y + ", " +la.z);
				trace("Camera rotations: x " + camera.rotation.x + " y " + camera.rotation.y + " z " + camera.rotation.z+ " Array ( " + camera.rotation.x + ","+camera.rotation.y+","+camera.rotation.z+ " )");
			}
			if(event.keyCode == 81)//'q''
			{
				trace("point stored");
				if(storedPoints[cast p.name]== null)
				{
					storedPoints[cast p.name] = {pos:[], rot:[], look:[]};
				}
				var la:Vector3 = cast camera.position.clone().add(camdir);
				storedPoints[cast p.name].pos.push("new Vector3("+Math.round(camera.position.x*100)/100+","+
				Math.round(camera.position.y*100)/100+","+Math.round(camera.position.z*100)/100+")");
				storedPoints[cast p.name].rot.push("new Vector3("+
				Math.round(camera.rotation.x*100)/100+","+Math.round(camera.rotation.y*100)/100+","+Math.round(camera.rotation.z*100)/100+")\n");
				storedPoints[cast p.name].look.push("new Vector3("+Math.round(la.x*100)/100+","+
				Math.round(la.y*100)/100+","+Math.round(la.z*100)/100+")");
			}
			if(event.keyCode == 85)//'u'
			{
				trace("------------------------");
				
				for(point in Reflect.fields(storedPoints))
				{
					
					trace("--- " + point + " ---");
					trace("[\r\n" + storedPoints[cast point].pos.join(",\r\n")+
					"],[\r\n"+ storedPoints[cast point].look.join(",\r\n")+"]");
				}
				storedPoints = {};
			}
		}
	}
	
	public static function update():Void
	{
		for (c in fpsControls)
		{
			if(c.enabled)
				c.update(1);
		}
	}
	
	public static function attachPart(part:Part):Void
	{
		if (!Config.DEBUG) return;
		parts.push(part);
		var control:FirstPersonControls = new FirstPersonControls(part.camera);
		control.enabled = false;
		fpsControls.push(control);
	}
}