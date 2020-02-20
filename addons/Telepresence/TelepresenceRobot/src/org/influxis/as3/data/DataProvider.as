/**
 * DataProvider - Copyright © 2011 Influxis All rights reserved.
**/

package org.influxis.as3.data 
{
	//Influxis Classes
	import org.influxis.as3.data.database.DataCore;
	import org.influxis.as3.states.DataStates;
	import org.influxis.as3.events.SimpleEvent;
	import org.influxis.as3.utils.ArrayUtils;
	import org.influxis.as3.utils.doTimedLater;
	
	public class DataProvider extends DataCore
	{
		
		/*
		 * INIT API
		 */
		
		public function DataProvider( data:Vector.<Object> = null ): void
		{
			super(data);
			
			_data = !data ? new Vector.<Object>() : _data;
		}
		
		/*
		 * PUBLIC API
		 */
		
		public function addItem( data:Object, omitEvent:Boolean = false ): Boolean
		{
			if( !data ) return false;
			return addItemAt( length, data, omitEvent );
		}
		
		public function setArray( newData:Array, append:Boolean, omitEvent:Boolean = false ): void
		{
			if ( !append ) 
			{
				_data = new Vector.<Object>();
				resetLengthData();
			}
			
			for each( var o:Object in newData )
			{
				addItem( o, true );
			}
			
			if( !omitEvent ) dispatchEvent( new SimpleEvent(DataStates.CHANGE) );
		}
		
		public function indexOf( searchField:String, searchValue:Object ): Number
		{
			if ( !searchField || !searchValue ) return NaN;
			
			var index:Number;
			var searchData:Vector.<Object> = _data as Vector.<Object>;
			var nLen:Number = searchData.length;
			for ( var i:Number = 0; i < nLen; i++ )
			{
				try {
					if ( searchData[i][searchField] == searchValue )
					{
						index = i;
						break;
					}
				}catch ( e:Error )
				{
					
				}
			}
			return index;
		}
		
		/**
		 * PRIVATE API
		**/
		
		override protected function updateDataContainer( command:String, slot:*, data:Object, omitEvent:Boolean = false ): Boolean 
		{
			if( !command ) return false;
			
			var event:SimpleEvent;
			if( command == DataStates.ADD || command == DataStates.UPDATE )
			{
				if ( slot != undefined ) 
				{
					_data[slot] = data;
					if( omitEvent != true ) event = new SimpleEvent( command, null, {slot:slot,data:data} );
				}
			}else if( command == DataStates.REMOVE )
			{
				if ( slot != undefined ) 
				{
					var oldData:Object = _data[slot];
					_data[slot] = undefined;
					(_data as Vector.<Object>).splice(slot, 1);
					if( omitEvent != true ) event = new SimpleEvent( command, null, {slot:slot,data:oldData} );
				}
			}else if ( command == DataStates.CLEAR )
			{
				//Clear data with slots
				updateDataContainer( DataStates.REMOVE_MULTI, slots, null, omitEvent );
				if( omitEvent != true ) event = new SimpleEvent( command, null, {slot:slot} );
			}else if ( command == DataStates.ADD_MULTI || command == DataStates.CHANGE )
			{
				if ( data )
				{
					if ( command == DataStates.CHANGE ) 
					{
						_data = new Vector.<Object>();
						updateDataContainer( DataStates.ADD_MULTI, undefined, data, true );
					}else{
						for ( var i:* in data )
						{
							updateDataContainer( DataStates.ADD, i, data[i], omitEvent );
						}
					}
					if ( command == DataStates.CHANGE && omitEvent != true ) event = new SimpleEvent( command, null, data );
				}
			}else if ( command == DataStates.REMOVE_MULTI )
			{
				if ( slot != undefined && slot.length > 0 )
				{
					//Reverse order
					slot.reverse();
					var nLen:Number = slot.length;
					for ( var z:Number = 0; z < nLen; z++ )
					{
						updateDataContainer( DataStates.REMOVE, slot[z], undefined, omitEvent );
					}
				}
			}
			
			super.updateDataContainer(command, slot, data, omitEvent);
			if ( event ) dispatchEvent( event );
			return true;
		}
	}
}