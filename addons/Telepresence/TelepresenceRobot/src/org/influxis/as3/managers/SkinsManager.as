/**
 * SkinsManager - Copyright © 2010 Influxis All rights reserved.
**/

package org.influxis.as3.managers 
{
	//Flash Classes
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.text.Font;
	import flash.errors.IllegalOperationError;
	import flash.utils.getDefinitionByName;
	import __AS3__.vec.Vector;
	
	//Influxis Classes
	import org.influxis.as3.skins.SkinElement;
	import org.influxis.as3.events.SimpleEvent;
	import org.influxis.as3.events.SimpleEventConst
	import org.influxis.as3.data.ImageLibrary;
	import org.influxis.as3.utils.ImageUtils;
	
	[Event( name = "changed", type = "org.influxis.as3.events.SimpleEvent" )]
	[Event( name = "removed", type = "org.influxis.as3.events.SimpleEvent" )]
	
	public class SkinsManager extends EventDispatcher
	{	
		public static const ASSET_XML:String = "localAssetXML";
		
		private static var __skm:SkinsManager;
		private static var __skins:Object = new Object();
		
		private var _images:ImageLibrary = ImageLibrary.getInstance();
		private var _urllXMLLoader:URLLoader;
		private var _loadedSkins:XML;
		
		private var _sLoadPath:String;
		private var _bLocalChecked:Boolean;
		private var _bInitialized:Boolean;
		private var _bLoading:Boolean;
		private var _bLoaded:Boolean;
		private var _oLoadedFonts:Object = new Object();
		
		/**
		 * INIT API
		 */
		
		public function SkinsManager(): void
		{
			_images.addEventListener( Event.COMPLETE, __onImageLoaded );
		}
		 
		/**
		 * SINGLETON API
		**/
		
		//Returns singleton instance
		public static function getInstance() : SkinsManager
		{
			if( __skm == null ) __skm = new SkinsManager();
			return __skm;
		}
		
		/**
		 * PUBLIC API
		 */
		
		public function loadSkinSettings( path:String ): void
		{
			if ( !path || _sLoadPath == path || _bLoaded ) return;
			
			if ( path == ASSET_XML )
			{
				try {
					_sLoadPath = path;
					_bLoading = true;
					__onSettingsLoaded(new SimpleEvent("localXMLComplete", null, (getDefinitionByName("assets.Skins") as Class).SKIN_XML));
					return;
				}catch ( e:Error )
				{
					//Either class does not exist or property
				}
			}else if ( !_urllXMLLoader )
			{
				_urllXMLLoader = new URLLoader();
				_urllXMLLoader.addEventListener( Event.COMPLETE, __onSettingsLoaded );
				_urllXMLLoader.addEventListener( IOErrorEvent.IO_ERROR, __onSettingsLoaded );
				_urllXMLLoader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, __onSettingsLoaded );
			}
			
			_sLoadPath = path;
			_bLoading = true;
			
			if( _urllXMLLoader ) _urllXMLLoader.load( new URLRequest(_sLoadPath) );
		}
		
		public function setSkinElement( skinElementName:String, skinElement:SkinElement, omitChangeEvent:Boolean = false ): void
		{
			if ( !skinElementName || !skinElement ) return;
			__skins[skinElementName] = skinElement;
			if( !omitChangeEvent ) dispatchEvent( new SimpleEvent(SimpleEvent.CHANGED, null, skinElementName) );
		}
		 
		public function getSkinElement( skinElementName:String ): SkinElement
		{
			if ( !skinElementName ) return null;
			return (__skins[skinElementName] as SkinElement);
		}
		
		public function destroyAllSkins(): void
		{
			for each( var i:String in __skins )
			{
				destroySkinElement(i);
			}
		}
		
		public function destroySkinElement( skinElementName:String ): void
		{
			if ( !skinElementName || __skins[skinElementName] == undefined ) return;
			
			__skins[skinElementName].clear();
			__skins[skinElementName] = null;
			
			delete __skins[skinElementName];
			dispatchEvent( new SimpleEvent(SimpleEvent.REMOVED, null, skinElementName) );
		}
		
		public function exists( skinElementName:String ): Boolean
		{
			if ( !skinElementName ) return false;
			return (__skins[skinElementName] != undefined)
		}
		
		public function embeddedFontExists( fontName:String ): Boolean
		{	
			if ( !_oLoadedFonts ) return false;
			return (_oLoadedFonts[fontName] != undefined);
		}
		
		public function loadEmbeddedFont( fontName:String, path:String ): void
		{
			if ( !path ) return;
			
			//Since we can only load fonts from a symbol internally or in a loaded swf if not correct path then throw error
			if ( path.indexOf( ".swf:" ) == -1 && path.indexOf( "embed:" ) == -1 )
			{
				throw new IllegalOperationError("Font path must come from a symbol within a loaded swf. ex: fontFile.swf:ArialCustom");
				return;
			}
			
			if ( _images.loaded(path) )
			{
				__registerFont( _images.getImageClass(path), path );
			}else {	
				_oLoadedFonts[fontName] = {path:path, loaded:false};
				_images.loadImage(path);
			}
		}
		
		/**
		 * HANDLERS
		 */
		 
		private function __onSettingsLoaded( p_e:Event ): void
		{
			//trace( "__onSettingsLoaded: " + p_e.type );
			if ( p_e.type == Event.COMPLETE || p_e.type == "localXMLComplete" )
			{
				_bLocalChecked = false;
				_bLoaded = true;
				_bLoading = false;
				
				//Form main xml data
				_loadedSkins = p_e.type == Event.COMPLETE ? new XML( p_e.target.data ) : SimpleEvent(p_e).data as XML;
				
				//Feed data
				var skins:XMLList = _loadedSkins.skin;
				for each( var skin:XML in skins )
				{
					__loadSkinAsset( skin.@instanceID, skin );
					//__skins[skin.@instanceID] = SkinElement.getInstance(skin.@instanceID, skin);
				}
				__parseXMLFonts( _loadedSkins );
			}else if ( p_e.type == IOErrorEvent.IO_ERROR || p_e.type == SecurityErrorEvent.SECURITY_ERROR )
			{
				if ( _bLocalChecked )
				{
					_bLocalChecked = false;
					_bLoading = false;
				}else{
					_bLocalChecked = true;
					loadSkinSettings(ImageUtils.checkImageLocalPath(_sLoadPath));
					return;
				}
			}
			
			if ( !_images.pendingImages ) 
			{
				_bInitialized = true;
				dispatchEvent(new SimpleEvent(Event.COMPLETE));
			}
		}
		
		private function __loadSkinAsset( skinID:String, skinData:Object ): void
		{
			if ( !skinID || !skinData ) return;
			
			var aIds:Array = skinID.split(",");
			for each( var i:String in aIds )
			{
				__skins[i] = SkinElement.getInstance(i, skinData);
			}
		}
		
		private function __onImageLoaded( p_e:Event ): void
		{
			//Checks any loaded fonts that were loaded in
			__checkPendingFonts();
			if ( !_images.pendingImages ) 
			{
				_bInitialized = true;
				dispatchEvent(new SimpleEvent(Event.COMPLETE));
			}
		}
		
		/**
		 * PRIVATE API
		 */
		
		private function __checkPendingFonts(): void
		{
			if ( !_oLoadedFonts ) return;
			
			var cFont:Class; var sFontName:String; var sFontPath:String
			for( var i:String in _oLoadedFonts )
			{
				sFontPath = _oLoadedFonts[i].path;
				//trace( "__checkPendingFonts: " + _aPendingFonts[i], i, _oLoadedFonts[i].path );
				if ( _images.loaded(sFontPath) && _oLoadedFonts[i].loaded != true )
				{
					cFont = _images.getImageClass(sFontPath);
					if ( cFont )
					{
						delete _oLoadedFonts[i];
						__registerFont( cFont, sFontPath );
					}
				}
			}
		}
		 
		private function __parseXMLFonts( skin:XML ): void
		{
			var sStyle:String;
			for each( var o:XML in skin.font )
			{
				loadEmbeddedFont( o.@fontName, o.toString() );
			}
		}
		
		private function __registerFont( font:Class, path:String ): void
		{
			if ( font )
			{
				Font.registerFont(font);
				_oLoadedFonts[(new font() as Font).fontName] = {path:path, loaded:true};
			}
		}
		
		/**
		 * GETTER / SETTER
		 */
		
		public function get loadedXMLSkin(): Boolean
		{
			return _bLoaded;
		}
		 
		public function get loadingXMLSkin(): Boolean
		{
			return _bLoading;
		}
		 
		public function get initialized(): Boolean
		{
			return _bInitialized;
		}
	}
}