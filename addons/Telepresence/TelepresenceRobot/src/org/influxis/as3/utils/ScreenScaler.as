package org.influxis.as3.utils 
{
	//Flash Classes
	import flash.system.Capabilities;
	import flash.text.TextFormat;
	
	//Influxis Classes
	import org.influxis.as3.core.Display;
	
	public class ScreenScaler 
	{
		public static const IPHONE_1G:String = "iPhone1,1"; // first gen is 1,1 
		public static const IPHONE_3G:String = "iPhone1"; // second gen is 1,2 
		public static const IPHONE_3GS:String = "iPhone2"; // third gen is 2,1 
		public static const IPHONE_4:String = "iPhone3"; // normal:3,1 verizon:3,3 
		public static const IPHONE_4S:String = "iPhone4"; // 4S is 4,1 
		public static const IPHONE_5PLUS:String = "iPhone"; 
		public static const TOUCH_1G:String = "iPod1,1"; 
		public static const TOUCH_2G:String = "iPod2,1"; 
		public static const TOUCH_3G:String = "iPod3,1"; 
		public static const TOUCH_4G:String = "iPod4,1"; 
		public static const TOUCH_5PLUS:String = "iPod"; 
		public static const IPAD_1:String = "iPad1"; // iPad1 is 1,1 
		public static const IPAD_2:String = "iPad2"; // wifi:2,1 gsm:2,2 cdma:2,3 
		public static const IPAD_3:String = "iPad3"; // (guessing) 
		public static const IPAD_4PLUS:String = "iPad"; 
		public static const UNKNOWN:String = "unknown"; 
		
		private static const IOS_DEVICES:Array = 
		[
			IPHONE_1G, 
			IPHONE_3G, 
			IPHONE_3GS, 
			IPHONE_4, 
			IPHONE_4S, 
			IPHONE_5PLUS, 
			IPAD_1, 
			IPAD_2, 
			IPAD_3, 
			IPAD_4PLUS, 
			TOUCH_1G, 
			TOUCH_2G, 
			TOUCH_3G, 
			TOUCH_4G, 
			TOUCH_5PLUS
		];
		
		public static const IOS_DEVICE:String = getDevice();
		public static const MOBILE_DPI:Number = 120;
		public static const DESKTOP_DPI:Number = 72;
		public static const REPORT_DPI:Number = runtimeDPI();
		public static var DPI_SCALE:uint = 100;
		private static var DEFAULT_DPI:Number;
		private static var SCALING_ENABLED:Boolean;
		
		/*
		 * PUBLIC API
		 */
		
		public static function scaleTextFormat( format:TextFormat ): TextFormat
		{
			//Set default dpi if not set yet
			if ( isNaN(DEFAULT_DPI) ) setupDefaults();
			
			//Calculate new format
			if ( !SCALING_ENABLED ) return format;
			format.size = Math.floor(calculateSize(Number(format.size)));
			return format
		}
		
		public static function calculateSize( value:Number ): Number
		{
			return !SCALING_ENABLED ? value : value == 0 ? 0 : ((value / DEFAULT_DPI) * ((REPORT_DPI/100)*DPI_SCALE));
		}
		
		/*
		 * PRIVATE API
		 */
		
		private static function getDevice():String 
		{ 
			var info:Array = Capabilities.os.split(" "); 
			if (info[0] + " " + info[1] != "iPhone OS") return UNKNOWN;
			
			for each (var device:String in IOS_DEVICES) 
			{ 
				if (info[3].indexOf(device) != -1) 
				{ 
					return device; 
				} 
			} 
			return UNKNOWN; 
		}
		
		private static function runtimeDPI():Number
		{
			var os:String = Capabilities.os;
			if(os.indexOf("iPad") != -1 || os.indexOf("iPod") != -1 || os.indexOf("iPhone") != -1)
			{
				if ( os.indexOf(IPAD_3) != -1 || os.indexOf(IPHONE_4S) != -1 || (Capabilities.screenResolutionX >= 1920 || Capabilities.screenResolutionY >= 1920) )
				{
					return 320;
				}else if ( os.indexOf(IPAD_2) == -1 && (Capabilities.screenResolutionX >= 960 || Capabilities.screenResolutionY >= 960) ) 
				{
					return 260;
				}else{
					return 162;
				}
			}else{
				return Number(unescape(Capabilities.serverString).split("&DP=", 2)[1]);
			}
		}
		
		private static function setupDefaults(): void
		{
			DEFAULT_DPI = Display.IS_MOBILE ? MOBILE_DPI : DESKTOP_DPI;
			SCALING_ENABLED = DEFAULT_DPI != REPORT_DPI;/* && 
							  IOS_DEVICE != IPAD_1 && 
							  IOS_DEVICE != IPAD_2 && 
							  IOS_DEVICE != IPAD_3 &&
							  IOS_DEVICE != IPAD_4PLUS;*/
		}
	}
}