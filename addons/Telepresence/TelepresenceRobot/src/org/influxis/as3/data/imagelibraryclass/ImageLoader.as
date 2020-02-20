/**
 * ImageLoader - Copyright © 2010 Influxis All rights reserved.
**/

package org.influxis.as3.data.imagelibraryclass 
{
	//Flash Classes
	import flash.display.Loader;
	import flash.events.Event;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	
	//Influxis Classes
	import org.influxis.as3.utils.doTimedLater;
	
	public class ImageLoader extends Loader
	{
		private var _width:Number;
		private var _height:Number;
		private var _measuredWidth:Number;
		private var _measuredHeight:Number;
		
		/**
		 * INIT API
		 */
		
		public function ImageLoader() 
		{
			contentLoaderInfo.addEventListener( Event.INIT, __onImageLoaded );
			super();
		}
		
		/**
		 * PUBLIC API
		 */
		
		override public function loadBytes( bytes:ByteArray, context:LoaderContext = null ): void 
		{
			super.loadBytes( bytes, context );
			doTimedLater( 10, __checkBytesLoaded );
		}
		 
		/**
		 * PRIVATE API
		 */
		
		private function __checkBytesLoaded(): void
		{
			if ( contentLoaderInfo.content )
			{
				__onImageLoaded( new Event(Event.INIT) );
			}else{
				doTimedLater( 100, __checkBytesLoaded );
			}
		}
		 
		/**
		 * HANDLERS
		 */
		
		private function __onImageLoaded( event:Event ): void 
		{
			if ( event.type == Event.INIT )
			{
				_measuredWidth = contentLoaderInfo.content.width;
				_measuredHeight = contentLoaderInfo.content.height;
			}
		}
		
		/**
		 * GETTER / SETTER
		 */
		
		override public function set width( width:Number ): void
		{
			super.width = _width = width;
		}
		
		override public function get width():Number 
		{
			return isNaN(_width) ? _measuredWidth : _width;
		}
		
		override public function set height( height:Number ): void
		{
			super.height = _height = height;
		}
		
		override public function get height():Number 
		{
			return  isNaN(_height) ? _measuredHeight : _height;
		}
		
		public function get measuredWidth(): Number
		{
			return _measuredWidth;
		}
		
		public function get measuredHeight(): Number
		{
			return _measuredHeight;
		}
	}
}