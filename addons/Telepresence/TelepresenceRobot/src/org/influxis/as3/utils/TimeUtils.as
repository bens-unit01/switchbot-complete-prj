/**
 * TimeUtils - Copyright © 2011 Influxis All rights reserved.
**/

package org.influxis.as3.utils 
{
	public class TimeUtils
	{
		public static function getTimeFromString( time:String ): Number
		{
			if ( !time ) return NaN;
			
			var aTimes:Array = time.split(":");
				aTimes.reverse();
				
			var nTime:Number = 0;
			var nRate:Number;
			
			var nLen:Number = aTimes.length;
			for ( var i:Number = 0; i < nLen; i++ ) 
			{
				if ( i == 3 ) break;
				if ( !isNaN(aTimes[i]) ) nTime = nTime + (Number(aTimes[i]) * (i == 0 ? 1 : i == 1 ? 60 : 3600));
			}
			return nTime;
		}
	}
}