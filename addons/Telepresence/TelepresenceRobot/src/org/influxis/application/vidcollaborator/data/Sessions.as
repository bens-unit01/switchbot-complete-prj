package org.influxis.application.vidcollaborator.data 
{
	//Flash Classes
	import flash.events.EventDispatcher;
	import flash.net.NetConnection;
	
	//Influxis Classes
	import org.influxis.as3.net.ClientSideCallHandler;
	import org.influxis.as3.states.DataStates;
	import org.influxis.as3.data.DataProvider;
	import org.influxis.as3.data.HashTable;
	
	public class Sessions extends EventDispatcher
	{
		private static const _CALL_PREFIX_:String = "VidCollaboratorSessions:static";
		private static var _ses:Sessions;
		
		private var _nc:NetConnection;
		private var _clsh:ClientSideCallHandler;
		private var _sessions:DataProvider;
		private var _viewerSessionLists:HashTable;
		
		/*
		 * INIT API
		 */
		
		public function Sessions(): void
		{
			super();
			
			_clsh = ClientSideCallHandler.getInstance();
			_clsh.addPath( "VidCollaboratorSessions", { __onServerEvent:__onServerEvent } );
			_sessions = new DataProvider();
			_viewerSessionLists = new HashTable();
		}
		
		/*
		 * SINGLETON
		 */
		
		public static function getInstance(): Sessions
		{
			if ( !_ses ) _ses = new Sessions();
			return _ses;
		}
		 
		public static function destroy(): void
		{
			_ses.close();
			_ses = null;
		}
		
		/*
		 * CONNECT API
		 */
		
		public function connect( netConnection:NetConnection ): Boolean
		{
			if ( netConnection == null ) return false;
			
			//Close existing sessions
			if ( _nc ) close();
			
			//Save ref and connect to server end
			_nc = netConnection;
			_nc.call( _CALL_PREFIX_ +".connect?clientInfo", null );
			return true;
		}
		 
		public function close(): void
		{
			_nc.call( _CALL_PREFIX_+".close", null );
			
			//Clear and close session data
			_sessions.clear();
			_nc = null;
		}
		
		/*
		 * PUBLIC API
		 */
		
		public function createNewSession( instanceName:String, data:Object ): void
		{
			if ( !instanceName || !data ) return;
			_nc.call( _CALL_PREFIX_+".createNewSession?clientInfo", null, instanceName, data );
		}
		
		public function getSessionAt( instanceName:String ): Object
		{
			return !instanceName ? null : _sessions.getItemAt(_sessions.indexOf( "id", instanceName ));
		}
		
		public function removeSession( instanceName:String ): void
		{
			if ( !instanceName ) return;
			_nc.call( _CALL_PREFIX_+".removeSession", null, instanceName );
		}
		
		public function joinAndAdminSession( instanceName:String ): void
		{
			if ( !instanceName ) return;
			_nc.call( _CALL_PREFIX_+".joinAndAdminSession?clientInfo", null, instanceName );
		}
		
		public function adminLeaveSession( instanceName:String, deleteSession:Boolean = false ): void
		{
			if ( !instanceName ) return;
			_nc.call( _CALL_PREFIX_+".adminLeaveSession?clientInfo", null, instanceName, deleteSession );
		}
		
		public function joinSession( instanceName:String, data:Object = null ): void
		{
			if ( !instanceName ) return;
			_nc.call( _CALL_PREFIX_+".joinSession?clientInfo", null, instanceName, data );
		}
		
		public function leaveSession(): void
		{
			_nc.call( _CALL_PREFIX_ +".leaveSession?clientInfo", null );
		}
		
		/*
		 * HANDLERS
		 */
		
		private function __onServerEvent( event:Object ): void 
		{
			//trace("__onServerEvent: " + event.type, event.viewerList);
			if ( event.viewerList == true )
			{	
				var targetList:DataProvider;
				if ( event.id != undefined )
				{
					if ( !_viewerSessionLists.exists(event.id) ) _viewerSessionLists.addItemAt(event.id, new DataProvider);
					targetList = _viewerSessionLists.getItemAt(event.id) as DataProvider;
				}
				
				//trace("__onServerEvent2: " + event.type, event.id, targetList);
				switch( String(event.type) )
				{
					case DataStates.ADD :
						targetList.addItem( event.data );
						break;
					case DataStates.REMOVE :
						//trace("__onServerEvent3: " + event.data.id, targetList.indexOf("id", event.data.id) );
						targetList.removeItemAt( targetList.indexOf("id", event.data.id) );
						//trace("__onServerEvent4: " + targetList.length );
						break;
					case DataStates.UPDATE :
						//trace("__onServerEvent3: " + event.data.id, targetList.indexOf("id", event.data.id) );
						targetList.updateItemAt( targetList.indexOf("id", event.data.id), event.data );
						break;
					case DataStates.CHANGE :
						for ( var i:String in event.data )
						{
							targetList = new DataProvider();
							//trace("__onServerEvent3: " + i, event.data[i] );
							targetList.setArray( event.data[i] == undefined ? new Array() : event.data[i] as Array, false );
							_viewerSessionLists.addItemAt( i, targetList );
						}		
						break;
				}
			}else{
				switch( String(event.type) )
				{
					case DataStates.ADD :
						_sessions.addItem( event.data );
						break;
					case DataStates.REMOVE :
						_sessions.removeItemAt( _sessions.indexOf("id", event.id) );
						break;
					case DataStates.UPDATE :
						_sessions.updateItemAt( _sessions.indexOf("id", event.id), event.data );
						break;
					case DataStates.CHANGE :
						_sessions.setArray( event.data == undefined ? new Array() : event.data as Array, false );
						break;
				}
			}
		}
		
		/*
		 * GETTER / SETTER
		 */
		
		public function get dataProvider(): DataProvider
		{
			return _sessions;
		}
		
		public function get viewerDataProvider(): HashTable
		{
			return _viewerSessionLists;
		}
	}
}