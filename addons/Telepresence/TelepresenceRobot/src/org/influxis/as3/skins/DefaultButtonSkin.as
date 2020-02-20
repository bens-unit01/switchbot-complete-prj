package org.influxis.as3.skins 
{
	public class DefaultButtonSkin
	{
		public static const BG_UP:String = "background:up";
		public static const BG_OVER:String = "background:over";
		public static const BG_DOWN:String = "background:down";
		public static const BG_DISABLED:String = "background:disabled";
		
		public static const ICON_UP:String = "icon:up";
		public static const ICON_OVER:String = "icon:over";
		public static const ICON_DOWN:String = "icon:down";
		public static const ICON_DISABLED:String = "icon:Disabled";
		
		public static const LABEL_UP:String = "label:up";
		public static const LABEL_OVER:String = "label:over";
		public static const LABEL_DOWN:String = "label:down";
		public static const LABEL_DISABLED:String = "label:disabled";
		
		public static function get defaultSkin(): Object
		{
			var o:Object = new Object();
			o[ "background:up" ] = 
			{
				cornerRadius: [1, 1, 1, 1],
				backgroundColor: [0xcccccc]	
			};
			
			o[ "background:over" ] = 
			{
				cornerRadius: [1, 1, 1, 1],
				backgroundColor: [0xaaaaaa]
			};
			
			o[ "background:down" ] = 
			{
				cornerRadius: [1, 1, 1, 1],
				backgroundColor: [0xcccccc]
			};
			
			o[ "background:selectedUp" ] = 
			{
				cornerRadius: [1, 1, 1, 1],
				backgroundColor: [0xaaaaaa]
			};
			
			o[ "background:selectedOver" ] = 
			{
				cornerRadius: [1, 1, 1, 1],
				backgroundColor: [0x999999]
			};
			
			o[ "background:selectedDown" ] = 
			{
				cornerRadius: [1, 1, 1, 1],
				backgroundColor: [0xaaaaaa]
			};
			
			o[ "background:disabled" ] = 
			{
				cornerRadius: [1, 1, 1, 1],
				backgroundColor: [0xeeeeee]
			};
			
			o[ "label:up" ] = { color: 0x000000 };
			o[ "label:over" ] = { color: 0xffffff };
			o[ "label:down" ] = { color: 0x000000 };
			o[ "label:selectedUp" ] = { color: 0x000000 };
			o[ "label:selectedOver" ] = { color: 0xffffff };
			o[ "label:selectedDown" ] = { color: 0x000000 };
			o[ "label:disabled" ] = { color: 0xcccccc };
			
			return o;
		}
	}
}