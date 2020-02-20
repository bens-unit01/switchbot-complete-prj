package org.influxis.as3.interfaces.controls 
{
	import flash.events.IEventDispatcher
	
	//Events
	[Event( name = "thumbPress", type = "flash.events.Event" )]
	[Event( name = "thumbDrag", type = "flash.events.Event" )]
	[Event( name = "thumbRelease", type = "flash.events.Event" )]
	[Event( name = "change", type = "flash.events.Event" )]
	[Event( name = "trackClick", type = "flash.events.Event" )]
	
	public interface ISeekBar extends IEventDispatcher
	{
		function set enabled( enabled:Boolean ): void;
		function get enabled(): Boolean;
		
		function set direction( direction:String ): void;
		function get direction(): String;
		
		function set minimum( minimum:Number ): void;
		function get minimum(): Number;
		
		function set maximum( maximum:Number ): void;
		function get maximum(): Number;
		
		function set value( value:Number ): void;
		function get value(): Number;
		
		function set ticks( value:Vector.<Number> ): void;
		function get ticks(): Vector.<Number>;
		
		function set snapInterval( value:Vector.<Number> ): void;
		function get snapInterval(): Vector.<Number>;
	}
	
}