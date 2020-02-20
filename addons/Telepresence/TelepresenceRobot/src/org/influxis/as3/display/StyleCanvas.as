/**
 * StyleCanvas - Copyright © 2010 Influxis All rights reserved.
**/

package org.influxis.as3.display 
{
	//Flash Classes
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	//Influxis Classes
	import org.influxis.as3.display.StyleComponent;
	import org.influxis.as3.core.infx_internal;
	
	public class StyleCanvas extends StyleComponent
	{
		//Create namespace
		use namespace infx_internal;
		
		private var _background:DisplayObject;
		private var _bShowBackground:Boolean = true;
		
		/**
		 * PRIVATE API
		 */
		
		infx_internal function showBackground( value:Boolean ): void
		{
			if ( _bShowBackground == value ) return;
			_bShowBackground = value;
			if ( _background ) _background.visible = _bShowBackground;
		}
		
		/**
		 * DISPLAY API
		 */
		
		override protected function measure():void 
		{
			super.measure();
			if ( measuredWidth == 0 && _background.width > 0 ) measuredWidth = _background.width;
			if ( measuredHeight == 0 && _background.height > 0 ) measuredHeight = _background.height;
		}
		 
		override protected function createChildren():void 
		{
			super.createChildren();
			_background = getStyleGraphic( "background" );
			_background.visible = _bShowBackground;
			addChild( _background );
		}
		
		override protected function arrange():void 
		{
			super.arrange();
			
			_background.width = width;
			_background.height = height;
		}
	}
}