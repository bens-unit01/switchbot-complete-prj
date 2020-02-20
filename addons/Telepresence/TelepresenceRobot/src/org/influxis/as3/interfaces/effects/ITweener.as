package org.influxis.as3.interfaces.effects 
{
	public interface ITweener 
	{
		function get updateFunction(): Function;
		function get completed(): Boolean;
	}
}