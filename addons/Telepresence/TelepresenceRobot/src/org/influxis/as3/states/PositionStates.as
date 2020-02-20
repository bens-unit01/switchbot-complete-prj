package org.influxis.as3.states 
{
	public class PositionStates
	{
		public static const LEFT:String = "left";
		public static const CENTER:String = "center";
		public static const RIGHT:String = "right";
		public static const UP:String = "up";
		public static const MIDDLE:String = "middle";
		public static const DOWN:String = "down";
		public static const TOP:String = "top";
		public static const BOTTOM:String = "bottom";
		
		public static const LEFT_TOP:String = "topLeft";
		public static const LEFT_MIDDLE:String = "middleLeft";
		public static const LEFT_BOTTOM:String = "bottomLeft";
		public static const CENTER_TOP:String = "topCenter";
		public static const CENTER_MIDDLE:String = "middleCenter";
		public static const CENTER_BOTTOM:String = "bottomCenter";
		public static const RIGHT_TOP:String = "topRight";
		public static const RIGHT_MIDDLE:String = "middleRight";
		public static const RIGHT_BOTTOM:String = "bottomRight";
		
		public static function getPosition( value:String, horizontal:Boolean = false ): String
		{
			if ( !value ) return null;
			return (value.toLocaleLowerCase().replace( new RegExp(horizontal?"top|middle|bottom":"left|center|right", "gi"), "" ));
		}
	}
}