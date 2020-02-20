package org.influxis.as3.utils 
{
	public class URLUtils 
	{
		
		public static function parseURL( targetUrl:String, convertValues:Boolean = false ): Object
		{
			if( !targetUrl || targetUrl.length == 0 ) return null;
	    	
			var sProps:String; var aProp:Array;
			var o:Object = new Object();
		    var aParamArray:Array = targetUrl.split('&');
		    for( var x:int = 0; x < aParamArray.length; x++ )
		    {
		    	var sSingleParam:String = aParamArray[x] as String;
		    	if( sSingleParam == null || sSingleParam == "" ) continue;
				aProp = sSingleParam.split("=");
				sProps = aProp.shift();
				o[sProps] = aProp.join("=");
				if( convertValues ) o[sProps] = o[sProps] == "true" || o[sProps] == "false" ? o[sProps] == "true" : o[sProps];
		    }
		    return o;
		}
	}
}