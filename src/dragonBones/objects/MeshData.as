package dragonBones.objects 
{
	/**
	 * ...
	 * @author sukui
	 */
	public class MeshData extends DisplayData
	{
		/**
		 * 仅包含点坐标
		 */
		public var rawVertices:Vector.<Number>;
		public var triangles:Vector.<int>;
		public var uvs:Vector.<Number>;
		public var edges:Vector.<int>;
		
		public var updated:Boolean;
		/**
		 * 包含点坐标和uv
		 */
		public var vertices:Vector.<Number>;
				
		public function MeshData() 
		{
			super();
		}
		
		public function updateVertices(offset:int, offsetVertices:Vector.<Number>):void
		{
			var i:int = offset;
			var len:int = offset + offsetVertices.length;
			var index:int;
			
			for (; i < len; i++)
			{
				index = int(i / 2) * 4 + (i % 2);
				vertices[index] = rawVertices[i] + offsetVertices[i - offset];
			}
			updated = true;
		}
		
	}

}