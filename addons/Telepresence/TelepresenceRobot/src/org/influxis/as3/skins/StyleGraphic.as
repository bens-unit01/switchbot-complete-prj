package org.influxis.as3.skins 
{
	//Flash Classes
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	
	//Influxis Classes
	import org.influxis.as3.core.infx_internal;
	import org.influxis.as3.display.SimpleSprite;
	import org.influxis.as3.events.SimpleEvent;
	import org.influxis.as3.skins.SkinElement;
	import org.influxis.as3.skins.GraphicSkin;
	import org.influxis.as3.skins.BitmapWrapper;
	import org.influxis.as3.utils.ScreenScaler;
	
	public class StyleGraphic extends SimpleSprite
	{
		private var _skinStyle:String;
		private var _originClass:String;
		private var _skinElement:SkinElement;
		private var _classSkinElement:SkinElement;
		private var _graphic:InteractiveObject;
		
		/**
		 * INIT API
		 */
		
		public function StyleGraphic( skinElement:SkinElement, skinStyle:String, originClass:String ): void
		{
			//If custom skin does not exist then we need to create class back fall
			_originClass = originClass;
			_classSkinElement = SkinElement.getInstance( _originClass );
			if ( _classSkinElement ) _classSkinElement.addEventListener( SimpleEvent.CHANGED, __onClassSkinChanged );
			
			changeStyle( skinStyle );
			changeSkinElement( skinElement );
		}
		
		/**
		 * PUBLIC API
		 */
		
		public function changeStyle( skinStyle:String ): void
		{
			_skinStyle = skinStyle;
			
			//Update skins
			if ( _skinElement && _skinStyle )
			{
				if ( _skinElement.getStyle(_skinStyle) != undefined ) updateGraphic();
			}
		}
		 
		public function changeSkinElement( skinElement:SkinElement ): void
		{
			if ( _skinElement )
			{
				_skinElement.removeEventListener( SimpleEvent.CHANGED, __onSkinChanged );
				_skinElement = null;
			}
			
			_skinElement = skinElement;
			if ( !_skinElement ) return;
			
			if ( getGraphic() != null ) updateGraphic();
			if ( _skinElement.skinName != _originClass ) _skinElement.addEventListener( SimpleEvent.CHANGED, __onSkinChanged );
		}
		
		/**
		 * PROTECTED API
		 */
		
		protected function getGraphic(): InteractiveObject
		{
			var clip:InteractiveObject = _skinElement.getGraphics( _skinStyle );
			if ( _skinElement.skinName != _originClass && !clip ) clip = _classSkinElement.getGraphics( _skinStyle );
			return clip;
		}
		
		protected function updateGraphic(): void 
		{
			removeAllChildren();
			_graphic = getGraphic();	
			if ( _graphic ) 
			{
				__measureGraphic();
				addChild( _graphic );
				arrange();
			}
		}
		
		protected function onStyleChanged( styleName:String = null, styleItem:String = null ):void 
		{
			if ( (styleName && styleName == _skinStyle) || !styleName ) updateGraphic();
		}
		
		/**
		 * HANDLERS
		 */
		 
		private function __onSkinChanged( event:SimpleEvent ):void 
		{
			if ( event.data )
			{
				onStyleChanged( event.data.styleName, event.data.styleItem );
			}else{
				onStyleChanged();
			}
		}
		
		private function __onClassSkinChanged( event:SimpleEvent ):void 
		{
			if ( event.data )
			{
				onStyleChanged( event.data.styleName, event.data.styleItem );
			}else{
				onStyleChanged();
			}
		}
		
		private function __onImageLoaded( event:Event ): void
		{
			if ( !_graphic ) return;
			
			if ( event.type == Event.INIT )
			{
				__measureGraphic();
				arrange();
			}
		}
		
		/**
		 * PRIVATE API
		 */
		
		private function __measureGraphic(): void
		{
			if ( !_graphic ) return;
			
			if (_graphic is Loader)
			{
				var loader:Loader = _graphic as Loader;
				if ( loader )
				{
					try 
					{
						measuredWidth = ScreenScaler.calculateSize(loader.contentLoaderInfo.width);
						measuredHeight = ScreenScaler.calculateSize(loader.contentLoaderInfo.height);
					}catch( e:Error )
					{
						loader.contentLoaderInfo.addEventListener( Event.INIT, __onImageLoaded );
					}
				}
			}else if (_graphic is GraphicSkin )
			{
				var grSkin:GraphicSkin = _graphic as GraphicSkin;
				measuredWidth = grSkin.measuredWidth;
				measuredHeight = grSkin.measuredHeight;
			}else {
				infx_internal::updateMeasure( ScreenScaler.calculateSize(_graphic.width), ScreenScaler.calculateSize(_graphic.height) );
				checkDimensions();
			}
		}
		 
		/**
		 * DISPLAY API
		 */
		 
		override protected function arrange(): void
		{
			if ( _graphic )
			{
				_graphic.width = width;
				_graphic.height = height;
			}
		}
		
		public function get source(): DisplayObject
		{
			if ( _graphic is BitmapWrapper )
			{
				return BitmapWrapper(_graphic).source;
			}else{
				return _graphic;
			}
		}
	}
}