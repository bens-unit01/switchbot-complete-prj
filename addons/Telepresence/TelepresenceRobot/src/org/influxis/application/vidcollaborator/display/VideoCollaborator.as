package org.influxis.application.vidcollaborator.display 
{
	//Flash Classes
	import flash.display.DisplayObject;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.net.NetConnection;
	import flash.utils.setTimeout;
	import flash.net.NetGroup;
	import flash.net.GroupSpecifier;
	
	//Influxis Classes
	import org.influxis.as3.core.Display;
	import org.influxis.as3.display.Label;
	import org.influxis.as3.display.Alert;
	import org.influxis.as3.events.SimpleEventConst;
	import org.influxis.as3.events.SimpleEvent;
	import org.influxis.as3.events.DragDropEvent;
	import org.influxis.as3.managers.DragDropManager;
	import org.influxis.as3.states.BroadcastStates;
	import org.influxis.as3.states.DataStates;
	import org.influxis.as3.utils.handler;
	
	//Flotools Classes
	import org.influxis.flotools.data.MediaSettings;
	import org.influxis.flotools.core.InfluxisComponent;
	import org.influxis.flotools.display.CamWindow;
	import org.influxis.flotools.net.BWDetect;
	import org.influxis.flotools.managers.VideoThumbCacher;
	import org.influxis.flotools.managers.BroadcastManager;
	import org.influxis.flotools.containers.DisplayPositioner;
	import org.influxis.flotools.data.MediaSettings;
	
	//VideoCollaboration Classes
	import org.influxis.application.vidcollaborator.managers.VidCollaboratorManager;
	import org.influxis.application.vidcollaborator.display.videocollaboratorclasses.CollabControls;
	import org.influxis.application.vidcollaborator.display.VideoDisplay;
	import org.influxis.application.vidcollaborator.states.VidCollabStates;
	
	public class VideoCollaborator extends InfluxisComponent 
	{
		private static const _PERM_VID_CAST_ALLOWED_:String = "vidCastPermAllowed";
		
		private var _castManager:BroadcastManager;
		private var _netgroup:NetGroup;
		private var _groupSpec:GroupSpecifier;
		private var _vcm:VidCollaboratorManager;
		private var _frames:VideoThumbCacher;
		private var _dragDrop:DragDropManager;
		private var _check:BWDetect;
		private var _adminMode:Boolean;
		private var _frameSaved:Boolean;
		private var _adminStreamStarted:Boolean;
		private var _session:Object;
		private var _twitterToken:String;
		private var _facebookToken:String;
		private var _includeExit:Boolean;
		private var _viewerLink:String;
		private var _allowRequests:Boolean = true;
		
		private var _controls:CollabControls;
		private var _camWindow:CamWindow;
		private var _windowHolder:VideoDisplay;
		private var _mainWindow:DisplayObject;
		private var _statusLabel:Label;
		
		/*
		 * INIT API
		 */
		
		public function VideoCollaborator( adminMode:Boolean = true ): void
		{
			//Desktop support only does not work for mobile :)
			MediaSettings.USE_ECHO_CANCELLATION = !Display.IS_MOBILE;
			
			_adminMode = adminMode;
			_dragDrop = DragDropManager.getInstance();
			
			//If not an admin but not in auto mode then force auto mode :)
			var mediaSettings:MediaSettings = MediaSettings.getInstance();
			if ( !_adminMode && !mediaSettings.autoMode )
			{
				mediaSettings.loadPreset(MediaSettings.MEDIUM);
				mediaSettings.autoMode = true;
			}
			
			//Create cast manager used for doing broadcasts
			_castManager = new BroadcastManager();
			_castManager.addEventListener( SimpleEventConst.STATE, __onCastManagerEvent );
			_castManager.addEventListener( BroadcastManager.NETSTREAM_CHANGE, __onCastManagerEvent );
			
			super();
		}
		
		/*
		 * CONNECT API
		 */
		
		protected function onSessionChanged( value:Object ): void
		{
			if ( _session == value || (_session && value && _session.id == value.id) ) return;
			
			_session = value;
			instance = !_session ? null : _session.id;
		}
		
		override protected function instanceClose():void 
		{
			super.instanceClose();
			
			//Close out rtmfp comps if used
			if ( _groupSpec )
			{
				if ( initialized )
				{
					_windowHolder.netGroup = null;
					_windowHolder.groupSpec = null;
				}
				
				_castManager.groupSpec = null;
				_castManager.netGroup = null;
				
				_netgroup.close(); _netgroup = null;
				_groupSpec = null;
			}
			
			//Close all supporting services
			if ( _castManager.state == BroadcastStates.BROADCASTING ) _castManager.stopBroadcast();
			_castManager.netConnection = null;
			
			//If the viewer is viewing the admin stream then close that out as well
			__startAdminStream(false);
			
			//Close BW Detect
			if ( _check )
			{
				if ( _camWindow ) _camWindow.bwChecker = null;
				_check.close();
				_check = null;
			}
			
			refreshStatusDisplay();
			
			if ( _frameSaved && _vcm.localData ) 
			{
				_frameSaved = false;
				_frames.removeImageAt(_vcm.localData.thumbName);
			}
			
			_frames.close();
			_frames = null;
			
			//Remove old listeners
			_vcm.castersList.removeEventListener( DataStates.ADD, __onActiveListChange );
			_vcm.castersList.removeEventListener( DataStates.REMOVE, __onActiveListChange );
			_vcm.castersList.removeEventListener( DataStates.CHANGE, __onActiveListChange );
			
			_vcm.removeEventListener( VidCollaboratorManager.LOCAL_DATA_UPDATE, __onVidManagerEvent );
			_vcm.removeEventListener( VidCollaboratorManager.ADMIN_UPDATE, __onVidManagerEvent );
			_vcm.removeEventListener( VidCollaboratorManager.MESSAGE_REQUEST, __onVidManagerMessageRequest );
			
			_vcm.close();
			_vcm = null;
			VidCollaboratorManager.destroy(instance);
		}
		
		override protected function instanceChange():void 
		{
			super.instanceChange();
			
			//Main VidCollab engine on the server
			_vcm = VidCollaboratorManager.getInstance(_session.id);
			_vcm.addEventListener( VidCollaboratorManager.LOCAL_DATA_UPDATE, __onVidManagerEvent );
			_vcm.addEventListener( VidCollaboratorManager.ADMIN_UPDATE, __onVidManagerEvent );
			_vcm.addEventListener( VidCollaboratorManager.MESSAGE_REQUEST, __onVidManagerMessageRequest );
			
			//Keep track of the casters
			_vcm.castersList.addEventListener( DataStates.ADD, __onActiveListChange );
			_vcm.castersList.addEventListener( DataStates.REMOVE, __onActiveListChange );
			_vcm.castersList.addEventListener( DataStates.CHANGE, __onActiveListChange );
			
			//Used to save vid thumbs
			_frames = VideoThumbCacher.getInstance(_session.id, _adminMode);
			
			//Set limit if the component is already initialized
			if( initialized ) _camWindow.qualityLimitationLevel = _adminMode ? 2 : _vcm.castersList.length + 1;
			
			//If rtmfp is passed in then cast using rtmfp instead (this assumes all installs are running via rtmfp)
			if ( _nc.uri.indexOf("rtmfp") != -1 )
			{
				_groupSpec = new GroupSpecifier(instance);
				_groupSpec.multicastEnabled = true;
				_groupSpec.serverChannelEnabled = true;
				
				_netgroup = new NetGroup( _nc, _groupSpec.groupspecWithAuthorizations() );
				_castManager.groupSpec = _groupSpec;
				_castManager.netGroup = _netgroup;
				
				//Add group spec to window holder to playback group stream
				if ( initialized )
				{
					_windowHolder.groupSpec = _groupSpec;
					_windowHolder.netGroup = _netgroup;	
				}
			}
			
			_castManager.netConnection = _nc;
			_check = new BWDetect(_nc);
			
			if ( connected )
			{
				_vcm.connect( _nc, _adminMode );
				_frames.connect(_nc);
			}
			
			if ( initialized ) 
			{
				_camWindow.doCameraInit();
				_camWindow.bwChecker = _check;
				refreshMeasures();
				__refreshAdminStream();
				refreshStatusDisplay();
			}
		}
		
		/*
		 * PROTECTED API
		 */
		
		protected function onAdminModeChange( value:Boolean ): void
		{
			if ( _adminMode == value ) return;
			
			_adminMode = value;
			if ( initialized ) 
			{
				_controls.adminMode = _adminMode;
				_controls.camWindow = _adminMode ? null : _camWindow;
				_windowHolder.adminMode = _adminMode;
				_camWindow.qualityLimitationLevel = _adminMode ? 2 : _vcm.castersList.length + 1;
			}
		}
		
		protected function changeMainDisplayWindow( value:DisplayObject ): void
		{
			if ( _mainWindow == value ) return;
			
			_mainWindow = value;
			_controls.visible = _mainWindow != _statusLabel;
			if ( initialized ) _windowHolder.mainWindow = _mainWindow;
			invalidateDisplayList();
		}
		
		protected function updateSavedFrame(): void
		{
			if ( _frameSaved || !connected || !initialized || _vcm.localData == null ) return;
			
			_frameSaved = true
			if ( Display.IS_MOBILE )
			{
				_frames.saveCameraImage( _vcm.localData.thumbName, _camWindow.camera, 80, 64, 36 );
			}else{
				_frames.saveCameraImage( _vcm.localData.thumbName, _camWindow.camera, 80, 64, 36, 3000, 0 );
			}
		}
		
		protected function refreshStatusDisplay(): void
		{
			if ( !initialized ) return;
			
			_statusLabel.text = getLabelAt( !connected || !_vcm ? VidCollabStates.CONNECTING : 
											_vcm.adminData == null ? VidCollabStates.NO_ADMIN : VidCollabStates.ADMIN_PRESENT);
		}
		
		/*
		 * PRIVATE API
		 */
		
		//Starts and stops the admin viewing stream (Viewer Mode Only)
		private function __startAdminStream( start:Boolean = true ): void
		{
			if ( _adminMode || _adminStreamStarted == start ) return;
			
			_adminStreamStarted = start;
			
			//If active then create window so stream refresh runs properly
			if( _adminStreamStarted ) changeMainDisplayWindow(new LiveUserWindow());
			__refreshAdminStream();
			
			//If not active wait for it to close the admin stream before putting in the label again
			if( !_adminStreamStarted ) changeMainDisplayWindow(_statusLabel);
		}
		
		//Refreshes the admin stream in case name or connection changes (Viewers Only)
		private function __refreshAdminStream(): void
		{
			if ( !initialized || !connected || _adminMode ) return;
			
			var adminWindow:LiveUserWindow = _windowHolder.mainWindow as LiveUserWindow;
			if ( adminWindow )
			{
				if ( _adminStreamStarted )
				{
					if ( _vcm.adminData && _vcm.adminData.activeCaster == true ) 
					{
						adminWindow.streamName = _vcm.adminData.streamName + ".mp4";
						if( !adminWindow.connected ) adminWindow.connect(_nc);
					}
				}else if ( adminWindow.streamName )
				{
					adminWindow.streamName = null;
					adminWindow.close();
				}
			}
		}
		 
		/*
		 * HANDLERS
		 */
		
		//Handles events coming from the controls
		private function __onControlsEvent( event:Event ): void
		{
			if ( event.type == CollabControls.BROADCAST_CHANGE )
			{
				if ( _adminMode )
				{
					//In Admin mode we cast or stop the stream when they hit the publish button
					if ( _controls.publishActive )
					{
						_castManager.startBroadcast();
					}else{
						_castManager.stopBroadcast();
						
						//If the admin stops casting then you basically clear all streams and camera requests
						_vcm.clearSession();
					}
					_vcm.registerAdminPublish(_controls.publishActive);
				}else{
					//In Viewer mode we dont publish we just update user status to the admin and save their frame
					if ( _controls.publishActive ) 
					{
						updateSavedFrame();
					}else{
						_frameSaved = false;
						_frames.removeImageAt(_vcm.localData.thumbName);
					}
					
					//Unregister cam and stop cast if casting
					_vcm.registerCamera(_controls.publishActive);
					if ( _castManager.state == BroadcastStates.BROADCASTING ) _castManager.stopBroadcast();
				}
			}
		}
		
		//Handles events coming from the broadcast manager
		private function __onCastManagerEvent( event:Event ): void
		{
			if ( event.type == SimpleEventConst.STATE )
			{
				if ( initialized ) _controls.state = _castManager.state;
			}else if ( event.type == BroadcastManager.NETSTREAM_CHANGE )
			{
				if ( initialized )
				{
					_camWindow.netstream = _castManager.netStream;
					_castManager.metaData = _camWindow.streamMetaData;
				}
			}
		}
		
		//Handles events coming from the CameraWindow
		private function __onCamWindowEvent( event:Event ): void
		{
			if ( event.type == Event.CHANGE )
			{
				//updateSavedFrame();
				_castManager.camera = _camWindow.camera;
				_castManager.microphone = _camWindow.microphone;
			}
		}
		
		//Handles events coming from the VidCollaborator Manager on the server
		private function __onVidManagerEvent( event:Event ): void
		{
			if ( event.type == VidCollaboratorManager.LOCAL_DATA_UPDATE )
			{
				//Insert stream name to cast manager (we append mp4 because we know by default that h.264 is supported (Desktop Only))
				_castManager.streamName = _vcm.localData.streamName + ".mp4";
				
				//If camera was disabled by admin or system make sure to update local user
				if ( initialized && !_adminMode && _controls.publishActive && _vcm.localData.cameraEnabled != true ) 
				{
					_controls.publishActive = false;
					if ( _castManager.state == BroadcastStates.BROADCASTING ) _castManager.stopBroadcast();
				}
			}else if ( event.type == VidCollaboratorManager.ADMIN_UPDATE )
			{
				//trace("__onVidManagerEvent: " + event.type, _vcm.adminData, _vcm.adminData.streamName, _vcm.adminData.activeCaster );
				if ( !_adminMode ) 
				{
					refreshStatusDisplay();
					__startAdminStream(_vcm.adminData == null?false:_vcm.adminData.activeCaster == true);
				}
			}
		}
		
		private function __onAlertEvent( event:Event, alertType:String ): void
		{
			//trace("__onAlertEvent: " + event.type, alertType );
			switch( alertType )
			{
				case _PERM_VID_CAST_ALLOWED_ : 
					
					if ( event.type == Alert.OK )
					{
						if ( _vcm.castersList.length == VidCollaboratorManager.ACTIVE_CASTERS_LIMIT )
						{
							Alert.alert( getLabelAt("windowLimitReachedViewer"), getLabelAt("limitReachedTitle"), getLabelAt("okBtn"));
						}else{
							//Publish local video
							_castManager.startBroadcast();
							
							//Update user in cast list
							_vcm.joinPublishGroup(true);
							
							//Update admin on status
							_vcm.sendMessageRequest( _vcm.adminData.id, { type:VidCollaboratorManager.VIEWER_VIDEO_RESPONSE, videoBroadcast:true } );
						}
					}else{
						_vcm.sendMessageRequest( _vcm.adminData.id, { type:VidCollaboratorManager.VIEWER_VIDEO_RESPONSE, startVideoRequest:false } );
					}
					break;
			}
		}
		
		//Handles events coming from the VidCollaborator Manager on the server
		private function __onVidManagerMessageRequest( event:SimpleEvent ): void
		{
			//trace("__onVidManagerMessageRequest: " + event.type);
			if ( event.type == VidCollaboratorManager.MESSAGE_REQUEST )
			{
				var msg:Object = event.data.message;
				//trace("__onVidManagerMessageRequest2: " + msg.type);
				switch( msg.type )
				{
					case VidCollaboratorManager.ADMIN_VIDEO_REQUEST : 
						//Only answer to response if you are the viewer
						if ( !_adminMode )
						{
							//Fired when a admin sends request for user video
							
							//For now were going to ignore the alert that is going to be here and instead just cast directly
							if ( msg.startVideoRequest == true )
							{
								var alertDisplay:DisplayObject = Alert.alert( getLabelAt("viewerCastPermission"), getLabelAt("viewerCastPermissionTitle"), getLabelAt("yesBtn"), getLabelAt("noBtn") ); 
									alertDisplay.addEventListener( Alert.OK, handler(__onAlertEvent, _PERM_VID_CAST_ALLOWED_) );
									alertDisplay.addEventListener( Alert.CANCEL, handler(__onAlertEvent, _PERM_VID_CAST_ALLOWED_) );
									
							}else{
								_castManager.stopBroadcast();
								//_vcm.sendMessageRequest( _vcm.adminData.id, {type:VidCollaboratorManager.VIEWER_VIDEO_RESPONSE, videoStopped:true} );
							}
						}
						break;
					case VidCollaboratorManager.VIEWER_VIDEO_RESPONSE : 
						//Only answer to response if you are the admin
						if ( _adminMode )
						{
							//Ye got denied sucka sorry :/
							if ( msg.startVideoRequest == false )
							{
								Alert.alert( getLabelAt("viewerCastPermissionDenied"), getLabelAt("viewerCastPermissionDeniedTitle"), getLabelAt("okBtn") );
							}
						}
						break;
				}
			}
		}
		
		private function __onActiveListChange( event:Event ): void
		{
			if ( !initialized || _adminMode ) return;
			_camWindow.qualityLimitationLevel = adminMode ? 2 : _vcm.castersList.length + 1;
		}
		
		private function __onItemDropped( event:DragDropEvent ): void
		{
			//trace("__onItemDropped: " + event.type);
			if ( event.type == DragDropEvent.DRAG_DROP )
			{
				if ( _vcm.castersList.length == VidCollaboratorManager.ACTIVE_CASTERS_LIMIT )
				{
					Alert.alert( getLabelAt("windowLimitReachedAdmin"), getLabelAt("limitReachedTitle"), getLabelAt("okBtn") );
				}else{
					_vcm.sendMessageRequest( event.data.id, { type:VidCollaboratorManager.ADMIN_VIDEO_REQUEST, startVideoRequest:true } );
				}
			}
		}
		
		/*
		 * DISPLAY API
		 */
		
		override protected function createChildren():void 
		{
			super.createChildren();
			
			//Displays the Camera
			_camWindow = new CamWindow();
			
			//Controls for handling UI events
			_controls = new CollabControls();
			
			//Holds the main window and its live windows for users broadcasting
			_windowHolder = new VideoDisplay();
			_statusLabel = new Label("statusLabel");
			
			addChildren(_windowHolder, _controls);
		}
		
		override protected function childrenCreated():void 
		{
			super.childrenCreated();
			
			//Configre Camera and controls
			_controls.adminMode = adminMode;
			_controls.includeExit = _includeExit;
			_controls.allowRequests = _allowRequests;
			_controls.addEventListener( CollabControls.BROADCAST_CHANGE, __onControlsEvent );
			_controls.displayPositioner = _windowHolder.displayPositioner;
			_controls.viewerLink = _viewerLink;
			_controls.twitterToken = _twitterToken;
			_controls.facebookToken = _facebookToken;
			
			_camWindow.stageVideoEnabled = false;
			_camWindow.addEventListener( Event.CHANGE, __onCamWindowEvent );
			
			//Make sure you set main window based on admin mode
			if ( _adminMode )
			{
				changeMainDisplayWindow(_camWindow);
				_windowHolder.adminMode = true;
				
				//Register drag event to notify when a item has been dropped on it
				_dragDrop.registerForDragEvents(_camWindow);
				_camWindow.addEventListener( DragDropEvent.DRAG_DROP, __onItemDropped );
			}else{
				refreshStatusDisplay();
				
				//Instead of attaching the camera window to the holder we use a LiveUserWindow comp instead to show the admin stream
				changeMainDisplayWindow(_adminStreamStarted?new LiveUserWindow():_statusLabel);
				__refreshAdminStream();
				
				//In viewer mode we attach the camera to the comp but we dont make it visible (have to think about this one)
				_camWindow.visible = false;
				
				//Want to make sure we limit the casting ability of viewers so they dont take all the bw
				if( _vcm ) _camWindow.qualityLimitationLevel = _adminMode ? 2 : _vcm.castersList.length + 1;
				_controls.camWindow = _camWindow;
			}
			
			//Add groupspec to window holder if available
			if ( _groupSpec )
			{
				_windowHolder.groupSpec = _groupSpec;
				_windowHolder.netGroup = _netgroup;	
			}
			
			//Start camera and add bw detection
			if ( connected ) 
			{
				setTimeout( _camWindow.doCameraInit, 10 );
				_camWindow.bwChecker = _check;
			}
		}
		
		override protected function arrange():void 
		{
			super.arrange();
			_controls.setActualSize(width, height);
			_controls.addEventListener( Event.CLOSE, dispatchEvent );
			_windowHolder.setActualSize( width, height - (_controls.visible?_controls.controlsHeight:0) );
		}
		
		/*
		 * GETTER / SETTER
		 */
		
		public function set adminMode( value:Boolean ): void
		{
			onAdminModeChange(value);
		}
		
		public function get adminMode(): Boolean
		{
			return _adminMode;
		}
		
		public function set session( value:Object ): void
		{
			if ( _session == value ) return;
			onSessionChanged(value);
		}
		
		public function get session(): Object
		{
			return _session;
		}
		
		public function set includeExit( value:Boolean ): void
		{
			if ( _includeExit == value ) return;
			_includeExit = value;
			if ( initialized ) _controls.includeExit = _includeExit;
		}
		
		public function get includeExit(): Boolean
		{
			return _includeExit;
		}
		
		public function set allowRequests( value:Boolean ): void
		{
			if ( _allowRequests == value ) return;
			_allowRequests = value;
			if ( initialized ) _controls.allowRequests = _allowRequests;
		}
		
		public function get allowRequests(): Boolean
		{
			return _allowRequests;
		}
		
		public function set viewerLink( value:String ): void
		{
			if ( _viewerLink == value ) return;
			_viewerLink = value;
			if ( initialized ) _controls.viewerLink = _viewerLink;
		}
		
		public function get viewerLink(): String
		{
			return _viewerLink;
		}
		
		public function set twitterToken( value:String ): void
		{
			if ( _twitterToken == value ) return;
			_twitterToken = value;
			if ( initialized ) _controls.twitterToken = _twitterToken;
		}
		
		public function get twitterToken(): String
		{
			return _twitterToken;
		}
		
		public function set facebookToken( value:String ): void
		{
			if ( _facebookToken == value ) return;
			_facebookToken = value;
			if ( initialized ) _controls.facebookToken = _facebookToken;
		}
		
		public function get facebookToken(): String
		{
			return _facebookToken;
		}
	}
}