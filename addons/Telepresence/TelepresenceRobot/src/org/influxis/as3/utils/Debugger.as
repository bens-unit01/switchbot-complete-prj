/**
 * Debugger - Copyright © 2008 Influxis All rights reserved.
**/

package org.influxis.as3.utils
{
	public class Debugger
	{
		public static var symbolName:String = "Debugger";
		public static var symbolOwner:Object = org.influxis.as3.utils.Debugger;
		private var infxClassName:String = "Debugger";
		private var _sVersion:String = "1.0.0.0";
		
		private static var _DEBUGGER_LIST_:Object;
		
		/**
		 * PUBLIC API
		**/
		
		public static function setDebugger( p_sDebugName:String, p_bAllow:Boolean ): void
		{
			_DEBUGGER_LIST_ = _DEBUGGER_LIST_ == null ? new Object() : _DEBUGGER_LIST_;
			_DEBUGGER_LIST_[ p_sDebugName ] = p_bAllow;
		}
		
		public static function tracer( p_sDebugName:String, p_sMsg:* ): void
		{
			if( debugAllowed(p_sDebugName) ) trace( "#"+p_sDebugName+"# " + p_sMsg );
		}
		
		/**
		 * PRIVATE API
		**/
		
		private static function debugAllowed( p_sDebugName:String ): Boolean
		{
			if( p_sDebugName == null || _DEBUGGER_LIST_ == null ) return false;
			return (_DEBUGGER_LIST_[p_sDebugName] == true)
		}
	}
}