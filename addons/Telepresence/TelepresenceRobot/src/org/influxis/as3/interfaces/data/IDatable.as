package org.influxis.as3.interfaces.data 
{
	public interface IDatable 
	{
		function set data( p_data:Object ): void;
		function get data(): Object;
	}
}