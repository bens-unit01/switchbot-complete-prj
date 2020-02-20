/**
 * AS3ConversionHandler - Copyright © 2009 Influxis All rights reserved.
**/

package org.influxis.as3.net.callmodelclasses
{
	//Flash Classes
	import flash.events.NetStatusEvent;
	import flash.events.Event;
	import flash.net.NetConnection;
	import flash.events.EventDispatcher;
	import flash.net.Responder;
	
	//Influxis Classes
	import org.influxis.as3.utils.doTimedLater;
	
	public class AS3ConversionHandler extends EventDispatcher
	{
		public static var symbolName:String = "AS3ConversionHandler";
		public static var symbolOwner:Object = org.influxis.as3.net.callmodelclasses.AS3ConversionHandler;
		private var infxClassName:String = "AS3ConversionHandler";
		private var _sVersion:String = "1.0.0.0";
		
		public static var DEBUG:Boolean = false;
		
		private static var __as3:AS3ConversionHandler;
		private static const _CONVERT_METHOD_:String = "isAS3Client";
		public static const COMPLETE:String = "complete";
		
		private var _nc:NetConnection;
		private var _sPrefix:String;
		private var _bAS3Converted:Boolean;
		private var _bAS3ConvertedWait:Boolean;
		
		public function AS3ConversionHandler( p_nc:NetConnection, p_sPrefix:String )
		{
			//trace( "AS3ConversionHandler: " + _bAS3Converted + " : " + _bAS3ConvertedWait + " : " + p_sPrefix );
			if( !p_nc || !p_sPrefix || _bAS3Converted || _bAS3ConvertedWait ) return;
			
			_bAS3ConvertedWait = true;
			_sPrefix = p_sPrefix;
			
			//reference net connect and add listener for when connection is closed
			_nc = p_nc;
			_nc.addEventListener( NetStatusEvent.NET_STATUS, __onConnect );
			__callAS3Conversion();
		}
		
		/**
		 * SINGLETON API
		**/
		
		public static function getInstance( p_nc:NetConnection, p_sPrefix:String ): AS3ConversionHandler
		{
			__as3 = __as3 == null ? new AS3ConversionHandler( p_nc, p_sPrefix ) : __as3;
			return __as3;
		}
		
		//Destroys given instance
		public static function destroy(): Boolean
		{
			var bDestroyed:Boolean;
			if( __as3 != null )
			{
				bDestroyed = true;
				__as3 = null;
			}
			return bDestroyed;
		}
		
		/**
		 * PRIVATE API
		**/
		
		private function __callAS3Conversion(): void
		{
			_nc.call( _sPrefix+_CONVERT_METHOD_, new Responder(__as3ConversionConfirmed) );
		}
		
		private function __as3ConversionConfirmed( p_bDone:Boolean = true ): void
		{
			//trace( "as3ConversionConfirmed(): " );
			
			_bAS3Converted = true;
			_bAS3ConvertedWait = false;
			
			dispatchEvent( new Event(COMPLETE) );
		}
		
		/**
		 * HANDLERS
		**/
		
		private function __onConnect( p_nse:NetStatusEvent ): void
		{
			if( p_nse.info.code == "NetConnection.Connect.Closed" )
			{
				destroy();
			}
		}
		
		/**
		 * GETTER / SETTER
		**/
		
		public function get as3Converted(): Boolean
		{
			return _bAS3Converted;
		}
		
		/**
		 * DEBUGGER
		**/
		
		public function tracer( p_msg:* ) : void
		{
			if( DEBUG ) trace("#" + infxClassName + "#  " + p_msg );
		}
	}
}