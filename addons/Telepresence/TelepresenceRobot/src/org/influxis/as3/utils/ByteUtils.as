/**
 * ByteUtils - Influxis Copyright @2011 - All Rights Reserved
**/

package org.influxis.as3.utils
{
	//Flash Classes
	import flash.utils.ByteArray;
	
	public class ByteUtils
	{		
		/**
		 * PUBLIC API
		**/
		
		public static function bytesToArray( p_ba:ByteArray ): Array
		{
			if( p_ba == null ) return null;
			
			var aBytes:Array = new Array();
			
			p_ba.position = 0;
			var nLen:Number = p_ba.bytesAvailable;
			
			for( var i:Number = 0; i < nLen; i++ )
			{
				aBytes.push( Number(p_ba.readByte()) );
			}
			return aBytes;
		}
		
		public static function arrayToBytes( p_aBytes:Array ): ByteArray
		{
			if( p_aBytes == null ) return null;
			
			var ba:ByteArray = new ByteArray();
			for each( var n:Number in p_aBytes )
			{
				ba.writeByte( (n as int) );
			}
			
			ba.position = 0;
			return ba;
		}
	}
}