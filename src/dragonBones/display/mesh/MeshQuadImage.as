package dragonBones.display.mesh 
{
	import dragonBones.objects.MeshData;
	import starling.textures.Texture;
	/**
	 * ...
	 * @author sukui
	 */
	public class MeshQuadImage extends MeshImage
	{
		
		public function MeshQuadImage(texture:Texture) 
		{
			var w:Number = texture.width;
			var h:Number = texture.height;
			
			var meshData:MeshData = new MeshData();
			var vertices:Vector.<Number> = new Vector.<Number>();
			vertices.push(0, 0, 0, 0);
			vertices.push(0, h, 0, 1);
			vertices.push(w, 0, 1, 0);
			vertices.push(w, h, 1, 1);
			var triangles:Vector.<int> = new Vector.<int>();
			triangles.push(0, 1, 2);
			triangles.push(1, 3, 2);
			meshData.vertices = vertices;
			meshData.triangles = triangles;
			super(texture, meshData);
		}
		
	}

}