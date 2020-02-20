/**
 * Mask - Copyright © 2010 Influxis All rights reserved.
**/

package org.influxis.as3.containers 
{
	//Influxis Classes
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.display.DisplayObjectContainer;
	
	//Influxis Classes
	import org.influxis.as3.interfaces.display.ISimpleSprite;
	import org.influxis.as3.events.SimpleEventConst;
	
	public class Mask extends Sprite
	{
		private var _target:ISimpleSprite;
		public function Mask( target:ISimpleSprite ): void
		{
			super();
			
			_target = target;
			var display:DisplayObjectContainer = _target as DisplayObjectContainer;
			if ( display )
			{
				display.addChild(this);
				mask = this;
			}
			_target.addEventListener( SimpleEventConst.RESIZE, __onResize );
			__onResize();
		}
		
		/**
		 * HANDLERS
		 */
		
		private function __onResize( event:Event = null ): void
		{
			graphics.clear();
			graphics.beginFill( 0, 1 );
			graphics.drawRect( 0, 0, _target.width, _target.height );
			graphics.endFill();
		}
	}
}