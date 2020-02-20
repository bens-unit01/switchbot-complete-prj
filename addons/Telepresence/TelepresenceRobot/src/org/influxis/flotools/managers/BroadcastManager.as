package org.influxis.flotools.managers 
{
	//Flash Classes
	import flash.net.NetConnection;
	import flash.events.NetStatusEvent;
	import flash.media.Microphone;
	import flash.media.Camera;
	import flash.utils.setTimeout;
	
	//Influxis Classes
	import org.influxis.as3.utils.StreamUtils;
	import org.influxis.as3.states.BroadcastStates;
	
	//Flotools Classes
	import org.influxis.flotools.managers.StreamManager;
	
	public class BroadcastManager extends StreamManager
	{
		public static const NETSTREAM_CHANGE:String = "netStreamChange";
		private var _activeBroadcast:Boolean;
		private var _camera:Camera;
		private var _microphone:Microphone;
		private var _publishRequest:Boolean;
		private var _recordFlag:String = "live";
		
		/*
		 * INIT API
		 */
		
		public function BroadcastManager( netConnection:NetConnection = null, streamName:String = null ): void
		{
			onStateChanged(BroadcastStates.UNINITIALIZED);
			super(netConnection, streamName);
		}
		
		/*
		 * PUBLIC API
		 */
		
		//Starts broadcast to server
		public function startBroadcast(): void
		{
			if ( _activeBroadcast ) return;
			_activeBroadcast = true;
			onStateChanged(BroadcastStates.STARTING);
			refreshStreamCast();
		}
		
		//Stop and cleans out broadcast
		public function stopBroadcast(): void
		{
			if ( !_activeBroadcast ) return;
			_activeBroadcast = false;
			onStateChanged(BroadcastStates.STOPPING);
			refreshStreamCast();
		}
		
		public function toggleBroadcast(): void
		{
			_activeBroadcast = !_activeBroadcast;
			onStateChanged(_activeBroadcast?BroadcastStates.STARTING:BroadcastStates.STOPPING);
			refreshStreamCast();
		}
		
		/*
		 * PROTECTED API
		 */
		
		protected function onCameraChanged( value:Camera ): void
		{
			if ( _camera == value ) return;
			
			//If no new camera just take off
			if ( _camera && !value && netStream ) _netStream.attachCamera(null);
			
			_camera = value;
			if ( _camera && netStream ) netStream.attachCamera(_camera);
		}
		
		protected function onMicrophoneChanged( value:Microphone ): void
		{
			if ( _microphone == value ) return;
			
			//If no new microphone just take off
			if ( _microphone && !value && netStream ) netStream.attachAudio(null);
			
			_microphone = value;
			if ( _microphone && netStream ) netStream.attachAudio(_microphone);
		}
		
		override protected function refreshStreamCast(): void
		{
			if ( _activeBroadcast )
			{
				if ( netStream ) stopAndDestroyStream();
				startAndRunStream();
			}else{
				stopAndDestroyStream();
			}
		}
		
		override protected function startAndRunStream(): void
		{
			if ( !streamName || !netConnection || _netStream ) return;
			
			super.startAndRunStream();
			_netStream.attachCamera(_camera);
			
			//Only attach mic if supported
			if ( Microphone.isSupported && _microphone ) _netStream.attachAudio( _microphone );
			
			var doPublish:Boolean = true;
			CONFIG::IS_MOBILE
			{
				//Don't cast P2P until Netgroup connect (AIR MOBILE ONLY)
				if ( netGroup ) doPublish = false;
			}
			
			if ( doPublish )
			{
				_publishRequest = true;
				setTimeout( publishStream, 10 );
			}
		}
		
		override protected function stopAndDestroyStream(): void
		{
			if ( !_netStream ) return;
			
			_netStream.publish("");
			_netStream.attachCamera(null); _netStream.attachAudio(null);
			super.stopAndDestroyStream();
		}
		
		protected function publishStream(): void
		{
			if ( !_publishRequest || !_netStream ) return;
			_publishRequest = false;
			_netStream.publish( StreamUtils.getPlayNameFromFile(streamName), _recordFlag );
			if( metaData ) _netStream.send("@setDataFrame", "onMetaData", metaData );
		}
		
		/*
		 * HANDLERS
		 */
		 
		//Events firing from Netstream
		override protected function onStreamEvent( event:NetStatusEvent ): void
		{
			if ( event.info.code == "NetStream.Publish.Start" )
			{
				onStateChanged(BroadcastStates.BROADCASTING);
			}else if ( event.info.code == "NetStream.Unpublish.Success" || (groupSpec != null && event.info.code == "NetStream.Publish.BadName") )
			{
				if ( !_activeBroadcast && state == BroadcastStates.STOPPING )
				{
					onStateChanged(BroadcastStates.UNINITIALIZED);
				}
			}
		}
		
		//When Netgroup connects broadcast (P2P only)
		override protected function onNetGroupEvent( event:NetStatusEvent ): void
		{
			var code:String = event.info.code;
			if ( code == "NetStream.Connect.Success" )
			{
				if ( _netStream )
				{
					_publishRequest = true;
					setTimeout( publishStream, 10 );
				}
			}
		}
		
		/*
		 * GETTER / SETTER
		 */
		
		public function set camera( value:Camera ): void
		{
			onCameraChanged(value);
		}
		
		public function get camera(): Camera
		{
			return _camera;
		}
		
		public function set microphone( value:Microphone ): void
		{
			onMicrophoneChanged(value);
		}
		
		public function get microphone(): Microphone
		{
			return _microphone;
		}
		
		public function set recordFlag( value:String ): void
		{
			if ( _recordFlag == value ) return;
			_recordFlag = value;
		}
		
		public function get recordFlag(): String
		{
			return _recordFlag;
		}
	}
}