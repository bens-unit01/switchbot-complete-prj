package org.influxis.flotools.managers 
{
	//Flash Classes
	import flash.net.NetConnection;
	import flash.events.EventDispatcher;
	import flash.net.Responder;
	
	//Influxis Classes
	import org.influxis.as3.events.SimpleEvent;
	import org.influxis.as3.states.ResultState;
	import org.influxis.as3.utils.handler;
	
	public class MediaInfo extends EventDispatcher
	{
		private static var __mi:MediaInfo;
		private var _netConnection:NetConnection;
		private var _serverData:Object = new Object();
		
		/**
		 * INIT API
		 */
		
		public function MediaInfo( netConnection:NetConnection ): void
		{
			_netConnection = netConnection;
		}
		
		/**
		 * SINGLETON API
		 */
		 
		public static function getInstance( netConnection:NetConnection ): MediaInfo
		{
			if ( !__mi ) __mi = new MediaInfo( netConnection );
			return __mi;
		}
		
		public function destroy(): void
		{
			if ( __mi ) __mi = null;
		}
		
		/**
		 * PUBLIC API
		 */
		
		public function requestMediaInfo( id:String, live:Boolean = false ): void
		{
			if ( mediaAvailable(id) ) return;
			
			var file:String; var folder:String;
			var nLastIndex:Number = id.lastIndexOf("/");
			if ( nLastIndex == -1 )
			{
				file = id;
			}else{
				var idName:String = id.charAt(0) == "/" ? id.substring(1) : id;
				file = idName.substring(nLastIndex + 1);
				folder = idName.substring(0, nLastIndex);
			}
			_netConnection.call( live ? "getLiveMediaInfo" : "getMediaInfo", new Responder(handler(__mediaInfoReceived, id)), file, folder );
		}
		 
		public function mediaAvailable( id:String ): Boolean
		{
			return (_serverData[id] != undefined);
		}
		
		public function getMediaItemAt( id:String ): Object
		{
			var o:Object;
			if ( _serverData[id] != undefined ) 
			{
				if ( _serverData[id].mediaExists == true ) o = _serverData[id].info;
			}
			return o;
		}
		
		public function mediaExists( id:String ): Boolean
		{
			var bExists:Boolean;
			if ( _serverData[id] != undefined ) bExists = _serverData[id].mediaExists == true;
			return bExists;
		}
		
		/**
		 * PRIVATE API
		 */
		
		private function __mediaInfoReceived( mediaData:Object, id:String ): void
		{
			_serverData[id] = new Object();
			_serverData[id].mediaExists = mediaData != null;
			
			var event:SimpleEvent;
			if ( _serverData[id].mediaExists ) 
			{
				_serverData[id].info = mediaData;
				event = new SimpleEvent( ResultState.RESULT, null, {id:id, data:mediaData} );
			}else{
				event = new SimpleEvent( ResultState.FAILED, null, {id:id} );
			}
			dispatchEvent(event);
		}
		 
		/**
		 * GETTER / SETTER
		 */
		
		/*public function get dataProvider(): Array
		{
			
		}*/
	}
}