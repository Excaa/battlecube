package wl.core;
import haxe.Json;
import haxe.ds.StringMap;
import js.html.Image;
import js.three.Texture;

/**
 * ...
 * @author Henri Sarasvirta
 */
@:expose("kvg.core.assets")
class Assets
{
	private static var _assets:StringMap<Dynamic> = new StringMap<Dynamic>();
	
	public function new() 
	{
		
	}
	
	public static function register(id:String, type:String, data:String, compressed:Bool):Void
	{
		
		if(compressed)
		{
			throw "Compression not implemented.";
/*			var bytesComp = base64DecToArr(data,1);
			var bytes = new Zlib.Inflate(bytesComp);
			data = bytes.decompress();
			
			//TODO - other compressed types to preprocess?
			if(type === "json") 
			{
				var s = "";
				for(var i = 0; i < data.length; i++)
				{
					s+=String.fromCharCode(data[i]);
				}
				data = s;
			}*/
		}
		if(type == "png" || type == "jpg")
		{
			//New Image
			var img = new Image();
			img.src = "data:image/" + (type == "jpg"?"jpeg":type) + ";base64," + data;
			
			_assets.set(id, img);
		}
		else if(type == "mp3" || type == "ogg")
		{
			//Sound registers as pure data.
			_assets.set(id, data);
		}
		else if(type == "json")
		{
			_assets.set(id, Json.parse(data));
		}
		else if(type == "object")
		{
			_assets.set(id, data);
		}
	}
	
	/**
		Get asset by id. Returns null if asset is not found and prints a warning.
		@method get
	*/
	public static function get(id:String):Dynamic{
		if(!_assets.exists(id)) trace("Asset " +id+" not found");
		return _assets.get(id);
	}
	
	public static function getTexture(id:String):Texture
	{
		var img:Image = get(id);
		if (img == null) throw "Texture "+ id+ " not found.";
		var tex:Texture = new Texture(img);
		tex.needsUpdate = true;
		return tex;
	}
}