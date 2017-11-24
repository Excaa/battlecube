package wl.util;
import js.three.ExtrudeGeometry;
import js.three.Geometry;
import js.three.Material;
import js.three.Mesh;
import js.three.MeshBasicMaterial;
import js.three.MeshPhongMaterial;
import js.three.Object3D;
import js.three.Shape;
import js.three.ShapeGeometry;
import js.three.Vector3;

/**
 * ...
 * @author 
 */
class NgonFactory extends Object3D
{
	private var ngonGeometry:Geometry;
	private var ngonMaterial:Material;
	private var ngon:Int;
	private var radius:Int;
	
	public function new(ngon:Int, radius:Int, height:Int, material:Material, extrudeSettings) 
	{
		super();
		
		this.ngon = ngon;
		this.radius = radius;
		
		extrudeSettings = extrudeSettings == null ?  {
				amount: height,
				bevelEnabled: true,
				bevelSegments: 0,
				steps: 1,
				bevelSize: 0.0,
				bevelThickness: 0.0,
			} : extrudeSettings;
		
		var i, verts = [];
	
		for (i in 0...ngon) {
			verts.push(this.createVertex(i));
		}
		
		var cellShape = new Shape();
		cellShape.moveTo(verts[0].x, verts[0].y);
		for (i in 0...this.ngon) {
			cellShape.lineTo(verts[i].x, verts[i].y);
		}
		cellShape.lineTo(verts[0].x, verts[0].y);
		cellShape.autoClose = true;

		this.ngonGeometry = new ExtrudeGeometry(cellShape, extrudeSettings);
		this.ngonMaterial = material;
	}
	
	public function CreateMesh() {
		var mesh = new Mesh(this.ngonGeometry, this.ngonMaterial);
		mesh.rotateOnAxis(new Vector3(1, 0, 0), Math.PI / 2);
		return mesh;
	}
	
	private function createVertex(i:Int):Vector3 {
		var angle = (2*Math.PI / this.ngon) * i;
		return new Vector3((this.radius * Math.cos(angle)), (this.radius * Math.sin(angle)), 0);
	}
	
}