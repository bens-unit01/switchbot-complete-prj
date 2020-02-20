/**
 * INFXConnection - Copyright © 2011 Influxis All rights reserved.
**/

package org.influxis.as3.net 
{
	//Flash Classes
	import flash.events.Event;
	import flash.net.NetConnection;
	import flash.events.NetStatusEvent;
	
	//Influxis Classes
	import org.influxis.as3.core.infx_internal;
	import org.influxis.as3.net.ClientSideCallHandler;
	import org.influxis.as3.states.ConnectStates;
	import org.influxis.as3.utils.doTimedLater;
	
	[Event(name = "initialized", type = "flash.events.Event")]
	[Event(name = "reconnecting", type = "flash.events.Event")]
	[Event(name = "reconnectFailed", type = "flash.events.Event")]
	
	public class INFXConnection extends NetConnection
	{
		//Setup namespace
		use namespace infx_internal;
		
		//Static props
		public static const INITIALIZED:String = "initialized";
		public static const RECONNECTING:String = "reconnecting";
		public static const RECONNECT_SUCCESS:String = "reconnectSuccess";
		public static const RECONNECT_FAILED:String = "reconnectFailed";
		public static const CONNECTED:String = "NetConnection.Connect.Success";
		public static const REJECTED:String = "NetConnection.Connect.Rejected";
		public static const FAILED:String = "NetConnection.Connect.Failed";
		public static const CLOSED:String = "NetConnection.Connect.Closed";
		public static const NETSTREAM_REJECTED:String = "NetStream.Connect.Rejected";
		public static const NETGROUP_REJECTED:String = "NetGroup.Connect.Rejected";
		
		//Handles all calls
		private var _callHandler:ClientSideCallHandler = ClientSideCallHandler.getInstance();
		
		private var _rtmp:String;
		private var _params:Array;
		private var _bForceClose:Boolean;
		private var _bTryOtherPort:Boolean;
		private var _bTryingPort:Boolean;
		private var _nConnectCount:uint = 0;
		private var _nReconnectAttempts:int = 0;
		private var _bReconnect:Boolean = true;
		private var _bReconnected:Boolean;
		private var _sConnectStatus:String = ConnectStates.CLOSED;
		private var _sNearID:String;
		
		/**
		 * INIT API
		 */
		
		public function INFXConnection() 
		{
			super();
			client = _callHandler;
			addEventListener( NetStatusEvent.NET_STATUS, __onConnect, false, 1000 );
		}
		
		/**
		 * PUBLIC API
		 */
		
		override public function connect( command:String, ...rest ): void 
		{
			_rtmp = command;
			_params = rest as Array;
			_sConnectStatus = ConnectStates.INITIALIZED;
			_connection();
			dispatchEvent( new Event(INITIALIZED) );
		}
		
		override public function close(): void 
		{
			_bForceClose = true;
			super.close();
		}
		
		/**
		 * PROTECTED API
		 */
		
		protected function tryRTMPPort(): void
		{
			_bTryingPort = true;
			_rtmp = _rtmp.replace( /rtmfp/gi, "rtmp" );
			_connection();
		}
		 
		protected function tryRTMPTPort(): void
		{
			_bTryingPort = true;
			_rtmp = _rtmp.replace( /rtmp|rtmpe|rtmpet|rtmps/gi, "rtmpt" );
			_connection();
		}
		
		/**
		 * PRIVATE API
		 */
		
		private function __clearConnectProps(): void
		{
			_bTryingPort = false;
			_bTryOtherPort = false;
			_bForceClose = false;
			_nConnectCount = 0;
		}
		
		private function _connection(): void
		{
			super.connect.apply( super, new Array(_rtmp).concat(_params) );
		}
		
		private function __setReconnected( value:Boolean ): void
		{
			_bReconnected = value;
		}
		
		/**
		 * HANDLERS
		 */
		
		private function __onConnect( event:NetStatusEvent ): void
		{
			var code:String = event.info.code;
			if( code == CONNECTED )
			{
				if ( _sConnectStatus == ConnectStates.RECONNECTING ) 
				{
					__setReconnected(true);
					doTimedLater( 500, __setReconnected, false );
					dispatchEvent(new Event(RECONNECT_SUCCESS));
				}else if ( _bTryingPort )
				{
					__setReconnected(true);
					doTimedLater( 500, __setReconnected, false );
				}
				_sConnectStatus = ConnectStates.CONNECTED;
				__clearConnectProps();
			}else if( code == REJECTED || code == FAILED )
			{
				dispatchEvent(new Event(code));// == REJECTED?REJECTED:FAILED
			}else if( code == CLOSED )
			{
				if ( _sConnectStatus == ConnectStates.INITIALIZED )
				{
					if ( !_bTryOtherPort && !_bTryingPort )
					{
						if ( _rtmp.indexOf("rtmfp") != -1 )
						{
							tryRTMPPort();
						}else {
							_bTryOtherPort = true;
							tryRTMPTPort();
						}
						event.stopPropagation();
						return;
					}
				}else if ( !_bForceClose && _nReconnectAttempts > -1 && _bReconnect && !_bTryingPort )
				{
					if( _sConnectStatus == ConnectStates.CONNECTED || _sConnectStatus == ConnectStates.RECONNECTING )
					{
						if ( _nReconnectAttempts == 0 || _nReconnectAttempts != _nConnectCount )
						{
							if ( _nConnectCount > 0 ) dispatchEvent( new Event(RECONNECT_FAILED) );
							if ( _nConnectCount == 5 )
							{
								_sConnectStatus = ConnectStates.RECONNECTING;
								dispatchEvent(new Event(RECONNECTING));
							}
							_nConnectCount++;
							event.preventDefault()
							event.stopPropagation();
							
							doTimedLater( 3000, _connection );
							return;
						}else{
							setToClose();
						}
					}
				}else if ( !_bTryingPort )
				{
					setToClose();
				}
			}else if ( (code == NETSTREAM_REJECTED||code == NETGROUP_REJECTED) && connected )
			{
				if ( _rtmp.indexOf("rtmfp") != -1 )
				{
					_bTryingPort = true;
					tryRTMPPort();
				}		
			}
		}
		
		protected function setToClose(): void
		{
			__clearConnectProps();
			_sConnectStatus = ConnectStates.CLOSED;
		}
		
		/**
		 * GETTER / SETTER
		 */
		
		//Override to send a custom id used for failover api
		override public function get nearID():String 
		{ 
			return !_sNearID ? super.nearID : _sNearID; 
		}
		
		//Set a new nearID here
		infx_internal function set nearID2( value:String ): void
		{
			if ( !value ) return;
			_sNearID = value;
		}
		
		public function set reconnect( value:Boolean ): void 
		{
			_bReconnect = value;
		}
		
		public function get reconnect(): Boolean
		{
			return _bReconnect;
		}
		
		public function set reconnected( value:Boolean ): void 
		{
			_bReconnected = value;
		}
		
		public function get reconnected(): Boolean
		{
			return _bReconnected;
		}
		
		public function set reconnectAttempts( value:int ): void 
		{
			_nReconnectAttempts = value;
		}
		
		public function get reconnectAttempts(): int
		{
			return _nReconnectAttempts;
		}
		
		public function get state(): String
		{
			return _sConnectStatus;
		}
		
		public function get clientHandler(): ClientSideCallHandler 
		{
			return _callHandler;
		}
		
		public function get infxConnected(): Boolean
		{
			return (_sConnectStatus == ConnectStates.CONNECTED);
		}
		
		public function get reconnecting(): Boolean
		{
			return (_sConnectStatus == ConnectStates.RECONNECTING||_bTryingPort==true);
		}
	}
}