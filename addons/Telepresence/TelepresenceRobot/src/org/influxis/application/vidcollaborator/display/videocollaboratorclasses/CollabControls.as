package org.influxis.application.vidcollaborator.display.videocollaboratorclasses 
{
	//Flash Classes
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.DisplayObject;
	import flash.utils.setTimeout;
	import flash.utils.clearTimeout;
	
	//Influxis Classes
	import org.influxis.as3.core.Display;
	import org.influxis.as3.display.Button;
	import org.influxis.as3.display.StyleCanvas;
	import org.influxis.as3.display.StyleComponent;
	import org.influxis.as3.display.Alert;
	import org.influxis.as3.core.infx_internal;
	import org.influxis.as3.states.BroadcastStates;
	import org.influxis.as3.utils.SizeUtils;
	import org.influxis.as3.utils.ScreenScaler;
	import org.influxis.as3.states.SizeStates;
	import org.influxis.as3.utils.HTTPUtil;
	
	//Flotools Classes
	import org.influxis.flotools.core.InfluxisComponent;
	import org.influxis.flotools.containers.DisplayPositioner;
	import org.influxis.flotools.display.CamWindow;
	
	//VidCollaborator Classes
	import org.influxis.application.vidcollaborator.display.videocollaboratorclasses.collabcontrolsclasses.*;
	
	public class CollabControls extends InfluxisComponent
	{
		use namespace infx_internal;
		public static const BROADCAST_CHANGE:String = "broadcastChange";
		private static const _DEFAULT_SESSION_:String = "defaultSession01";
		private static const _SHARE_ABUSE_LIMIT_:int = 5;
		private static const _SHARE_ABUSE_WAIT_:int = 5000;
		
		private var _sState:String;
		private var _bAdminMode:Boolean;
		private var _nUserCount:uint;
		private var _displayPosition:DisplayPositioner;
		private var _publishActive:Boolean;
		private var _twitterToken:String;
		private var _facebookToken:String;
		private var _camWindow:CamWindow;
		private var _includeExit:Boolean;
		private var _allowRequests:Boolean = true;
		private var _viewerLink:String;
		private var _viewerPublishActive:Object;
		private var _publishBtnCheck:Number;
		private var _shareAbuseWarned:Boolean;
		private var _shareAbuseCount:Number;
		private var _shareAbuseTimeStamp:Number;
		private var _shareAbuseBan:Boolean; 
		
		private var _controlsBG:InteractiveObject
		private var _settingsUI:SettingsUI;
		private var _shareUI:ShareUI;
		
		private var _userIconList:UserIconList;
		private var _userCount:UserCount;
		private var _screenOptions:ScreenOptions;
		private var _camPreview:CamPreview;
		
		private var _publishBtn:Button;
		private var _settingsBtn:Button;
		private var _shareBtn:Button;
		
		/*
		 * CONNECTED API
		 */
		
		override protected function instanceClose():void 
		{
			super.instanceClose();
			
			publishActive = false;
			_settingsUI.visible = false;
			invalidateDisplayList();
		}
		
		override protected function instanceChange():void 
		{
			super.instanceChange();
			if( initialized ) refreshPostInfo();
		}
		
		/*
		 * PROTECTED API
		 */
		
		protected function onStateChange(): void
		{
			if ( !initialized ) return;
		}
		 
		protected function onAdminModeChanged(): void
		{
			refreshViewOptions();
			if ( initialized ) _settingsUI.adminMode = adminMode;
		}
		
		protected function refreshViewOptions(): void
		{
			if ( !initialized ) return;
			
			_publishBtn.label = getLabelAt(_publishActive ? "stopBtn" : (_bAdminMode ? "broadcastBtn" : "shareCamBtn"));
			_settingsBtn.visible = _bAdminMode ? true : _allowRequests;
			_publishBtn.visible = _shareAbuseBan ? false : _bAdminMode ? true : _allowRequests;
			_shareBtn.visible = true;
			_screenOptions.visible = _bAdminMode ? _screenOptions.visible : false;
			_userCount.visible = _bAdminMode;
			_userIconList.visible = _bAdminMode && _allowRequests;
		}
		
		protected function refreshPostInfo(): void
		{
			var currentURL:String;
			if ( _viewerLink )
			{
				currentURL = _viewerLink;
			}else{
				currentURL = HTTPUtil.getUrl() + (instance && instance != _DEFAULT_SESSION_ ? "?sessionID=" + instance : "");
				currentURL = currentURL.indexOf("vidcollaborator_admin.html") > -1 ? currentURL.replace( /vidcollaborator_admin\.html/gi, "vidcollaborator_viewer.html" ) : currentURL;
			}
			
			_shareUI.defaultPostLink = currentURL;
			_shareUI.defaultPostMessage = getLabelAt("defaultSocialPostMessage");
		}
		
		/*
		 * PRIVATE API
		 */
		
		private function __stillHit( display:DisplayObject ): Boolean
		{
			if ( !display ) return false;
			var bHit:Boolean = display.hitTestPoint( Display.STAGE.mouseX, Display.STAGE.mouseY, true );
			return bHit;
		}
		
		private function __doViewerPublishCmd(): void
		{
			if ( isNaN(_publishBtnCheck) ) return;
			
			_publishBtnCheck = NaN;
			
			//No point in launching even if publishing did not change
			if ( _viewerPublishActive == _publishActive ) 
			{
				_viewerPublishActive = null;
				return;
			}
			_viewerPublishActive = null;
			
			//If viewer is just being annoying we send out abuse warning and then loses ability to share
			if ( !isNaN(_shareAbuseTimeStamp) )
			{
				var currentTime:Number = new Date().getTime();
				if ( (currentTime-_shareAbuseTimeStamp) < _SHARE_ABUSE_WAIT_ )
				{
					_shareAbuseCount = isNaN(_shareAbuseCount) ? 1 : _shareAbuseCount + 1;
					if ( _shareAbuseCount == _SHARE_ABUSE_LIMIT_ )
					{
						Alert.alert( getLabelAt(_shareAbuseWarned ? "abuseAlertBan" : "abuseAlertWarning"), getLabelAt("abuseAlertWarningTitle"), getLabelAt("okBtn") );
						
						if ( _shareAbuseWarned )
						{
							_shareAbuseBan = true;
							_camPreview.visible = false;
							refreshViewOptions();
						}else{
							_shareAbuseWarned = true;
						}
					}
				}else{
					//If its passed a certain time we give em a break and reset
					_shareAbuseCount = _shareAbuseTimeStamp = NaN;
				}
			}
			_shareAbuseTimeStamp = new Date().getTime();
			dispatchEvent(new Event(BROADCAST_CHANGE));
		}
		
		/*
		 * HANDLERS
		 */
		
		private function __onBtnMouseEvent( event:MouseEvent ): void
		{
			switch( event.currentTarget )
			{
				case _settingsBtn : 
					_settingsUI.visible = !_settingsUI.visible;
					invalidateDisplayList();
					break;
				case _publishBtn : 
					if ( _bAdminMode )
					{
						//If admin just send the cast change call
						_publishActive = !_publishActive;
						_publishBtn.label = getLabelAt(_publishActive ? "stopBtn" : (_bAdminMode ? "broadcastBtn" : "shareCamBtn"));
						invalidateDisplayList();
						dispatchEvent(new Event(BROADCAST_CHANGE));
					}else{
						//Keeps viewers from abusing share cam button since resources are needed to push image  
						if ( !isNaN(_publishBtnCheck) ) clearTimeout(_publishBtnCheck);
						if ( _viewerPublishActive == null ) _viewerPublishActive = _publishActive;
						
						//Change status and btn states
						_publishActive = !_publishActive;
						_publishBtn.label = getLabelAt(_publishActive ? "stopBtn" : (_bAdminMode ? "broadcastBtn" : "shareCamBtn"));
						invalidateDisplayList();
						
						//Don't register change until 500 milli secs after request has been made
						_publishBtnCheck = setTimeout( __doViewerPublishCmd, 500 );
					}
					break;
				case _shareBtn : 
					if ( !_shareUI.checkDefaultShareAlert() )
					{
						_shareUI.visible = !_shareUI.visible;
						invalidateDisplayList();
					}
					break;
				case stage :
					if( !__stillHit(_settingsUI) && !__stillHit(_settingsBtn) ) _settingsUI.visible = false;
					if( !__stillHit(_shareUI) && !__stillHit(_shareBtn) ) _shareUI.visible = false;
					break;
			}
		}
		
		private function __onBtnRollOverEvent( event:MouseEvent ): void
		{
			if( !_bAdminMode ) _camPreview.visible = _shareAbuseBan ? false : __stillHit(_publishBtn);
		}
		
		private function __onMeasuredEvent( event:Event ): void
		{
			invalidateDisplayList();
		}
		
		/*
		 * DISPLAY API
		 */
		
		override protected function createChildren():void 
		{
			super.createChildren();
			
			_controlsBG = getStyleGraphic("controlsBackground");
			_shareUI = new ShareUI();
			_shareUI.visible = false;
			_settingsUI = new SettingsUI();
			_settingsUI.visible = false;
			_userIconList = new UserIconList();
			_userIconList.visible = false;
			_userCount = new UserCount();
			_userCount.visible = false;
			_screenOptions = new ScreenOptions();
			_screenOptions.visible = false;
			_camPreview = new CamPreview();
			_camPreview.visible = false;
			
			_settingsBtn = new Button();
			_settingsBtn.skinName = "collabControlsSettingsBtn";
			_settingsBtn.visible = false;
			_publishBtn = new Button();
			_publishBtn.skinName = "collabControlsPublishBtnAlt";//"collabControlsPublishBtn";
			_publishBtn.visible = false;
			_shareBtn = new Button();
			_shareBtn.skinName = "collabControlsShareBtn";
			_shareBtn.visible = false;
			
			addChildren( _controlsBG, _publishBtn, _settingsBtn, _shareBtn, _settingsUI,
						 _userIconList, _userCount, _screenOptions, _camPreview, _shareUI );
			
		}
		
		override protected function childrenCreated():void 
		{
			super.childrenCreated();
			
			infx_internal::showBackground(false);
			_screenOptions.addEventListener( SizeStates.MEASURE, __onMeasuredEvent );
			_screenOptions.displayPositioner = _displayPosition;
			_camPreview.camWindow = _camWindow;
			
			_settingsUI.includeExit = _includeExit;
			_settingsUI.addEventListener( SizeStates.MEASURE_HEIGHT, __onMeasuredEvent );
			_settingsUI.addEventListener( Event.CLOSE, dispatchEvent );
			
			_shareUI.addEventListener( SizeStates.MEASURE_HEIGHT, __onMeasuredEvent );
			_shareUI.twitterToken = _twitterToken;
			_shareUI.facebookToken = _facebookToken;
			
			_publishBtn.toggle = true;
			_settingsBtn.addEventListener( MouseEvent.MOUSE_DOWN, __onBtnMouseEvent );
			_publishBtn.addEventListener( MouseEvent.MOUSE_DOWN, __onBtnMouseEvent );
			_shareBtn.addEventListener( MouseEvent.MOUSE_DOWN, __onBtnMouseEvent );
			
			//Check stage clicks downs to close menus if open
			stage.addEventListener( MouseEvent.MOUSE_DOWN, __onBtnMouseEvent );
			
			_publishBtn.addEventListener( MouseEvent.ROLL_OVER, __onBtnRollOverEvent );
			_publishBtn.addEventListener( MouseEvent.ROLL_OUT, __onBtnRollOverEvent );
			_publishBtn.addEventListener( MouseEvent.MOUSE_OVER, __onBtnRollOverEvent );
			_publishBtn.addEventListener( MouseEvent.MOUSE_OUT, __onBtnRollOverEvent );
			refreshPostInfo();
			refreshViewOptions();
		}
		
		override protected function arrange():void 
		{
			super.arrange();
			
			var totalWidth:Number = width - (paddingLeft + paddingRight);
			
			//Place Controls BG
			_controlsBG.width = totalWidth;
			_controlsBG.height = ScreenScaler.calculateSize(50);
			_controlsBG.x = paddingLeft;
			SizeUtils.moveY( _controlsBG, height, SizeUtils.BOTTOM, paddingBottom );
			
			//Align Controls
			SizeUtils.hookTarget( _settingsBtn, _controlsBG, SizeUtils.LEFT, innerPadding, true );
			SizeUtils.hookTarget( _publishBtn, _controlsBG, SizeUtils.CENTER, 0, true );
			SizeUtils.hookTarget( _shareBtn, _controlsBG, SizeUtils.RIGHT, innerPadding, true );
			SizeUtils.hookTarget( _settingsBtn, _controlsBG, SizeUtils.MIDDLE, 0, true );
			SizeUtils.hookTarget( _publishBtn, _controlsBG, SizeUtils.MIDDLE, 0, true );
			SizeUtils.hookTarget( _shareBtn, _controlsBG, SizeUtils.MIDDLE, 0, true );
			
			//Settings UI
			SizeUtils.hookTarget( _settingsUI, _controlsBG, SizeUtils.TOP );
			
			SizeUtils.hookTarget( _shareUI, _controlsBG, SizeUtils.TOP );
			SizeUtils.moveX( _shareUI, width, SizeUtils.RIGHT );
			
			//User Count
			SizeUtils.hookTarget( _userCount, this, SizeUtils.RIGHT, innerPadding, true );
			SizeUtils.hookTarget( _userCount, _controlsBG, SizeUtils.TOP, innerPadding );
			
			//Screen Options
			SizeUtils.hookTarget( _screenOptions, this, SizeUtils.CENTER, 0, true );
			SizeUtils.hookTarget( _screenOptions, _controlsBG, SizeUtils.TOP, innerPadding );
			
			//CamPreview (Viewer Mode Only)
			SizeUtils.hookTarget( _camPreview, this, SizeUtils.CENTER, 0, true );
			SizeUtils.hookTarget( _camPreview, _controlsBG, SizeUtils.TOP, styleExists("camPreviewPadding") ? Number(getStyle("camPreviewPadding")) : 0 );
			
			//UserIcon List
			SizeUtils.hookTarget( _userIconList, this, SizeUtils.RIGHT, 0, true );
			_userIconList.y = (innerPadding * 2);
			_userIconList.height = height - (_userIconList.y + _userCount.height + _controlsBG.height + ScreenScaler.calculateSize(50));
			refreshViewOptions();
		}
		
		/*
		 * GETTER / SETTER
		 */
		
		public function set state( value:String ): void
		{
			if ( _sState == value ) return;
			_sState = value;
			onStateChange();
		}
		
		public function get state(): String
		{
			return _sState;
		}
		
		public function set adminMode( value:Boolean ): void
		{
			if ( _bAdminMode == value ) return;
			_bAdminMode = value;
			onAdminModeChanged();
		}
		
		public function get adminMode(): Boolean
		{
			return _bAdminMode;
		}
		
		public function set userCount( value:uint ): void
		{
			if ( _nUserCount == value ) return;
			_nUserCount = value;
			if ( initialized ) _userCount.userCount = _nUserCount;
		}
		
		public function get userCount(): uint
		{
			return _nUserCount;
		}
		
		public function get controlsHeight(): uint
		{
			return initialized ? _controlsBG.height : 0;
		}
		
		public function set publishActive( value:Boolean ): void
		{
			if ( _publishActive == value ) return;
			
			_publishActive = value;
			if ( initialized ) 
			{
				_publishBtn.selected = _publishActive;
				_publishBtn.label = getLabelAt(_publishActive ? "stopBtn" : (_bAdminMode ? "broadcastBtn" : "shareCamBtn"));
			}
		}
		
		public function get publishActive(): Boolean
		{
			return _publishActive;
		}
		
		public function set displayPositioner( value:DisplayPositioner ): void
		{
			if ( _displayPosition == value ) return;
			_displayPosition = value;
			if ( initialized ) _screenOptions.displayPositioner = _displayPosition;
		} 
		
		public function get displayPositioner(): DisplayPositioner
		{
			return _displayPosition;
		}
		
		public function set camWindow( value:CamWindow ): void
		{
			if ( _camWindow == value ) return;
			_camWindow = value;
			if ( initialized ) _camPreview.camWindow = _camWindow;
		}
		
		public function get camWindow(): CamWindow
		{
			return _camWindow;
		}
		
		public function set includeExit( value:Boolean ): void
		{
			if ( _includeExit == value ) return;
			_includeExit = value;
			if ( initialized ) _settingsUI.includeExit = _includeExit;
		}
		
		public function get includeExit(): Boolean
		{
			return _includeExit;
		}
		
		public function set allowRequests( value:Boolean ): void
		{
			if ( _allowRequests == value ) return;
			_allowRequests = value;
			refreshViewOptions();
		}
		
		public function get allowRequests(): Boolean
		{
			return _allowRequests;
		}
		
		public function set viewerLink( value:String ): void
		{
			if ( _viewerLink == value ) return;
			_viewerLink = value;
			refreshPostInfo();
		}
		
		public function get viewerLink(): String
		{
			return _viewerLink;
		}
		
		public function set twitterToken( value:String ): void
		{
			if ( _twitterToken == value ) return;
			_twitterToken = value;
			if ( initialized ) _shareUI.twitterToken = _twitterToken;
		}
		
		public function get twitterToken(): String
		{
			return _twitterToken;
		}
		
		public function set facebookToken( value:String ): void
		{
			if ( _facebookToken == value ) return;
			_facebookToken = value;
			if ( initialized ) _shareUI.facebookToken = _facebookToken;
		}
		
		public function get facebookToken(): String
		{
			return _facebookToken;
		}
	}
}