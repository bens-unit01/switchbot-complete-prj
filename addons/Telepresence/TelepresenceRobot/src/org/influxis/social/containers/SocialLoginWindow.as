package org.influxis.social.containers 
{
	//Flash Classes
	import flash.events.Event;
	import flash.events.ErrorEvent;
	import flash.events.EventDispatcher;
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.external.ExternalInterface;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	//We have to make a compiler constant so that the sources compile on desktop :/
	CONFIG::IS_MOBILE
	{
		import flash.media.StageWebView;
		import org.influxis.social.containers.SocialMobileWindow;
	}
	
	//Social Classes
	import org.influxis.social.events.SocialAPIEvent;
	import org.influxis.social.core.SocialURLDefaults;
	
	public class SocialLoginWindow extends EventDispatcher
	{
		public static var STAGE:DisplayObjectContainer;
		
		private var _initialized:Boolean;
		private var _isMobile:Boolean;
		
		private var _accessToken:String;
		private var _accessSecret:String;
		private var _accessResult:Object;
		
		CONFIG::IS_MOBILE
		{
			public static var VIEW_PORT:Rectangle;	
			private var _sizeTimer:Timer;
			private var _mobileWindow:SocialMobileWindow;
		}
		
		/*
		 * INIT API
		 */
		
		public function SocialLoginWindow(): void
		{
			super();
			
			CONFIG::IS_MOBILE
			{
				_sizeTimer = new Timer(500);
				_sizeTimer.addEventListener( TimerEvent.TIMER, __onMobileStageEvent );
			}
		}
		 
		/*
		 * PUBLIC API
		 */
		
		public function requestLogin( service:String, fluxToken:String, redirectUri:String = null, apiVersion:String = null, scope:String = null, options:String = null ): Boolean
		{
			if ( !service || !fluxToken ) return false;
			
			//Starts up window services
			if ( !initialized ) initializeLoginTools();
			
			redirectUri = redirectUri == null ? isMobile ? SocialURLDefaults.MOBILE_REDIRECT : SocialURLDefaults.FLASH_REDIRECT : redirectUri;
			scope = scope == null ? "publish_stream" : scope;
			apiVersion = apiVersion == null ? "1" : apiVersion;
			options = options == null ? "" : options;
			
			var queryString:String = "version=" + apiVersion + 
									 "&service=" + service +
									 "&flux_token=" + fluxToken +
									 "&scope=" + scope + 
									 "&redirect_uri=" + escape( redirectUri ) + 
									 ( options ? options : "" );
			
			//Mobile only can load mobile stage view
			CONFIG::IS_MOBILE
			{
				if ( isMobile ) 
				{
					launchMobileWindow( redirectUri, { service:service, url:("https://social.influxis.com:31415/oauth/?" + queryString) } );
				}
			}
			
			if ( ExternalInterface.available ) 
			{
				var res:Object = ExternalInterface.call( "influxis.popup.popupService", { service:service, url:("https://social.influxis.com:31415/oauth/?" + queryString) } );
				if ( !res ) return false;
			}else{
				return false;
			}
			return true;
		}
		
		
		
		/*
		 * EXT. HANDLERS
		 */
		 
		//If login was successful, this will be fired
		protected final function oauthSuccessHandler( response:Object ): void
		{
			if ( response.access_token ) 
			{
				_accessToken = response.access_token;
			}else if ( response.oauth_token_secret ) 
			{
				_accessToken = response.oauth_token;
				_accessSecret = response.oauth_token_secret;
			}else{
				this.oauthErrorHandler( response );
				return;
			}
			
			_accessResult = new Object();
			for ( var i:String in response )
			{
				_accessResult[i] = response[i];
			}
			
			dispatchEvent( new SocialAPIEvent(SocialAPIEvent.AUTHORIZATION_SUCCESS, response.service, response) );
		}
		
		protected final function oauthDeniedHandler( response:Object ): void
		{
			dispatchEvent( new SocialAPIEvent(SocialAPIEvent.AUTHORIZATION_DENIED, response.service, response) );
		}
		
		protected final function oauthErrorHandler( response:Object ): void
		{
			dispatchEvent( new SocialAPIEvent(SocialAPIEvent.AUTHORIZATION_ERROR, response.service, response) );
		}
		 
		/*
		 * MOBILE SPECIFIC API
		 */
		
		CONFIG::IS_MOBILE
		{
			/*
			 * PUBLIC API
			 */
			
			public function unload(): void
			{
				if( _windowOpen ) unloadMobileWindow();
			}
			 
			public function refreshWindowView(): void
			{
				if ( !_mobileWindow.parent ) return;
				
				if ( VIEW_PORT )
				{
					_mobileWindow.move(VIEW_PORT.x,VIEW_PORT.y);
					_mobileWindow.setActualSize( VIEW_PORT.width, VIEW_PORT.height );
				}else {
					
					var mobileStage:Stage = STAGE as Stage;
					_mobileWindow.move(0,0);
					if ( mobileStage )
					{
						_mobileWindow.setActualSize( mobileStage.stageWidth, mobileStage.stageHeight );
					}else{
						_mobileWindow.setActualSize( STAGE.width, STAGE.height );
					}
				}
			}
			
			/*
			 * HANDLERS
			 */
			
			private function __onMobileWindowEvent( event:SocialAPIEvent ): void
			{
				switch( event.type )
				{
					case SocialAPIEvent.AUTHORIZATION_SUCCESS :
						oauthSuccessHandler( event.response );
						break;
					case SocialAPIEvent.AUTHORIZATION_ERROR :
						oauthErrorHandler( event.response );
						break;
					case SocialAPIEvent.AUTHORIZATION_DENIED :
						oauthDeniedHandler( event.response );
						break;
				}
				unloadMobileWindow();
			}
			
			private function __onMobileWindowEventAlt( event:Event ): void
			{
				var newEvent:SocialAPIEvent;
				switch( event.type )
				{
					case ErrorEvent.ERROR :
						newEvent = new SocialAPIEvent( SocialAPIEvent.PAGE_ERROR, null, null );
						break;
					default : 
						newEvent = event as SocialAPIEvent;
						break
				}
				if( newEvent ) dispatchEvent(newEvent);
			}
			
			public function __onMobileStageEvent( event:Event ): void
			{
				refreshWindowView();
			}
			
			/*
			 * PROTECTED API
			 */
			
			//In mobile we handle the popup directly :)
			protected function launchMobileWindow( redirectUri:String, callData:Object ): void
			{
				if (callData.url == undefined ) return;
				
				if ( !STAGE ) 
				{
					throw new Error( "Please set a MobileStage via SocialLoginWindow.STAGE!" );
					return;
				}
				
				_windowOpen = true;
				STAGE.addChild( _mobileWindow );
				var mobileStage:Stage = STAGE as Stage;
				refreshWindowView();
				
				_mobileWindow.loadURL( redirectUri + "?fluxPopup&redirect_uri=" + encodeURIComponent(callData.url) );
				_sizeTimer.start();
			}
			
			protected function unloadMobileWindow(): void
			{
				if ( !_mobileWindow.parent ) return;
				
				_sizeTimer.stop();
				_sizeTimer.reset();
				
				_mobileWindow.unload();
				_mobileWindow.setActualSize(0, 0);
				STAGE.removeChild(_mobileWindow);
				_windowOpen = false;
			}
			
			/*
			 * GETTER / SETTER
			 */ 
			
			private var _windowOpen:Boolean;
			public function get windowOpen(): Boolean
			{
				return _windowOpen && _mobileWindow && _mobileWindow.windowOpen;
			}
		}
		
		/*
		 * PROTECTED API
		 */
		 
		protected function initializeLoginTools(): void
		{
			CONFIG::IS_MOBILE
			{
				if ( StageWebView.isSupported )
				{
					_initialized = _isMobile = true;
					_mobileWindow = new SocialMobileWindow();
					_mobileWindow.addEventListener( SocialAPIEvent.AUTHORIZATION_SUCCESS, __onMobileWindowEvent );
					_mobileWindow.addEventListener( SocialAPIEvent.AUTHORIZATION_DENIED, __onMobileWindowEvent );
					_mobileWindow.addEventListener( SocialAPIEvent.AUTHORIZATION_ERROR, __onMobileWindowEvent );
					_mobileWindow.addEventListener( SocialAPIEvent.PAGE_INIT, __onMobileWindowEventAlt );
					_mobileWindow.addEventListener( SocialAPIEvent.PAGE_LOADED, __onMobileWindowEventAlt );
					_mobileWindow.addEventListener( ErrorEvent.ERROR, __onMobileWindowEventAlt );
					
				}else{
					trace("External interface is not available for this container.");
				}
			}
			
			if ( ExternalInterface.available ) 
			{
				try 
				{
					ExternalInterface.addCallback("oauthSuccess", oauthSuccessHandler);
					ExternalInterface.addCallback("oauthDenied", oauthDeniedHandler);
					ExternalInterface.addCallback("oauthError", oauthErrorHandler);
					_initialized = true;
				}catch ( error:SecurityError ) 
				{
					trace("A SecurityError occurred: " + error.message + "\n");
				}catch ( error:Error ) 
				{
					trace("An Error occurred: " + error.message + "\n");
				}
			}
		}
		
		
		protected function get initialized(): Boolean
		{
			return _initialized;
		}
		
		protected function get isMobile(): Boolean
		{
			return _isMobile;
		}
		
		/*
		 * GETTER / SETTER
		 */
		
		public function get token(): String
		{
			return _accessToken;
		}
		
		public function get secret(): String
		{
			return _accessSecret;
		}
		
		public function get result(): Object
		{
			return _accessResult;
		}
	}
}