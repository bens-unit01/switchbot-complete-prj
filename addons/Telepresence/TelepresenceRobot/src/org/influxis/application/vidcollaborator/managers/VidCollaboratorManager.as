package org.influxis.application.vidcollaborator.managers 
{
	//Flash Classes
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.net.NetConnection;
	
	//Influxis Classes
	import org.influxis.as3.events.SimpleEvent;
	import org.influxis.as3.data.DataProvider;
	import org.influxis.as3.states.DataStates;
	import org.influxis.as3.net.ClientSideCallHandler;
	
	public class VidCollaboratorManager extends EventDispatcher  
	{
		public static const ACTIVE_CASTERS_LIMIT:uint = 3;
		public static const ADMIN_UPDATE:String = "adminUpdate";
		public static const LOCAL_DATA_UPDATE:String = "localDataUpdate";
		public static const MESSAGE_REQUEST:String = "messageRequest";
		public static const VIEWERS_LIST_TYPE:String = "viewersList";
		public static const CAMERA_LIST_TYPE:String = "cameraList";
		public static const ACTIVE_LIST_TYPE:String = "activeList";
		public static const ADMIN_VIDEO_REQUEST:String = "adminVideoRequest";
		public static const VIEWER_VIDEO_RESPONSE:String = "viewerVideoResponse";
		
		private static var __instances:Object = new Object();
		
		private var _nc:NetConnection;
		private var _clsh:ClientSideCallHandler;
		private var _serverHandler:Object;
		private var _callPrefix:String;
		
		private var _viewerList:DataProvider;
		private var _cameraList:DataProvider;
		private var _castersList:DataProvider;
		private var _localData:Object;
		private var _adminData:Object;
		
		/*
		 * INIT API
		 */
		
		public function VidCollaboratorManager( instanceName:String = "_DEFAULT_" ): void
		{
			super();
			
			//Make casters list to update necessary listings
			_viewerList = new DataProvider();
			_cameraList = new DataProvider();
			_castersList = new DataProvider();
			
			//Setup call handlers
			_callPrefix = "VidCollaboratorManager:" + instanceName;
			_serverHandler = new Object();
			_serverHandler.__onServerEvent = __onServerEvent;	
			_clsh = ClientSideCallHandler.getInstance();
			
			_clsh.addPath( "VidCollaboratorManager", _serverHandler );
		}
		
		/*
		 * SINGLETON API
		 */
		
		public static function getInstance( instanceName:String = "_DEFAULT_" ): VidCollaboratorManager
		{
			if ( __instances[instanceName] == undefined ) __instances[instanceName] = new VidCollaboratorManager(instanceName);	
			return __instances[instanceName] as VidCollaboratorManager;
		}
		
		public static function destroy( instanceName:String = "_DEFAULT_" ): void
		{
			if ( __instances[instanceName] == undefined ) return;
			
			var vcm:VidCollaboratorManager = __instances[instanceName] as VidCollaboratorManager;
			if ( vcm.connected ) vcm.close();
			vcm = null;
			
			__instances[instanceName] = undefined;
			delete __instances[instanceName];
		}
		
		/*
		 * CONNECT API
		 */
		
		public function connect( netConnection:NetConnection, isAdmin:Boolean = true ): Boolean
		{
			if ( _nc || !netConnection || !netConnection.connected ) return false;
			_nc = netConnection;
			_nc.call( _callPrefix +".connect?clientInfo", null, isAdmin );
			return true;
		}
		
		public function close(): void
		{
			if ( !_nc ) return;
			
			_viewerList.clear(); _cameraList.clear();
			_castersList.clear();
			
			_nc.call( _callPrefix+".close?clientInfo", null );
			_nc = null;
		}
		
		/*
		 * PUBLIC API
		 */
		
		public function updateLocalData( infoData:Object ): void
		{
			if ( !connected ) return;
			_nc.call( _callPrefix+".updateLocalData?clientInfo", null, infoData );
		}
		
		public function registerCamera( register:Boolean ): void
		{
			if ( !connected ) return;
			_nc.call( _callPrefix+".registerCamera?clientInfo", null, register );
		}
		
		public function joinPublishGroup( joinGroup:Boolean ): void
		{
			if ( !connected ) return;
			_nc.call( _callPrefix+".joinPublishGroup?clientInfo", null, joinGroup );
		}
		
		public function haveViewerJoinPublish( viewerID:String, joinGroup:Boolean ): void
		{
			if ( !connected ) return;
			_nc.call( _callPrefix+".haveViewerJoinPublish?clientInfo", null, viewerID, joinGroup );
		}
		
		public function clearAllCameraRequests(): void
		{
			if ( !connected ) return;
			_nc.call( _callPrefix+".clearAllCameraRequests", null, true );
		}
		
		public function clearActiveCasters(): void
		{
			if ( !connected ) return;
			_nc.call( _callPrefix+".clearActiveCasters", null );
		}
		
		public function clearSession(): void
		{
			if ( !connected ) return;
			_nc.call( _callPrefix+".clearSession", null );
		}
		
		public function registerAdminPublish( publishing:Boolean ): void
		{
			if ( !connected ) return;
			_nc.call( _callPrefix+".registerAdminPublish?clientInfo", null, publishing );
		}
		
		public function sendMessageRequest( viewerID:String, message:Object ): void
		{
			if ( !connected ) return;
			_nc.call( _callPrefix+".sendMessageRequest?clientInfo", null, viewerID, message );
		}
		
		/*
		 * PRIVATE API
		 */
		
		protected final function indexOf( viewerData:Object, targetList:DataProvider ): Number
		{
			if ( !viewerData || !targetList ) return NaN;
			
			var index:Number, searchItem:Object;
			var nLen:Number = targetList.length;
			for (var i:int = 0; i < nLen; i++) 
			{
				searchItem = targetList.getItemAt(i);
				if ( searchItem.id == viewerData.id )
				{
					index = i;
					break;
				}
			}
			return index;
		} 
		
		/*
		 * HANDLERS
		 */
		
		private function __onServerEvent( event:Object ): void
		{
			//trace("__onServerEvent: " + event.type );
			if ( event.type == ADMIN_UPDATE )
			{
				_adminData = event.data;
			}else if ( event.type == LOCAL_DATA_UPDATE )
			{
				_localData = event.data;
			}else if ( event.type == MESSAGE_REQUEST )
			{
				dispatchEvent( new SimpleEvent(MESSAGE_REQUEST, null, {senderID:event.senderID, message:event.message}) );
				return;
			}else{
				var targetList:DataProvider = event.list == VIEWERS_LIST_TYPE ? _viewerList : 
											  event.list == CAMERA_LIST_TYPE ? _cameraList : _castersList;
				
				switch( event.type )
				{
					case DataStates.ADD : 
						targetList.addItem(event.data);
						break;
					case DataStates.REMOVE : 
						targetList.removeItemAt(indexOf(event.data, targetList));
						break;
					case DataStates.UPDATE : 
						targetList.updateItemAt(indexOf(event.data, targetList), event.data );
						break;
					case DataStates.CHANGE : 
						targetList.setArray( event.data as Array, false );
						break;
				}
				
				//Kill before it goes to dispatch event
				return;
			}
			dispatchEvent(new Event(event.type));
		}
		
		/*
		 * GETTER / SETTER
		 */
		
		public function get viewerList(): DataProvider
		{
			return _viewerList;
		}
		
		public function get cameraList(): DataProvider
		{
			return _cameraList;
		}
		
		public function get castersList(): DataProvider
		{
			return _castersList;
		}
		
		public function get localData(): Object
		{
			return _localData
		}
		
		public function get adminData(): Object
		{
			return _adminData
		}
		
		public function get connected(): Boolean
		{
			return _nc != null;
		}
	}
}