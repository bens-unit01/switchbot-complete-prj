package org.influxis.as3.interfaces.states 
{
	public interface ISelectable 
	{
		function set selected( value:Boolean ): void;
		function get selected(): Boolean;
		function set over( value:Boolean ): void;
		function get over(): Boolean;
		function set down( value:Boolean ): void;
		function get down(): Boolean;
		function set enabled( value:Boolean ): void;
		function get enabled(): Boolean;
		function set state( value:String ): void;
		function get state(): String;
	}	
}