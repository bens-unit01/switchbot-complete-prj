/**
 *  LiveDelayStream - Copyright © 2011 Influxis All rights reserved.   
**/

package org.influxis.as3.net 
{
	//Flash Classes
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.net.NetStream;
	import flash.net.NetConnection;
	import flash.net.NetStreamPlayOptions;
	
	//Influxis Classes
	import org.influxis.as3.states.PlayStates;
	import org.influxis.as3.data.HashTable;
	import org.influxis.as3.net.ClientSideCallHandler;
	import org.influxis.as3.states.DataStates;
	import org.influxis.as3.events.SimpleEventConst;
	import org.influxis.as3.utils.DateUtils;
	import org.influxis.as3.utils.Interval;
	import org.influxis.as3.utils.doTimedLater;
	import org.influxis.as3.utils.handler;
	
	public class LiveDelayStream extends NetStream
	{
		private static const _CALL_PREFIX_:String = "LDInstance:static";
		private var _netConnection:NetConnection;
		private var _oServerHandler:Object;
		
		private var _callHandler:ClientSideCallHandler = ClientSideCallHandler.getInstance();
		private var _streams:HashTable = new HashTable();
		private var _client:Object;
		private var _oLiveData:Object;
		private var _publishDate:Date;
		private var _streamName:String;
		private var _bLiveActive:Boolean;
		private var _bCanPlay:Boolean;
		private var _itema:Interval;
		private var _checkInt:Number;
		private var _nDelay:Number = 12;
		private var _nLiveDuration:Number = 0;
		private var _sState:String = PlayStates.UNLOADED;
		
		private var _nDefaultBuffer:Number;
		private var _bIsDualBuffering:Boolean;
		private var _nBuffer:Number = 15;
		private var _bUseDualBuffer:Boolean = true;
		private var _streamHandlers:Object = new Object();
		private var _INT:Number;
		
		/**
		 * INIT API
		 */
		
		public function LiveDelayStream( connection:NetConnection, peerID:String = "connectToFMS" ): void
		{
			super(connection, peerID);
			
			_itema = new Interval(this);
			
			//Listen to client events
			_streamHandlers["onCuePoint"] = handler( __handleClientObjEvent, "onCuePoint" );
			_streamHandlers["onDRMContentData"] = handler( __handleClientObjEvent, "onDRMContentData" );
			_streamHandlers["onImageData"] = handler( __handleClientObjEvent, "onImageData" );
			_streamHandlers["onMetaData"] = handler( __handleClientObjEvent, "onMetaData" );
			_streamHandlers["onPlayStatus"] = handler( __handleClientObjEvent, "onPlayStatus" );
			_streamHandlers["onSeekPoint"] = handler( __handleClientObjEvent, "onSeekPoint" );
			_streamHandlers["onTextData"] = handler( __handleClientObjEvent, "onTextData" );
			_streamHandlers["onXMPData"] = handler( __handleClientObjEvent, "onXMPData" );
			super.client = _streamHandlers;
			
			_oServerHandler = new Object()
			_oServerHandler.__onServerEvent = __onServerEvent;	
			_callHandler.addPath( "LiveDelay", _oServerHandler );
			
			_netConnection = connection;
			_netConnection.call( _CALL_PREFIX_ +".connect?clientInfo", null );
			addEventListener( NetStatusEvent.NET_STATUS, __onStreamStatus );
		}
		
		/**
		 * PUBLIC API
		 */
		
		override public function play( ...rest ):void 
		{
			var aArgs:Array = rest as Array;
			if ( aArgs && aArgs.length > 0 ) onStreamChanged( aArgs[0] == false && _streamName ? null : !_streamName && (aArgs[0] is String) ? String(aArgs[0]) : null );
		}
		
		override public function seek(offset:Number):void 
		{
			throw new Error("This stream can not be seeked!");
		}
		
		override public function pause():void 
		{
			throw new Error("This stream can not be paused!");
		}
		
		override public function play2(param:NetStreamPlayOptions): void 
		{
			throw new Error("This stream can not be played2!");
		}
		
		/**
		 * PROTECTED API
		 */
		
		protected function onStreamChanged( value:String ): void 
		{
			if ( value == _streamName ) return;
			
			_streamName = value;
			if ( _streamName )
			{
				if( _bLiveActive ) playLiveCache();
			}else if ( playing )
			{
				playLiveCache(false);
			}
		}
		
		protected function onStateChanged( value:String ): void 
		{
			if ( value == _sState ) return;
			
			_sState = value;
			if ( _sState == PlayStates.PLAYING )
			{
				if ( _bIsDualBuffering ) 
				{
					_bIsDualBuffering = false;
					_nDefaultBuffer = bufferTime;
					__callSetDefaultBuffer();
				}
			}else if ( (_sState == PlayStates.BUFFERING || _sState == PlayStates.COMPLETE) && !_bIsDualBuffering )
			{
				_bIsDualBuffering = true;
				_nDefaultBuffer = NaN;
				applyBuffer( 0.1 );
			}
			dispatchEvent(new Event(SimpleEventConst.STATE));
		}
		
		protected function onLiveDataChanged( value:Object ): void
		{
			if ( value == _oLiveData ) return;
			
			//Set live data
			_oLiveData = value;
			
			//Issue default props
			onStateChanged( !_oLiveData ? PlayStates.UNLOADED : PlayStates.LOADING );
			onDurationChanged( _oLiveData ? 0 : NaN );
			
			_publishDate = _oLiveData ? DateUtils.toDate( _oLiveData.startTime, DateUtils.LOCAL_ZONE ) : null;
			__registerInterval( _oLiveData != null );
		}
		
		protected function onDurationChanged( value:Number ): void
		{
			if ( _nLiveDuration == value ) return;
			_nLiveDuration = value;
			onLiveActiveChanged( value >= _nDelay );
		}
		
		protected function onLiveActiveChanged( value:Boolean ): void
		{
			if ( _bLiveActive == value ) return;
			
			_bLiveActive = value;
			onStateChanged( _bLiveActive ? PlayStates.READY : _oLiveData ? PlayStates.LOADING : PlayStates.UNLOADED );
			if ( _bLiveActive && _streamName && !playing ) playLiveCache();
		}
		
		protected function playLiveCache( playLive:Boolean = true ): void
		{
			if ( playing || !_oLiveData || _bCanPlay == playLive ) return;
			
			_bCanPlay = playLive;
			if ( _bCanPlay )
			{
				_bIsDualBuffering = true;
				applyBuffer(0.1);
				
				super.play( _oLiveData.cacheName, 0, -1 );
				super.seek( _nLiveDuration - _nDelay );
			}else{
				super.play(false);
			}
		}
		
		/**
		 * BUFFER API
		 */
		
		protected function applyBuffer( value:Number ): void
		{
			trace( "applyBuffer: " + value, _bIsDualBuffering );
			super.bufferTime = value;
		}
		 
		private function __setBuffer( value:Number ): void 
		{
			_nBuffer = value;
			if ( !_bIsDualBuffering ) applyBuffer( _nBuffer );
		}
		
		private function __callSetDefaultBuffer(): void
		{
			if ( !isNaN(_INT) ) _itema.stopInterval(_INT);
			_INT = _itema.startInterval( __setDefaultBuffer, 2500, 1 );
		}
		
		private function __setDefaultBuffer(): void
		{
			//Reset interval
			_INT = NaN;
			
			//If default buffer is nan then return;
			if ( isNaN(_nDefaultBuffer) ) return;
			
			//Set buffer and erase
			applyBuffer( _nDefaultBuffer );
			_nDefaultBuffer = NaN;
		}
		
		private function __handleClientObjEvent( ...args ): void
		{
			var aArgs:Array = args as Array;
			var sMethodName:String = aArgs.pop();
			if ( _client && _client[sMethodName] != undefined && (_client[sMethodName] is Function) )
			{
				(_client[sMethodName] as Function).apply( _client, aArgs );
			}
			if ( sMethodName == "onPlayStatus" ) __handlePlayEvent.apply( this, aArgs )
		}
		
		/**
		 * PRIVATE API
		 */
		 
		private function __registerInterval( value:Boolean = true ): void
		{
			if ( isNaN(_checkInt) )
			{
				_itema.stopInterval(_checkInt);
				_checkInt = NaN;
			}
			
			if ( !value ) return;
			_checkInt = _itema.startInterval( __updateLiveCache, 100, 0 );
		}
		 
		private function __updateLiveCache(): void 
		{
			if ( !_publishDate ) return;
			onDurationChanged( (new Date().getTime() - _publishDate.getTime()) / 1000 );
		}
		 
		/**
		 * HANDLERS
		 */
		
		private function __onServerEvent( event:Object ): void 
		{
			switch( event.type )
			{
				case DataStates.ADD :
					_streams.addItemAt( event.data.slot, event.data.data );
					break;
				case DataStates.REMOVE :
					_streams.removeItemAt( event.data.slot );
					break;
				case DataStates.CHANGE :
					_streams.source = event.data;
					break;
			}
			if ( _streamName && (event.type == DataStates.CHANGE || event.data.slot == _streamName) ) onLiveDataChanged( _streams.getItemAt(_streamName) );
		}
		
		private function __onStreamStatus( event:NetStatusEvent ): void 
		{
			if ( !_bCanPlay ) return;
			
			var code:String = event.info.code;
			if ( code == "NetStream.Pause.Notify" && _sState == PlayStates.PLAYING )
			{
				onStateChanged( PlayStates.PAUSED );
			}else if ( code == "NetStream.Unpause.Notify" && _sState == PlayStates.PAUSED )
			{
				onStateChanged( PlayStates.PLAYING );
			}else if ( (code == "NetStream.Play.Start" || code == "NetStream.Buffer.Full") && _sState != PlayStates.PAUSED )
			{
				onStateChanged( PlayStates.PLAYING );
			}else if ( code == "NetStream.Play.UnpublishNotify" && _sState == PlayStates.PLAYING )
			{
				onStateChanged( PlayStates.COMPLETE );
				_bCanPlay = false;
			}else if ( code == "NetStream.Buffer.Empty" )
			{
				onStateChanged( PlayStates.BUFFERING );
			}
		}
		
		private function __handlePlayEvent( p_nse:* ): void
		{
			try
			{
				if ( p_nse[ "code" ] == "NetStream.Play.Complete" ) 
				{
					onStateChanged( PlayStates.COMPLETE );
					_bCanPlay = false;
				}
			}catch( e:Error )
			{
				
			}
		}
		
		/**
		 * GETTER / SETTER
		 */
		
		public function get playing(): Boolean 
		{ 
			return (_sState == PlayStates.PLAYING);
		}
		
		public function get state(): String 
		{ 
			return _sState; 
		}
		
		public function set delay( value:Number ): void 
		{
			_nDelay = value;
			onLiveActiveChanged( _nLiveDuration >= _nDelay );
		}
		
		public function get delay(): Number
		{ 
			return _nDelay; 
		}
		
		override public function set bufferTime(value:Number):void 
		{
			__setBuffer(value);
		}
		
		override public function get bufferTime():Number 
		{ 
			return _nBuffer; 
		}
		
		override public function set client( value:Object ): void 
		{
			_client = value;
		}
		
		override public function get client():Object 
		{ 
			return _client; 
		}
	}
}