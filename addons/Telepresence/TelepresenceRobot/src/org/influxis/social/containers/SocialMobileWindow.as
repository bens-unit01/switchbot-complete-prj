package org.influxis.social.containers 
{
	//Flash Classes
	import flash.events.Event;
	import flash.events.ErrorEvent;
	import flash.events.LocationChangeEvent;
	import flash.net.URLVariables;
	
	//Influxis Classes
	import org.influxis.mobile.managers.ScreenManager;
	
	//SocialServices Classes
	import org.influxis.social.events.SocialAPIEvent;
	import org.influxis.social.containers.MobileWebWindow;
	
	public class SocialMobileWindow extends MobileWebWindow
	{
		private static const SVC_QUERY_NAME:String = "service";
		private static const SVC_NAME_FB:String = "facebook";
		private static const SVC_NAME_TW:String = "twitter";
		private static const SVC_NAME_GP:String = "googleplus";
		private var _serviceHandler:Object;
		private var _loading:Boolean = false;
		private var _targetFound:Boolean;
		
		/*
		 * INIT API
		 */
		
		public function SocialMobileWindow(): void 
		{
			super();
			_serviceHandler = new Object();
			_serviceHandler[SVC_NAME_FB] = __parseResponseFacebook;
			_serviceHandler[SVC_NAME_TW] = __parseResponseTwitter;
			_serviceHandler[SVC_NAME_GP] = __parseResponseGooglePlus;
		}
		
		/*
		 * PUBLIC API
		 */
		
		override public function loadURL(path:String):void 
		{
			_loading = true;
			visible = false;
			dispatchEvent(new SocialAPIEvent( SocialAPIEvent.PAGE_INIT, null, null));
			super.loadURL(path);
		}
		 
		/*
		 * PRIVATE API
		 */
		
		private function __getOAuthResponse( queryObj:Object ): Object
		{
			var response:Object = null;
			var service:String = queryObj[SVC_QUERY_NAME];
			
			if (queryObj && service) 
			{
				response = _serviceHandler[service](queryObj);
				if( response ) response.service = service;
			}
			return response;
		}
		
		private function __parseResponseFacebook( queryObj:Object ): Object
		{
			var facebook:Object;
			var accessToken:String;
			//var callbackFunction = null,
			
			if ( queryObj.access_token ) 
			{
				facebook = {};
				accessToken = queryObj.access_token;
				
				if ( accessToken ) 
				{
					facebook.access_token = accessToken;
					facebook.expires_in = getValueOrNull(queryObj.expires_in);
					facebook.responseType = SocialAPIEvent.AUTHORIZATION_SUCCESS;
					//callbackFunction = 'oauthSuccess';
				}else{
					// the correct querystring keys existed, but their values were empty/null
					// so essentially this is a failed callback, not a success
					facebook.flux_error = 'Service returned null/empty keys';
					facebook.responseType = SocialAPIEvent.AUTHORIZATION_ERROR;
				}
			}else if ( queryObj.error ) // denied querystring key
			{ 
				facebook = {};
				facebook.error = queryObj.error;
				facebook.error_reason = getValueOrNull(queryObj.error_reason);
				facebook.error_description = getValueOrNull(queryObj.error_description);
				facebook.responseType = SocialAPIEvent.AUTHORIZATION_DENIED;
			}else if (queryObj.flux_error || queryObj.flux_exception ) // some error on us 
			{
				facebook = {};
				facebook.flux_error = getValueOrNull(queryObj.flux_error);
				facebook.flux_exception = getValueOrNull(queryObj.flux_exception);
				facebook.responseType = SocialAPIEvent.AUTHORIZATION_ERROR;
			}
			return facebook;
		}
	
		private function __parseResponseTwitter( queryObj:Object ): Object 
		{
			var twitter:Object;
			var oauthToken:String;
			var oauthTokenSecret:String;
			
			if ( queryObj.oauth_token ) // assume oauth_token_secret also present
			{ 
				twitter = {};
				oauthToken = queryObj.oauth_token;
				oauthTokenSecret = queryObj.oauth_token_secret;
				if (oauthToken && oauthTokenSecret) 
				{
					twitter.oauth_token = oauthToken;
					twitter.oauth_token_secret = oauthTokenSecret;
					twitter.user_id = getValueOrNull(queryObj.user_id);
					twitter.screen_name = getValueOrNull(queryObj.screen_name);
					twitter.responseType = SocialAPIEvent.AUTHORIZATION_SUCCESS;
				} else {
					twitter.flux_error = "Service returned null/empty keys";
					twitter.responseType = SocialAPIEvent.AUTHORIZATION_ERROR;
				}
			}else if ( queryObj.denied ) // denied querystring key
			{ 
				twitter = {};
				twitter.denied = queryObj.denied;
				twitter.responseType = SocialAPIEvent.AUTHORIZATION_DENIED;
			} else if ( queryObj.flux_error || queryObj.flux_exception ) // some error on us 
			{
				twitter = { };
				twitter.flux_error = getValueOrNull(queryObj.flux_error);
				twitter.flux_exception = getValueOrNull(queryObj.flux_exception);
				twitter.responseType = SocialAPIEvent.AUTHORIZATION_ERROR;
			}
			return twitter;
		}
		
		private function __parseResponseGooglePlus( queryObj:Object ): Object
		{
			var google:Object;
			var accessToken:String;
			var refreshToken:String;
			
			if ( queryObj.access_token ) 
			{
				google = {};
				
				accessToken  = queryObj.access_token;
				refreshToken = queryObj.refresh_token;
				if (accessToken) // check .NET src
				{  
					google.access_token = accessToken;
					google.refresh_token = getValueOrNull(refreshToken);
					google.token_issue_date = getValueOrNull(queryObj.token_issue_date);
					google.token_expire_date = getValueOrNull(queryObj.token_expire_date);
					google.responseType = SocialAPIEvent.AUTHORIZATION_SUCCESS;
				}else{
					google.flux_error = 'Service returned null/empty keys';
					google.responseType = SocialAPIEvent.AUTHORIZATION_ERROR;
				}
			}else if (queryObj.denied) // denied querystring key
			{ 
				google = {};
				google.denied = queryObj.denied;
				google.responseType = SocialAPIEvent.AUTHORIZATION_DENIED;
			}else if (queryObj.flux_error || queryObj.flux_exception) // some error on us
			{
				google = {};
				google.flux_error = getValueOrNull(queryObj.flux_error);
				google.flux_exception = getValueOrNull(queryObj.flux_exception);
				google.responseType = SocialAPIEvent.AUTHORIZATION_ERROR;
			}
			return google;
		};
		 
		/*
		 * PROTECTED API
		 */
		
		protected final function getValueOrNull( value:* ): Object
		{
			return value == undefined ? null : value;
		}
		
		protected function ready( queryObj:Object ): Boolean
		{
			return !queryObj ? false : !queryObj.hasOwnProperty("fluxPopup");
		}
		
		protected final function parseQueryString( query:String ): Object 
		{
			var newQuery:String;
			if ( query.indexOf('#') != -1 ) {
				newQuery = query.slice(query.indexOf('#') + 1);
			} else if ( query.indexOf('?') != -1 ) {
				newQuery = query.slice(query.indexOf('?') + 1);
			}
			
			if ( !newQuery ) return null;
			var arrQuery:Array = newQuery.split("&");
			var result:Object = { };
			var keyValue:Array;
				
			for ( var i:Number = 0; i < arrQuery.length; ++i ) 
			{
				if ( arrQuery[i].length > 0 ) 
				{ // skip any blank items like empty '&' statements in querystring
					keyValue = arrQuery[i].split("="); // split key/value pair
					
					if ( keyValue.length == 1 && keyValue[0].length > 0 ) 
					{ // querystring key with no value
						result[decodeQueryString(keyValue[0])] = null;
					}else if ( keyValue.length == 2 && keyValue[1].length > 0 ) 
					{ // must at least have a value, ignores empty '=' statements
						result[decodeQueryString(keyValue[0])] = decodeQueryString(keyValue[1]);
					} // else ignore anything which splits multiple = signs
				}
			}
			return result;
		}
		
		protected final function decodeQueryString( str:String ): String 
		{
			return decodeURIComponent(str.replace(/\+/g, " "));
		}
		
		override protected function onWebViewEvent( event:Event ): void 
		{
			super.onWebViewEvent(event);
			var newEvent:LocationChangeEvent = event as LocationChangeEvent;
			if ( newEvent && newEvent.type == LocationChangeEvent.LOCATION_CHANGE )
			{
				//If page is loaded then we check and notify when loaded to site
				if ( _loading && (/(twitter|facebook)\.com/gi).test(newEvent.location) )
				{
					_loading = false;
					_targetFound = true;
				}
				
				//Check if we got token
				var queryObj:Object = parseQueryString(newEvent.location);
				if ( queryObj == null && newEvent.location == "https://twitter.com/oauth/authenticate" )
				{
					dispatchEvent( new SocialAPIEvent(SocialAPIEvent.AUTHORIZATION_DENIED, "twitter", {service:"twitter"}) );
				}else if ( ready(queryObj) )
				{
					var response:Object = __getOAuthResponse(queryObj);
					if ( response && response.responseType != undefined ) dispatchEvent( new SocialAPIEvent(response.responseType, response.service, response) );
				}
			}else if ( event.type == ErrorEvent.ERROR )
			{
				_loading = false;
			}else if ( event.type == Event.COMPLETE && _targetFound )
			{
				_targetFound = false;
				_windowOpen = true;
				visible = true;
				dispatchEvent(new SocialAPIEvent(SocialAPIEvent.PAGE_LOADED, null, null));
			}
		}
		
		/*
		 * GETTER / SETTER
		 */
		
		private var _windowOpen:Boolean;
		public function get windowOpen(): Boolean
		{
			return _windowOpen;
		}
	}
}