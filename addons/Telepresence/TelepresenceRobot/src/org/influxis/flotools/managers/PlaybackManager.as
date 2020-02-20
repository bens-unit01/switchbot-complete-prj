package org.influxis.flotools.managers 
{
	//Flash Classes
	import flash.net.NetConnection;
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.utils.setTimeout;
	
	//Influxis Classes
	import org.influxis.as3.utils.StreamUtils;
	import org.influxis.as3.controls.StreamController;
	import org.influxis.as3.events.SimpleEventConst;
	
	//Flotools Classes
	import org.influxis.flotools.managers.StreamManager;
	
	public class PlaybackManager extends StreamManager
	{
		public static const NETSTREAM_CHANGE:String = "netStreamChange";
		private var _isLive:Boolean;
		private var _playRequest:Boolean;
		private var _controller:StreamController;
		
		/*
		 * INIT API
		 */
		
		public function PlaybackManager( netConnection:NetConnection = null, streamName:String = null ): void
		{
			_controller = new StreamController();
			_controller.addEventListener( SimpleEventConst.STATE, __onControllerEvent );
			onStateChanged(_controller.state);
			super(netConnection, streamName);
		}
		
		/*
		 * PROTECTED API
		 */
		
		override protected function startAndRunStream():void 
		{
			if ( !streamName || !netConnection || netStream ) return; 
			
			super.startAndRunStream();
			_controller.source = netStream;
			
			var doPlay:Boolean = true;
			CONFIG::IS_MOBILE
			{
				//Don't cast P2P until Netgroup connect (AIR MOBILE ONLY)
				if ( netGroup ) doPlay = false;
			}
			
			if ( doPlay )
			{
				_playRequest = true;
				setTimeout( playStream, 10 );
			}
		}
		
		override protected function stopAndDestroyStream():void 
		{
			if ( !netStream ) return;
			
			netStream.play(false);
			_controller.clear();
			super.stopAndDestroyStream();
		}
		
		protected function playStream(): void
		{
			if ( !_playRequest || !_netStream ) return;
			_playRequest = false;
			netStream.play( StreamUtils.getPlayNameFromFile(streamName), (isLive?-1:0) );
		}
		
		/*
		 * HANDLERS
		 */
		
		private function __onControllerEvent( event:Event ): void
		{
			if ( event.type == SimpleEventConst.STATE )
			{
				onStateChanged(_controller.state);
			}
		}
		
		//When Netgroup connects (P2P only)
		override protected function onNetGroupEvent( event:NetStatusEvent ): void
		{
			var code:String = event.info.code;
			if ( code == "NetStream.Connect.Success" )
			{
				if ( _netStream )
				{
					_playRequest = true;
					setTimeout( playStream, 10 );
				}
			}
		}
		
		/*
		 * GETTER / SETTER
		 */
		
		public function get isLive(): Boolean
		{
			return _isLive;
		}
		
		public function set isLive( value:Boolean ): void
		{
			if ( _isLive == value ) return;
			_isLive = value;
			refreshStreamCast();
		}
	}
}