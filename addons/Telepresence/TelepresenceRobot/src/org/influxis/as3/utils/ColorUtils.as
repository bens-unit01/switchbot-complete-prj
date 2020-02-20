/**
 * ColorUtils - Copyright © 2010 Influxis All rights reserved.
**/

package org.influxis.as3.utils 
{
	public class ColorUtils
	{
		private static const _CSS_COLORS_:Object = 
		{
			aqua: 0x00ffff, 	grey: 0x808080,
			navy: 0x000080, 	silver: 0xc0c0c0,
			black: 0x000000, 	green: 0x008000,
			olive: 0x808000, 	teal: 0x008080,
			blue: 0x0000ff, 	lime: 0x00ff00,
			purple: 0x800080, 	white: 0xffffff,
			fuchsia: 0xff00ff, 	maroon: 0x800000,
			red: 0xff0000, 		yellow: 0xffff00,
			orange: 0xffa500, 	pink: 0xffc0cb,
			hotpink: 0xff69b4, 	brown: 0xa52a2a
		};
		
		/**
		 * PUBLIC API
		 */
		
		//Gets the string color
		public static function getColor( color:String ): uint
		{
			return (_CSS_COLORS_[color] != undefined ? _CSS_COLORS_[color] : Number(color.replace(/^(#)/gim, "0x")));
		}
		
		//Checks if the color is valid
		public static function isValidColor( color:String ): Boolean
		{
			return !isNaN(_CSS_COLORS_[color] != undefined ? _CSS_COLORS_[color] : Number(color.replace(/^(#)/gim, "0x")));
		}
		
		//Gets the colors in a string list seperated by comma
		public static function getColors( colors:String ): Array
		{
			var aNewColors:Array = new Array();
			var aColors:Array = colors.split( "," );
			for ( var i:String in aColors )
			{
				if ( isValidColor(aColors[i]) ) aNewColors.push( getColor(aColors[i]) );
			}
			return aNewColors;
		}
		
		//Even if one is a color then its valid
		public static function isValidColors( colors:String ): Boolean
		{
			var aNewColors:Array = new Array();
			var aColors:Array = colors.split( "," );
			for ( var i:String in aColors )
			{
				if ( isValidColor(aColors[i]) ) 
				{
					aNewColors.push( getColor(aColors[i]) );
					break;
				}
			}
			return (aNewColors.length > 0);
		}
	}

}