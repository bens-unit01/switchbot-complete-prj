package org.influxis.as3.data 
{
	//Flash Classes
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import org.influxis.as3.events.SimpleEvent;
	
	[Event(name = "added", type = "flash.events.Event")]
	[Event(name = "removed", type = "flash.events.Event")]
	[Event(name = "changed", type = "flash.events.Event")]
	
	public class DataProviderOld extends EventDispatcher
	{
		protected var _data:Vector.<Object>;
		
		/**
		 * INIT API
		 */
		
		public function DataProvider() 
		{
			_data = new Vector.<Object>();
		}
		
		/**
		 * PUBLIC API
		 */
		
		public function addItem( data:Object, omitEvent:Boolean = true ): void
		{
			addItemAt( _data.length, data, omitEvent );
		}
		
		public function addItemAt( index:uint, data:Object, omitEvent:Boolean = false ): void
		{
			_data[index] = data;
			if( !omitEvent ) dispatchEvent( new SimpleEvent(SimpleEvent.ADDED, null, {index:index, data:data}) );
		}
		
		public function removeItemAt( index:uint, omitEvent:Boolean = false ): void
		{
			_data.splice( index, 1 );
			if( !omitEvent ) dispatchEvent( new SimpleEvent(SimpleEvent.REMOVED, null, {index:index}) );
		}
		
		public function getItemAt( index:uint ): Object
		{
			return _data[index];
		}
		
		public function setArray( data:Array, append:Boolean, omitEvent:Boolean = false ): void
		{
			if ( append ) _data = new Vector.<Object>();
			for each( var o:Object in data )
			{
				_data.push( o );
			}
			if( !omitEvent ) dispatchEvent( new SimpleEvent(SimpleEvent.CHANGED) );
		}
		
		public function clear( omitEvent:Boolean = false ): void
		{
			_data = new Vector.<Object>();
			if( !omitEvent ) dispatchEvent( new SimpleEvent(SimpleEvent.CHANGED) );
		}
		
		/**
		 * GETTER / SETTER
		 */
		
		public function set source( value:Vector.<Object> ): void
		{
			_data = value;
			dispatchEvent( new SimpleEvent(SimpleEvent.CHANGED) );
		}
		
		public function get source(): Vector.<Object>
		{
			return _data;
		}
		
		public function get length(): uint
		{
			return _data.length;
		}
	}
}