package org.influxis.application.vidcollaborator 
{
	//Flash Classes
	import flash.net.NetConnection;
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	//Influxis Classes
	import org.influxis.flotools.core.InfluxisComponent;
	import org.influxis.as3.display.Alert;
	import org.influxis.as3.data.DataProvider;
	import org.influxis.as3.events.SimpleEvent;
	import org.influxis.as3.events.SimpleEventConst;
	import org.influxis.as3.events.DataEvent;
	import org.influxis.as3.states.DataStates;
	import org.influxis.as3.list.ItemStates;
	import org.influxis.as3.utils.handler;
	
	//VidCollaboration Classes
	import org.influxis.application.vidcollaborator.display.VideoCollaborator;
	import org.influxis.application.vidcollaborator.data.Sessions;
	import org.influxis.application.vidcollaborator.list.SessionsList;
	import org.influxis.application.vidcollaborator.alert.PasswordPanel;
	
	public class VidCollaboratorViewer extends InfluxisComponent
	{
		public static const INITIALIZED:String = "sessionInitialized";
		private static const _DEFAULT_SESSION_:String = "defaultSession01";
		private static const _SESSION_EMPTY_ALERT_:String = "sessionEmptyAlert";
		private static const _SESSIONS_ALERT_:String = "sessionAlert";
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
		
		public function VidCollaboratorViewer(): void
		{
			//We dont want the root application controlling this
			syncInstances = false;
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
		
		public function updateSession( value:Object ): void
		{
			if ( !value )
			{
				onSessionChanged(null);
				_sessions.leaveSession();
			}else{
				_sessions.joinSession(value.id);
				onSessionChanged(value);
			}
		}
		
		/*
		 * HANDLERS
		 */
		
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
					if ( !_sessionInitialized )
					{
						_sessionInitialized = true;
						var localSessionData:Object;
						_sessionID = _sessionID ? _sessionID : _sessionsEnabled ? null : _DEFAULT_SESSION_;
						
						//If sessions are not enabled then default to the default session
						if ( !_sessionsEnabled )
						{
							onSessionChanged({id:_sessionID});
						}else if ( _sessionID && _sessionData.length > 0 )
						{
							//If user passed in session ID then its ok as long as session does not have limit or pass
							var sessionIndex:Number = _sessionData.indexOf( "id", _sessionID );
							if ( isNaN(sessionIndex) ) 
							{
								_sessionsList.visible = true;
								dispatchEvent(new Event(INITIALIZED));
								return;
							}
							
							localSessionData = _sessionData.getItemAt(sessionIndex);
							if ( localSessionData.password == undefined && localSessionData.limit == 0 ) 
							{
								updateSession(localSessionData);
							}else{
								_sessionsList.visible = true;
								dispatchEvent(new Event(INITIALIZED));
							}
						}else if ( _sessionData.length == 1 )
						{
							//If there is only one session then simply just log them straight in
							localSessionData = _sessionData.getItemAt(0);
							if ( localSessionData.password == undefined && localSessionData.limit == 0 ) updateSession(localSessionData);
						}else{
							_sessionsList.visible = true;
							dispatchEvent(new Event(INITIALIZED));
						}
					}
					break;
			}
		}
		
		private function __onSessionCreated( event:DataEvent ): void
		{
			_sessions.createNewSession( event.data.id, event.data );
		}
		
		private function __onListEvents( event:Event ): void
		{
			var alertPanel:DisplayObject;
			var alertPassPanel:PasswordPanel;
			switch( event.type )
			{
				case ItemStates.ITEM_DOUBLE_CLICK : 
					var viewerData:DataProvider = _sessions.viewerDataProvider.getItemAt(_sessionsList.selectedItem.id) as DataProvider;
					if ( !viewerData || _sessionsList.selectedItem.limit < 1 || viewerData.length < _sessionsList.selectedItem.limit )
					{
						if ( _sessionsList.selectedItem.password != undefined )	
						{
							alertPassPanel = new PasswordPanel();
							alertPassPanel.source = _sessionsList.selectedItem;
							alertPassPanel.addEventListener( PasswordPanel.AUTHORIZED, handler(__onPasswordAuthorized, _PASSWORD_LOGIN_) );
								
							Alert.launchAlertPanel( alertPassPanel, getLabelAt("passRequiredAlertTitle") );
						}else {
							updateSession(_sessionsList.selectedItem);
						}
					}else{
						Alert.alert( getLabelAt("sessionMaxedAlert"), getLabelAt("sessionMaxedAlertTitle"), getLabelAt("okBtn") );
					}
					break;
			}
		}
		
		private function __onPasswordAuthorized( event:Event, alertType:String ): void
		{
			var alertPanel:PasswordPanel = event.currentTarget as PasswordPanel;
			switch( alertType )
			{
				case _PASSWORD_LOGIN_ : 
					updateSession(alertPanel.source);
					break;
			}
		}
		
		private function __onVidCollbaEvent( event:Event ): void
		{
			if ( event.type == SimpleEventConst.INITIALIZED )
			{
				_vidCollab.removeEventListener( SimpleEventConst.INITIALIZED, __onVidCollbaEvent );
				dispatchEvent(new Event(INITIALIZED));
			}else{
				updateSession(null);
			}
			
		}
		
		/*
		 * DISPLAY API
		 */
		
		override protected function createChildren():void 
		{
			super.createChildren();
			
			_vidCollab = new VideoCollaborator(false);
			_sessionsList = new SessionsList();
			_sessionsList.visible = false;
			
			addChild(_sessionsList);
		}
		
		override protected function childrenCreated():void 
		{
			super.childrenCreated();
			_vidCollab.facebookToken = _facebookToken;
			_vidCollab.twitterToken = _twitterToken;
			_vidCollab.includeExit = _sessionsEnabled;
			_vidCollab.viewerLink = _viewerLink;
			_vidCollab.addEventListener( Event.CLOSE, __onVidCollbaEvent );
			_vidCollab.addEventListener( SimpleEventConst.INITIALIZED, __onVidCollbaEvent );
			
			_sessionsList.adminMode = false;
			_sessionsList.addEventListener( ItemStates.ITEM_DOUBLE_CLICK, __onListEvents );
		}
		
		override protected function arrange():void 
		{
			super.arrange();
			
			_vidCollab.setActualSize(width, height);
			
			_sessionsList.move( paddingLeft, paddingTop );
			_sessionsList.setActualSize(width - (paddingLeft+paddingRight), height-(paddingTop+paddingBottom));
		}
		
		/*
		 * GETTER / SETTER
		 */
		
		override public function set instance(value:String):void 
		{
			//Stop from overriding instance
			//super.instance = value;
		}
		
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