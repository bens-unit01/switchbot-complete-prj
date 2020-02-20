/**
 * ScrollTrack - Copyright © 2010 Influxis All rights reserved.
**/

package org.influxis.as3.display.scrollbarclasses 
{
	//Influxis Classses
	import org.influxis.as3.display.Slider;
	import org.influxis.as3.states.PositionStates;
	
	public class ScrollTrack extends Slider
	{
		private var _sVersion:String = "1.0.0.0";
		
		/**
		 * INIT API
		 */
		
		override protected function preInitialize(): void 
		{
			direction = PositionStates.DOWN;
			super.preInitialize();
		}
		
		/**
		 * DISPLAY API
		 */
		
		override protected function arrange(): void 
		{
			if ( direction == PositionStates.UP || direction == PositionStates.DOWN )
			{
				cbThumb.width = width;
				cbThumb.height = cbThumb.width;
			}else {
				cbThumb.height = height;
				cbThumb.width = cbThumb.height;
			}
			super.arrange();
		}
	}
}