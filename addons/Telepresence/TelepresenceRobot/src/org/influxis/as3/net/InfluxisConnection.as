package org.influxis.as3.net 
{
	//Flash Classes
	import flash.net.NetConnection;
	import flash.events.NetStatusEvent;
	import flash.events.Event;
	import flash.net.Responder;
	
	//Influxis Classes
	import org.influxis.as3.net.ClientSideCallHandler;
	import org.influxis.as3.states.ConnectStates;
	import org.influxis.as3.events.SimpleEventConst;
	import org.influxis.as3.utils.doTimedLater;
	
	[Event(name = "status", type = "flash.events.Event")]
	[Event(name = "netStatus", type = "flash.events.NetStatusEvent")]
	
	public class InfluxisConnection extends NetConnection
	{
		//Handles all calls
		private var _callHandler:ClientSideCallHandler = ClientSideCallHandler.getInstance();
		public var serverCallsEnabled:Boolean = true;
		
		private var _rtmp:String;
		private var _params:Array;
		private var _bForceClose:Boolean;
		private var _bTryingPort:Boolean;
		private var _bTriedAllPorts:Boolean;
		private var _sNearID:String;
		private var _oLastInfo:Object;
		private var _bReconnected:Boolean;
		private var _nConnectCount:uint = 0;
		private var _nReconnectAttempts:int = 4;
		private var _bPortForwarding:Boolean = true;
		private var _sState:String = ConnectStates.CLOSED;
		
		/**
		 * INIT API
		 */
		
		public function InfluxisConnection(): void
		{
			super();
			
			//Set main handler and listen to connect events
			super.client = _callHandler;
			_callHandler.client = new Object();
			addEventListener( NetStatusEvent.NET_STATUS, onConnect, false, 1000 );
		}
		
		/**
		 * PUBLIC API
		 */
		
		//Connects to server
		override public function connect( command:String, ...rest ): void 
		{
			//Gather connect info
			_rtmp = command;
			_params = rest as Array;
			
			//Reset port info
			_bTriedAllPorts = _bTryingPort = _bReconnected = false;
			
			//Set initialized state
			onStateChanged(ConnectStates.INITIALIZED);
			_connection();
		}
		
		//Closes our connection
		override public function close(): void 
		{
			_bForceClose = true;
			_bReconnected = false;
			super.close();
		}
		
		override public function call(command:String, responder:Responder, ...rest):void 
		{
			if ( serverCallsEnabled ) super.call.apply( null, ([command, responder]).concat(rest as Array) );
		}
		
		/**
		 * PROTECTED API
		 */
		
		protected function onStateChanged( value:String ): void
		{
			if ( _sState == value ) return;
			_sState = value;
			dispatchEvent(new Event(SimpleEventConst.STATE));
		}
		 
		protected function tryRTMPPort(): void
		{
			_bTryingPort = true;
			_rtmp = _rtmp.replace( /^(rtmfp)/gi, "rtmp" );
			_connection();
		}
		 
		protected function tryRTMPTPort(): void
		{
			_bTryingPort = true;
			_rtmp = _rtmp.replace( /^(rtmp|rtmpe|rtmpet|rtmps)/gi, "rtmpt" );
			_connection();
		}
		
		protected function setToClose(): void
		{
			__clearConnectProps();
			onStateChanged(ConnectStates.CLOSED);
		}
		
		/**
		 * PRIVATE API
		 */
		
		private function __clearConnectProps(): void
		{
			_bTryingPort = false;
			_bForceClose = false;
			_nConnectCount = 0;
		}
		
		private function _connection(): void
		{
			super.connect.apply( super, new Array(_rtmp).concat(_params) );
		}
		
		/**
		 * HANDLERS
		 */
		
		protected function onConnect( event:NetStatusEvent ): void
		{
			//Collect info and set code
			_oLastInfo = event.info;
			var code:String = _oLastInfo.code;
			//trace( "onConnect: " + code );
			
			//If connect then change state and clear props
			if( code == ConnectStates.INFO_CONNECTED )
			{
				__clearConnectProps();
				if ( state == ConnectStates.RECONNECTING ) _bReconnected = true;
				doTimedLater( 100, onStateChanged, ConnectStates.CONNECTED );
			}else if( code == ConnectStates.INFO_FAILED || code == ConnectStates.INFO_REJECTED )
			{
				//If initialized but connect failed then try other ports
				if ( state == ConnectStates.INITIALIZED )
				{
					if ( _rtmp.indexOf("rtmpt") != -1 || _bTriedAllPorts || code == ConnectStates.INFO_REJECTED )
					{
						_bTriedAllPorts = true;
						_bTryingPort = false;
						onStateChanged( code == ConnectStates.INFO_FAILED ? ConnectStates.FAILED : ConnectStates.REJECTED );
					}else if ( _rtmp.indexOf("rtmfp") != -1 )
					{
						doTimedLater( 1, tryRTMPPort );
					}else{
						doTimedLater( 1, tryRTMPTPort );
					}
				}
			}else if( code == ConnectStates.INFO_CLOSED )
			{
				//If not initialized and connect closes then reconnect
				if ( !_bForceClose && !_bTryingPort && !_bTriedAllPorts && _nReconnectAttempts > -1 )
				{
					if ( state == ConnectStates.CONNECTED )
					{
						_bReconnected = false;
						_nConnectCount = 0;
						onStateChanged(ConnectStates.RECONNECTING);
					}
					
					if ( state == ConnectStates.RECONNECTING )
					{
						if ( _nReconnectAttempts != _nConnectCount )
						{
							_nConnectCount++;
							doTimedLater( 3000, _connection );
						}else{
							_nConnectCount = 0;
						}
					}
				}else{
					setToClose();
				}
			}
		}
		
		/**
		 * GETTER / SETTER
		 */
		
		public function get path(): String
		{
			return _rtmp;
		}
		
		public function get connectParams(): Array
		{
			return _params;
		}
		
		public function set portForwarding( value:Boolean ): void
		{
			_bPortForwarding = value;
		}
		
		public function get portForwarding(): Boolean
		{
			return _bPortForwarding
		}
		
		override public function set client( value:Object ): void 
		{
			_callHandler.client = value;
		}
		 
		override public function get client(): Object 
		{ 
			return _callHandler.client; 
		}
		
		public function get state(): String 
		{
			return _sState;
		}
		
		override public function get connected(): Boolean 
		{ 
			return (state == ConnectStates.CONNECTED || state == ConnectStates.RECONNECTING); 
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
		
		public function get clientHandler(): ClientSideCallHandler 
		{
			return _callHandler;
		}
		
		public function get reconnecting(): Boolean
		{
			return (state == ConnectStates.RECONNECTING);
		}
		
		public function get lastInfo(): Object
		{
			return _oLastInfo;
		}
	}
}