/**
 * Singleton - Copyright © 2010 Influxis All rights reserved.
**/

package org.influxis.as3.data
{
	public class Singleton
	{
		public static var symbolName:String = "Singleton";
		public static var symbolOwner:Object = org.influxis.as3.data.Singleton;
		private var infxClassName:String = "Singleton";
		private var _sVersion:String = "1.0.0.0";
		
		public static var DEBUG:Boolean = false;
		private var _singleton:Object = new Object();
		
		 /**
		 * PUBLIC API
		 */
		 
		public function addInstance( p_sInstance:String, p_Class:* ): void
		{
			if ( _singleton[p_sInstance] != undefined ) return;
			_singleton[p_sInstance] = p_Class;
		}
		
		public function getInstance( p_sInstance:String ): *
		{
			return _singleton[p_sInstance];
		}
		
		public function destroy( p_sInstance:String ): void 
		{
			__destroyInstance( p_sInstance );
		}
		
		public function destroyAll(): void
		{
			for ( var i:String in _singleton )
			{
				__destroyInstance( i );
			}
		}
		
		/**
		 * PRIVATE API
		 */
		
		private function __destroyInstance( p_sInstance:String ): void 
		{
			_singleton[p_sInstance] = null;
			delete _singleton[p_sInstance];
		}
		
		/**
		 * GETTER / SETTER
		 */
		
		public function get dataProvider(): Object
		{
			return _singleton;
		}
	}
}