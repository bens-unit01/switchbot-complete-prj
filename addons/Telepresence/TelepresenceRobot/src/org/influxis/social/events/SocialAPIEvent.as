package org.influxis.social.events 
{
	//Flash Classes
	import flash.events.Event;
	
	public class SocialAPIEvent extends Event
	{
		public static const AUTHORIZATION_SUCCESS:String = "oauthSuccess";
		public static const AUTHORIZATION_ERROR:String = "oauthError";
		public static const AUTHORIZATION_DENIED:String = "oauthDenied";
		public static const METHOD_REQUEST_ERROR:String = 	"methodRequestError";
		public static const LOCAL_USER_INFO_RECEIVED:String = "localUserInfoReceived";
		public static const LOCAL_USER_INFO_FAIL:String = "localUserInfoFail";
		public static const POST_RESPONSE_SUCCESS:String = "postReponseSuccess";
		public static const POST_RESPONSE_FAILED:String = "postReponseFailed";
		public static const SESSION_STARTED:String = "sessionStarted";
		public static const SESSION_EXPIRED:String = "sessionExpired";
		public static const PAGE_INIT:String = "pageInit";
		public static const PAGE_LOADED:String = "pageLoaded";
		public static const PAGE_ERROR:String = "pageError";
		
		private var _service:String;
		private var _response:Object;
		
		/*
		 * INIT API
		 */
		
		public function SocialAPIEvent( type:String, service:String, response:Object, bubbles:Boolean = false, cancelable:Boolean = false ): void 
		{
			super( type, bubbles, cancelable );
			_service = service;
			_response = response;
		}
		
		/*
		 * PUBLIC API 
		 */
		
		override public function clone(): flash.events.Event 
		{
			return new SocialAPIEvent( type, service, response, bubbles, cancelable );
		}
		
		/*
		 * GETTER / SETTER
		 */
		
		public function get service(): String
		{
			return _service;
		}
		
		public function get response(): Object
		{
			return _response;
		}
	}
}