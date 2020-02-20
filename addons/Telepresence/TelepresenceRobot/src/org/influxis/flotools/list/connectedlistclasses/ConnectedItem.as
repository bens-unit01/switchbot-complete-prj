package org.influxis.flotools.list.connectedlistclasses 
{
	//Flash Classes
	import flash.net.NetConnection;
	
	//Influxis Classes
	import org.influxis.as3.display.listclasses.ListItem;
	import org.influxis.as3.interfaces.net.IFMS;
	
	public class ConnectedItem extends ListItem implements IFMS
	{
		protected var _netConnection:NetConnection;
		private var _instance:String;
		
		/*
		 * INIT API
		 */
		
		public function ConnectedItem( skinName:String ): void
		{
			super(skinName);
		}
		 
		/*
		 * CONNECTED API
		 */
		
		public function connect( netConnection:NetConnection ): Boolean
		{
			if ( !netConnection || !netConnection.connected ) return false;
			_netConnection = netConnection;
			if ( instance ) instanceChange();
			return true;
		}
		
		public function close(): void
		{
			instanceClose();
			_netConnection = null;
		}
		
		protected function instanceClose(): void
		{
			if ( !instance || !connected ) return;
			
		}
		 
		protected function instanceChange(): void
		{
			if ( !connected || !instance ) return;
			
		}
		
		/*
		 * PRIVATE API
		 */
		
		private function __onInstanceChange( value:String ): void
		{
			if ( _instance == value ) return;
			if ( _instance ) instanceClose();
			
			_instance = value;
			//refreshItemInstances();
			if( _instance ) instanceChange();
		}
		
		/*
		 * GETTER / SETTER API
		 */
		
		public function get connected(): Boolean
		{
			return !_netConnection ? false : _netConnection.connected;
		}
		
		public function get instance(): String
		{
			return _instance;
		}
		
		public function set instance( value:String ): void
		{
			if ( value == _instance ) return;
			__onInstanceChange(value);
		}
	}
}