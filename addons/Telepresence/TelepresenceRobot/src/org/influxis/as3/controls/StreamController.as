/**
 * StreamController - Copyright © 2010 Influxis All rights reserved.
**/

package org.influxis.as3.controls
{
	//Flash Classes
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.media.SoundTransform;
	import flash.net.NetStream;
	
	import org.influxis.as3.events.SimpleEventConst;
	import org.influxis.as3.interfaces.media.IMediaHandler;
	import org.influxis.as3.states.PlayStates;
	import org.influxis.as3.utils.Interval;
	import org.influxis.as3.utils.doTimedLater;
	
	[Event(name = "state", type = "flash.events.Event")]
	[Event(name = "time", type = "flash.events.Event")]
	
	public class StreamController extends EventDispatcher implements IMediaHandler
	{
		public static var symbolName:String = "StreamController";
		public static var symbolOwner:Object = org.influxis.as3.controls.StreamController;
		private var infxClassName:String = "StreamController";
		private var _sVersion:String = "1.0.0.0";
		
		public static var DEBUG:Boolean = false;
		
		private var _nCheckTimeINT:Number;
		private var __source:*;
		
		private var _bMute:Boolean = false;
		private var _bFullScreen:Boolean = false;
		private var _nVolume:Number = 100;
		private var _nTime:Number = 0;
		private var _nLength:Number = 0;
		private var _sPlayState:String = PlayStates.UNLOADED;
		private var _itema:Interval = new Interval();
		private var _nBuffer:Number = 0.1;
		private var _bUseDualBuffer:Boolean = true;
		private var _bIsDualBuffering:Boolean;
		private var _nDefaultBuffer:Number;
		
		/**
		* INIT METHODS
		**/
		
		/*public function StreamController(): void
		{
			
		}*/
		
		/**
		 * VERSION
		**/
		
		override public function toString(): String
		{
			return ("[ "+ infxClassName + " " + _sVersion +" ]")
		}
		
		public function get version(): String
		{
			return _sVersion;
		}
		
		/**
		 * PUBLIC API
		**/
		
		public function play(): void
		{
			__source.play();
		}
		
		public function stop(): void
		{
			__source.play(false);
		}
		
		public function clear(): void
		{
			stopTimeCheck();
			setTimeChange( 0 );
			setStreamDuration( 0 );
			setStateChange( PlayStates.UNLOADED );
			__setSource(undefined);
		}
		
		public function pause(): void
		{
			if( __source == undefined ) return;
			
			if( _sPlayState == PlayStates.READY )
			{
				__source.play();
			}else{
				__source.pause();
			}
		}
		
		public function seek( p_nSeek:uint ): void
		{
			if( __source == undefined || currentTime == p_nSeek ) return;
			
			if ( _bUseDualBuffer && !_bIsDualBuffering )
			{
				_bIsDualBuffering = true;
				_nDefaultBuffer = NaN;
				applyBuffer( 0.1 );
			}
			__source.seek( p_nSeek );
		}
		
		/**
		 * PRIVATE API
		**/
		
		private function __setSource(p_source:*): void
		{
			if ( __source != undefined ) unregisterEvents();
			__source = undefined;
			
			if ( p_source == undefined ) return;
			__source = p_source;
			registerEvents();
		}
		
		private function __setBuffer( value:Number ): void 
		{
			_nBuffer = value;
			if ( !_bIsDualBuffering ) applyBuffer( _nBuffer );
		}
		
		private function __setDefaultBuffer(): void
		{
			if ( isNaN(_nDefaultBuffer) ) return;
			applyBuffer( _nDefaultBuffer );
			_nDefaultBuffer = NaN;
		}
		
		/**
		 * PROTECTED API
		 */
		
		protected function unregisterEvents(): void
		{
			if( __source == undefined ) return;
			__source.removeEventListener( NetStatusEvent.NET_STATUS, __handleStreamEvent );
		}
		
		protected function registerEvents(): void
		{
			if( __source == undefined ) return;
			__source.addEventListener( NetStatusEvent.NET_STATUS, __handleStreamEvent );
		}
		
		protected function setStreamDuration( length:Number ): void
		{
			_nLength = isNaN(length) ? 0 : length;
			dispatchEvent( new Event(SimpleEventConst.DURATION) );
		}
		
		protected function applyBuffer( value:Number ): void
		{
			if ( source == undefined ) return;
			__source.bufferTime = value;
		}
		
		protected function setStreamVolume(): void
		{
			if( __source == undefined ) return;
			
			var nVolume:uint = (_bMute ? 0 : (_nVolume / 100));
			var sdt:SoundTransform = new SoundTransform();
				sdt.volume = nVolume;
				
			__source.soundTransform = sdt;
		}
		
		protected function doTimeCheck(): void
		{
			if( __source == undefined )
			{
				setTimeChange( 0 );
				return;
			}	
			setTimeChange( __source.time );
		}
		
		protected function startTimeCheck(): void
		{
			if( isNaN(_nCheckTimeINT) ) _nCheckTimeINT = _itema.startInterval( this.doTimeCheck, 100, 0 );
		}
		
		protected function stopTimeCheck(): void
		{
			if( !isNaN( _nCheckTimeINT ) )
			{
				_itema.stopInterval( _nCheckTimeINT );
				_nCheckTimeINT = NaN;
			}
		}
		
		protected function setStateChange( p_sState:String ): void
		{
			if( _sPlayState == p_sState ) return;
			
			_sPlayState = p_sState;
			if ( _sPlayState == PlayStates.PLAYING )
			{
				startTimeCheck();
				if ( useDualBuffer && _bIsDualBuffering ) 
				{
					_bIsDualBuffering = false;
					_nDefaultBuffer = buffer
					doTimedLater( 2000, __setDefaultBuffer );
				}
			}else if ( _sPlayState == PlayStates.BUFFERING && useDualBuffer && !_bIsDualBuffering )
			{
				_bIsDualBuffering = true;
				_nDefaultBuffer = NaN;
				applyBuffer( 0.1 );
			}else{
				stopTimeCheck();
			}
			dispatchEvent( new Event(SimpleEventConst.STATE) );
		}
		
		protected function setTimeChange( p_nTime:Number ): void
		{
			if( isNaN(p_nTime) || p_nTime == _nTime ) return;
			
			_nTime = p_nTime;
			dispatchEvent( new Event(SimpleEventConst.TIME) );
		}
		
		/**
		 * HANDLERS
		**/
		
		private function __handlePlayEvent( p_nse:* ): void
		{
			try
			{
				//tracer( "handlePlayEvent: " + p_nse[ "code" ] );
				if ( p_nse[ "code" ] == "NetStream.Play.Complete" ) 
				{
					setStateChange( PlayStates.COMPLETE );
				}
			}catch( e:Error )
			{
				tracer( "Error: " + e )
			}
		}
		
		private function __handleStreamEvent( p_nse:NetStatusEvent ): void
		{
			var code:String = p_nse.info.code;
			//tracer( "handleStreamEvent: " + code );
			
			switch( code )
			{
				case ("NetStream.Pause.Notify" && _sPlayState == PlayStates.PLAYING) : 
					setStateChange( PlayStates.PAUSED );
					break;
					
				case ("NetStream.Unpause.Notify" && _sPlayState == PlayStates.PAUSED) : 
					setStateChange( PlayStates.PLAYING );
					break;
					
				case (("NetStream.Play.Start" || "NetStream.Buffer.Full") && _sPlayState != PlayStates.PAUSED) : 
					setStateChange( PlayStates.PLAYING );
					break;
					
				case ("NetStream.Play.UnpublishNotify" && _sPlayState == PlayStates.PLAYING) :
					setStateChange( PlayStates.COMPLETE );
					break;
					
				case "NetStream.Buffer.Empty" : 
					setStateChange( PlayStates.BUFFERING );
					break;
			}
			dispatchEvent( p_nse );
		}
		
		/**
		 * GETTER / SETTER
		**/
		
		public function set source( p_source:* ): void
		{
			//trace( "source: " + p_source );
			if ( p_source == undefined ) 
			{
				__setSource(undefined);
			}else{
				clear();
				__setSource(p_source);
			}
			
		}
		
		public function get source(): *
		{
			return __source;
		}
		
		public function set mute( p_bMute:Boolean ): void
		{
			_bMute = p_bMute;
			setStreamVolume();
		}
		
		public function get mute(): Boolean
		{
			return _bMute;
		}
		
		public function set volume( p_nVolume:Number ): void
		{
			_nVolume = p_nVolume;
			setStreamVolume();
		}
		
		public function get volume(): Number
		{
			return _nVolume;
		}
		
		public function get state(): String
		{
			return _sPlayState;
		}
		
		public function get currentTime(): Number
		{
			return _nTime;
		}
		
		public function set length( p_nLength:Number ) : void
		{
			setStreamDuration(p_nLength);
		}
		
		public function get length(): Number
		{
			return _nLength;
		}
		
		public function set buffer( value:Number ): void
		{
			__setBuffer(value);
		}
		
		public function get buffer(): Number
		{
			return _nBuffer;
		}
		
		public function set useDualBuffer(value:Boolean):void 
		{
			_bUseDualBuffer = value;
		}
		
		public function get useDualBuffer(): Boolean
		{ 
			return _bUseDualBuffer; 
		}
		
		/** 
		 * DEBUGGER 
		**/
		
		private function tracer( p_msg:* ) : void
		{
			if( DEBUG ) trace("##" + infxClassName + "##  "+p_msg);
		}
	}
}