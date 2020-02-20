package org.influxis.as3.skins 
{
	public class DefaultTextAreaSkin
	{
		public static function get defaultSkin(): Object
		{
			var o:Object = new Object();
			o["background"] = 
			{
				backgroundColor: "white",
				borderColor: 0xcccccc,
				cornerRadius: 1
			};
			o["vScrollWidth"] = 5;
			o["paddingLeft"] = 5;
			o["paddingTop"] = 5;
			o["paddingBottom"] = 5;
			o["paddingBottom"] = 5;
			
			return o;
		}
	}
}