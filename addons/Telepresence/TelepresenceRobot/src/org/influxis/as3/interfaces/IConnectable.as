package org.influxis.as3.interfaces 
{
	//Flash Classes
	import flash.net.NetConnection;
	
	public interface IConnectable 
	{
		function set netConnection( value:NetConnection );
		function get netConnection(): NetConnection;
	}	
}