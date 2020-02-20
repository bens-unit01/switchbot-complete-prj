/**
 * ImageUtils - Copyright © 2009 Influxis All rights reserved.
**/

package org.influxis.as3.utils
{
	//Influxis Classes
	import org.influxis.as3.core.Display;
	
	public class ImageUtils
	{
		public static var symbolName:String = "ImageUtils";
		public static var symbolOwner:Object = org.influxis.as3.utils.ImageUtils;
		private var infxClassName:String = "ImageUtils";
		private var _sVersion:String = "1.0.0.0";
		
		private static const _VALID_IMAGE_TYPES_:Object = 
		{
			jpg:true,
			swf:true,
			png:true,
			gif:true	
		}
		
		public function ImageUtils(){}
		
		/**
		 * PUBLIC API
		**/
		
		//Formats an image url so we can send it to the server
		public static function getImageInfo( p_sPath:String, igonoreValid:Boolean = false ): Object
		{
			//trace( "getImageInfo: " + imageIsValid(p_sPath) );
			if( !imageIsValid(p_sPath) && !igonoreValid ) return null;
			
			var sPath:String = p_sPath.indexOf("?") != -1 ? p_sPath.substring( 0, p_sPath.indexOf("?") ) : p_sPath;
			var sFile:String;
			if( sPath.indexOf("/") != -1 )
			{
				sFile = sPath.substring( sPath.lastIndexOf("/")+1, sPath.length );
			}else{
				sFile = sPath;
			}
			
			if( sFile.indexOf(".") == -1 ) return null;
			
			var aFileInfo:Array = sFile.split( "." );
			var sType:String = aFileInfo[1];
			var o:Object = new Object();
				o[ "filename" ] = aFileInfo[0];
				o[ "type" ] = aFileInfo[1];
				o[ "path" ] = sFile;
				o[ "image" ] = sPath;
				
			return o;
		}
		
		public static function imageIsValid( p_sPath:String ) : Boolean
		{
			if( p_sPath == "" || p_sPath == "http://" ) return false;
			
			var sPath:String = p_sPath;
			var sFile:String;
			if( sPath.indexOf("/") != -1 )
			{
				sFile = sPath.substring( sPath.lastIndexOf("/")+1, sPath.length );
			}else{
				sFile = sPath;
			}
			
			if( sFile.indexOf(".") == -1 ) return false;
			var aFileInfo:Array = sFile.split( "." );
			var sType:String = aFileInfo[1];
			
			var bValidImage:Boolean = (_VALID_IMAGE_TYPES_[sType] == true);
			return bValidImage
		}
		
		public static function checkImageLocalPath( p_sSource:String ): String
        {
        	if( p_sSource == null ) return null;
        	
        	var oInfo:Object = getImageInfo( p_sSource, true );
        	if( !oInfo ) return null;
        	
        	var sPath:String = p_sSource;
        	if( p_sSource == (oInfo.filename+"."+oInfo.type) )
        	{
        		try
        		{
        			if( Display.ROOT.loaderInfo.url )
        			{
        				sPath = Display.ROOT.loaderInfo.url;
        				if( sPath.indexOf("?") != -1 ) sPath = sPath.substring( 0, sPath.indexOf("?") );
        				sPath = sPath.substr( 0, sPath.lastIndexOf("/") )+"/"+(oInfo.filename+"."+oInfo.type);
        			}
        		}catch( e:Error )
        		{
        			trace( e );
        		}
        	}
        	return sPath;
        }
	}
}