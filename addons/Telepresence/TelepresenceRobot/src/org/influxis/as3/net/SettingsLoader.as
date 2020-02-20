/**
 * SettingsLoader Copyright © 2010 Influxis All rights reserved.
**/

package org.influxis.as3.net
{
	//Flash Classes
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.display.LoaderInfo;
	import flash.display.Stage;
	import flash.net.URLRequest;
	import flash.events.IOErrorEvent;
	import flash.events.ErrorEvent;
	import flash.external.ExternalInterface;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	
	
	//Influxis Classes
	import org.influxis.as3.utils.HTTPUtil;
	import org.influxis.as3.core.Display;
	import org.influxis.as3.utils.ImageUtils;
	import org.influxis.as3.utils.ObjectUtils;
	import org.influxis.as3.codecs.Base64Decoder;
	
	//Events
	[Event(name="complete", type="flash.events.Event")]
	[Event(name="error", type="flash.events.ErrorEvent")]
	[Event(name="ioError", type="flash.events.IOErrorEvent")]
	
	public class SettingsLoader extends EventDispatcher
	{
		private var infxClassName:String = "SettingsLoader";
		private var _sVersion:String = "1.0.0.0";
		
		public static var DEBUG:Boolean = false;
		
		public static var SETTINGS_XML_PATH:String = "";
		public static var FILE_NAME:String = "settings.xml";
		
		private static var __stl:SettingsLoader;
		
		private var _urllXMLLoader:URLLoader;
		private var _xmlSettings:XML;
		private var _oParams:Object;
		private var _bLoaded:Boolean;
		private var _sRTMP:String;
		private var _sSkin:String;
		private var _bLocalChecked:Boolean;
		private var _sLoadPath:String;
		
		/**
		* INIT METHODS
		**/
		
		function SettingsLoader( p_sPath:String = null )
		{
			loadParameters();
			loadSettingsXML(p_sPath);
		}
		
		/**
		 * SINGLETON API
		**/
		
		//Returns singleton instance
		public static function getInstance( p_sPath:String = null ) : SettingsLoader
		{
			if( __stl == null ) __stl = new SettingsLoader(p_sPath);
			return __stl;
		}
		
		public static function destroy() : void
		{
			if ( __stl ) __stl = null;
		}
		
		/**
		 * PUBLIC API
		**/
		
		public function load( p_sPath:String = null ): void
		{
			loadSettingsXML(p_sPath);
		}
		
		public function getHtmlVarsAt( value:String ): Object
		{
			return HTTPUtil.getURLProperty(value);
		}
		
		/**
		 * PROTECTED API
		**/
		
		//Gets parameters passed in from container
		protected function loadParameters(): void
		{
			if ( !Display.ROOT ) return;
			try
			{
				_oParams = LoaderInfo(Display.ROOT.loaderInfo).parameters;
				_oParams = !_oParams ? new Object() : _oParams;
			}catch( e:Error )
			{
				//Display.APPLICATION.writeDebugger( "Parameters has no properties: " + e.message );
			}
		}
		
		//Loads the settings xml file
		protected function loadSettingsXML( p_sPath:String = null ): void
		{
			_sLoadPath = !p_sPath ? SETTINGS_XML_PATH+FILE_NAME : p_sPath;
			if ( _urllXMLLoader )
			{
				_urllXMLLoader.load( new URLRequest(_sLoadPath) );
			}else{
				try
				{
					_urllXMLLoader = new URLLoader();
					_urllXMLLoader.addEventListener( Event.COMPLETE, onLoadSettings );
					_urllXMLLoader.addEventListener( IOErrorEvent.IO_ERROR, onLoadError );
					_urllXMLLoader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onLoadError );
					_urllXMLLoader.load( new URLRequest(_sLoadPath) );
				}catch( e:Error )
				{
					dispatchEvent( new ErrorEvent( ErrorEvent.ERROR, false, false, e.toString()) );
				}
			}
		}
		
		//Receives loaded xml data
		protected function onLoadSettings( p_e:Event ): void
		{
			_bLoaded = true;
			
			//Try to check and see if any data was downloaded
			try
			{
				_xmlSettings = new XML( p_e.target.data );
			}catch( e:Error )
			{
				tracer( e );
				//dispatchEvent( new ErrorEvent( ErrorEvent.ERROR, false, false, e.toString()) );
			}
			
			//loadClassSettings();
			parseSettings();
			dispatchEvent( new Event(Event.COMPLETE, false, false) );
		}
		
		//Handles any IO errors thrown by the loader
		private function onLoadError( p_e:Event ): void
		{
			if ( p_e.type == IOErrorEvent.IO_ERROR || p_e.type == SecurityErrorEvent.SECURITY_ERROR )
			{
				if ( _bLocalChecked )
				{
					_bLocalChecked = false;
				}else{
					if ( _sLoadPath == (SETTINGS_XML_PATH+FILE_NAME) )
					{
						_bLocalChecked = true;
						loadSettingsXML(ImageUtils.checkImageLocalPath(_sLoadPath));
					}else{
						loadSettingsXML(SETTINGS_XML_PATH+FILE_NAME);
					}
					return;
				}
				
				_bLoaded = true;
				parseSettings();
				dispatchEvent( new Event(Event.COMPLETE, false, false) );
			}
			//dispatchEvent( p_e );
		}
		
		protected function parseSettings(): void
		{
			//Test to see if we have script access
			var bScriptAccess:Boolean = true;
			try
			{
				ExternalInterface.call("window.location.href.toString");
			}catch( e:Error )
			{
				bScriptAccess = false;
			}
			
			//Check settings xml
			if ( dataProvider )
			{
				_sRTMP = dataProvider.rtmp.@path;
				_sSkin = dataProvider.rtmp.@skin;
			}
			
			if ( parameters )
			{
				//Decode and copy pKey
				if ( HTTPUtil.getURLProperty("pKey") != null || parameters.pKey != undefined )
				{
					var pDecoder:Base64Decoder = new Base64Decoder();
						pDecoder.decode(decodeURI(parameters.pKey != undefined ? parameters.pKey : HTTPUtil.getURLProperty("pKey")));
					
					var decodeBuff:ByteArray = pDecoder.flush();
						decodeBuff.uncompress();
						
					var params:URLVariables = new URLVariables(decodeBuff.readUTFBytes(decodeBuff.length));
					ObjectUtils.applyObject( params, _oParams );
				}
				
				if ( parameters.RTMP != undefined ) _sRTMP = parameters.RTMP;
				if ( parameters.skin != undefined ) _sSkin = parameters.skin;
			}
			
			//Check url to see if any params are available
			if ( bScriptAccess )
			{
				var sRTMP:String = HTTPUtil.getURLProperty( "RTMP" );
				var sSkins:String = HTTPUtil.getURLProperty( "skin" );
				if ( sRTMP ) _sRTMP = sRTMP;
				if ( sSkins ) _sSkin = sSkins;
			}
		}
		
		/**
		 * GETTER / SETTER
		**/
		
		public function get dataProvider(): XML
		{
			return _xmlSettings;
		}
		
		public function get parameters(): Object
		{
			return _oParams;
		}
		
		public function get loaded(): Boolean
		{
			return _bLoaded;
		}
		
		public function get rtmp(): String 
		{
			return _sRTMP;
		}
		
		public function get skin(): String
		{
			return _sSkin;
		}
		
		/**
		* DEBUGGER
		**/
		
		protected function tracer( p_msg:* ) : void
		{
			if( DEBUG  ) trace("#" + infxClassName +"#  "+p_msg);
		}
	}
}
