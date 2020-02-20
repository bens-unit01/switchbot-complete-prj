/**
 * DateUtils - Copyright © 2010 Influxis All rights reserved.
**/

package org.influxis.as3.utils
{
	public class DateUtils
	{
		public static var LOCAL_ZONE:int = (-(new Date().getTimezoneOffset()/60));
		private static var MONTH_DAYS:Object =
		{
			month0:31,
			month1:28,
			month2:31,
			month3:30,
			month4:31,
			month5:30,
			month6:31,
			month7:31,
			month8:30,
			month9:31,
			month10:30,
			month11:31
		}
		
		/**
		 * PUBLIC API
		 */
		
		public static function get TIME_MILLI_NOW(): Number
		{
			return (new Date().getTime());
		}
		
		public static function getHourFormat( p_nHours:Number, p_sAM:String = "am", p_sPM:String = "pm" ): Object
		{
			if( isNaN(p_nHours) ) return null;
			
			var oHoursFormat:Object = new Object();
				oHoursFormat[ "format" ] = ( p_nHours < 12 ) ? "am" : "pm";
				oHoursFormat[ "hours" ] = p_nHours == 0 || p_nHours == 12 ? 12 : p_nHours % 12;
			
			return oHoursFormat;
		}
		
		public static function formatHour( p_nHours:Number, p_sAM:String = "am", p_sPM:String = "pm" ): String
		{
			if( isNaN(p_nHours) ) return null;
			return String(p_nHours == 0||p_nHours == 12?12:p_nHours%12)+" "+((p_nHours < 12 )?p_sAM:p_sPM);
		}
		
		public static function getDateFormat( p_nUniTime:Number, p_bUseEastern:Boolean ) : String
		{
			if( isNaN(p_nUniTime) ) return null;
			
			var dat:Date = new Date( p_nUniTime );
			var sYear:String = String(dat.getFullYear());
			var sMonth:String = roundZeroTime( dat.getMonth() + 1 );
			var sDay:String = roundZeroTime( dat.getDate() );
			var sDate:String = (p_bUseEastern == true ? (sDay+"/"+sMonth) : (sMonth+"/"+sDay) ) + "/" + sYear;
			
			return sDate;
		}
		
		public static function getTimeFormat( p_nUniTime:Number, p_sAM:String, p_sPM:String ) : String
		{
			if( isNaN(p_nUniTime) ) return null;
			
			var dat:Date = new Date( p_nUniTime );
			var oHourFormat:Object = getHourFormat( dat.getHours() );
			var sHour:String = String( oHourFormat.hours );
			var sMinutes:String = roundZeroTime( dat.getMinutes() );
			var sSeconds:String = roundZeroTime( dat.getSeconds() );
			var sTimeFormat:String = (oHourFormat.format == "am" ? p_sAM : p_sPM);
				sTimeFormat = sTimeFormat == null ? oHourFormat.format : sTimeFormat;
			
			var sTime:String = sHour +":"+ sMinutes +":"+ sSeconds +" "+ sTimeFormat;
			return sTime;
		}
		
		public static function getTimeLength( p_nTime:Number, p_bOmitZeroHours:Boolean = false ): String
		{
			if( isNaN(p_nTime) ) return null;
			
			var nHour:* = p_nTime >= 3600 ? Math.floor(p_nTime / 3600) : 0;
			var nMin:* = nHour != 0 ? Math.floor((p_nTime - (nHour * 3600)) / 60) : Math.floor(p_nTime / 60);
			var nSec:* = p_nTime > 59 ? Math.floor((p_nTime - ((nMin * 60) + (nHour * 3600)))) : Math.floor(p_nTime);
			
			nHour = nHour > 9 ? nHour : "0" + nHour;
			nMin = nMin > 9 ? nMin : "0" + nMin;
			nSec = nSec > 9 ? nSec : "0" + nSec;
			
			var sTime:String = ( p_bOmitZeroHours == true && nHour == "00" ? "" : nHour + ":" ) + nMin + ":" + nSec;
			return sTime;
		}
		
		public static function getTotalDays( p_nMonth:Number ) : Number
		{
			if( isNaN(p_nMonth) ) return NaN;
			
			var nTotalDays:Number = MONTH_DAYS[ "month" + String( p_nMonth ) ];
			return nTotalDays;
		}
		
		public static function roundZeroTime( p_nTime:Number ) : String
		{
			if( isNaN(p_nTime) ) return null;
			
			var sTime:String = String( p_nTime < 10 ? "0" + p_nTime : p_nTime );
			return sTime;
		}
		
		//[Depricated See toTimeZone below]
		public static function getTimezoneTime( p_nTargetTimezone:Number, p_nDateTimeZone:Number, p_datCurrent:Date ): Date
		{
			var newDay:Date = new Date( p_datCurrent.getTime() - (getHourMilliSeconds(p_nDateTimeZone)-getHourMilliSeconds(p_nTargetTimezone)) );
			return newDay;
		}
		
		public static function getHourMilliSeconds( p_nHours:Number ): Number
		{
			var nHour:Number = p_nHours * 3600000;
			return nHour;
		}
		
		//Convert date time to specific time zone time
		public static function toTimeZone( p_dat:Date, p_nTargetZone:int = 0, p_nOriginZoneHours:Number = NaN ): Date
		{
			var dat:Date;
			if( isNaN(p_nOriginZoneHours) == true ) 
			{
				dat = (new Date(new Date(p_dat.getUTCFullYear(), p_dat.getUTCMonth(), p_dat.getUTCDate(), p_dat.getUTCHours(), p_dat.getUTCMinutes(), p_dat.getUTCSeconds(), p_dat.getUTCMilliseconds()).getTime() + (p_nTargetZone*3600000)));
			}else{
				dat = new Date( p_dat.getTime() - ((p_nOriginZoneHours*3600000)-(p_nTargetZone*3600000)) );
			}
			return dat;
		}
		
		//Convert date to string format
		public static function toString( p_dat:Date, p_nTargetZone:Number = NaN, p_nOriginZoneHours:Number = NaN ): String
		{
			if( p_dat == null ) return null;
			
			var dat:Date = isNaN(p_nTargetZone) != true || isNaN(p_nOriginZoneHours) != true ? toTimeZone(p_dat, p_nTargetZone, p_nOriginZoneHours) : p_dat;
			return String(dat.getMonth()+"/"+dat.getDate()+"/"+dat.getFullYear()+" "+dat.getHours()+":"+dat.getMinutes()+":"+dat.getSeconds()+" "+(isNaN(p_nTargetZone)==true?(String(-(dat.getTimezoneOffset()/60))) : p_nTargetZone));
		}
		
		//Convert string date to date object
		public static function toDate( p_sdat:String, p_nTargetZone:Number = NaN, p_bRealTime:Boolean = false ): Date
		{
			if( p_sdat == null ) return null;
			
			var aDatElements:Array = p_sdat.split( " " );
			var aDate:Array, aTime:Array, nTimeOffset:int;
			
			var nLen:uint = aDatElements.length;
			for( var i:Number = 0; i < nLen; i++ )
			{
				if( aDatElements[i].indexOf("/") != -1 )
				{
					aDate = aDatElements[i].split( "/" );
				}else if( aDatElements[i].indexOf(":") != -1 ) 
				{
					aTime = aDatElements[i].split( ":" );
				}else if( isNaN(Number(aDatElements[i])) != true )
				{
					nTimeOffset = Number(aDatElements[i]);
				}
			}
			var dat:Date = new Date();
			if( aDate != null && aTime != null )
			{
				dat = new Date( Number(aDate[2]),(Number(aDate[0])-(p_bRealTime?1:0)), Number(aDate[1]), Number(aTime[0]), Number(aTime[1]), Number(aTime[2]), 0 );
			}else if( aDate == null && aTime != null )
			{
				dat = new Date( dat.getFullYear(), dat.getMonth(), dat.getDate(), Number(aTime[0]), Number(aTime[1]), Number(aTime[2]), 0 );
			}else if( aDate != null && aTime == null )
			{
				dat = new Date( Number(aDate[2]),(Number(aDate[0])-(p_bRealTime?1:0)), Number(aDate[1]), dat.getHours(), dat.getMinutes(), dat.getSeconds(), 0 );
			}
			if( (isNaN(nTimeOffset) != true && nTimeOffset != (-(dat.getTimezoneOffset()/60))) || isNaN(p_nTargetZone) != true ) dat = toTimeZone( dat, (isNaN(p_nTargetZone)==true?nTimeOffset:p_nTargetZone), nTimeOffset );
			return dat;
		}
	}
}