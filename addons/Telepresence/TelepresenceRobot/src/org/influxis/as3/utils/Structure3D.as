package org.influxis.as3.utils 
{
	//Flash Classes
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	
	public class Structure3D
	{
		public static function createCarousel( displayList:Vector.<DisplayObject>, container:DisplayObjectContainer = null ): Object
		{
			if ( !displayList ) return null;
			
			var display:DisplayObject;
			var nLen:Number = displayList.length;
			var info:Object = new Object();
				info["anglePerDisplay"] = (Math.PI * 2) / nLen;
				info["angles"] = new Array();
			
			var b:Number = 350 / 38;
			for( var i:Number = 0; i < nLen; i++ )
			{
				display = displayList[i] as DisplayObject;
				info.angles.push((i * info["anglePerDisplay"]) - Math.PI / 2);
				display.scaleX = display.scaleY = 0.5;
				display.x = Math.cos(info.angles[i]) * 350;
				display.z = Math.sin(info.angles[i]) * 350;
				display.rotationY = 38 * -i;
				if( container ) container.addChild(display);
			}
			return info;
		}
	}
}