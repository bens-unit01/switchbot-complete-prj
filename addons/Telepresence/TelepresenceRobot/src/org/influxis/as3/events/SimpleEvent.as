/**
 *  SimpleEvent - Copyright © 2007 Influxis All rights reserved.
**/

package org.influxis.as3.events
{
	//Flash Classes
	import flash.events.Event;
	
	public class SimpleEvent extends Event
	{
		//Enable Debugger
		public static const ADDED:String = "added";
		public static const UPDATED:String = "updated";
		public static const REMOVED:String = "removed";
		public static const CHANGED:String = "changed";
		public static const STATE:String = "state";
		
		private var _oData:Object;
		private var _sCode:String;
		
		/**
		 * INIT API
		**/ 
		
		public function SimpleEvent( p_sType:String, p_sCode:String = null, p_oData:Object = null, p_bBubbles:Boolean = false, p_bCancelable:Boolean = false )
		{
			_oData = p_oData;
			_sCode = p_sCode;
			
			super( p_sType, p_bBubbles, p_bCancelable );
		}
		
		/**
		 * EVENT OVERRIDE API
		**/
		
		public override function clone() : Event
		{
			return new SimpleEvent( type, _sCode, _oData, bubbles, cancelable );
		}
		
		public override function toString() : String
		{
			return formatToString( "type", "bubbles", "cancelable", "eventPhase", "code", "data" );
		}
		
		/**
		 * GETTER / SETTER
		**/
		
		public function get code() : String
		{
			return _sCode;
		}
		
		public function get data(): Object
		{
			return _oData;
		}
	}
}