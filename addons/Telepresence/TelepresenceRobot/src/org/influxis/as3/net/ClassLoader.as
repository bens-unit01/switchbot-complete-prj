/**
 * ClassLoader - Copyright © 2010 Influxis All rights reserved.
**/

package org.influxis.as3.net
{
	//Flash Classes
	import flash.display.Loader;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	
	import org.influxis.as3.utils.doTimedLater;
	
	//Events
	[Event(name="classLoaded", type="flash.events.Event")]
	[Event(name="loadError", type="flash.events.Event")]
	
	public class ClassLoader extends EventDispatcher
	{
		public static var symbolName:String = "ClassLoader";
		public static var symbolOwner:Object = org.influxis.as3.net.ClassLoader;
		private var infxClassName:String = "ClassLoader";
		private var _sVersion:String = "1.0.0.0";
		
		public static var CLASS_LOADED:String = "classLoaded";
		public static var LOAD_ERROR:String = "loadError";
		
		private var _loader:Loader;
		private var _swfLib:String;
		private var _testSymbol:String;
		private var _request:URLRequest;
		private var _loadedClass:Class;

		/**
		 * INIT API
		 */
		
		public function ClassLoader() 
		{
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener( Event.COMPLETE, __completeHandler );
			_loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, __ioErrorHandler );
			_loader.contentLoaderInfo.addEventListener( SecurityErrorEvent.SECURITY_ERROR, __securityErrorHandler );
		}
		
		/**
		 * PUBLIC API
		 */
		
		public function unload(): void
		{
			if ( !_loader ) return;
			_loader.unload();
		}
		 
		public function load( lib:String, testSymbol:String = null ): void 
		{
			_swfLib = lib;
			_testSymbol = testSymbol;
			_request = new URLRequest( _swfLib );
			
			var context:LoaderContext = new LoaderContext();
				context.applicationDomain = ApplicationDomain.currentDomain;
			
			_loader.load( _request, context );
		}

		public function getClass( className:String ): Class 
		{
			if ( !_loader.contentLoaderInfo.applicationDomain.hasDefinition(className) ) return null;
			try {
				return _loader.contentLoaderInfo.applicationDomain.getDefinition(className) as Class;
			} catch (e:Error) {
				throw new IllegalOperationError(className + " definition not found in " + _swfLib);
			}
			return null;
		}
		
		/**
		 * PRIVATE API
		 */
		
		private function __completeHandler(p_e:Event): void 
		{
			if ( _testSymbol && !getClass(_testSymbol) )
			{
				doTimedLater( 50, __completeHandler, p_e );
				return;
			}else{
				_testSymbol = null;
				dispatchEvent(new Event(ClassLoader.CLASS_LOADED));
			}
		}

		private function __ioErrorHandler(p_e:Event): void 
		{
			dispatchEvent(new Event(ClassLoader.LOAD_ERROR));
		}

		private function __securityErrorHandler(p_e:Event): void 
		{
			dispatchEvent(new Event(ClassLoader.LOAD_ERROR));
		}
	}
}