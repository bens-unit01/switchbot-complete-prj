/**
 * HashTable - Copyright © 2011 Influxis All rights reserved.
**/

package org.influxis.as3.data 
{
	//Influxis Classes
	import org.influxis.as3.data.database.DataCore;
	import org.influxis.as3.states.DataStates;
	import org.influxis.as3.events.SimpleEvent;
	import org.influxis.as3.utils.ArrayUtils;
	
	public class HashTable extends DataCore
	{
		/**
		 * INIT API
		 */
		
		public function HashTable( data:Object = null ): void
		{
			_data = !data ? new Object() : data;
			super(_data);
		}
		
		/**
		 * PRIVATE API
		**/
		
		override protected function updateDataContainer(command:String, slot:*, data:Object, omitEvent:Boolean = false): Boolean 
		{
			if( !command ) return false;
			
			var event:SimpleEvent;
			if( command == DataStates.ADD || command == DataStates.UPDATE )
			{
				if ( slot != undefined ) 
				{
					_data[slot] = data;
					if( !omitEvent ) event = new SimpleEvent( command, null, {slot:slot,data:data} );
				}
			}else if( command == DataStates.REMOVE )
			{
				if ( slot != undefined ) 
				{
					_data[slot] = undefined;
					delete _data[slot];
					if( !omitEvent ) event = new SimpleEvent( command, null, {slot:slot} );
				}
			}else if ( command == DataStates.CLEAR )
			{
				updateDataContainer( DataStates.REMOVE_MULTI, slots, null, omitEvent );
				if( omitEvent != true ) event = new SimpleEvent( command, null, {slot:slot} );
			}else if ( command == DataStates.ADD_MULTI || command == DataStates.CHANGE )
			{
				if ( data )
				{
					if ( command == DataStates.CHANGE ) _data = new Object();
					for ( var i:* in data )
					{
						if ( command == DataStates.CHANGE )
						{
							this.updateDataContainer( DataStates.ADD_MULTI, undefined, data, true );
						}else{
							this.updateDataContainer( DataStates.ADD, i, data[i], omitEvent );
						}
					}
					if ( command == DataStates.CHANGE && !omitEvent ) event = new SimpleEvent( command );
				}
			}else if ( command == DataStates.REMOVE_MULTI )
			{
				if ( slot != undefined && (slot is Array) )
				{
					var nLen:Number = slot.length;
					for ( var z:Number = 0; z < nLen; z++ )
					{
						this.updateDataContainer( DataStates.REMOVE, slot[z], undefined, omitEvent );
					}
				}
			}
			
			//Call the super to update slot positions
			super.updateDataContainer( command, slot, data, omitEvent );
			
			//Call events
			if (event) dispatchEvent( event );
			return true;
		}
	}
}