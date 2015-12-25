package dragonBones
{
	import flash.geom.Point;
	
	import dragonBones.objects.IKData;
	
	public class IKConstraint
	{
		private var ikdata:IKData;
		private var armature:Armature;
		
		public var bones:Vector.<Bone>;
		public var target:Bone;
		public var bendDirection:int;
		public var weight:Number;
		
		
		public function IKConstraint(data:IKData,armatureData:Armature)
		{
			this.ikdata = data;
			this.armature = armatureData
				
			weight = data.weight;
			bendDirection = (data.bendPositive?1:-1);
			bones = new Vector.<Bone>();
			for each (var boneData:String in data.bones){
				bones[bones.length] = armatureData.getBone(boneData);
			} 
			target = armatureData.getBone(data.target);
		}
		public function dispose():void
		{
			
		}
		public function compute():void
		{
			switch (ikdata.bones.length) {
				case 1:
					compute1(bones[0], target, weight);
					break;
				case 2:
					var tt:Point = compute2(bones[0],bones[1],target.global.x,target.global.y, bendDirection, weight);
					bones[0].rotationIK = tt.x;
					bones[1].rotationIK = tt.y;
					bones[0].ikDvalue = bones[0].rotationIK-bones[0].global.rotation;
					bones[1].ikDvalue = bones[1].rotationIK-bones[1].global.rotation;
					break;
			}
		}
		private const radDeg:Number = 180 / Math.PI;
		public function compute1 (bone:Bone, target:Bone, weightA:Number) : void {
			var parentRotation:Number = (!bone.inheritRotation || bone.parent == null) ? 0 : bone.parent.global.rotation;
			var rotation:Number = bone.global.rotation;
			var rotationIK:Number = Math.atan2(target.global.y - bone.global.y, target.global.x - bone.global.x);// * radDeg;
			//if (bone._worldFlipX != (bone._worldFlipY != Bone.yDown)) rotationIK = -rotationIK;
			//rotationIK -= parentRotation;
			bone.rotationIK = rotation + (rotationIK - rotation) * weightA;
			bone.ikDvalue = bone.rotationIK-rotation;
		}
		private const tempPosition:Vector.<Number> = new Vector.<Number>(2, true);
		public function compute2(parent:Bone, child:Bone, targetX:Number,targetY:Number, bendDirection:int, weightA:Number):Point
		{
			var tt:Point = new Point();
			var p1:Point = new Point(parent.global.x,parent.global.y);
			var p2:Point = new Point(child.global.x,child.global.y);
			var childRotation:Number = child.global.rotation;
			var parentRotation:Number = parent.global.rotation;
			if (weightA == 0) {
				return new Point(parentRotation,childRotation);
			}
			var childlength:Number = child.length;
			var childX:Number = p2.x-p1.x;
			var childY:Number = p2.y-p1.y;
			//var offset:Number = Math.atan2(childY, childX);//父坐标偏移，
			var len1:Number = Math.sqrt(childX * childX + childY* childY);
			var len2:Number = childlength;
			targetX = targetX-p1.x;
			targetY = targetY-p1.y
			var cosDenom:Number = 2 * len1 * len2;
			if (cosDenom < 0.0001) {
				return new Point(0,0);
			}
			var cos:Number = (targetX * targetX + targetY * targetY - len1 * len1 - len2 * len2) / cosDenom;
			if (cos < -1)
				cos = -1;
			else if (cos > 1)
				cos = 1;
			var childAngle:Number = Math.acos(cos) * bendDirection;//o2
			var adjacent:Number = len1 + len2 * cos;  //ae
			var opposite:Number = len2 * Math.sin(childAngle);//be
			var parentAngle:Number = Math.atan2(targetY * adjacent - targetX * opposite, targetX * adjacent + targetY * opposite);//o1
			var rotation:Number = parentAngle
			rotation = (rotation-parentRotation) * weightA+parentRotation;
			if (rotation > Math.PI)
				rotation -= Math.PI*2;
			else if (rotation < -Math.PI) 
				rotation += Math.PI*2;
			tt.x = rotation;
			//* radDeg;
			//trace("parent:",rotation * alpha* radDeg)
			rotation = childAngle;
			//trace("child:",rotation* alpha* radDeg);
			rotation = tt.x + (rotation-tt.x)* weightA+tt.x;
			if (rotation > Math.PI)
				rotation -= Math.PI*2;
			else if (rotation < -Math.PI)
				rotation += Math.PI*2;
			tt.y = rotation;
			return tt;
		}
	}
}