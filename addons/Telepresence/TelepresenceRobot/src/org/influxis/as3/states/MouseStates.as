package org.influxis.as3.states 
{
	public class MouseStates
	{
		public static const UP:String = "up";
		public static const DOWN:String = "down";
		public static const OVER:String = "over";
		public static const SELECTED_UP:String = "selectedUp";
		public static const SELECTED_DOWN:String = "selectedDown";
		public static const SELECTED_OVER:String = "selectedOver";
		public static const DISABLED:String = "disabled";
		
		public static function getState( selected:Boolean = false, over:Boolean = false, down:Boolean = false, enabled:Boolean = true ): String
		{
			var state:String;
			if (!enabled)
			{
				state = DISABLED;
			}else if (selected)
			{
				state = (down ? SELECTED_DOWN : over ? SELECTED_OVER : SELECTED_UP);
			}else{
				state = (down ? DOWN : over ? OVER : UP);
			}
			return state;
		}
	}
}