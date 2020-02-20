package org.influxis.as3.net.loaderclasses 
{
	//Flash Classes
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.IOErrorEvent;
	import flash.events.ErrorEvent;
	import flash.events.SecurityErrorEvent;
	
	//Influxis Classes
	import org.influxis.as3.utils.ImageUtils;
	
	//Events
	[Event(name="complete", type="flash.events.Event")]
	[Event(name="error", type="flash.events.ErrorEvent")]
	[Event(name="ioError", type="flash.events.IOErrorEvent")]
	
	public class LoaderBase extends EventDispatcher
	{
		private var infxClassName:String = "LoaderBase";
		private var _sVersion:String = "1.0.0.0";
		
		private var _urllXMLLoader:URLLoader;
		private var _xmlSettings:XML;
		private var _bLoaded:Boolean;
		private var _bLoading:Boolean;
		private var _bLocalChecked:Boolean;
		private var _sLoadPath:String;
		
		/**
		* INIT METHODS
		**/
		
		public function LoaderBase( targetFile:String = null ): void
		{
			loadTargetFile(targetFile);
		}
		
		/**
		 * PUBLIC API
		**/
		
		public function load( p_sPath:String = null ): void
		{
			loadTargetFile(p_sPath);
		}
		
		/**
		 * PROTECTED API
		**/
		
		//Loads the settings xml file
		protected function loadTargetFile( p_sPath:String = null ): void
		{
			if ( !p_sPath ) return;
			
			_bLoading = true;
			_sLoadPath = p_sPath;
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
			_bLoading = false;
			
			//Try to check and see if any data was downloaded
			try
			{
				_xmlSettings = new XML( p_e.target.data );
			}catch( e:Error )
			{
				trace( e );
			}
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
				}else {
					
					_bLocalChecked = true;
					loadTargetFile(ImageUtils.checkImageLocalPath(_sLoadPath));
					return;
				}
				
				_bLoading = false;
				_bLoaded = true;
				parseSettings();
				dispatchEvent( new Event(Event.COMPLETE, false, false) );
			}
		}
		
		protected function loadManualXML( data:XML ): void
		{
			_xmlSettings = data;
			_bLoaded = true;
			parseSettings();
			dispatchEvent( new Event(Event.COMPLETE, false, false) );
		}
		
		protected function parseSettings(): void
		{
			
		}
		
		/**
		 * GETTER / SETTER
		**/
		
		public function get dataProvider(): XML
		{
			return _xmlSettings;
		}
		
		public function get loaded(): Boolean
		{
			return _bLoaded;
		}
		
		public function get loading(): Boolean
		{
			return _bLoading;
		}
	}
}