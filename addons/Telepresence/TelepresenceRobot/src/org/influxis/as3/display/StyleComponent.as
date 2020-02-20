/**
 * StyleComponent - Copyright © 2010 Influxis All rights reserved.
**/

package org.influxis.as3.display 
{
	//Flash Classes
	import flash.display.InteractiveObject;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	//Influxis Classes
	import org.influxis.as3.display.SimpleComponent;
	import org.influxis.as3.managers.SkinsManager;
	import org.influxis.as3.net.LabelLoader;
	import org.influxis.as3.skins.StyleGraphic;
	import org.influxis.as3.skins.SkinElement;
	import org.influxis.as3.events.SimpleEvent;
	import org.influxis.as3.utils.doTimedLater;
	import org.influxis.as3.utils.ScreenScaler;
	
	public class StyleComponent extends SimpleComponent
	{
		public static var SKINS_PATH:String = "skins.xml";
		
		private var _sSkinName:String;
		private var _bEnabled:Boolean = true;
		private var _skinsManager:SkinsManager = SkinsManager.getInstance();
		private var _labels:LabelLoader = LabelLoader.getInstance();
		
		/**
		 * INIT API
		 */
		
		override protected function preInitialize():void 
		{
			//_skinsManager = SkinsManager.getInstance();
			//_labels = LabelLoader.getInstance();
			
			__loadAssets();
		}
		
		override protected function onInitialize():void 
		{
			super.onInitialize();
			__updateStyleGraphics();
		}
		
		private function __loadAssets(): void
		{
			//If skin and label xml has not been loaded then let's go ahead and load it in
			if ( !_skinsManager.initialized || !_labels.loaded )
			{
				if ( !_skinsManager.initialized && !_skinsManager.loadingXMLSkin ) _skinsManager.loadSkinSettings( SKINS_PATH );
				doTimedLater( 30, __loadAssets );
			}else {
				__registerSubSkin( _sSkinName != null ? _sSkinName : className );
				init();
			}
		}
		
		/**
		 * STYLES API
		 */
		
		public function getStyle( styleName:String, styleItem:String = null ): *
		{
			if ( !_skinsManager.initialized ) return;
			
			var value:*;
			if( _skinsManager.exists(skinName) ) value = _skinsManager.getSkinElement(skinName).getStyle(styleName, styleItem);
			if( value == undefined && skinName != className && _skinsManager.exists(className) ) value = _skinsManager.getSkinElement(className).getStyle(styleName, styleItem);
			return value;
		}
		
		public function setStyle( styleName:String, skin:*, styleItem:String = null ): void
		{
			_skinsManager.getSkinElement(skinName).setStyle(styleName, skin, styleItem);
		}
		
		public function styleExists( styleName:String, styleItem:String = null ): Boolean
		{
			return (getStyle(styleName, styleItem) != undefined);
		}
		
		public function embeddedFontExists( fontName:String ): Boolean
		{
			return _skinsManager.embeddedFontExists(fontName);
		}
		
		protected function getGraphic( styleName:String ): InteractiveObject
		{
			var grClip:InteractiveObject = _skinsManager.getSkinElement(skinName).getGraphics(styleName);
			if( !grClip && skinName != className ) _skinsManager.getSkinElement(className).getGraphics(styleName);
			return grClip;
		}
		
		protected function getStyleGraphic( styleName:String ): InteractiveObject
		{
			return _skinsManager.getSkinElement(skinName).getStyleGraphic(styleName, className);
		}
		
		protected function getTextFormat( styleName:String ): TextFormat
		{
			var tx:TextFormat = _skinsManager.exists(skinName) ? _skinsManager.getSkinElement(skinName).getTextFormat(styleName) : null;
			if ( !tx && skinName != className && _skinsManager.exists(className) ) tx = _skinsManager.getSkinElement(className).getTextFormat(styleName);
			if ( !tx ) tx = new TextFormat();
			return tx;
		}
		
		protected function getStyleText( styleName:String ): TextField
		{
			return _skinsManager.getSkinElement(skinName).getStyleText(styleName, className);
		}
		
		protected function onStyleChanged( style:String = null, styleItem:String = null ): void
		{
			
		}
		
		private function __onSkinStyleChanged( p_e:SimpleEvent ): void
		{
			if ( p_e.data )
			{
				onStyleChanged( p_e.data.styleName, p_e.data.styleItem );
			}else{
				onStyleChanged();
			}
		}
		
		private function __registerSubSkin( skinName:String ): void
		{
			if ( skinName == _sSkinName ) return;
			
			var skinElement:SkinElement;
			if ( _sSkinName )
			{
				skinElement = _skinsManager.getSkinElement(_sSkinName);
				if ( skinElement ) skinElement.removeEventListener( SimpleEvent.CHANGED, __onSkinStyleChanged );
				_sSkinName = null;
			}
			
			//trace( "__registerSubSkin: " + skinName, _sSkinName );
			if ( skinName )
			{
				_sSkinName = skinName;
				__checkSkinInstance();
				__updateStyleGraphics();
				skinElement = _skinsManager.getSkinElement(_sSkinName);
				if ( skinElement ) skinElement.addEventListener( SimpleEvent.CHANGED, __onSkinStyleChanged );
			}
		}
		
		private function __checkSkinInstance(): void
		{
			var sSkin:String = skinName != null ? skinName : className;
			if( !_skinsManager.exists(sSkin) ) _skinsManager.setSkinElement( sSkin, SkinElement.getInstance(sSkin), true );
		}
		
		private function __updateStyleGraphics(): void
		{
			if ( !initialized ) return;
			
			var nLen:int = numChildren;
			for ( var i:int = 0; i < nLen; i++ )
			{
				var child:StyleGraphic = getChildAt(i) as StyleGraphic;
				if ( child ) child.changeSkinElement( _skinsManager.getSkinElement(_sSkinName) );
			}
		}
		
		/**
		 * LABELS API
		 */
		
		protected function getLabelAt( id:String ): String
		{
			if ( !id || !_labels ) return null;
			return _labels.getLabelAt(id);
		}
		 
		/**
		 * PROTECTED API
		 */
		
		protected function setEnabled( enabled:Boolean ): void
		{
			_bEnabled = enabled;
		}
		
		/**
		 * DISPLAY API
		 */
		
		override protected function measure():void 
		{
			super.measure();
			measurePadding();
		}
		 
		protected function measurePadding(): void
		{
			//General padding for when others are missing
			var padding:int = styleExists("padding") ? ScreenScaler.calculateSize(getStyle("padding") as int) : 0;
			
			//Set padding
			paddingLeft = styleExists("paddingLeft") ? ScreenScaler.calculateSize(getStyle("paddingLeft") as int) : padding;
			paddingTop = styleExists("paddingTop") ? ScreenScaler.calculateSize(getStyle("paddingTop") as int) : padding;
			paddingBottom = styleExists("paddingBottom") ? ScreenScaler.calculateSize(getStyle("paddingBottom") as int) : padding;
			paddingRight = styleExists("paddingRight") ? ScreenScaler.calculateSize(getStyle("paddingRight") as int) : padding;
			innerPadding = styleExists("innerPadding") ? ScreenScaler.calculateSize(getStyle("innerPadding") as int) : padding;
			outerPadding = styleExists("outerPadding") ? ScreenScaler.calculateSize(getStyle("outerPadding") as int) : padding;
		}
		 
		/**
		 * GETTER / SETTER
		 */
		
		public function set enabled( enabled:Boolean ): void
		{
			setEnabled(enabled);
		}
		
		public function get enabled(): Boolean
		{
			return _bEnabled;
		}
		
		public function set skinName( skinName:String ): void
		{
			if ( _sSkinName == skinName ) return;
			__registerSubSkin( skinName == null ? className : skinName );
		}
		
		public function get skinName(): String
		{
			return _sSkinName;
		}
	}
}