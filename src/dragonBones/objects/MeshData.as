package dragonBones.objects 
{
	import dragonBones.Armature;
	import dragonBones.Bone;
	import dragonBones.Slot;
	import dragonBones.utils.TransformUtil;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author sukui
	 */
	public class MeshData extends DisplayData
	{
		
		private var _helpMatrix:Matrix;
		private var _helpPoint:Point;
		/**
		 * 仅包含点坐标
		 */
		public var rawVertices:Vector.<Number>;
		public var triangles:Vector.<int>;
		public var uvs:Vector.<Number>;
		public var edges:Vector.<int>;
		public var updated:Boolean;
		
		private var _bones:Array;
		private var _rigVertices:Vector.<MeshRigData>
		
		private var _boneMatrixDict:Dictionary = new Dictionary();
		private var _skinned:Boolean;
		
		/**
		 * 包含点坐标和uv
		 */
		public var vertices:Vector.<Number>;
				
		public function MeshData() 
		{
			super();
			_helpMatrix = new Matrix();
			_helpPoint = new Point();
		}
		
		public function updateVertices(offset:int, offsetVertices:Vector.<Number>):void
		{
			var i:int = offset;
			var len:int = offset + offsetVertices.length;
			var index:int;
			for (; i < len; i++)
			{
				index = int(i / 2) * 4 + (i % 2);
				if (skinned)
				{
					vertices[index] += offsetVertices[i - offset];
				}
				else
				{
					vertices[index] = rawVertices[i] + offsetVertices[i - offset];
				}
			}
			updated = true;
		}
		
		public function get skinned():Boolean
		{
			return _skinned;
		}
		
		public function set bones(value:Array):void 
		{
			_bones = value;
			_skinned = _bones != null && _bones.length > 0;
		}
		
		public function updateSkinnedMesh():void
		{	
			var vertex:Point;
			for (var i:int = 0, len:int = _rigVertices.length; i < len; i++)
			{
				vertex = _rigVertices[i].getFinalVertex();
				vertices[i * 4] = vertex.x;
				vertices[i * 4 + 1] = vertex.y;
			}
			updated = true;
		}
		
		/**
		 * 此方法应在armature处于骨架状态下仅调用一次
		 * @param	armature
		 */
		public function rig(armature:Armature, slot:Slot):void
		{
			_skinned = true;
			var boneName:String;
			var weight:Number;
			var bone:Bone;
			var meshRigData:MeshRigData;
			
			_rigVertices = new Vector.<MeshRigData>();
			
			var vertexRigData:Array = getVertexRigData();
			var i:int;
			while (vertexRigData)
			{
				trace(vertexRigData);
				_rigVertices.push(createRigVertex(i, vertexRigData, armature, slot));
				
				vertexRigData = getVertexRigData();
				i++;
			}
		}
		
		private function createRigVertex(index:int, vertexRigData:Array, armature:Armature, slot:Slot):MeshRigData
		{
			var meshRigData:MeshRigData = new MeshRigData();
			var num:int = vertexRigData[0];
			
			var bone:Bone;
			var mat:Matrix;
			
			for (var i:int = 0; i < num; i++)
			{
				bone = armature.getBone(vertexRigData[i * 2 + 1]);
				meshRigData.bones.push(bone);
				meshRigData.weights.push(vertexRigData[1 + i * 2 + 1]);
				
				mat = getBoneRelativeMatrix(bone, slot);
				_helpPoint.x = rawVertices[index * 2];
				_helpPoint.y = rawVertices[index * 2 + 1];
				_helpPoint = mat.transformPoint(_helpPoint);
				meshRigData.vertices.push(_helpPoint.x, _helpPoint.y);
			}
			trace(meshRigData.vertices);
			return meshRigData;
		}
		
		private function getVertexRigData():Array
		{
			if (_bones.length == 0)
			{
				return null;
			}
			var num:int = _bones[0];
			var arr:Array = _bones.splice(0, num * 2 + 1);
			return arr;
		}
		
		private function getBoneRelativeMatrix(bone:Bone, slot:Slot):Matrix
		{
			if (_boneMatrixDict[bone] == null)
			{
				_boneMatrixDict[bone] = getRelativeMatrix(bone.global, slot.parent.global);
			}
			
			return _boneMatrixDict[bone] as Matrix;
		}
		
		private function getRelativeMatrix(boneTransform:DBTransform, slotTransform:DBTransform):Matrix
		{
			var relativeMatrix:Matrix = new Matrix();
			if (boneTransform === slotTransform)
			{
				return relativeMatrix;
			}
			
			var boneMatrix:Matrix = new Matrix();
			TransformUtil.transformToMatrix(boneTransform, boneMatrix);
			var slotMatrix:Matrix = new Matrix();
			TransformUtil.transformToMatrix(slotTransform, slotMatrix);
			var absMatrix:Matrix = new Matrix;
			TransformUtil.transformToMatrix(this.transform, absMatrix);
			
			absMatrix.concat(slotMatrix);
			
			boneMatrix.invert();
			
			relativeMatrix.copyFrom(absMatrix);
			relativeMatrix.concat(boneMatrix);
			
			return relativeMatrix;
		}
		
	}

}