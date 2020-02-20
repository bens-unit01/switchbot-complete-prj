package org.influxis.flotools.list 
{
	//Flash Classes
	import flash.net.NetConnection;
	
	//Influxis Classes
	import org.influxis.as3.interfaces.net.IFMS;
	import org.influxis.as3.display.List;
	
	//Extends List component to allow to pass connection info through items
	public class ConnectedList extends List implements IFMS 
	{
		private var _netConnection:NetConnection;
		private var _instance:String;
		
		/*
		 * CONNECTED API
		 */
		
		public function connect( netConnection:NetConnection ): Boolean
		{
			if ( !netConnection || !netConnection.connected ) return false;
			
			_netConnection = netConnection;
			if ( instance ) instanceChange();
			connectItems();
			return true;
		}
		
		public function close(): void
		{
			connectItems(false);
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
			if ( _instance && connected ) instanceClose();
			
			_instance = value;
			refreshItemInstances();
			if( _instance && connected ) instanceChange();
		}
		 
		/*
		 * PROTECTED API
		 */
		
		override protected function createItemAt(index:Number, data:Object):void 
		{
			super.createItemAt(index, data);
			
			var cell:IFMS = getCellItemAt(index) as IFMS;
			if ( cell ) 
			{
				cell.connect(_netConnection);
				if ( instance ) cell.instance = instance;
			}
		}
		
		protected function connectItems( doConnect:Boolean = true ): void
		{
			var cell:IFMS;
			var nLen:Number = rowCount;
			for (var i:Number = 0; i < nLen; i++) 
			{
				cell = getCellItemAt(i) as IFMS;
				if ( cell ) 
				{
					if ( doConnect )
					{
						cell.connect(_netConnection);
						if ( instance ) cell.instance = instance;
					}else{
						cell.instance = null;
						cell.close();
					}
				}
			}
		}
		
		protected final function refreshItemInstances(): void
		{
			if ( !_netConnection ) return;
			
			var cell:IFMS;
			var nLen:Number = rowCount;
			for (var i:Number = 0; i < nLen; i++) 
			{
				cell = getCellItemAt(i) as IFMS;
				if ( cell ) cell.instance = instance;
			}
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