package org.influxis.social.data 
{
	//Social Classes
	import org.influxis.social.core.social_internal;
	
	public class SocialSession 
	{
		use namespace social_internal;
		
		private var _service:String;
		private var _fluxToken:String;
		private var _accessToken:String;
		private var _accessSecret:String;
		
		/*
		 * INIT API
		 */
		
		public function SocialSession( service:String, fluxToken:String ): void
		{
			_service = service;
			_fluxToken = fluxToken;
		}
		
		/*
		 * GETTER / SETTER
		 */
		
		public function get service(): String
		{
			return _service;
		}
		
		public function get fluxToken(): String
		{
			return _fluxToken;
		}
		 
		public function get accessToken(): String
		{
			return _accessToken;
		}
		 
		social_internal function set accessToken( value:String ): void
		{
			_accessToken = value;
		}
		
		public function get accessSecret(): String
		{
			return _accessSecret;
		}
		 
		social_internal function set accessSecret( value:String ): void
		{
			_accessSecret = value;
		}
	}
}