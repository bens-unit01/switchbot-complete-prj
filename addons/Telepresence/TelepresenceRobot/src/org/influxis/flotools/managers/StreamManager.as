package org.influxis.flotools.managers 
{
	//Flash Classes
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.net.NetConnection;
	import flash.events.NetStatusEvent;
	import flash.net.GroupSpecifier;
	import flash.net.NetGroup;
	import flash.net.NetStream;
	
	//Influxis Classes
	import org.influxis.as3.events.SimpleEventConst;
	
	public class StreamManager extends EventDispatcher 
	{
		public static const NETSTREAM_CHANGE:String = "netStreamChange";
		protected var _netStream:NetStream;
		private var _netConnection:NetConnection;
		private var _netGroup:NetGroup;
		private var _groupSpec:GroupSpecifier;
		private var _metaData:Object;
		private var _streamName:String;	
		private var _clientObj:Object = new Object();
		private var _state:String;
		
		/*
		 * INIT API
		 */
		
		public function StreamManager( netConnection:NetConnection = null, streamName:String = null ) 
		{
			this.netConnection = netConnection;
			this.streamName = streamName;
			super();
		}
		
		/*
		 * PROTECTED API
		 */
		
		protected function onStateChanged( value:String ): void
		{
			if ( _state == value ) return;
			_state = value;
			dispatchEvent(new Event(SimpleEventConst.STATE));
		}
		 
		protected function onStreamNameChanged( value:String ): void
		{
			if ( _streamName == value ) return;
			
			//Stop the broadcast if name is missing
			if ( _streamName && !value && _netStream ) stopAndDestroyStream();
			
			_streamName = value;
			if ( !_streamName ) return;
			refreshStreamCast();
		}
		
		protected function onConnectionChanged( value:NetConnection ): void
		{
			if ( _netConnection == value ) return;
			
			//Stop the broadcast if connection is missing
			if ( _netConnection && !value && _netStream ) stopAndDestroyStream();
			
			_netConnection = value;
			if ( !_netConnection ) return;
			refreshStreamCast();
		}
		
		protected function onNetGroupChanged( value:NetGroup ): void
		{
			if ( _netGroup == value ) return;
			
			if ( _netGroup )
			{
				_netGroup.removeEventListener( NetStatusEvent.NET_STATUS, onNetGroupEvent );
				_netGroup = null;
			}
			
			_netGroup = value;
			if ( !_netGroup ) return;
			
			_netGroup.addEventListener( NetStatusEvent.NET_STATUS, onNetGroupEvent );
			refreshStreamCast();
		}
		
		protected function onGroupSpecChanged( value:GroupSpecifier ): void
		{
			if ( _groupSpec == value ) return;
			_groupSpec = value;
			if ( !_groupSpec ) return;
			refreshStreamCast();
		}
		
		protected function startAndRunStream(): void
		{
			if ( _netStream || !_netConnection ) return;
			//trace("startAndRunStream: " + _netGroup, _groupSpec);
			//Create stream and dispatch event notifying change
			_netStream = new NetStream(_netConnection, (_netGroup != null?_groupSpec.groupspecWithAuthorizations():NetStream.CONNECT_TO_FMS));
			dispatchEvent(new Event(NETSTREAM_CHANGE));
			
			_netStream.client = _clientObj;
			_netStream.addEventListener( NetStatusEvent.NET_STATUS, onStreamEvent );
		}
		
		protected function stopAndDestroyStream(): void
		{
			if ( !_netStream ) return;
			
			_netStream.removeEventListener( NetStatusEvent.NET_STATUS, onStreamEvent );
			_netStream.close();
			_netStream = null;
			dispatchEvent(new Event(NETSTREAM_CHANGE));
		}
		
		protected function refreshStreamCast(): void
		{
			if ( _netStream ) stopAndDestroyStream();
			startAndRunStream();	
		}
		
		/*
		 * HANDLERS
		 */
		 
		//Events firing from Netstream
		protected function onStreamEvent( event:NetStatusEvent ): void
		{
			
		}
		
		//When Netgroup connects broadcast (P2P only)
		protected function onNetGroupEvent( event:NetStatusEvent ): void
		{
			
		}
		
		/*
		 * GETTER / SETTER
		 */
		
		public function set streamName( value:String ): void
		{
			if ( _streamName == value ) return;
			onStreamNameChanged(value);
		}
		
		public function get streamName(): String
		{
			return _streamName;
		}
		
		public function set netConnection( value:NetConnection ): void
		{
			if ( _netConnection == value ) return;
			onConnectionChanged(value);
		}
		
		public function get netConnection(): NetConnection
		{
			return _netConnection;
		}
		
		public function get netStream(): NetStream
		{
			return _netStream;
		}
		
		public function set netGroup( value:NetGroup ): void
		{
			onNetGroupChanged(value);
		}
		
		public function get netGroup(): NetGroup
		{
			return _netGroup;
		}
		
		public function set groupSpec( value:GroupSpecifier ): void
		{
			onGroupSpecChanged(value);
		}
		
		public function get groupSpec(): GroupSpecifier
		{
			return _groupSpec;
		}
		
		public function set client( value:Object ): void
		{
			if ( _clientObj == value ) return;
			_clientObj = value;
			if ( _netStream ) _netStream.client = _clientObj;
		}
		
		public function get client(): Object
		{
			return _clientObj;
		}
		
		public function set metaData( value:Object ): void
		{
			if ( _metaData == value ) return;
			_metaData = value;
		}
		
		public function get metaData(): Object
		{
			return _metaData;
		}
		
		public function get state(): String
		{
			return _state;
		}
		
		public function get connected(): Boolean
		{
			return _netConnection && _netConnection.connected;
		}
	}
}