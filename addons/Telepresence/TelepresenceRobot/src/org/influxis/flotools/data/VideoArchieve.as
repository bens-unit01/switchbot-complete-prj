package org.influxis.flotools.data 
{
	//Flash Classes
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.net.NetConnection;
	import flash.utils.setTimeout;
	import flash.utils.clearTimeout;
	
	//Influxis Classes
	import org.influxis.as3.data.DataProvider;
	import org.influxis.as3.states.DataStates;
	import org.influxis.as3.net.ClientSideCallHandler;
	
	public class VideoArchieve extends EventDispatcher
	{
		public static var FORCE_REFRESH:Boolean = false;
		private static var __instances:Object = new Object();
		
		private var _callPrefix:String;
		private var _netConnection:NetConnection;
		private var _clsh:ClientSideCallHandler;
		private var _instanceName:String;
		private var _data:DataProvider;
		private var _changeInt:Number;
		
		/*
		 * INIT API
		 */
		
		public function VideoArchieve( target:String ): void
		{
			_instanceName = target;
			_data = new DataProvider();
			
			if ( !_instanceName ) throw new Error( "Target folder must be non-null!" );
			
			_clsh = ClientSideCallHandler.getInstance();
			_clsh.addPath( "VideoArchieve", { __onServerEvent:__onServerEvent } );
			_callPrefix = "VideoArchieve:" + target;
		}
		
		/*
		 * SINGLETON API
		 */
		
		public static function getInstance( instanceName:String = "_DEFAULT_" ): VideoArchieve
		{
			if ( !instanceName ) return null;
			if ( __instances[instanceName] == undefined ) __instances[instanceName] = new VideoArchieve(instanceName);
			return (__instances[instanceName] as VideoArchieve);
		}
		 
		/*
		 * CONNECT API
		 */
		
		public function connect( netConnection:NetConnection ):void 
		{
			if ( !netConnection ) return;
			_netConnection = netConnection;
			_netConnection.call( _callPrefix+".connect?clientInfo", null, FORCE_REFRESH );
		}
		
		public function close(): void 
		{
			if ( !_netConnection ) return;
			_data.clear();
			_netConnection = null;
		}
		
		/*
		 * PUBLIC API
		 */
		
		//Adds a definst media item
		public function addDefinstMediaAt( p_sFileName:String, p_sType:String, p_sFileType:String, p_oData:Object, p_bOmitCall:Boolean = false ): void
		{
			_netConnection.call( _callPrefix+".addDefinstMediaAt", null, p_sFileName, p_sType, p_sFileType, p_oData, p_bOmitCall );
		}
		
		//Add multiple definst items
		public function addDefinstItemsMediaAt( p_aMediaData:Array ): void
		{
			_netConnection.call( _callPrefix+".addDefinstItemsMediaAt", null, p_aMediaData );
		}
		
		//Remove a definst item
		public function removeDefinstMediaAt( p_sFileName:String, p_sType:String, p_sFileType:String, p_bOmitCall:Boolean = false ): void
		{
			_netConnection.call( _callPrefix+".removeDefinstMediaAt", null, p_sFileName, p_sType, p_sFileType, p_bOmitCall );
		}
		
		//Remove multiple definst items
		public function removeDefinstMediaItemsAt( p_aMediaData:Array ): void
		{
			_netConnection.call( _callPrefix+".removeDefinstMediaItemsAt", null, p_aMediaData );
		}
		
		//Remove all definst items
		public function removeAllDefinst(): void
		{
			_netConnection.call( _callPrefix+".removeAllDefinst", null );
		}
		
		public function clearDefinst(): void
		{
			_netConnection.call( _callPrefix+".clearDefinst", null );
		}
		
		//Add Media
		public function addMediaAt( p_sFileName:String, p_sType:String, p_sFileType:String, p_oData:Object ): void
		{
			if( p_sFileName == null || p_sFileType == null || p_sType == null ) return;
			_netConnection.call( _callPrefix+".addMediaAt", null, p_sFileName, p_sType, p_sFileType, p_oData );
		}
		
		public function addMediaItemsAt( p_aMediaData:Array ): void
		{
			if( p_aMediaData == null ) return;
			_netConnection.call( _callPrefix+".addMediaItemsAt", null, p_aMediaData );
		}
		
		/*public function getItemAt( p_sFileName:String, p_sType:String ): Object
		{
			if( p_sFileName == null || p_sType == null || _oMediaData == null ) return null;
			return ObjectUtils.cloneObject(_oMediaData[ p_sFileName+"_"+p_sType ]);
		}
		
		public function getDataAt( p_sField:String, p_Value:* ): Array
		{
			if( p_sField == null || p_Value == undefined ) return null;
			
			var aData:Array = new Array();
			if( _aMediaData != null )
			{
				for each( var o:Object in _aMediaData )
				{
					if( p_Value != null && o[p_sField] == p_Value ) aData.push( ObjectUtils.cloneObject(o) );
				}
			}
			return aData;
		}*/
		
		//Removes media from saved slot
		public function removeMediaAt( p_sFileName:String, p_sType:String, p_sFileType:String ): void
		{
			if( p_sFileName == null || p_sFileType == null || p_sType == null ) return;
			_netConnection.call( _callPrefix+".removeMediaAt", null, p_sFileName, p_sType, p_sFileType );
		}
		
		//Removes specific items and corresponding files
		public function removeMediaItemsAt( p_aMediaData:Array ): void
		{
			if( p_aMediaData == null ) return;
			_netConnection.call( _callPrefix+".removeMediaItemsAt", null, p_aMediaData );
		}
		
		//Clears data and removes all files on the server
		public function removeAll(): void
		{
			_netConnection.call( _callPrefix+".removeAll", null );
		}
		
		//Clears the data for specific items
		public function clearMediaItemsAt( p_aMediaData:Array ): void
		{
			if( p_aMediaData == null ) return;
			_netConnection.call( _callPrefix+".clearMediaItemsAt", null, p_aMediaData );
		}
		
		//Clears and resets all media data
		public function clear(): void
		{
			_netConnection.call( _callPrefix+".clear", null );
		}
		
		//Let's you remove data in reference to a specific param in the media data object
		public function removeDataAt( p_sField:String, p_Value:* ): void
		{
			if( p_sField == null || p_Value == null ) return;
			_netConnection.call( _callPrefix+".removeDataAt", null, p_sField, p_Value );
		}
		
		//Updates media
		public function updateMediaAt( p_sFileName:String, p_sType:String, p_sFileType:String, p_oData:Object ): void
		{
			if( p_sFileName == null || p_sFileType == null || p_sType == null || p_oData == null ) return;
			_netConnection.call( _callPrefix+".updateMediaAt", null, p_sFileName, p_sType, p_sFileType, p_oData );
		}
		
		public function updateMediaItemsAt( p_aMediaData:Array ): void
		{
			if( p_aMediaData == null ) return;
			_netConnection.call( _callPrefix+".updateMediaItemsAt", null, p_aMediaData );
		}
		
		public function refresh(): void
		{
			_netConnection.call( _callPrefix+".refresh", null );
		}
		 
		/*
		 * HANDLERS
		 */
		
		private function __onServerEvent( event:Object ): void 
		{
			if ( event.instanceName != _instanceName || event.data == undefined ) return;
			
			switch( String(event.type) )
			{
				case DataStates.ADD :
					_data.addItem(event.data);
					break;
				case DataStates.REMOVE :
					_data.removeItemAt(indexOf(event.data));
					break;
				case DataStates.UPDATE :
					_data.updateItemAt(indexOf(event.data), event.data);
					break;
				case DataStates.CHANGE :
					if ( !isNaN(_changeInt) ) clearTimeout(_changeInt);
					_changeInt = setTimeout( __doChange, 50, event.data as Array );
					break;
			}
		}
		
		protected final function indexOf( mediaItem:Object ): Number
		{
			if ( !mediaItem ) return NaN;
			
			var index:Number, searchItem:Object;
			var nLen:Number = _data.length;
			for (var i:int = 0; i < nLen; i++) 
			{
				searchItem = _data.getItemAt(i);
				if ( searchItem.filename == mediaItem.filename && searchItem.type == mediaItem.type )
				{
					index = i;
					break;
				}
			}
			return index;
		}
		
		/*
		 * PRIVATE API
		 */
		
		private function __doChange( newData:Array ): void
		{
			_changeInt = NaN;
			_data.setArray(newData, false);
		}
		 
		/*
		 * GETTER / SETTER
		 */
		
		public function get mediaData(): DataProvider
		{
			return _data;
		}
	}
}