package org.influxis.flotools.data 
{
	//Flash Classes
	import flash.events.NetFilterEvent;
	import flash.net.NetConnection;
	import flash.events.EventDispatcher;
	
	//Influxis Classes
	import org.influxis.as3.net.ClientSideCallHandler;
	import org.influxis.as3.states.DataStates;
	import org.influxis.as3.data.HashTable;
	import org.influxis.as3.utils.StreamUtils;
	
	public class LiveCasters extends EventDispatcher
	{
		private static const _CALL_PREFIX_:String = "LiveCasters:static";
		private static var __sg:LiveCasters;
		
		private var _clsh:ClientSideCallHandler;
		private var _casters:HashTable;
		
		public function LiveCasters() 
		{
			_clsh = ClientSideCallHandler.getInstance();
			_clsh.addPath( "LiveCasters", { __onServerEvent:__onServerEvent } );
			
			_casters = new HashTable();
			_casters.addEventListener( DataStates.ADD, dispatchEvent );
			_casters.addEventListener( DataStates.REMOVE, dispatchEvent );
			_casters.addEventListener( DataStates.UPDATE, dispatchEvent );
			_casters.addEventListener( DataStates.CHANGE, dispatchEvent );
		}
		
		/**
		 * SINGLETON API
		 */
		
		public static function getInstance(): LiveCasters
		{
			if ( !__sg ) __sg = new LiveCasters();
			return __sg;
		}
		 
		public static function destroy(): void 
		{
			if ( !__sg ) return;
			__sg.close();
			__sg = null;
		}
		
		/**
		 * CONNECT API
		 */
		
		private var _netConnection:NetConnection;
		public function connect( netConnection:NetConnection ):void 
		{
			if ( !netConnection ) return;
			_netConnection = netConnection;
			_netConnection.call( _CALL_PREFIX_+".connect?clientInfo", null );
		}
		
		public function close(): void 
		{
			if ( !_netConnection ) return;
			_netConnection.call( _CALL_PREFIX_+".close?clientInfo", null );
			_netConnection = null;
		}
		
		/**
		 * PUBLIC API
		 */
		
		public function getStreamInfoAt( file:String ): Object
		{
			if ( !file ) return null;
			var aFile:Array = file.split(".");
			return _casters.getItemAt( aFile[0]+"_"+(aFile.length == 1 ? "flv" : aFile[1]) );
		}
		 
		public function streamExists( file:String ): Boolean
		{
			return getStreamInfoAt(file) != null;
		}
		
		/**
		 * HANDLERS
		 */
		
		private function __onServerEvent( event:Object ): void 
		{
			switch( String(event.type) )
			{
				case DataStates.ADD :
					_casters.addItemAt( event.slot, event.data );
					break;
				case DataStates.REMOVE :
					_casters.removeItemAt( event.slot );
					break;
				case DataStates.UPDATE :
					_casters.updateItemAt( event.slot, event.data );
					break;
				case DataStates.CHANGE :
					_casters.source = event.data;
					break;
			}
		}
	}
}