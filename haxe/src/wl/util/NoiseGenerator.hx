package wl.util;

import js.Browser;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.three.Texture;

/**
 * ...
 * @author 
 */
class NoiseGenerator
{

	public function new() 
	{
		
	}
	
	
	public static function generateNoise(?width:Int, ?height:Int, ?opacity:Float):Texture {
		
		var canvas:CanvasElement = cast Browser.document.createElement("canvas");
		var ctx:CanvasRenderingContext2D = canvas.getContext('2d');
		
		var number:Int = 0;
		
		opacity = opacity != null ? opacity : .2;
 
		canvas.width = width != null ? width : 45;
		canvas.height = height != null ? height : 45;
 
		for ( x in 0...canvas.width ) {
			for ( y in 0...canvas.height) {
				number = Math.floor( Math.random() * 60 );
 
				ctx.fillStyle = "rgba(" + number + "," + number + "," + number + "," + opacity + ")";
				ctx.fillRect(x, y, 1, 1);
			}
		}
		return new Texture(canvas);
	  
	  
	//document.body.style.backgroundImage = "url(" + canvas.toDataURL("image/png") + ")";  
   
 
   
   
}
}