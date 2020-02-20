package org.influxis.application.vidcollaborator 
{
	//Flash Classes
	import flash.events.Event;
	import flash.net.NetConnection;
	import flash.display.DisplayObject;
	
	//Influxis Classes
	import org.influxis.flotools.core.InfluxisComponent;
	import org.influxis.as3.data.DataProvider;
	import org.influxis.as3.states.DataStates;
	import org.influxis.as3.events.SimpleEvent;
	import org.influxis.as3.events.SimpleEventConst;
	import org.influxis.as3.events.DataEvent;
	import org.influxis.as3.list.ItemStates;
	import org.influxis.as3.display.Alert;
	import org.influxis.as3.utils.handler;
	
	//VidCollaboration Classes
	import org.influxis.application.vidcollaborator.display.VideoCollaborator;
	import org.influxis.application.vidcollaborator.data.Sessions;
	import org.influxis.application.vidcollaborator.alert.NewSessionPanel;
	import org.influxis.application.vidcollaborator.alert.PasswordPanel;
	import org.influxis.application.vidcollaborator.list.SessionsList;
	
	public class VidCollaboratorAdmin extends InfluxisComponent
	{
		public static const INITIALIZED:String = "sessionInitialized";
		private static const _DEFAULT_SESSION_:String = "defaultSession01";
		private static const _SESSION_EMPTY_ALERT_:String = "sessionEmptyAlert";
		private static const _SESSIONS_ALERT_:String = "sessionAlert";
		private static const _SESSIONS_DELETE_:String = "sessionDelete";
		private static const _PASSWORD_REMOVAL_:String = "authSessionRemoval";
		private static const _PASSWORD_LOGIN_:String = "authJoinSession";
		
		private var _currentSession:Object;
		private var _sessionInitialized:Boolean;
		private var _sessions:Sessions;
		private var _sessionData:DataProvider;
		private var _sessionID:String;
		private var _sessionsEnabled:Boolean;
		private var _twitterToken:String;
		private var _facebookToken:String;
		private var _viewerLink:String;
		private var _allowRequests:Boolean = true;
		
		private var _sessionsList:SessionsList; 
		private var _vidCollab:VideoCollaborator;
		
		/*
		 * INIT API
		 */
		
		public function VidCollaboratorAdmin(): void
		{
			//We dont want the root application controlling this
			syncInstances = false;
			
			//Create and manage sessions
			_sessions = Sessions.getInstance();
			_sessionData = _sessions.dataProvider;
			_sessionData.addEventListener( DataStates.ADD, __onDataEvent );
			_sessionData.addEventListener( DataStates.UPDATE, __onDataEvent );
			_sessionData.addEventListener( DataStates.REMOVE, __onDataEvent );
			_sessionData.addEventListener( DataStates.CHANGE, __onDataEvent );	
		}
		
		/*
		 * CONNECT API
		 */
		
		override public function connect(p_nc:NetConnection):Boolean 
		{
			if ( !super.connect(p_nc) ) return false;
			_sessions.connect(p_nc);
			return true;
		}
		
		override public function close():void 
		{
			_sessions.close();
			super.close();
		}
		
		//Changes up the displayed session
		protected function onSessionChanged( value:Object ): void
		{
			if ( _currentSession == value ) return;
			
			if ( _currentSession && !value )
			{
				_vidCollab.visible = false;
				_vidCollab.session = null;
				_sessionsList.visible = true;
			}
			
			_currentSession = value;
			if ( !_currentSession ) return;
			
			_sessionsList.visible = false;
			_vidCollab.session = _currentSession;
			_vidCollab.visible = true;
			if ( !_vidCollab.parent ) addChild(_vidCollab);
		}
		
		/*
		 * PROTECTED API
		 */
		
		//Launches alert for creating new sessions
		protected function launchSessionCreate(): void
		{
			var sessionPanel:NewSessionPanel = new NewSessionPanel();
				sessionPanel.addEventListener( NewSessionPanel.CREATED, __onSessionCreated );
				sessionPanel.includeCancel = _sessionData.length > 0;
			
			Alert.launchAlertPanel( sessionPanel, getLabelAt("newSessionTitle") );
		}
		
		//Launches alert to delete sessions
		protected function launchDeleteAlert(): void
		{
			if ( !initialized || !_sessionsList.selectedItem ) return;
			
			var alertPanel:DisplayObject = Alert.alert( getLabelAt("deleteSessionAlert"), getLabelAt("deleteSessionAlertTitle"), getLabelAt("yesBtn"), getLabelAt("noBtn") );
				alertPanel.addEventListener( Alert.OK, handler(__onAlertEvent, _SESSIONS_DELETE_, _sessionsList.selectedItem) );
				alertPanel.addEventListener( Alert.CANCEL, handler(__onAlertEvent, _SESSIONS_DELETE_, _sessionsList.selectedItem) );
		}
		
		/*
		 * HANDLERS
		 */
		
		//Catches when any session data has changed from the server
		private function __onDataEvent( event:SimpleEvent ): void
		{
			switch( event.type )
			{
				case DataStates.ADD : 
					break;
				case DataStates.REMOVE : 
					break;
				case DataStates.UPDATE : 
					break;
				case DataStates.CHANGE : 
					
					//A first run just waiting for the data to initially come in so we decide what to do
					if ( !_sessionInitialized )
					{
						_sessionInitialized = true;
						_sessionID = _sessionID ? _sessionID : _sessionsEnabled ? null : _DEFAULT_SESSION_;
						
						if ( _sessionID )
						{
							//If sessions are disabled just send straight to default session
							if ( !_sessionsEnabled )
							{
								onSessionChanged({id:_sessionID})
							}else{
								//If sessions are enabled and a session ID was passed in let's make sure to take that user straight to the room
								var sessionIndex:Number = _sessionData.indexOf( "id", _sessionID );
								if ( isNaN(sessionIndex) ) 
								{
									_sessionsList.visible = true;
									dispatchEvent(new Event(INITIALIZED));
									return;
								}
								var localSessionData:Object = _sessionData.getItemAt(sessionIndex);
								if ( localSessionData.password == undefined && localSessionData.limit == 0 ) 
								{
									_sessions.joinAndAdminSession(localSessionData.id);
									_vidCollab.session = localSessionData;
								}else{
									_sessionsList.visible = true;
									dispatchEvent(new Event(INITIALIZED));
								}
							}
						}else{
							_sessionsList.visible = true;
							dispatchEvent(new Event(INITIALIZED));
							
							//If no sessionID and sessions enabled then just do first run on sessions
							var alertDisplay:DisplayObject;
							if ( _sessionData.length == 0 )
							{
								//No Rooms so notify admin to create one
								alertDisplay = Alert.alert( getLabelAt("newSessionAlert"), getLabelAt("activeSessionAlertTitle"), getLabelAt("okBtn") );
								alertDisplay.addEventListener( Alert.OK, handler(__onAlertEvent,_SESSION_EMPTY_ALERT_) );							
							}else{
								//Else we want to alert admin anyway to create a room or join an existing one
								alertDisplay = Alert.alert( getLabelAt("activeSessionAlert"), getLabelAt("activeSessionAlertTitle"), getLabelAt("createSession"), getLabelAt("joinSession") );
								alertDisplay.addEventListener( Alert.OK, handler(__onAlertEvent,_SESSIONS_ALERT_) );
								alertDisplay.addEventListener( Alert.CANCEL, handler(__onAlertEvent,_SESSIONS_ALERT_) );
							}
						}
					}
					break;
			}
		}
		
		//Handles alert callbacks
		private function __onAlertEvent( event:Event, alertType:String, ...args ): void
		{
			switch( alertType )
			{
				case _SESSION_EMPTY_ALERT_ : 
					launchSessionCreate();
					break;
				case _SESSIONS_ALERT_ : 
					if( event.type == Alert.OK ) launchSessionCreate();
					break;
				case _SESSIONS_DELETE_ : 
					if ( event.type == Alert.OK ) _sessions.removeSession( (args as Array)[0].id );
					break;
			}
		}
		
		//Handles alert when creating new sessions via panel
		private function __onSessionCreated( event:DataEvent ): void
		{
			_sessions.createNewSession( event.data.id, event.data );
		}
		
		//Handles events coming from the session list UI
		private function __onListEvents( event:Event ): void
		{
			var alertPanel:DisplayObject;
			var alertPassPanel:PasswordPanel;
			switch( event.type )
			{
				case ItemStates.ITEM_CLICK : 
					break;
				case ItemStates.ITEM_DOUBLE_CLICK :
					if ( _sessionsList.selectedItem.admin != undefined )
					{
						Alert.alert( getLabelAt("adminAlreadyInAlert"), getLabelAt("adminAlreadyInAlertTitle"), getLabelAt("okBtn") );
					}else if ( _sessionsList.selectedItem.password != undefined )	
					{
						alertPassPanel = new PasswordPanel();
						alertPassPanel.source = _sessionsList.selectedItem;
						alertPassPanel.addEventListener( PasswordPanel.AUTHORIZED, handler(__onPasswordAuthorized, _PASSWORD_LOGIN_) );
							
						Alert.launchAlertPanel( alertPassPanel, getLabelAt("passRequiredAlertTitle") );
					}else{
						_sessions.joinAndAdminSession(_sessionsList.selectedItem.id);
						onSessionChanged( _sessionsList.selectedItem );
					}
					break;
				case SessionsList.CREATE : 
					launchSessionCreate();
					break;
				case SessionsList.REMOVE : 
					if ( _sessionsList.selectedItem )
					{
						if ( _sessionsList.selectedItem.password != undefined )
						{
							alertPassPanel = new PasswordPanel();
							alertPassPanel.source = _sessionsList.selectedItem;
							alertPassPanel.addEventListener( PasswordPanel.AUTHORIZED, handler(__onPasswordAuthorized, _PASSWORD_REMOVAL_) );
								
							Alert.launchAlertPanel( alertPassPanel, getLabelAt("passRequiredAlertTitle") );
						}else{
							launchDeleteAlert();
						}
					}
					break;
			}
		}
		
		//Handles password auth coming from the password alert
		private function __onPasswordAuthorized( event:Event, alertType:String ): void
		{
			var alertPanel:PasswordPanel = event.currentTarget as PasswordPanel;
			switch( alertType )
			{
				case _PASSWORD_REMOVAL_ : 
					_sessions.removeSession( alertPanel.source.id );
					break;
				case _PASSWORD_LOGIN_ : 
					_sessions.joinAndAdminSession(alertPanel.source.id);
					onSessionChanged( alertPanel.source );
					break;
			}
		}
		
		//Handles events coming from the VidCollab UI
		private function __onVidCollbaEvent( event:Event ): void
		{
			if ( event.type == SimpleEventConst.INITIALIZED )
			{
				_vidCollab.removeEventListener( SimpleEventConst.INITIALIZED, __onVidCollbaEvent );
				dispatchEvent(new Event(INITIALIZED));
			}else{
				if( _currentSession ) _sessions.adminLeaveSession(_currentSession.id);
				onSessionChanged(null);
			}
		}
		
		/*
		 * DISPLAY API
		 */
		
		//Override createChildren call to create UI elements for this component
		override protected function createChildren():void 
		{
			super.createChildren();
			_vidCollab = new VideoCollaborator();
			_sessionsList = new SessionsList();
			_sessionsList.visible = false;
			addChild(_sessionsList);
		}
		
		//Override to prep display UI attached to the component
		override protected function childrenCreated():void 
		{
			super.childrenCreated();
			
			_vidCollab.visible = !_sessionsEnabled;
			_vidCollab.facebookToken = _facebookToken;
			_vidCollab.twitterToken = _twitterToken;
			_vidCollab.includeExit = _sessionsEnabled;
			_vidCollab.allowRequests = _allowRequests;
			_vidCollab.viewerLink = _viewerLink;
			_vidCollab.addEventListener( Event.CLOSE, __onVidCollbaEvent );
			_vidCollab.addEventListener( SimpleEventConst.INITIALIZED, __onVidCollbaEvent );
			
			_sessionsList.visible = _sessionsEnabled;
			_sessionsList.adminMode = true;
			_sessionsList.addEventListener( ItemStates.ITEM_CLICK, __onListEvents );
			_sessionsList.addEventListener( ItemStates.ITEM_DOUBLE_CLICK, __onListEvents );
			_sessionsList.addEventListener( SessionsList.CREATE, __onListEvents );
			_sessionsList.addEventListener( SessionsList.REMOVE, __onListEvents );
		}
		
		//Fires when sizing changes
		override protected function arrange():void 
		{
			super.arrange();
			
			_vidCollab.setActualSize(width, height);
			
			_sessionsList.move( paddingLeft, paddingTop );
			_sessionsList.setActualSize(width - (paddingLeft+paddingRight), height-(paddingTop+paddingBottom));
		}
		
		//Since we're using instances we dont want the parents to affect this component tree
		override public function set instance(value:String): void 
		{
			//Stop from overriding instance
			//super.instance = value;
		}
		
		/*
		 * GETTER / SETTER
		 */
		
		public function set sessionsEnabled( value:Boolean ): void
		{
			if ( _sessionsEnabled == value ) return;
			_sessionsEnabled = value;
			if ( initialized ) _vidCollab.includeExit = _sessionsEnabled;
		}
		
		public function get sessionsEnabled(): Boolean
		{
			return _sessionsEnabled;
		}
		
		public function set sessionID( value:String ): void
		{
			if ( _sessionID == value ) return;
			_sessionID = value;
		}
		
		public function get sessionID(): String
		{
			return _sessionID;
		}
		
		public function set allowRequests( value:Boolean ): void
		{
			if ( _allowRequests == value ) return;
			_allowRequests = value;
			if ( initialized ) _vidCollab.allowRequests = _allowRequests;
		}
		
		public function get allowRequests(): Boolean
		{
			return _allowRequests;
		}
		
		public function set viewerLink( value:String ): void
		{
			if ( _viewerLink == value ) return;
			_viewerLink = value;
			if ( initialized ) _vidCollab.viewerLink = _viewerLink;
		}
		
		public function get viewerLink(): String
		{
			return _viewerLink;
		}
		
		public function set twitterToken( value:String ): void
		{
			if ( _twitterToken == value ) return;
			_twitterToken = value;
			if ( initialized ) _vidCollab.twitterToken = _twitterToken;
		}
		
		public function get twitterToken(): String
		{
			return _twitterToken;
		}
		
		public function set facebookToken( value:String ): void
		{
			if ( _facebookToken == value ) return;
			_facebookToken = value;
			if ( initialized ) _vidCollab.facebookToken = _facebookToken;
		}
		
		public function get facebookToken(): String
		{
			return _facebookToken;
		}
	}
}