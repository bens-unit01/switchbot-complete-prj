/**
 * Display - Copyright © 2010 Influxis All rights reserved.
**/

package org.influxis.as3.core 
{
	//Flash Classes
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.system.Capabilities;
	
	public class Display
	{
		public static var STAGE:Stage;
		public static var ROOT:DisplayObject;
		public static var APPLICATION:DisplayObject;
		public static var IS_MOBILE:Boolean;
		public static const IS_IOS:Boolean = Capabilities.os.indexOf("iPad") != -1 || Capabilities.os.indexOf("iPod") != -1 || Capabilities.os.indexOf("iPhone") != -1;
	}
}