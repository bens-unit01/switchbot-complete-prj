/**
 * CallModel - Copyright © 2010 Influxis All rights reserved.
**/

package org.influxis.as3.net
{
	//Flash Classes
	import flash.net.NetConnection;
	import flash.utils.Dictionary;
	import flash.events.Event;
	
	//Influxis Classes
	import org.influxis.as3.data.Singleton;
	import org.influxis.as3.net.callmodelclasses.AS3ConversionHandler;
	import org.influxis.as3.utils.delegate;
	
	public class CallModel
	{
		public static var symbolName:String = "CallModel";
		public static var symbolOwner:Object = org.influxis.as3.net.CallModel;
		private var infxClassName:String = "CallModel";
		private var _sVersion:String = "2.0.0.0";
		
		public static var DEBUG:Boolean = false;
		private static var __st:Singleton = new Singleton();
		
		private var _nc:NetConnection;
		private var _sPrefix:String;
		private var _sPath:String;
		private var _as3Converter:AS3ConversionHandler;
		
		private var _clsh:ClientSideCallHandler = ClientSideCallHandler.getInstance();
		private var _aDelayedCalls:Array = new Array();
		private var _oConnectionHost:Object = new Object();
		private var _dtRemoteListeners:Dictionary = new Dictionary();
		
		/**
		 * INIT API
		 */
		
		public function CallModel( p_sPath:String, p_nc:NetConnection ): void
		{
			if( p_sPath && p_nc )
			{
				if( p_nc.connected )
				{
					_nc = p_nc;
					
					_sPrefix = p_sPath + ".";
					_sPath = p_sPath;
					_clsh.addPath( _sPath, _oConnectionHost );
					
					_as3Converter = AS3ConversionHandler.getInstance( _nc, _sPrefix );
					_as3Converter.addEventListener( AS3ConversionHandler.COMPLETE, __as3ConversionConfirmed );
				}
			}
		}
		
		/**
		 * VERSION
		**/
		
		public function toString(): String
		{
			return ("[ "+ infxClassName + " " + _sVersion +" ]")
		}
		
		public function get version(): String
		{
			return _sVersion;
		}
		
		/**
		 * SINGLETON API
		**/
		
		public static function getInstance( p_sPath:String = "_DEFAULT_", p_nc:NetConnection = null ) : CallModel
		{
			if ( !p_sPath || !p_nc ) return null;
			
			var cll:CallModel = __st.getInstance( p_sPath ) as CallModel;
			if ( !cll ) 
			{
				cll = new CallModel( p_sPath, p_nc );
				__st.addInstance( p_sPath, cll );
			}
			return cll;
		}
		
		//Destroys given instance
		public static function destroy( p_sName:String = "_DEFAULT_" ): Boolean
		{
			if( __st.getInstance(p_sName) == undefined ) return false;
			
			(__st.getInstance( p_sName ) as CallModel).close();
			__st.destroy( p_sName );
			return true;
		}
		
		/**
		 * PUBLIC API
		**/
		
		public function close(): void
		{
			_clsh.removePath( _sPath );
			_oConnectionHost = null;
			_dtRemoteListeners = new Dictionary();
			
			_sPath = null
			_sPrefix = null;
			_nc = null;
		}
		
		public function addRemoteMethod( p_sMethodName:String, p_fCall:Function ): void
		{
			if ( !p_sMethodName ) return;
			
			_dtRemoteListeners[ p_fCall as Object ] = p_sMethodName;
			_oConnectionHost[ p_sMethodName ] = delegate( this, __handleServerCall, {serverMethod:p_sMethodName} );
		}
		
		public function removeRemoteMethod( p_fCall:Function ): void
		{
			if ( p_fCall == null ) return;
			delete _dtRemoteListeners[ p_fCall as Object ];
		}
		
		public function call( p_sMethodName:String, ...p_aArgs ): void
		{
			if( _as3Converter )
			{
				if( !_as3Converter.as3Converted )
				{
					var aCallArgs:Array = p_aArgs as Array;
						aCallArgs.unshift( p_sMethodName );
					
					_aDelayedCalls.push( aCallArgs );
					return;
				}
			}
			
			var aArgs:Array = p_aArgs as Array;
			var aCallArray:Array = new Array( (_sPrefix+p_sMethodName) ).concat( aArgs );
			
			try
			{
				_nc.call.apply( _nc, aCallArray );
			}catch( e:Error )
			{
				tracer( "Error: " + e );
			}
		}
		
		/**
		 * PRIVATE API
		**/
		
		private function __as3ConversionConfirmed( p_e:Event ): void
		{
			if( _aDelayedCalls.length > 0 )
			{
				for each( var aArgs:Array in _aDelayedCalls )
				{
					this.call.apply( this, aArgs )
				}
			}
			_aDelayedCalls = new Array();
		}
		
		private function __handleServerCall( ...p_aArgs ): void
		{
			var aArgs:Array = p_aArgs as Array;
			var sMethod:String = aArgs.pop().serverMethod;
			tracer( "__handleServerCall3: " + sMethod );
			for ( var f:Object in _dtRemoteListeners )
			{
				if ( _dtRemoteListeners[f] == sMethod ) (f as Function).apply( null, aArgs );
			}
		}
		
		/**
		 * GETTER / SETTER
		**/
		
		public function get path(): String
		{
			return _sPath;
		}
		
		/**
		 * DEBUGGER
		**/
		
		public function tracer( p_msg:* ) : void
		{
			if( DEBUG ) trace("#" + infxClassName + "#  " + p_msg );
		};
		
	}
}