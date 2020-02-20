package org.influxis.as3.states 
{
	//Influxis Classes
	import org.influxis.as3.utils.ArrayUtils;
	
	public class OrderStates
	{
		public static const NORMAL:String = "normal";
		public static const SHUFFLE:String = "shuffle";
		public static const REVERSE:String = "reverse";
		public static const ORDERED_SHUFFLE:String = "orderedShuffle";
		public static const REVERSE_SHUFFLE:String = "reverseShuffle";
		
		public static function orderList( orderList:String, data:* ): Object
		{
			if ( !orderList || !data || orderList == NORMAL ) return data;
			
			var newList:Object = data;
			if ( data is Array || data is Vector.<Object> ) 
			{
				if ( orderList == REVERSE )
				{
					trace( "orderList: " );
					newList = (data is Array) ? ArrayUtils.duplicateArray(data) : ArrayUtils.duplicateVector(data);
					newList.reverse();
				}else{
					newList = ArrayUtils.shuffle( data, (data is Vector.<Object>) );
				}
			}
			return newList;
		}
	}
}