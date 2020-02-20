/**
 * IMediaControls - Copyright © 2010 Influxis All rights reserved.
**/

package org.influxis.as3.interfaces.media 
{
	//Flash Classes
	import flash.events.IEventDispatcher
	
	//Events
	[Event(name = "play", type = "flash.events.Event")]
	[Event(name = "stop", type = "flash.events.Event")]
	[Event(name = "pause", type = "flash.events.Event")]
	[Event(name = "rewind", type = "flash.events.Event")]
	[Event(name = "seek", type = "flash.events.Event")]
	[Event(name = "seeking", type = "flash.events.Event")]
	[Event(name = "rewind", type = "flash.events.Event")]
	[Event(name = "volume", type = "flash.events.Event")]
	[Event(name = "mute", type = "flash.events.Event")]
	[Event(name = "fullScreen", type = "flash.events.Event")]
	
	public interface IMediaControls extends IEventDispatcher
	{
		//Used to set the current time
		function set currentTime( time:uint ) : void;
		function get currentTime() : uint;
		
		//Used to give media duration
		function set length( length:Number ): void;
		function get length(): Number;
		
		//Media Volume
		function set volume( volume:Number ): void;
		function get volume(): Number;
		
		//Media Muted
		function set mute( mute:Boolean ): void;
		function get mute(): Boolean;
		
		//Last Seek Position
		function set seekPosition( seekPosition:uint ): void;
		function get seekPosition(): uint;
		
		//Fullscreen
		function set fullScreen( fullScreen:Boolean ): void;
		function get fullScreen(): Boolean;
		
		//Media State
		function set state( state:String ): void;
		function get state(): String;
	}
}