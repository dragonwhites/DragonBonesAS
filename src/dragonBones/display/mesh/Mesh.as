package dragonBones.display.mesh
{
	import dragonBones.objects.MeshData;
    import flash.geom.Matrix;
    import flash.geom.Matrix3D;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.geom.Vector3D;
	import starling.display.DisplayObject;
    
    import starling.core.RenderSupport;
    import starling.utils.VertexData;
    
    /**
     *  
     */
    public class Mesh extends DisplayObject
    {
        private var mTinted:Boolean;
        
        /** The raw vertex data of the mesh. */
        protected var mVertexData:VertexData;
        protected var mTriangles:Vector.<int>;
		protected var mVertices:Vector.<Number>;
		protected var mMeshData:MeshData;
        /** Helper objects. */
        private static var sHelperPoint:Point = new Point();
        private static var sHelperPoint3D:Vector3D = new Vector3D();
        private static var sHelperMatrix:Matrix = new Matrix();
        private static var sHelperMatrix3D:Matrix3D = new Matrix3D();
        
        /** Creates a quad with a certain size and color. The last parameter controls if the 
         *  alpha value should be premultiplied into the color values on rendering, which can
         *  influence blending output. You can use the default value in most cases.  */
        public function Mesh(meshData:MeshData, color:uint=0xffffff,
                             premultipliedAlpha:Boolean=true)
        {
            mTinted = color != 0xffffff;
            mMeshData = meshData;
			mVertices = meshData.vertices;
			var dataLen:int = mVertices.length / 4;
            mVertexData = new VertexData(dataLen, premultipliedAlpha);
			
			for (var i:int = 0; i < dataLen; i++)
			{
				mVertexData.setPosition( i, mVertices[i * 4 + 0], mVertices[i * 4 + 1]);
				mVertexData.setTexCoords(i, mVertices[i * 4 + 2], mVertices[i * 4 + 3]);
			}
            mVertexData.setUniformColor(color);
            mTriangles = meshData.triangles;
            onVertexDataChanged();
        }
        
		public function get numVertex():int
		{
			return mVertexData.numVertices;
		}
		
		public function get numTriangle():int
		{
			return mTriangles.length / 3;
		}
		
		public function get skinned():Boolean
		{
			return mMeshData.skinned;
		}
		protected function updateVertices():void
		{
			var dataLen:int = mVertices.length / 4;
			
			for (var i:int = 0; i < dataLen; i++)
			{
				mVertexData.setPosition( i, mVertices[i * 4 + 0], mVertices[i * 4 + 1]);
			}
			onVertexDataChanged();
		}
        /** Call this method after manually changing the contents of 'mVertexData'. */
        protected function onVertexDataChanged():void
        {
            // override in subclasses, if necessary
        }
        
        /** @inheritDoc */
        public override function getBounds(targetSpace:DisplayObject, resultRect:Rectangle=null):Rectangle
        {
            if (resultRect == null) resultRect = new Rectangle();
            
            if (targetSpace == this) // optimization
            {
                mVertexData.getBounds(null, 0, numVertex, resultRect);
            }
            //else if (targetSpace == parent && rotation == 0.0) // optimization
            //{
                //var scaleX:Number = this.scaleX;
                //var scaleY:Number = this.scaleY;
                //mVertexData.getPosition(3, sHelperPoint);
                //resultRect.setTo(x - pivotX * scaleX,      y - pivotY * scaleY,
                                 //sHelperPoint.x * scaleX, sHelperPoint.y * scaleY);
                //if (scaleX < 0) { resultRect.width  *= -1; resultRect.x -= resultRect.width;  }
                //if (scaleY < 0) { resultRect.height *= -1; resultRect.y -= resultRect.height; }
            //}
            else if (is3D && stage)
            {
                stage.getCameraPosition(targetSpace, sHelperPoint3D);
                getTransformationMatrix3D(targetSpace, sHelperMatrix3D);
                mVertexData.getBoundsProjected(sHelperMatrix3D, sHelperPoint3D, 0, 4, resultRect);
            }
            else
            {
                getTransformationMatrix(targetSpace, sHelperMatrix);
                mVertexData.getBounds(sHelperMatrix, 0, 4, resultRect);
            }
            
            return resultRect;
        }
        
		public function get triangles():Vector.<int>
		{
			return mTriangles;
		}
        /** Returns the color of a vertex at a certain index. */
        public function getVertexColor(vertexID:int):uint
        {
            return mVertexData.getColor(vertexID);
        }
        
        /** Sets the color of a vertex at a certain index. */
        public function setVertexColor(vertexID:int, color:uint):void
        {
            mVertexData.setColor(vertexID, color);
            onVertexDataChanged();
            
            if (color != 0xffffff) mTinted = true;
            else mTinted = mVertexData.tinted;
        }
        
        /** Returns the alpha value of a vertex at a certain index. */
        public function getVertexAlpha(vertexID:int):Number
        {
            return mVertexData.getAlpha(vertexID);
        }
        
        /** Sets the alpha value of a vertex at a certain index. */
        public function setVertexAlpha(vertexID:int, alpha:Number):void
        {
            mVertexData.setAlpha(vertexID, alpha);
            onVertexDataChanged();
            
            if (alpha != 1.0) mTinted = true;
            else mTinted = mVertexData.tinted;
        }
        
        /** Returns the color of the quad, or of vertex 0 if vertices have different colors. */
        public function get color():uint 
        { 
            return mVertexData.getColor(0); 
        }
        
        /** Sets the colors of all vertices to a certain value. */
        public function set color(value:uint):void 
        {
            mVertexData.setUniformColor(value);
            onVertexDataChanged();
            
            if (value != 0xffffff || alpha != 1.0) mTinted = true;
            else mTinted = mVertexData.tinted;
        }
        
        /** @inheritDoc **/
        public override function set alpha(value:Number):void
        {
            super.alpha = value;
            
            if (value < 1.0) mTinted = true;
            else mTinted = mVertexData.tinted;
        }
        
        /** Copies the raw vertex data to a VertexData instance. */
        public function copyVertexDataTo(targetData:VertexData, targetVertexID:int=0):void
        {
            mVertexData.copyTo(targetData, targetVertexID);
        }
        
        /** Transforms the vertex positions of the raw vertex data by a certain matrix and
         *  copies the result to another VertexData instance. */
        public function copyVertexDataTransformedTo(targetData:VertexData, targetVertexID:int=0,
                                                    matrix:Matrix=null):void
        {
            mVertexData.copyTransformedTo(targetData, targetVertexID, matrix, 0, 4);
        }
        
        /** @inheritDoc */
        public override function render(support:RenderSupport, parentAlpha:Number):void
        {
			if (mMeshData.updated)
			{
				updateVertices();
			}
        }
        
        /** Returns true if the quad (or any of its vertices) is non-white or non-opaque. */
        public function get tinted():Boolean { return mTinted; }
        
        /** Indicates if the rgb values are stored premultiplied with the alpha value; this can
         *  affect the rendering. (Most developers don't have to care, though.) */
        public function get premultipliedAlpha():Boolean { return mVertexData.premultipliedAlpha; }
    }
}