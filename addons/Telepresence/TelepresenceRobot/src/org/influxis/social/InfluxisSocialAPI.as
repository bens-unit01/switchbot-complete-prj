package org.influxis.social 
{
	//Flash Classes
	import flash.events.EventDispatcher;
	import flash.geom.Rectangle;
	import flash.net.SharedObject;
	import flash.display.DisplayObjectContainer;
	import flash.external.ExternalInterface;
	
	//Social Classes
	import org.influxis.social.core.social_internal;
	import org.influxis.social.core.SocialURLDefaults;
	import org.influxis.social.data.SocialSession;
	import org.influxis.social.net.SocialRequests;
	import org.influxis.social.containers.SocialLoginWindow;
	import org.influxis.social.events.SocialAPIEvent;
	
	public class InfluxisSocialAPI extends EventDispatcher
	{
		use namespace social_internal;
		public static const FACEBOOK:String = "facebook";
		public static const TWITTER:String = "twitter";
		private static const LOCAL_FILE:RegExp = /^file\:\/\/\/C(\:|\|)/gi;
		private static const WEB_FILE:RegExp = /^http(s)?:\/\//gi;
		
		private static var __infxServices:Object = new Object();
		
		private var _session:SocialSession;
		private var _socialRequests:SocialRequests;
		private var _service:String;
		private var _fluxToken:String;
		private var _ls:SharedObject;
		private var _socialWindow:SocialLoginWindow;
		private var _localUserData:Object;
		
		/*
		 * INIT API
		 */
		
		public function InfluxisSocialAPI( service:String, fluxToken:String ): void
		{
			super();
			
			if ( !service ) throw new Error( "You must enter a valid service!" );
			if ( !fluxToken ) throw new Error( "A Flux token must be provided!" );
			
			_service = service;
			_fluxToken = fluxToken;
			
			//Start shared object and check if last session was active
			_ls = SharedObject.getLocal( "SocialService." + _service + "_" + _fluxToken, "/" );
			if ( _ls.data && _ls.data.token != undefined ) startSession( _ls.data.token, _ls.data.tokenSecret );
		}
		
		/*
		 * STATIC API
		 */
		
		public static function getService( service:String, fluxToken:String ): InfluxisSocialAPI
		{
			if ( __infxServices[service + "_" + fluxToken] == undefined ) __infxServices[service + "_" + fluxToken] =  new InfluxisSocialAPI( service, fluxToken );
			return __infxServices[service + "_" + fluxToken] as InfluxisSocialAPI;
		}
		
		public static function destroyService( service:String, fluxToken:String ): void
		{
			if ( __infxServices[service + "_" + fluxToken] == undefined ) return ;
			__infxServices[service + "_" + fluxToken] = null;
			delete __infxServices[service + "_" + fluxToken];
		}
		
		public static function setStage( stage:DisplayObjectContainer, viewPort:Rectangle = null ): void
		{
			SocialLoginWindow.STAGE = stage;
			
			//When desktop mode we need to provide link to redirect html we get this by checking the loader info
			SocialURLDefaults.FLASH_REDIRECT = stage.loaderInfo.url.substring(0, stage.loaderInfo.url.lastIndexOf("/") + 1) + "redirect.html";
			
			var redirectRelPath:String;
			if ( LOCAL_FILE.test(SocialURLDefaults.FLASH_REDIRECT) )
			{
				redirectRelPath = SocialURLDefaults.FLASH_REDIRECT.replace( LOCAL_FILE, "" );
			}else if ( WEB_FILE.test(SocialURLDefaults.FLASH_REDIRECT) )
			{
				redirectRelPath = SocialURLDefaults.FLASH_REDIRECT.replace( WEB_FILE, "" );
				
				var parsedPath:Array = redirectRelPath.split("/");
				if ( parsedPath.length == 1 )
				{
					//On the domain so just set path directly
					redirectRelPath = "/redirect.html";
				}else{
					
					//Drop the first part since it contains the domain which we dont need then join the string again
					parsedPath.shift();
					
					//Join relative path
					redirectRelPath = "/" + parsedPath.join("/");
				}
			}
			
			//In desktop mode we also need to init the social api in the javascript
			if ( ExternalInterface.available ) ExternalInterface.call( "initFluxPopup", redirectRelPath );
			
			//View port only for mobile version
			CONFIG::IS_MOBILE
			{
				SocialLoginWindow.VIEW_PORT = viewPort;
			}
		}
		 
		/*
		 * MOBILE SPECIFIC API
		 */
		
		//Only way to compile on desktop :/
		CONFIG::IS_MOBILE
		{
			public static function setMobileViewPort( viewPort:Rectangle ): void
			{
				SocialLoginWindow.VIEW_PORT = viewPort;
			}
			
			public function refreshWindowView(): void
			{
				if( _socialWindow ) _socialWindow.refreshWindowView();
			}
			
			public function closeWindow(): void
			{
				if ( _socialWindow ) 
				{
					_socialWindow.unload();
					unloadWindow();
				}
			}
			
			public function get windowOpen(): Boolean
			{
				return _socialWindow && _socialWindow.windowOpen;
			}
		}
		
		/*
		 * PUBLIC API
		 */
		
		public function login(): void
		{
			if ( _session || _socialWindow ) return;
			
			_socialWindow = new SocialLoginWindow();
			_socialWindow.addEventListener( SocialAPIEvent.AUTHORIZATION_SUCCESS, __onSocialWindowEvent );
			_socialWindow.addEventListener( SocialAPIEvent.AUTHORIZATION_DENIED, __onSocialWindowEvent );
			_socialWindow.addEventListener( SocialAPIEvent.AUTHORIZATION_ERROR, __onSocialWindowEvent );
			_socialWindow.addEventListener( SocialAPIEvent.PAGE_INIT, __onSocialWindowEvent );
			_socialWindow.addEventListener( SocialAPIEvent.PAGE_LOADED, __onSocialWindowEvent );
			_socialWindow.addEventListener( SocialAPIEvent.PAGE_ERROR, __onSocialWindowEvent );
			_socialWindow.requestLogin( _service, _fluxToken );
		}
		
		public function logout(): void
		{
			if ( !_session ) return;
			
			//Erase saved tokens
			_ls.setProperty( "token", null );
			_ls.setProperty( "tokenSecret", null );
			
			_socialRequests.removeEventListener( SocialAPIEvent.LOCAL_USER_INFO_RECEIVED, __onRequestEvent );
			_socialRequests.removeEventListener( SocialAPIEvent.LOCAL_USER_INFO_FAIL, __onRequestEvent );
			_socialRequests.removeEventListener( SocialAPIEvent.METHOD_REQUEST_ERROR, __onRequestEvent );
			_socialRequests.removeEventListener( SocialAPIEvent.POST_RESPONSE_SUCCESS, __onRequestEvent );
			_socialRequests.removeEventListener( SocialAPIEvent.POST_RESPONSE_FAILED, __onRequestEvent );
			_socialRequests = null;
			_session = null;
		}
		
		public function postMessage( data:Object ): Boolean
		{
			if( !data || !_session ) return false;
			_socialRequests.postMessage(data);
			return true;
		}
		
		/*
		 * HANDLERS
		 */
		
		private function __onSocialWindowEvent( event:SocialAPIEvent ): void
		{
			if ( event.type == SocialAPIEvent.PAGE_LOADED || event.type == SocialAPIEvent.PAGE_INIT )
			{
				dispatchEvent(event);
				return;
			}else if ( event.type == SocialAPIEvent.AUTHORIZATION_SUCCESS )
			{
				_ls.setProperty( "token", _socialWindow.token );
				_ls.setProperty( "tokenSecret", _socialWindow.secret );	
				startSession( _socialWindow.token, _socialWindow.secret );
			}
			dispatchEvent(event);
		}
		
		private function __onRequestEvent( event:SocialAPIEvent ): void
		{
			if ( event.type == SocialAPIEvent.LOCAL_USER_INFO_RECEIVED )
			{
				_localUserData = new Object();
				for ( var i:String in event.response )
				{
					if ( i != "success" && 
						 i != "method" && 
						 i != "service" ) _localUserData[i] = event.response[i].toString();
				}
				dispatchEvent( new SocialAPIEvent(SocialAPIEvent.LOCAL_USER_INFO_RECEIVED, _service, _localUserData) );
				return;
			}else if ( event.type == SocialAPIEvent.LOCAL_USER_INFO_FAIL )
			{
				//Do something here to logout user
				if ( _session )
				{
					//Officially logout session
					logout();
					dispatchEvent( new SocialAPIEvent(SocialAPIEvent.SESSION_EXPIRED, _service, null) );
				}
			}
			dispatchEvent(event);
		}
		
		/*
		 * PROTECTED API
		 */
		
		protected function unloadWindow(): void
		{
			if ( !_socialWindow ) return;
			_socialWindow.removeEventListener( SocialAPIEvent.AUTHORIZATION_SUCCESS, __onSocialWindowEvent );
			_socialWindow.removeEventListener( SocialAPIEvent.AUTHORIZATION_DENIED, __onSocialWindowEvent );
			_socialWindow.removeEventListener( SocialAPIEvent.AUTHORIZATION_ERROR, __onSocialWindowEvent );
			_socialWindow.removeEventListener( SocialAPIEvent.PAGE_INIT, __onSocialWindowEvent );
			_socialWindow.removeEventListener( SocialAPIEvent.PAGE_LOADED, __onSocialWindowEvent );
			_socialWindow.removeEventListener( SocialAPIEvent.PAGE_ERROR, __onSocialWindowEvent );
			_socialWindow = null;
		}
		 
		protected function startSession( token:String, secret:String ): void
		{
			if ( _session ) return;
			
			_session = new SocialSession( _service, _fluxToken );
			_session.social_internal::accessToken = token;
			_session.social_internal::accessSecret = secret;
			
			_socialRequests = new SocialRequests(_session);
			_socialRequests.addEventListener( SocialAPIEvent.LOCAL_USER_INFO_RECEIVED, __onRequestEvent );
			_socialRequests.addEventListener( SocialAPIEvent.LOCAL_USER_INFO_FAIL, __onRequestEvent );
			_socialRequests.addEventListener( SocialAPIEvent.METHOD_REQUEST_ERROR, __onRequestEvent );
			_socialRequests.addEventListener( SocialAPIEvent.POST_RESPONSE_SUCCESS, __onRequestEvent );
			_socialRequests.addEventListener( SocialAPIEvent.POST_RESPONSE_FAILED, __onRequestEvent );
			_socialRequests.requestLocalUserData();
			
			dispatchEvent(new SocialAPIEvent(SocialAPIEvent.SESSION_STARTED, _service, null));
		}
		 
		/*
		 * GETTER / SETTER
		 */
		
		public function get service(): String
		{
			return _service;
		}
		 
		public function get localUserData(): Object
		{
			return _localUserData;
		}
		
		public function get loggedIn(): Boolean
		{
			return (_session != null);
		}
	}
}