/**
 * StreamUtils - Copyright © 2011 Influxis All rights reserved.
**/

package org.influxis.as3.utils
{
	public class StreamUtils
	{
		public static function getPlayNameFromFile( file:String ): String
		{
			if ( !file ) return null;
			var aFile:Array = file.split(".");
			var sType:String = aFile.length == 1 ? "flv" : aFile[1];
			var sFilename:String = aFile[0];
			return getPlayName(sFilename, sType);
		}
		
		public static function getOSMFPlayNameFromFile( file:String ): String
		{
			if ( !file ) return null;
			var aFile:Array = file.split(".");
			var sType:String = aFile.length == 1 ? "flv" : aFile[1];
			var sFilename:String = aFile[0];
			return getOSMFPlayName(sFilename, sType);
		}
		
		public static function getPlayName( p_sStreamName:String, p_sType:String, p_sFolder:String = "_definst_", p_sVirtualPath:String = null ) : String
		{
			var sPlayName:String = (p_sVirtualPath!=""&&p_sVirtualPath!=null?(p_sVirtualPath+"/"):"")+(p_sFolder == "_definst_" || p_sFolder == null || p_sFolder == "" ? "" : p_sFolder+"/");
			return (p_sType != "flv" ? ( p_sType == "mp3" ? "mp3" : "mp4" ) + ":" : "") + sPlayName+p_sStreamName + ( p_sType != "flv" && p_sType != "mp3" ? "." + p_sType : "");
		}
		
		public static function getOSMFPlayName( p_sStreamName:String, p_sType:String, p_sFolder:String = "_definst_", p_sVirtualPath:String = null ) : String
		{
			p_sType = !p_sType ? "flv" : p_sType;
			var sPlayName:String = (p_sVirtualPath!=""&&p_sVirtualPath!=null?(p_sVirtualPath+"/"):"")+(p_sFolder == "_definst_" || p_sFolder == null || p_sFolder == "" ? "" : p_sFolder+"/");
			return (p_sType == "flv" || p_sType == "mp3" ? p_sType : "mp4") + ":" + sPlayName+p_sStreamName + ( p_sType != "flv" && p_sType != "mp3" ? "." + p_sType : "");
		}
	}
}