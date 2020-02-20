package org.influxis.social.managers 
{
	//Flash Classes
	import flash.events.EventDispatcher;
	import flash.display.DisplayObjectContainer;
	
	//Influxis Classes
	import org.influxis.as3.events.DataEvent;
	
	//Social Classes
	import org.influxis.social.events.SocialAPIEvent;
	import org.influxis.social.InfluxisSocialAPI;
	
	//Handles sessions for both Facebook and Twitter
	public class SocialCasterManager extends EventDispatcher
	{
		public static const TOKEN_CHANGE:String = "tokenChange";
		public static const FACEBOOK:String = InfluxisSocialAPI.FACEBOOK;
		public static const TWITTER:String = InfluxisSocialAPI.TWITTER;
		
		private static var __scm:SocialCasterManager;
		
		private var _isMobile:Boolean;
		private var _facebookToken:String;
		private var _twitterToken:String;
		private var _socialAPI_FB:InfluxisSocialAPI;
		private var _socialAPI_TW:InfluxisSocialAPI;
		
		/*
		 * INIT API
		 */
		
		public function SocialCasterManager( stage:DisplayObjectContainer, isMobile:Boolean = false ): void
		{
			_isMobile = isMobile;
			
			//Set stage for mobile or desktop view
			InfluxisSocialAPI.setStage( stage );
		}
		
		/*
		 * STATIC API
		 */
		
		public static function getInstance( stage:DisplayObjectContainer ): SocialCasterManager
		{
			if ( !__scm ) __scm = new SocialCasterManager( stage );
			return __scm;
		}
		
		/*
		 * PROTECTED API
		 */
		
		protected function onFaceBookTokenChanged(): void
		{
			if ( _socialAPI_FB )
			{
				_socialAPI_FB.removeEventListener( SocialAPIEvent.AUTHORIZATION_SUCCESS, __onSocialFBEvent );
				_socialAPI_FB.removeEventListener( SocialAPIEvent.AUTHORIZATION_DENIED, __onSocialFBEvent );
				_socialAPI_FB.removeEventListener( SocialAPIEvent.AUTHORIZATION_ERROR, __onSocialFBEvent );
				_socialAPI_FB.removeEventListener( SocialAPIEvent.LOCAL_USER_INFO_RECEIVED, __onSocialFBEvent );
				_socialAPI_FB.removeEventListener( SocialAPIEvent.POST_RESPONSE_FAILED, __onSocialFBEvent );
				_socialAPI_FB.removeEventListener( SocialAPIEvent.POST_RESPONSE_SUCCESS, __onSocialFBEvent );
				_socialAPI_FB.removeEventListener( SocialAPIEvent.SESSION_STARTED, __onSocialFBEvent );
				_socialAPI_FB.removeEventListener( SocialAPIEvent.SESSION_EXPIRED, __onSocialFBEvent );
				_socialAPI_FB.removeEventListener( SocialAPIEvent.PAGE_INIT, __onSocialFBEvent );
				_socialAPI_FB.removeEventListener( SocialAPIEvent.PAGE_LOADED, __onSocialFBEvent );
				_socialAPI_FB.removeEventListener( SocialAPIEvent.PAGE_ERROR, __onSocialFBEvent );
				_socialAPI_FB = null;
			}
			
			if ( !_facebookToken ) return;
			
			//Create new Facebook service
			_socialAPI_FB = InfluxisSocialAPI.getService( InfluxisSocialAPI.FACEBOOK, _facebookToken );
			_socialAPI_FB.addEventListener( SocialAPIEvent.AUTHORIZATION_SUCCESS, __onSocialFBEvent );
			_socialAPI_FB.addEventListener( SocialAPIEvent.AUTHORIZATION_DENIED, __onSocialFBEvent );
			_socialAPI_FB.addEventListener( SocialAPIEvent.AUTHORIZATION_ERROR, __onSocialFBEvent );
			_socialAPI_FB.addEventListener( SocialAPIEvent.LOCAL_USER_INFO_RECEIVED, __onSocialFBEvent );
			_socialAPI_FB.addEventListener( SocialAPIEvent.POST_RESPONSE_FAILED, __onSocialFBEvent );
			_socialAPI_FB.addEventListener( SocialAPIEvent.POST_RESPONSE_SUCCESS, __onSocialFBEvent );
			_socialAPI_FB.addEventListener( SocialAPIEvent.SESSION_STARTED, __onSocialFBEvent );
			_socialAPI_FB.addEventListener( SocialAPIEvent.SESSION_EXPIRED, __onSocialFBEvent );
			_socialAPI_FB.addEventListener( SocialAPIEvent.PAGE_INIT, __onSocialFBEvent );
			_socialAPI_FB.addEventListener( SocialAPIEvent.PAGE_LOADED, __onSocialFBEvent );
			_socialAPI_FB.addEventListener( SocialAPIEvent.PAGE_ERROR, __onSocialFBEvent );
		}
		
		protected function onTwitterTokenChanged(): void
		{
			if ( _socialAPI_TW )
			{
				_socialAPI_TW.removeEventListener( SocialAPIEvent.AUTHORIZATION_SUCCESS, __onSocialTwitterEvent );
				_socialAPI_TW.removeEventListener( SocialAPIEvent.AUTHORIZATION_DENIED, __onSocialTwitterEvent );
				_socialAPI_TW.removeEventListener( SocialAPIEvent.AUTHORIZATION_ERROR, __onSocialTwitterEvent );
				_socialAPI_TW.removeEventListener( SocialAPIEvent.LOCAL_USER_INFO_RECEIVED, __onSocialTwitterEvent );
				_socialAPI_TW.removeEventListener( SocialAPIEvent.POST_RESPONSE_FAILED, __onSocialTwitterEvent );
				_socialAPI_TW.removeEventListener( SocialAPIEvent.POST_RESPONSE_SUCCESS, __onSocialTwitterEvent );
				_socialAPI_TW.removeEventListener( SocialAPIEvent.SESSION_STARTED, __onSocialTwitterEvent );
				_socialAPI_TW.removeEventListener( SocialAPIEvent.SESSION_EXPIRED, __onSocialTwitterEvent );
				_socialAPI_TW.removeEventListener( SocialAPIEvent.PAGE_INIT, __onSocialTwitterEvent );
				_socialAPI_TW.removeEventListener( SocialAPIEvent.PAGE_LOADED, __onSocialTwitterEvent );
				_socialAPI_TW.removeEventListener( SocialAPIEvent.PAGE_ERROR, __onSocialTwitterEvent );
				_socialAPI_TW = null;
			}
			
			if ( !_twitterToken ) return;
			
			//Create new Twitter service
			_socialAPI_TW = InfluxisSocialAPI.getService( InfluxisSocialAPI.TWITTER, _twitterToken );
			_socialAPI_TW.addEventListener( SocialAPIEvent.AUTHORIZATION_SUCCESS, __onSocialTwitterEvent );
			_socialAPI_TW.addEventListener( SocialAPIEvent.AUTHORIZATION_DENIED, __onSocialTwitterEvent );
			_socialAPI_TW.addEventListener( SocialAPIEvent.AUTHORIZATION_ERROR, __onSocialTwitterEvent );
			_socialAPI_TW.addEventListener( SocialAPIEvent.LOCAL_USER_INFO_RECEIVED, __onSocialTwitterEvent );
			_socialAPI_TW.addEventListener( SocialAPIEvent.POST_RESPONSE_FAILED, __onSocialTwitterEvent );
			_socialAPI_TW.addEventListener( SocialAPIEvent.POST_RESPONSE_SUCCESS, __onSocialTwitterEvent );
			_socialAPI_TW.addEventListener( SocialAPIEvent.SESSION_STARTED, __onSocialTwitterEvent );
			_socialAPI_TW.addEventListener( SocialAPIEvent.SESSION_EXPIRED, __onSocialTwitterEvent );
			_socialAPI_TW.addEventListener( SocialAPIEvent.PAGE_INIT, __onSocialTwitterEvent );
			_socialAPI_TW.addEventListener( SocialAPIEvent.PAGE_LOADED, __onSocialTwitterEvent );
			_socialAPI_TW.addEventListener( SocialAPIEvent.PAGE_ERROR, __onSocialTwitterEvent );
		}
		
		/*
		 * HANDLERS
		 */
		
		private function __onSocialFBEvent( event:SocialAPIEvent ): void
		{
			if ( event.type == SocialAPIEvent.LOCAL_USER_INFO_RECEIVED )
			{
				//_socialAPI.postMessage( {message: "This is a test message... Yo Face!"} );
			}else if ( event.type == SocialAPIEvent.POST_RESPONSE_FAILED )
			{
				//throw new Error( "Post Failed :(" );
				_socialAPI_FB.logout();
				_socialAPI_FB.login();
			}
			dispatchEvent(event);
		}
		
		private function __onSocialTwitterEvent( event:SocialAPIEvent ): void
		{
			if ( event.type == SocialAPIEvent.LOCAL_USER_INFO_RECEIVED )
			{
				//_socialAPI.postMessage( {message: "This is a test message... Yo Face!"} );
			}else if ( event.type == SocialAPIEvent.POST_RESPONSE_FAILED )
			{
				_socialAPI_TW.logout();
				_socialAPI_TW.login();
			}
			dispatchEvent(event);
		}
		
		/*
		 * GETTER / SETTER
		 */
		
		public function get facebook(): InfluxisSocialAPI
		{
			return _socialAPI_FB;
		}
		
		public function get twitter(): InfluxisSocialAPI
		{
			return _socialAPI_TW;
		}
		
		public function set twitterToken( value:String ): void
		{
			if ( _twitterToken == value ) return;
			_twitterToken = value;
			onTwitterTokenChanged();
			dispatchEvent(new DataEvent(TOKEN_CHANGE, TWITTER));
		}
		
		public function get twitterToken(): String
		{
			return _twitterToken;
		}
		
		public function set facebookToken( value:String ): void
		{
			if ( _facebookToken == value ) return;
			_facebookToken = value;
			onFaceBookTokenChanged();
			dispatchEvent(new DataEvent(TOKEN_CHANGE, FACEBOOK));
		}
		
		public function get facebookToken(): String
		{
			return _facebookToken;
		}
	}
}