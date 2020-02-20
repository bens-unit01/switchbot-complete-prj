package org.influxis.as3.skins 
{
	//Flash Classes
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.Bitmap;
	
	public class BitmapWrapper extends Sprite
	{
		public function BitmapWrapper( bitmapImg:Bitmap ): void
		{
			super.addChild(bitmapImg);
		}
		
		/*
		 * PUBLIC API
		 */
		
		override public function addChild(child:DisplayObject):flash.display.DisplayObject 
		{
			throw new Error("Display Management not allowed!");
		}
		 
		override public function addChildAt(child:DisplayObject, index:int):flash.display.DisplayObject 
		{
			throw new Error("Display Management not allowed!");
		}
		
		override public function removeChild(child:DisplayObject):flash.display.DisplayObject 
		{
			throw new Error("Display Management not allowed!");
		}
		
		override public function removeChildAt(index:int):flash.display.DisplayObject 
		{
			throw new Error("Display Management not allowed!");
		}
		
		/*override public function removeChildren(beginIndex:int = 0, endIndex:int = 2147483647):void 
		{
			throw new Error("Display Management not allowed!");
		}*/
		
		/*
		 * GETTER / SETTER
		 */
		
		override public function get width():Number 
		{
			return getChildAt(0).width;
		}
		
		override public function set width(value:Number):void 
		{
			if ( numChildren > 0 ) getChildAt(0).width = value;
		}
		
		override public function get height():Number 
		{
			return getChildAt(0).height;
		}
		
		override public function set height(value:Number):void 
		{
			if ( numChildren > 0 ) getChildAt(0).height = value;
		}
		
		public function get source(): DisplayObject
		{
			if ( numChildren > 0 ) 
			{
				return getChildAt(0);
			}else{
				return null;
			}
		}
	}
}