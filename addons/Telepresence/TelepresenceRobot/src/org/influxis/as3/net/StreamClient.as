/**
 * StreamClient - Copyright © 2010 Influxis All rights reserved.
**/

package org.influxis.as3.net
{
	//Flash Classes
	import flash.events.NetStatusEvent;
	import flash.events.EventDispatcher;
	import flash.net.NetStream;
	
	import org.influxis.as3.events.SimpleEvent;
	import org.influxis.as3.states.PlayStates;
	import org.influxis.as3.utils.doTimedLater;
	import org.influxis.as3.utils.delegate;
	
	import org.influxis.tvstation.data.TVChannel;
	
	//Events
	[Event(name="state", type="org.influxis.as3.events.SimpleEvent")]
	
	public class StreamClient extends EventDispatcher
	{										   
		public static var symbolName:String = "StreamClient";
		public static var symbolOwner:Object = org.influxis.as3.net.StreamClient;
		private var infxClassName:String = "StreamClient";
		private var _sVersion:String = "1.0.0.0";
		
		public static var DEBUG:Boolean = false;
		
		public static const SWITCH = "switch";
		public static const STATE = "state";
		public static const CUE_POINT = "cuePoint";
		public static const METADATA = "metaData";
		public static const IMAGE = "image";
		public static const TEXT = "text";
		
		private var _stream:NetStream;
		private var _oHandler:Object = new Object();
		private var _sPlayState:String = PlayStates.UNLOADED;
		
		private var _bCheckingTime:Boolean;
		private var _nTime:Number;
		
		private var _oLastCuePoint:Object;
		private var _oImageData:Object;
		private var _oTextData:Object;
		private var _oMetaData:Object;
		
		/**
		 * INIT API
		 */
		
		public function StreamClient( stream:NetStream = null, state:String = null ): void
		{
			_oHandler["onPlayStatus"] = __onPlayStatus;
			_oHandler["onCuePoint"] = delegate( this, __handleClientEvent, "onCuePoint" );
			_oHandler["onImageData"] = delegate( this, __handleClientEvent, "onImageData" );
			_oHandler["onMetaData"] = delegate( this, __handleClientEvent, "onMetaData" );
			_oHandler["onTextData"] = delegate( this, __handleClientEvent, "onTextData" );
			setStream(stream, state);
		}
		
		/**
		 * PUBLIC API
		 */
		
		public function setStream( stream:NetStream, state:String = null ): void
		{
			if( stream ) __setStateChange( state ? state : stream.time > 0 ? PlayStates.PLAYING : PlayStates.READY );
			__registerStream(stream);
		}
		
		public function clear(): void
		{
			__unregisterStream();
		}
		 
		/**
		 * PRIVATE API
		 */
		
		private function __registerStream( stream:NetStream ): void 
		{
			__unregisterStream(false);
			if ( !stream ) return;
			
			_stream = stream;
			
			_stream.addEventListener( NetStatusEvent.NET_STATUS, __handleStreamEvent );
			_stream.client = _oHandler;
			
		}
		
		private function __unregisterStream(p_bIdle:Boolean = true): void
		{
			if ( !_stream ) return;
			
			_stream.removeEventListener( NetStatusEvent.NET_STATUS, __handleStreamEvent );
			_stream.client = null;
			_stream = null;
			
			if ( p_bIdle )
			{
				_nTime = 0;
				__setStateChange( PlayStates.UNLOADED );
			}
		}
		
		private function __setStateChange( p_sState:String ): void
		{
			if( _sPlayState == p_sState ) return;
			
			_sPlayState = p_sState;
			if ( _sPlayState == PlayStates.PLAYING ) __startTimeCheck();
			dispatchEvent( new SimpleEvent(STATE, null, _sPlayState) );
		}
		
		private function __startTimeCheck(): void
		{
			if ( _bCheckingTime ) return;
			_bCheckingTime = true;
			doTimedLater( 800, __timeCheck );
		}
		
		private function __timeCheck(): void
		{
			if ( _stream ) _nTime = isNaN(_stream.time) ? 0 : _stream.time;
			_bCheckingTime = _sPlayState == PlayStates.PLAYING;
			if ( _bCheckingTime ) __startTimeCheck();
		}
		
		/**
		 * HANDLERS
		 */
		
		private function __handleClientEvent( p_oData:Object, p_sType:String ): void
		{
			var se:SimpleEvent;
			switch( p_sType )
			{
				case "onCuePoint" : 
					_oLastCuePoint = p_oData;
					se = new SimpleEvent( CUE_POINT, null, p_oData );
					break;
				
				case "onImageData" : 
					_oImageData = p_oData;
					se = new SimpleEvent( IMAGE, null, p_oData );
					break;
				
				case "onMetaData" : 
					_oMetaData = p_oData;
					se = new SimpleEvent( METADATA, null, p_oData );
					break;
				
				case "onTextData" : 
					_oTextData = p_oData;
					se = new SimpleEvent( TEXT, null, p_oData );
					break;
			}
			dispatchEvent(se);
		}
		
		private function __onPlayStatus( p_e:Object ): void
		{
			var code:String = p_e.code;
			if ( code == "NetStream.Play.Complete" )
			{
				__setStateChange( PlayStates.COMPLETE );
			}else if ( code == "NetStream.Play.Switch" )
			{
				dispatchEvent( new SimpleEvent(SWITCH) );
			}
		}
		
		private function __handleStreamEvent( p_e:NetStatusEvent ): void
		{
			var code:Object = p_e.info.code;
			switch( code )
			{
				case "NetStream.Pause.Notify" : 
					__setStateChange( PlayStates.PAUSED );
					break;
					
				case "NetStream.Unpause.Notify" : 
					__setStateChange( PlayStates.PLAYING );
					__startTimeCheck();
					break;
					
				case "NetStream.Play.Start" : 
					if( !paused )
					{
						__setStateChange( PlayStates.PLAYING );
						__startTimeCheck();
					}
					break;
					
				case "NetStream.Buffer.Empty" : 
					__setStateChange( PlayStates.BUFFERING );
					break;
					
				case "NetStream.Buffer.Full" :
					__setStateChange( PlayStates.PLAYING );
					break;
					
				case "NetStream.Play.UnpublishNotify" :
					__setStateChange( PlayStates.COMPLETE );
					break;
			}
			//dispatchEvent( p_nse );
		}
		 
		/**
		 * GETTER / SETTER
		 */
		
		public function get stream(): NetStream
		{
			return _stream;
		}
		
		public function get playing(): Boolean
		{
			return (_sPlayState == PlayStates.PLAYING);
		}
		
		public function get paused(): Boolean
		{
			return (_sPlayState == PlayStates.PAUSED);
		}
		
		public function get buffering(): Boolean
		{
			return (_sPlayState == PlayStates.BUFFERING);
		}
		
		public function get loaded(): Boolean
		{
			return (_stream!=null);
		}
		
		public function get state(): String
		{
			return _sPlayState;
		}
		
		public function get lastCuePoint(): Object
		{
			return _oLastCuePoint;
		}
		
		public function get imageData(): Object
		{
			return _oImageData;
		}
		
		public function get textData(): Object
		{
			return _oTextData;
		}
		
		public function get metaData(): Object
		{
			return _oMetaData;
		}
	}
}