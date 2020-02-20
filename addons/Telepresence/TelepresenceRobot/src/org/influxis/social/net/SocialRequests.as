package org.influxis.social.net 
{
	//Flash Classes
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequestMethod;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	
	//Social Classes
	import org.influxis.social.data.SocialSession;
	import org.influxis.social.net.SocialRequestType;
	import org.influxis.social.events.SocialAPIEvent;
	
	public class SocialRequests extends EventDispatcher
	{
		private static const SOCIAL_URL:String = "https://social.influxis.com:31415/socapi/";
		private static const REQUEST_NAMESPACE:String = "https://social.influxis.com/socapi/requests";
		private static const RESPONSE_NAMESPACE:String = "https://social.influxis.com/socapi/responses";
		
		private var _session:SocialSession;
		protected var socialAPI:Namespace;
		protected var requestLdr:URLLoader;
		protected var apiVersion:String = "1";
		
		/*
		 * INIT API
		 */
		
		public function SocialRequests( session:SocialSession ): void 
		{
			super();
			
			if ( !session ) throw new Error( "No Session object detected" );
			if ( !session.accessToken ) throw new Error( "The session has not been authorized to make requests!" );
			
			_session = session;
			socialAPI = new Namespace(RESPONSE_NAMESPACE);
			default xml namespace = socialAPI;
			XML.prettyPrinting = false;
			
			requestLdr = new URLLoader();
			requestLdr.addEventListener( Event.COMPLETE, onRequestResult );
			requestLdr.addEventListener( Event.OPEN, openHandler );
			requestLdr.addEventListener( ProgressEvent.PROGRESS, progressHandler );
			requestLdr.addEventListener( SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler );
			requestLdr.addEventListener( HTTPStatusEvent.HTTP_STATUS, httpStatusHandler );
			requestLdr.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
		}
		
		/*
		 * PUBLIC API
		 */
		
		public function requestLocalUserData(): Boolean
		{
			sendRequest( {method:SocialRequestType.API_GET_LOCALUSER_INFO} );
			return true;
		}
		
		//posts a message to the authorized service.
		public function postMessage( postData:Object ): Boolean
		{
			if( !postData ) return false;
			if( postData.method == null ) postData.method = SocialRequestType.API_POST_MESSAGE;
			sendRequest( postData );
			return true;
		}
		
		/*
		 * HANDLERS
		 */
		
		protected function onRequestResult( event:Event ): void 
		{
			var data:Object = parseResponse(new XML((event.target as URLLoader).data));
			var type:String = data.method == SocialRequestType.API_GET_LOCALUSER_INFO ? data.success ? SocialAPIEvent.LOCAL_USER_INFO_RECEIVED : SocialAPIEvent.LOCAL_USER_INFO_FAIL : 
																						data.success ? SocialAPIEvent.POST_RESPONSE_SUCCESS : SocialAPIEvent.POST_RESPONSE_FAILED;
			if( type ) dispatchEvent(new SocialAPIEvent( type, _session.service, data ));
		}
		 
		protected function openHandler( event:Event ): void {}
		protected function progressHandler( event:ProgressEvent ): void {}//{trace("progressHandler loaded:" + event.bytesLoaded + " total: " + event.bytesTotal);}
		protected function securityErrorHandler( event:SecurityErrorEvent ): void {}//{trace("securityErrorHandler: " + event);}
		protected function httpStatusHandler( event:HTTPStatusEvent ): void {}//{trace("httpStatusHandler: " + event);}
        protected function ioErrorHandler( event:IOErrorEvent ): void {}//{trace("ioErrorHandler: " + event);}
		
		/*
		 * PROTECTED API
		 */
		 
		//returns a string for authorizing a request for social API
		protected function generateRequest( data:Object ): String
		{
			if ( data.method == null || (data.method == SocialRequestType.API_POST_MESSAGE && data.message == null) ) 
			{
				dispatchEvent( new SocialAPIEvent(SocialAPIEvent.METHOD_REQUEST_ERROR, _session.service, {code:(data.method == null ? "method" : "message")}) );
				return null;
			}
			
			return '<SocialRequest version="' + apiVersion + '" xmlns="' + REQUEST_NAMESPACE + '">' +
						'<Methods>' +
							'<Method name="'+ data.method + '">' +
								'<MethodArgs>' +
									( data.message == undefined ? "" : ('<Arg name="message"><![CDATA[' + data.message + ']]></Arg>') ) +
									( data.link == undefined ? "" : ('<Arg name="link"><![CDATA[' + data.link + ']]></Arg>') ) +
								'</MethodArgs>' +
								'<Services>' +
									'<Service name="' + _session.service + '">' +
										'<Tokens>' +
											'<FluxToken>' +  _session.fluxToken + '</FluxToken>' +
											'<AccessToken>' + _session.accessToken + '</AccessToken>' +
											'<AccessTokenSecret>' + _session.accessSecret + '</AccessTokenSecret>' +
										'</Tokens>' +
									'</Service>' +
								'</Services>' +
							'</Method>' +
						'</Methods>' +
					'</SocialRequest>';
		}
		
		protected function parseResponse( xml:XML ):Object
		{
			var o:Object = { method:xml..Method.@name, service:xml..Service.@name, success:(xml..Success.text() == "true" ? true : false) };
			var responseObject:XMLList = xml..GeneralResponse.*;
			for each( var i:XML in responseObject ) 
			{
				o[i.localName().toString()] = i.text();
			}
			return o;
		}
		
		//handles request traffic. sets the formated string needed for API
		protected function sendRequest( data:Object ): void
		{
			var social_request:String = generateRequest(data);
			if(!social_request) return;
			
			var request:URLRequest = new URLRequest();
				request.contentType = "text/xml";
				request.method = URLRequestMethod.POST;
				request.url = SOCIAL_URL;
				request.data = social_request;
			
			requestLdr.load( request );
		}
		
		/*
		 * GETTER / SETTER
		 */
		
		public function get session(): SocialSession
		{
			return _session;
		}
	}
}