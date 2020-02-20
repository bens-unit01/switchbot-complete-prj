/**
 * DataCore - Copyright © 2011 Influxis All rights reserved.
**/

package org.influxis.as3.data.database 
{
	//Flash Classes
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	//Influxis Classes
	import org.influxis.as3.states.DataStates;
	import org.influxis.as3.utils.ObjectUtils;
	
	//Events
	[Event(name = "addItem", type = "org.influxis.as3.events.SimpleEvent")]
	[Event(name = "addItems", type = "org.influxis.as3.events.SimpleEvent")]
	[Event(name = "removeItem", type = "org.influxis.as3.events.SimpleEvent")]
	[Event(name = "removeItems", type = "org.influxis.as3.events.SimpleEvent")]
	[Event(name = "updateItem", type = "org.influxis.as3.events.SimpleEvent")]
	[Event(name = "clear", type = "org.influxis.as3.events.SimpleEvent")]
	[Event(name = "change", type = "org.influxis.as3.events.SimpleEvent")]
	
	public class DataCore extends EventDispatcher
	{
		protected var _data:Object;
		private var _rows:uint;
		private var _slots:Vector.<Object>;
		private var _indexHolder:Dictionary;
		
		/**
		 * INIT API
		 */
		
		public function DataCore( data:Object = null ): void 
		{
			_slots = new Vector.<Object>();
			_indexHolder = new Dictionary();
			if( data ) updateDataContainer( DataStates.CHANGE, undefined, data, true );
		}
		
		/**
		 * PUBLIC API
		**/
		
		public function addItemAt( slot:*, data:Object, omitEvent:Boolean = false ): Boolean
		{
			if ( slot == undefined ) return false;
			return updateDataContainer( DataStates.ADD, slot, data, omitEvent );
		}
		
		public function addItemsAt( data:Object, omitEvent:Boolean = false ): Boolean
		{
			if ( !data ) return false;
			return updateDataContainer( DataStates.ADD_MULTI, undefined, data, omitEvent );
		}
		
		public function removeItemAt( slot:*, omitEvent:Boolean = false ): Boolean
		{
			if ( slot == undefined ) return false;
			return updateDataContainer( DataStates.REMOVE, slot, null, omitEvent );
		}
		
		public function removeItemsAt( slots:Array, omitEvent:Boolean = false ): Boolean
		{
			if ( !slots ) return false;
			return updateDataContainer( DataStates.REMOVE_MULTI, slots, null, omitEvent );
		}
		
		public function updateItemAt( slot:*, data:Object, omitEvent:Boolean = false ): Boolean
		{
			if ( slot == undefined ) return false;
			return updateDataContainer( DataStates.UPDATE, slot, data, omitEvent );
		}
		
		public function clear( omitEvent:Boolean = false ): Boolean
		{
			return updateDataContainer( DataStates.CLEAR, undefined, undefined, omitEvent );
		}
		
		public function exists( slot:* ): Boolean
		{
			return (_data[slot] != undefined);
		}
		
		public function getItemAt( slot:* ): Object
		{
			if ( !_data || slot == undefined ) return null;
			return _data[slot];
		}
		
		public function getItemSlotAt( data:Object ): *
		{
			return _indexHolder[data];
		}
		
		/**
		 * PROTECTED API
		**/
		
		protected function updateDataContainer( command:String, slot:*, data:Object, omitEvent:Boolean = false ): Boolean
		{
			if( !command || slot == undefined ) return false;
			
			__refreshDataInfo();
			
			//Extend this method here
			return true;
		}
		
		/**
		 * PRIVATE API
		**/
		
		private function __refreshDataInfo(): void
		{
			_rows = 0;
			_slots = new Vector.<Object>();
			for ( var i:* in _data )
			{
				++_rows;
				_indexHolder[_data[i]] = i;
				_slots.push(i);
			}
		}
		
		protected final function resetLengthData(): void
		{
			_rows = 0;
			_slots = new Vector.<Object>();
			_indexHolder = new Dictionary();
		}
		
		/**
		 * GETTER / SETTER
		**/
		
		public function set source( data:Object ): void
		{
			updateDataContainer( DataStates.CHANGE, undefined, data, true );
		}
		
		public function get source(): Object
		{
			return _data;//ObjectUtils.cloneObject(_data);//
		}
		
		/*public function get copy(): Object
		{
			return ObjectUtils.cloneObject(_data);
		}*/
		
		public function get length(): uint
		{
			return _rows;
		}
		
		public function get slots(): Vector.<Object>
		{
			return _slots;
		}
		
		public function get isEmpty(): Boolean
		{
			return (length == 0);
		}
	}
}