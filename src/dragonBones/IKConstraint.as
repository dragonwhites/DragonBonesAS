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
		
		public var animationCacheBend:int=0;		
		public var animationCacheWeight:Number=-1;	
		
		public function IKConstraint(data:IKData,armatureData:Armature)
		{
			this.ikdata = data;
			this.armature = armatureData
				
			weight = data.weight;
			bendDirection = (data.bendPositive?1:-1);
			bones = new Vector.<Bone>();
			for each (var boneData:String in data.bones){
				var bone:Bone = armatureData.getBone(boneData);
				bone.isIKConstraint = true;
				bones[bones.length] = bone;
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
					var weig1:Number = animationCacheWeight>=0?animationCacheWeight:weight;
					compute1(bones[0], target, weig1);
					break;
				case 2:
					var bend:int = animationCacheBend!=0?animationCacheBend:bendDirection;
					var weig:Number = animationCacheWeight>=0?animationCacheWeight:weight;
					var tt:Point = compute2(bones[0],bones[1],target.global.x,target.global.y, bend, weig);
					bones[0].rotationIK = tt.x;
					bones[1].rotationIK = tt.y;
					bones[0].ikDvalue = bones[0].rotationIK-bones[0].global.rotation;
					bones[1].ikDvalue = bones[1].rotationIK-bones[1].global.rotation;
					break;
			}
		}
		public function compute1 (bone:Bone, target:Bone, weightA:Number) : void {
			var parentRotation:Number = (!bone.inheritRotation || bone.parent == null) ? 0 : bone.parent.global.rotation;
			var rotation:Number = bone.global.rotation;
			var rotationIK:Number = Math.atan2(target.global.y - bone.global.y, target.global.x - bone.global.x);
			bone.rotationIK = rotation + (rotationIK - rotation) * weightA;
			bone.ikDvalue = bone.rotationIK-rotation;
		}
		public function compute2(parent:Bone, child:Bone, targetX:Number,targetY:Number, bendDirection:int, weightA:Number):Point
		{
			if (weightA == 0) {
				return new Point(parent.global.rotation,child.global.rotation);
			}
			var tt:Point = new Point();
			var p1:Point = new Point(parent.global.x,parent.global.y);
			var p2:Point = new Point(child.global.x,child.global.y);
			var childRotation:Number = child.origin.rotation;
			var dx:Number = p2.x - p1.x;
			var dy:Number = p2.y - p1.y;
			var angle:Number = Math.atan2(dy, dx);
			var parentRotation:Number = angle;
			
			var cx:Number = child.origin.x;
			var cy:Number = child.origin.y;
			var initalRotation:Number = Math.atan2(cy, cx);
			
			var childlength:Number = child.length;
			var childX:Number = p2.x-p1.x;
			var childY:Number = p2.y-p1.y;
			var len1:Number = Math.sqrt(childX * childX + childY* childY);
			var len2:Number = childlength;
			targetX = targetX-p1.x;
			targetY = targetY-p1.y;
			var cosDenom:Number = 2 * len1 * len2;
			if (cosDenom < 0.0001) {
				var temp:Number = Math.atan2(targetY, targetX);
				tt.x = temp  * weightA - initalRotation;
				tt.y = temp  * weightA + tt.x + initalRotation;
				normalize(tt.x);
				normalize(tt.y);
				return tt;
			}
			var cos:Number = (targetX * targetX + targetY * targetY - len1 * len1 - len2 * len2) / cosDenom;
			if (cos < -1)
				cos = -1;
			else if (cos > 1)
				cos = 1;
			var childAngle:Number = Math.acos(cos) * bendDirection;
			var adjacent:Number = len1 + len2 * cos;  
			var opposite:Number = len2 * Math.sin(childAngle);
			var parentAngle:Number = Math.atan2(targetY * adjacent - targetX * opposite, targetX * adjacent + targetY * opposite);
			// Based on code by Ryan Juckett, http://www.ryanjuckett.com/
			var rotationIK:Number = parentAngle;
			rotationIK = parentAngle * weightA;
			tt.x = rotationIK-initalRotation;
			rotationIK = childAngle;
			rotationIK =childAngle* weightA+tt.x;
			tt.y = rotationIK+initalRotation;
			normalize(tt.x);
			normalize(tt.y);
			return tt;
		}
		private function normalize(rotation:Number):void
		{
			if (rotation > Math.PI)
				rotation -= Math.PI*2;
			else if (rotation < -Math.PI)
				rotation += Math.PI*2;
		}
	}
}