package wl.library;
import js.three.Material;

/**
 * ...
 * @author 
 */
class Library 
{
	private static var inst:Library;
	@:isVar public static var instance(get,null):Library;
	
	private var staticMaterials:Map<Materials, Material>;
	
	static function get_instance(){
		if (inst == null){
			instance = new Library();
		}
		return inst;
	}

	private var materials:MaterialBuilders;
	
	public function new() 
	{
		if (inst == null) inst = this;
		else trace("Creating multiple Library instances. Are you sure?");
		
		materials = new MaterialBuilders();
		staticMaterials = new Map<Materials,Material>();
	}
	
	public function getMaterial(type:Materials, ?asStatic:Bool):Material{
		if (asStatic){
			var m = staticMaterials.get(type);
			if (m == null){
				m = Reflect.callMethod(materials, Reflect.field(materials, type.getName()), []);
				staticMaterials.set(type, m);
			}
			return m;
		}
		return Reflect.callMethod(materials, Reflect.field(materials, type.getName()),[]);
	}
	
}