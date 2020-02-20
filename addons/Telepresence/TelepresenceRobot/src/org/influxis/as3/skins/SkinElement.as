/**
 * SkinElement - Copyright © 2010 Influxis All rights reserved.
**/

package org.influxis.as3.skins 
{
	//Flash Classes
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.text.TextFormat;
	import flash.text.TextField;
	import flash.text.StyleSheet;
	
	//Influxis Classes
	import org.influxis.as3.data.Singleton;
	import org.influxis.as3.data.ImageLibrary;
	import org.influxis.as3.events.SimpleEvent;
	import org.influxis.as3.utils.ColorUtils;
	import org.influxis.as3.skins.GraphicSkin;
	import org.influxis.as3.skins.StyleGraphic;
	import org.influxis.as3.skins.StyleText;
	import org.influxis.as3.utils.ScreenScaler;
	
	[Event(name = "changed", type = "org.influxis.as3.events.SimpleEvent")]
	[Event(name = "imageLoaded", type = "org.influxis.as3.events.SimpleEvent")]
	
	public class SkinElement extends EventDispatcher
	{
		public static var symbolName:String = "SkinElement";
		public static var symbolOwner:Object = org.influxis.as3.skins.SkinElement;
		private var infxClassName:String = "SkinElement";
		private var _sVersion:String = "1.0.0.0";
		
		private static var __st:Singleton = new Singleton();
		public static const IMAGE_LOADED:String = "imageLoaded";
		
		private var _FORMAT_SEARCH_:Array = 
		[
			"align",
			"blockIndent",
			"bold",
			"bullet",
			"color",
			"font",
			"indent",
			"italic",
			"kerning",
			"leading",
			"leftMargin",
			"letterSpacing",
			"rightMargin",
			"size",
			"underline",
			"url"
		];
		
		private var _sSkinName:String;
		private var _oSkin:Object;
		private var _images:ImageLibrary = ImageLibrary.getInstance();
		private var _isImage:RegExp = /(\.swf|\.jpg|\.png|\.gif)/i;
		
		/**
		 * INIT API
		 */
		
		public function SkinElement( skinName:String, skinContents:Object = null ) : void
		{
			_images.addEventListener( Event.COMPLETE, __onImageLoaded );
			
			_sSkinName = skinName;
			_oSkin = skinContents is XML ? __parseXMLStyles(skinContents as XML) : __parseStyles(skinContents);
			dispatchEvent( new SimpleEvent(SimpleEvent.CHANGED) );
		}
		
		/**
		 * SINGLETON API
		**/
		
		public static function getInstance( skinName:String, skinContents:Object = null ) : SkinElement
		{
			if ( !skinName ) return null;
			
			var ske:SkinElement = __st.getInstance( skinName ) as SkinElement;
			if ( !ske )
			{
				ske = new SkinElement( skinName, skinContents );
				__st.addInstance( skinName, ske );
			}
			return ske;
		}
		
		//Destroys given instance
		public static function destroy( skinName:String ): Boolean
		{
			if( !__st.getInstance(skinName) ) return false;
			
			__st.destroy( skinName );
			return true;
		}
		
		/**
		 * PUBLIC API
		 */
		
		public function setStyle( styleName:String, style:*, styleItem:String = null ): void
		{
			var value:*;
			if ( style is String )
			{
				if ( _isImage.test(style as String) )
				{
					value = _images.getImage( style as String );
					_images.loadImage( value );
				}else{
					value = style;
				}
			}else{
				value = style;
			}
			
			if ( styleItem )
			{
				if( !(_oSkin[styleName] is Object) ) _oSkin[styleName] = new Object();
				_oSkin[styleName][styleItem] = value;
			}else {
				_oSkin[styleName] = value;
			}
			dispatchEvent( new SimpleEvent(SimpleEvent.CHANGED, null, {styleName:styleName, styleItem:styleItem}) );
		}
		
		public function getStyle( styleName:String, styleItem:String = null ): *
		{
			var value:*;
			if ( !styleItem ) 
			{
				value = _oSkin[styleName];
			}else{
				try 
				{
					value = _oSkin[styleName][styleItem];
				}catch( e:Error )
				{
					//No styles target so ignore
				}
			}
			return value;
		}
		
		public function getGraphics( styleName:String ): InteractiveObject
		{
			if ( !styleName ) return null;
			
			var grClip:InteractiveObject;
			var sStyle:* = getStyle(styleName);
			if( sStyle != undefined )
			{
				if ( sStyle is String )
				{
					grClip = _images.getImage( sStyle as String );
				}else if ( getStyle(styleName, "image") != undefined || getStyle(styleName, "mask") != undefined ) 
				{
					grClip = styleName.indexOf(":") != -1 ? new GraphicImageSkin(getStyle(styleName),getStyle(styleName.split(":")[0])) : new GraphicImageSkin(getStyle(styleName));
				}else{
					grClip = styleName.indexOf(":") != -1 ? new GraphicSkin(getStyle(styleName),getStyle(styleName.split(":")[0])) : new GraphicSkin(getStyle(styleName));
				}
			}
			return grClip;
		}
		
		public function getStyleGraphic( styleName:String, originClass:String = null ): InteractiveObject
		{
			if ( !styleName ) return null;
			return new StyleGraphic(this, styleName, originClass);
		}
		
		public function getStyleText( styleName:String, originClass:String = null ): TextField
		{
			if ( !styleName ) return null;
			return new StyleText(this, styleName, originClass);
		}
		
		/*public function getTextFormat( styleName:String ) : TextFormat
		{
			if ( !styleName || _oSkin[styleName] == undefined ) return null;
			
			var tFormat:TextFormat = new TextFormat();
			if ( _oSkin[styleName] is String )
			{
				var sTextStyle:String = _oSkin[styleName] as String;
				if ( _images.loaded(sTextStyle) )
				{
					var spClass:Sprite = _images.getImage( sTextStyle ) as Sprite;
					var child:TextField;
					for ( var n:int = 0; n < spClass.numChildren; n++ )
					{
						child = spClass.getChildAt(n) as TextField;
						if ( child )
						{
							tFormat = child.defaultTextFormat;
							tFormat.bold = new RegExp( "<b>", "gi" ).test(child.htmlText);
							tFormat.italic = new RegExp( "<i>", "gi" ).test(child.htmlText);
							
							break;
						}
					}
				}
			}else if ( _oSkin[styleName] is Object )
			{
				var oFormat:Object = _oSkin[styleName];
				for each( var i:String in _FORMAT_SEARCH_ )
				{
					if ( oFormat[i] == undefined ) continue;
					tFormat[i] = oFormat[i];
				}
			}
			
			//For mobile devices scale text to match screen size
			return ScreenScaler.scaleTextFormat(tFormat);
		}*/
		
		protected function getTextFromStyleAt( styleName:String ): TextField
		{
			if ( !styleName || _oSkin[styleName] == undefined ) return null;
			
			var textField:TextField;
			if ( _oSkin[styleName] is String )
			{
				var sTextStyle:String = _oSkin[styleName] as String;
				if ( _images.loaded(sTextStyle) )
				{
					var spClass:Sprite = _images.getImage( sTextStyle ) as Sprite;
					for ( var n:int = 0; n < spClass.numChildren; n++ )
					{
						textField = spClass.getChildAt(n) as TextField;
						if ( textField ) 
						{
							textField.defaultTextFormat.bold = new RegExp( "<b>", "gi" ).test(textField.htmlText);
							textField.defaultTextFormat.italic = new RegExp( "<i>", "gi" ).test(textField.htmlText);
						}
					}
				}
			}
			//For mobile devices scale text to match screen size
			return textField;
		}
		
		public function getTextFormat( styleName:String, targetTextField:TextField = null ) : TextFormat
		{
			var textField:TextField = getTextFromStyleAt(styleName);
			if ( textField == null && _oSkin[styleName] is Object )
			{
				textField = new TextField();
				var tFormat:TextFormat = new TextFormat();
				var oFormat:Object = _oSkin[styleName];
				for each( var i:String in _FORMAT_SEARCH_ )
				{
					if ( oFormat[i] == undefined ) continue;
					tFormat[i] = oFormat[i];
				}
				textField.defaultTextFormat = tFormat;
			}
			return textField != null ? ScreenScaler.scaleTextFormat(textField.defaultTextFormat) : null;
		}
		
		public function applyTextProps( styleName:String, textField:TextField ): void
		{
			if ( !styleName || !textField ) return;
			
			var skinTextField:TextField = getTextFromStyleAt(styleName);
			if ( skinTextField == null && _oSkin[styleName] is Object )
			{
				skinTextField = new TextField();
				var oFormat:Object = _oSkin[styleName];
				for each( var i:String in _FORMAT_SEARCH_ )
				{
					if ( oFormat[i] == undefined ) continue;
					skinTextField.defaultTextFormat[i] = oFormat[i];
				}
			}
			
			if ( skinTextField )
			{
				textField.defaultTextFormat = skinTextField.defaultTextFormat;
				textField.antiAliasType = skinTextField.antiAliasType;
				textField.sharpness = skinTextField.sharpness;
				textField.thickness = skinTextField.thickness;
				textField.selectable = skinTextField.selectable;
			}
		}
		
		/**
		 * PRIVATE API
		 */
		 
		private function __parseStyles( styles:Object ): Object
		{
			var oSkins:Object = new Object();
			for( var i:String in styles )
			{
				if ( styles[i] is String )
				{
					if ( _isImage.test(styles[i] as String) )
					{
						oSkins[i] = _images.getImage( styles[i] as String );
						_images.loadImage( oSkins[i] );
					}else{
						oSkins[i] = styles[i];
					}
				}else{
					oSkins[i] = styles[i];
				}
			}
			return oSkins;
		}
		
		private function __parseXMLStyles( skin:XML, p_bDoItems:Boolean = false ): Object
		{
			var oSkins:Object = new Object();
			var styles:Object = p_bDoItems ? skin.styleItem : skin.style;
			var sStyle:String;
			for each( var o:XML in styles )
			{
				//trace( "__parseXMLStyles: " + o, o.@styleName );
				if ( o.styleItem.length() > 0 )
				{
					oSkins[o.@styleName] = __parseXMLStyles(o, true);
				}else{
					sStyle = o.toString();
					if ( sStyle == "" && o.@styleName == "borderSides" )
					{
						oSkins[o.@styleName] = sStyle;
					}else if ( _isImage.test(sStyle) )
					{
						oSkins[o.@styleName] = sStyle;
						_images.loadImage( oSkins[o.@styleName] );
					}else if ( !isNaN(Number(sStyle)) && sStyle.indexOf("0x") == -1 )
					{
						oSkins[o.@styleName] = Number(sStyle);
					}else if ( ColorUtils.isValidColors(sStyle) )
					{
						oSkins[o.@styleName] = ColorUtils.getColors(sStyle);
					}else if ( sStyle == "true" || sStyle == "false" )
					{
						oSkins[o.@styleName] = (sStyle == "true");
					}else{
						oSkins[o.@styleName] = sStyle;
					}
				}
			}
			return oSkins;
		}
		
		/**
		 * HANDLERS
		 */
		
		private function __onImageLoaded( p_e:SimpleEvent ): void
		{
			//Check to see if fonts were loaded or included
			dispatchEvent( new SimpleEvent(IMAGE_LOADED, null, p_e.data) );
		}
		 
		/**
		 * GETTER / SETTER
		 */
		
		public function get skinName(): String
		{
			return _sSkinName;
		}
		
		public function get skin(): Object
		{
			return _oSkin;
		}
	}
}