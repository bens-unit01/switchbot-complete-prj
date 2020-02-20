/**
 * IMediaHandler - Copyright © 2010 Influxis All rights reserved.
**/

package org.influxis.as3.interfaces.media 
{
	//Flash Classes
	import flash.events.IEventDispatcher;
	
	//Events
	[Event(name = "state", type = "flash.events.Event")]
	[Event(name = "time", type = "flash.events.Event")]
	[Event(name = "duration", type = "flash.events.Event")]
	
	public interface IMediaHandler extends IEventDispatcher
	{
		function play(): void;
		function stop(): void;
		function seek( seekSeconds:uint ): void
		function pause(): void;
		
		function set volume( volume:Number ): void;
		function get volume(): Number;
		
		function set mute( mute:Boolean ): void;
		function get mute(): Boolean;
		
		function get state(): String;
		function get currentTime(): Number;
		function get length(): Number;
	}
}