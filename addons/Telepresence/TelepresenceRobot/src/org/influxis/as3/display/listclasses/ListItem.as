/**
 * ListItem - Copyright © 2011 Influxis All rights reserved.
**/

package org.influxis.as3.display.listclasses 
{
	//Influxis Classes
	import org.influxis.as3.interfaces.data.IDatable;
	import org.influxis.as3.interfaces.states.ISelectable;
	import org.influxis.as3.skins.StateSkin;
	
	public class ListItem extends StateSkin implements IDatable, ISelectable
	{
		private var _data:Object;
		
		/**
		 * INIT API
		 */
		
		public function ListItem( skinName:String = "List" ): void
		{
			super( skinName, "itemBackground", false );
		}
		 
		/**
		 * GETTER / SETTER
		 */
		
		public function set data( value:Object ): void
		{
			_data = value;
		}
		
		public function get data(): Object
		{
			return _data;
		}
	}
}