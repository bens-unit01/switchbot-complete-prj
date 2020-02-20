package org.influxis.as3.events 
{
	//Flash Classes
	import flash.events.Event;
	
	public class DataEvent extends Event
	{
		private var _data:Object;
		
		/*
		 * INIT API
		 */
		
		public function DataEvent( type:String, data:Object, bubbles:Boolean = false, cancelable:Boolean = false ): void
		{
			super( type, bubbles, cancelable );
			_data = data;
		}
		
		/*
		 * PUBLIC API
		 */
		
		override public function clone(): Event 
		{
			return new DataEvent( type, _data, bubbles, cancelable );
		}
		
		/*
		 * GETTER / SETTER
		 */
		
		public function get data(): Object
		{
			return _data;
		}
		
		public function set data( value:Object ): void
		{
			_data = value;
		}
	}
}