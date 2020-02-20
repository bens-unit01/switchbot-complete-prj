/**
 * RegUtils - Copyright © 2011 Influxis All rights reserved.
**/

package org.influxis.as3.utils 
{
	public class RegUtils
	{
		//Parses a comma list within a comma list seperated by brackets []
		public static function parseCommaList( list:String, checkResult:Boolean = true, formatFunction:Function = null ): Array
		{
			if ( !list ) return null;
				
			var aMatches:Array = list.match( /(\[)[^\[\]]+(\])|[^,\s\[\]]+/gi );
			var nLen:Number = aMatches.length;
			for( var i:Number = 0; i < nLen; i++ )
			{
				//Take of [] that might still be on the list
				aMatches[i] = aMatches[i].replace( /(^(\s+)?\[)|(\](\s+)?$)/gi, "" );
				if( aMatches[i].indexOf(",") != -1 && checkResult ) 
				{
					if ( formatFunction != null )
					{
						aMatches[i] = formatFunction.apply( null, [aMatches[i]] );
					}else {
						aMatches[i] = parseCommaList(aMatches[i], false );
					}
				}
			}
			return aMatches;
		}
	}
}