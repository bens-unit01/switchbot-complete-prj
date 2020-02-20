/**
 * HTTPUtil v1.0.0.0 - Copyright © 2010 Influxis All rights reserved.
**/

package org.influxis.as3.utils
{
	//Flash Classes
	import flash.external.ExternalInterface;
	
	public class HTTPUtil
	{
		public static var symbolName:String = "HTTPUtil";
		public static var symbolOwner:Object = org.influxis.as3.utils.HTTPUtil;
		private var infxClassName:String = "HTTPUtil";
		private var _sVersion:String = "1.0.0.0";
		
		/**
		 * PUBLIC API
		**/
		
	    //Returns Url
	    public static function getUrl(): String
	    {
	    	return String( callExternal("window.location.href.toString") );
	    }
	    
	    //Returns web domain
	    public static function getHostName():String
	    {
	    	return String(callExternal("window.location.hostname.toString"));
	    }
	    
	    public static function getHostBrowser(): String
	    {
	    	var sBrowserUse:String;
	    	
	    	var sUserAgent:String = String( callExternal("navigator.userAgent.toString") ).toLocaleLowerCase();
			if( sUserAgent == null ) return null;
			
			//Check for browsers
			var bOpera:Boolean = (sUserAgent.indexOf('opera') != -1);
			var bIE:Boolean = (sUserAgent.indexOf('msie') != -1);
			var bGecko:Boolean = (sUserAgent.indexOf('gecko') != -1);
			var bFirefox:Boolean = (sUserAgent.indexOf('firefox') != -1);
			var bSafari:Boolean = (sUserAgent.indexOf('safari') != -1 && sUserAgent.indexOf('chrome') == -1);
			var bCamino:Boolean = (sUserAgent.indexOf('camino') != -1);
			var bOldNetscape:Boolean = (sUserAgent.indexOf('mozilla') != -1);
			var bChrome:Boolean = (sUserAgent.indexOf('chrome') != -1);
			
			if( bOpera )
			{
				sBrowserUse = "opera";
			}else if( bIE )
			{
				sBrowserUse = "ie";
			}else if( bGecko )
			{
				if( bChrome )
				{
					sBrowserUse = "chrome";
				}else if( bSafari )
				{
					sBrowserUse = "safari";
				}else if( bFirefox )
				{
					sBrowserUse = "firefox";
				}else if( bCamino )
				{
					sBrowserUse = "camino";
				}else{
					sBrowserUse = "mozilla";
				}
			}else if( bOldNetscape )
			{
				sBrowserUse = "netscape";
			}else{
				sBrowserUse = "unknown";
			}
			return sBrowserUse;
	    }
	    
	    //returns protocol
	    public static function getProtocol():String
	    {
	    	return String( callExternal("window.location.protocol.toString") );
	    } 
	    
	    //Returns window port
	    public static function getPort():String
	    {
	    	return String( callExternal("window.location.port.toString") );
	    }
	    
	    //Gets the context
	    public static function getContext():String
	    {
	    	return String( callExternal("window.location.pathname.toString") );
	    }
	    
	    //Gets URL paramter property
	    public static function getURLProperty( p_sProp:String ): String
	    { 
	    	var sValue:String;
	    	var sParams:String = String( callExternal("window.location.search.toString") );
	    	
	    	if ( sParams == null || sParams.length == 0 ) return null;
			
		    var aParamArray:Array = sParams.split('&');
		    for( var x:int = 0; x < aParamArray.length; x++ )
		    {
		    	var sSingleParam:String = aParamArray[x] as String;
		    	if( sSingleParam == null || sSingleParam == "" ) continue;
		    	if( sSingleParam.indexOf(p_sProp + '=') > -1 )
		    	{
		    		sValue = ( sSingleParam.replace( (p_sProp + '=' ), '') ).replace( '?','' );
		    		break;
		    	}
		    }
		    return sValue;
	    }
	    
	    /**
	     * PRIVATE API
	    **/ 
	    
	    private static function callExternal( ...p_aArgs ): *
	    {
	    	var o:*;
	    	try
	    	{
	    		o = ExternalInterface.call.apply( ExternalInterface, p_aArgs );
	    	}catch( e:Error )
	    	{
	    		return null;
	    	}
	    	return o;
	    }
	}
}