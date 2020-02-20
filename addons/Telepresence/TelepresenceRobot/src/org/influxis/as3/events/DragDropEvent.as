package org.influxis.as3.events 
{
	//Flash Classes
	import flash.events.Event;
	
	//Influxis Classes
	import org.influxis.as3.events.DataEvent;
	
	public class DragDropEvent extends DataEvent
	{
		public static const DRAG_START:String = "dragItemStart";
		public static const DRAG_OVER:String = "dragItemOver";
		public static const DRAG_OUT:String = "dragItemOut";
		public static const DRAG_DROP:String = "dragItemDrop";
		
		/*
		 * INIT API
		 */
		
		public function DragDropEvent( type:String, data:Object, bubbles:Boolean = false, cancelable:Boolean = false ): void
		{
			super( type, data, bubbles, cancelable );
		}
		
		/*
		 * PUBLIC API
		 */
		
		override public function clone(): Event 
		{
			return new DragDropEvent( type, data, bubbles, cancelable );
		}
	}
}