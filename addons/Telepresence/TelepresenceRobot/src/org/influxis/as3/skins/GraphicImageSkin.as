package org.influxis.as3.skins 
{
	//Flash Classes
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Loader;
	import flash.display.Sprite;
	
	//Influxis Classes
	import org.influxis.as3.skins.GraphicSkin;
	import org.influxis.as3.data.ImageLibrary;
	import org.influxis.as3.utils.ScreenScaler;
	
	public class GraphicImageSkin extends GraphicSkin
	{
		private static var imageLibrady:ImageLibrary = ImageLibrary.getInstance();
		private var _mainGraphic:Sprite;
		private var _image:DisplayObject;
		private var _mask:DisplayObject;
		
		/**
		 * INIT API
		 */
		
		public function GraphicImageSkin( skinData:Object, originSkin:Object = null ) 
		{
			super( skinData, originSkin );
		}
		
		/**
		 * PUBLIC API
		 */
		
		override public function clear():void 
		{
			super.clear();
			removeAllChildren();
			
			if( _mainGraphic ) _mainGraphic.graphics.clear();
			if ( _image is Loader ) (_image as Loader).unload();
			_mainGraphic = null;
			_image = null;
		}
		
		override public function redraw():void 
		{
			if ( !_mainGraphic ) return;
			GraphicSkin.drawGraphic( skinData, _mainGraphic.graphics, width, height );
		}
		
		/**
		 * PROTECTED API
		 */
		
		override protected function parseData(skinData:Object, originSkin:Object, draw:Boolean = true):void 
		{
			clear();
			super.parseData(skinData, originSkin, false);
			
			var o:Object = this.skinData;
			o.image = skinData.image == undefined || skinData.image == "" ? originSkin.image == undefined || originSkin.image == "" ? null : originSkin.image : skinData.image;
			o.mask = skinData.mask == undefined || skinData.mask == "" ? originSkin.mask == undefined || originSkin.mask == "" ? null : originSkin.mask : skinData.mask;
			this.skinData = o;
			
			_composeImage();
			if ( draw ) arrange();
		}
		
		/**
		 * PRIVATE API
		 */
		
		private function _composeImage(): void
		{
			_mainGraphic = new Sprite();
			
			_image = imageLibrady.getImage( skinData.image );
			_mask = imageLibrady.getImage( skinData.mask );
			
			var newMeasuredWidth:Number;
			var newMeasuredHeight:Number;
			
			var loader:Loader = _image as Loader;
			if ( loader )
			{
				try
				{
					newMeasuredWidth = !isNaN(skinData.measuredWidth) ? Number(skinData.measuredWidth) : loader.contentLoaderInfo.width;
					newMeasuredHeight = !isNaN(skinData.measuredHeight) ? Number(skinData.measuredHeight) : loader.contentLoaderInfo.height;
				}catch ( e:Error )
				{
					
				}
			}
			
			//If first measure fails then check original
			try
			{
				if ( isNaN(newMeasuredWidth) || newMeasuredWidth == 0 ) newMeasuredWidth = _image.width;
				if ( isNaN(newMeasuredHeight) || newMeasuredHeight == 0 ) newMeasuredHeight = _image.height;
			}catch ( e:Error )
			{
				
			}
			
			//Set new measure
			measuredWidth = ScreenScaler.calculateSize(newMeasuredWidth);
			measuredHeight = ScreenScaler.calculateSize(newMeasuredHeight);
			
			if ( _mask ) mask = _mask;
			if ( _image ) addChild( _image );
			addChild( _mainGraphic );
		}
		
		/**
		 * DISPLAY API
		 */
		
		override protected function arrange():void 
		{
			super.arrange();
			
			if ( _image )
			{
				_image.width = width;
				_image.height = height;
			}
			
			if ( _mask )
			{
				_mask.width = width;
				_mask.height = height;
			}
		}
	}
}