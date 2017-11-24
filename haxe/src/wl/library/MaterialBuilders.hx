package wl.library;
import js.three.Mapping;
import js.three.Material;
import js.three.MaterialParameters;
import js.three.MeshPhongMaterial;
import js.three.MeshPhongMaterialParameters;
import wl.core.Assets;

/**
 * ...
 * @author 
 */
class MaterialBuilders 
{

	public function new() 
	{
		
	}
	
	public function chrome():Material{
		var params:MeshPhongMaterialParameters = {};
		params.envMap = Assets.getTexture("chrome_env_map.png");
		params.envMap.mapping = Mapping.SphericalReflectionMapping;
		params.reflectivity = 0.8;
		params.color = 0xffffff;
		
		return new MeshPhongMaterial(params);
	}
	
	public function whiteChrome():Material{
		var params:MeshPhongMaterialParameters = {};
		params.envMap = Assets.getTexture("white_chrome_env_map.png");
		params.envMap.mapping = Mapping.SphericalReflectionMapping;
		params.reflectivity = 0.8;
		params.color = 0xffffff;
		
		return new MeshPhongMaterial(params);
	}
}