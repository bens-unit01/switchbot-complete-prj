/**
 * SimpleMediaControlsBase - Copyright © 2010 Influxis All rights reserved.
**/

package org.influxis.as3.display.simplemediacontrolsclasses 
{
	//Flash Classes
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	
	//Influxis Classes
	import org.influxis.as3.core.infx_internal;
	import org.influxis.as3.display.StyleComponent;
	import org.influxis.as3.events.SimpleEventConst;
	import org.influxis.as3.states.PlayStates;
	import org.influxis.as3.interfaces.media.IMediaControls;
	import org.influxis.as3.interfaces.media.IMediaHandler;
	import org.influxis.as3.utils.handler;
	import org.influxis.as3.utils.DateUtils;
	import org.influxis.as3.utils.SizeUtils;
	import org.influxis.as3.interfaces.controls.ISeekBar;
	import org.influxis.as3.display.Slider;
	
	//Events
	[Event(name = "play", type = "flash.events.Event")]
	[Event(name = "rewind", type = "flash.events.Event")]
	[Event(name = "stop", type = "flash.events.Event")]
	[Event(name = "pause", type = "flash.events.Event")]
	[Event(name = "seek", type = "flash.events.Event")]
	[Event(name = "seeking", type = "flash.events.Event")]
	[Event(name = "rewind", type = "flash.events.Event")]
	[Event(name = "volume", type = "flash.events.Event")]
	[Event(name = "mute", type = "flash.events.Event")]
	[Event(name = "fullScreen", type = "flash.events.Event")]
	[Event(name = "fullscreenOff", type = "flash.events.Event")]
	
	public class SimpleMediaControlsBase extends StyleComponent implements IMediaControls
	{
		public static var symbolName:String = "SimpleMediaControlsBase";
		public static var symbolOwner:Object = org.influxis.as3.display.simplemediacontrolsclasses.SimpleMediaControlsBase;
		private var infxClassName:String = "SimpleMediaControlsBase";
		private var _sVersion:String = "1.0.0.0";
		
		//Avaiable display modes
		public static const PRE_RECORDED:String = "preRecordedMode";
		public static const LIVE:String = "liveMode";
		public static const DVR:String = "dvrMode";
		
		private var _bMuted:Boolean;
		private var _bFullScreen:Boolean;
		private var _bSeeking:Boolean;
		private var _source:IMediaHandler;
		private var _bMouseOutsideFP:Boolean;
		private var _sensorBar:Sprite;;
		
		private var _sControlsPosition:String = SizeUtils.BOTTOM;
		private var _sDisplayMode:String = PRE_RECORDED;
		private var _sState:String = PlayStates.UNLOADED;
		private var _nCurrentTime:uint = 0;
		private var _nVolume:Number = 50;
		private var _nSeekSeconds:uint = 0;
		private var _nMaxCache:uint = 0;
		private var _nLength:Number = 0;
		private var _nControlsHeight:Number = 0;
		private var _bShowDuration:Boolean = true;
		private var _bInverseTime:Boolean = false;
		private var _bButtonMode:Boolean;
		
		private var _bShowStop:Boolean = true;
		private var _bShowPlay:Boolean = true;
		private var _bShowRewind:Boolean = true;
		private var _bShowVolume:Boolean = true;
		private var _bShowFullScreen:Boolean = true;
		private var _bShowStreamScrubber:Boolean = true;
		private var _bShowTime:Boolean = true;
		private var _bShowBuffer:Boolean = true;
		private var _bDVRAutoScrubbed:Boolean;
		
		protected var PLAY_COMMAND:String = "playComm";
		protected var PAUSE_COMMAND:String = "pauseComm";
		protected var REWIND_COMMAND:String = "rewindComm";
		protected var STOP_COMMAND:String = "stopComm";
		protected var MUTE_COMMAND:String = "muteComm";
		protected var UNMUTE_COMMAND:String = "unmuteComm";
		protected var SEEKING_COMMAND:String = "seekingComm";
		protected var SEEK_COMMAND:String = "seekComm";
		protected var FULLSCREEN_COMMAND:String = "fullscreenComm";
		protected var FULLSCREEN_OFF_COMMAND:String = "fullscreenOffComm";
		protected var VOLUME_COMMAND:String = "volumeComm";
		
		//Assets
		protected var cbBackground:InteractiveObject;
		
		protected var cbPlay:InteractiveObject;
		protected var cbPause:InteractiveObject;
		protected var cbRewind:InteractiveObject;
		protected var cbMuted:InteractiveObject;
		protected var cbVolume:InteractiveObject;
		protected var cbFullScreenOn:InteractiveObject;
		protected var cbFullScreenOff:InteractiveObject;
		protected var cbStop:InteractiveObject;
		protected var cbScrubber:InteractiveObject;
		protected var cbVolumeScrubber:InteractiveObject;
		protected var cbVolumeScrubberBG:InteractiveObject;
		protected var lTime:InteractiveObject;
		protected var cbBigPlay:InteractiveObject;
		protected var cbBuffer:InteractiveObject;
		
		/**
		 * INIT API
		 */
		
		override protected function init(): void
		{
			//Need to add this even if createChild is overriden
			_sensorBar = new Sprite();
			addChild( _sensorBar );
			super.init();
		}
		 
		/**
		 * PROTECTED API
		 */
		 
		//Used to create events for buttons and scrubbers 
		protected function registerEvents(): void
		{
			cbPlay.addEventListener( MouseEvent.CLICK, handler(onControlEvent, PLAY_COMMAND) );
			cbBigPlay.addEventListener( MouseEvent.CLICK, handler(onControlEvent, PLAY_COMMAND) );
			cbPause.addEventListener( MouseEvent.CLICK, handler(onControlEvent, PAUSE_COMMAND) );
			cbRewind.addEventListener( MouseEvent.CLICK, handler(onControlEvent, REWIND_COMMAND) );
			cbStop.addEventListener( MouseEvent.CLICK, handler(onControlEvent, STOP_COMMAND) );
			cbMuted.addEventListener( MouseEvent.CLICK, handler(onControlEvent, UNMUTE_COMMAND) );
			cbVolume.addEventListener( MouseEvent.CLICK, handler(onControlEvent, MUTE_COMMAND) );
			cbFullScreenOn.addEventListener( MouseEvent.CLICK, handler(onControlEvent, FULLSCREEN_OFF_COMMAND) );
			cbFullScreenOff.addEventListener( MouseEvent.CLICK, handler(onControlEvent, FULLSCREEN_COMMAND) );
			
			var streamScrubber:ISeekBar;
			if ( cbScrubber is ISeekBar )
			{
				streamScrubber = cbScrubber as ISeekBar;
				streamScrubber.addEventListener( Slider.THUMB_PRESS, handler(onControlEvent, SEEKING_COMMAND) );
				streamScrubber.addEventListener( Slider.THUMB_RELEASE, handler(onControlEvent, SEEK_COMMAND) );
				streamScrubber.addEventListener( Slider.TRACK_CLICK, handler(onControlEvent, SEEK_COMMAND) );
				streamScrubber.addEventListener( Event.CHANGE, __handleSeekChange );
			}else{
				cbScrubber.addEventListener( MouseEvent.MOUSE_DOWN, handler(onControlEvent, SEEKING_COMMAND) );
				cbScrubber.addEventListener( MouseEvent.MOUSE_UP, handler(onControlEvent, SEEK_COMMAND) );
			}
			
			if ( cbVolumeScrubber is ISeekBar )
			{
				streamScrubber = cbVolumeScrubber as ISeekBar;
				streamScrubber.addEventListener( Event.CHANGE, handler(onControlEvent, VOLUME_COMMAND) );
			}else{
				cbVolumeScrubber.addEventListener( MouseEvent.MOUSE_UP, handler(onControlEvent, VOLUME_COMMAND) );
			}
			
			//Used to make colume bg appear and disappear
			cbVolume.addEventListener( MouseEvent.MOUSE_OVER, __checkVolumeHit );
			cbVolume.addEventListener( MouseEvent.ROLL_OVER, __checkVolumeHit );
			cbVolume.addEventListener( MouseEvent.MOUSE_OUT, __checkVolumeHit );
			cbVolume.addEventListener( MouseEvent.ROLL_OUT, __checkVolumeHit );
			
			cbMuted.addEventListener( MouseEvent.MOUSE_OVER, __checkVolumeHit );
			cbMuted.addEventListener( MouseEvent.ROLL_OVER, __checkVolumeHit );
			cbMuted.addEventListener( MouseEvent.MOUSE_OUT, __checkVolumeHit );
			cbMuted.addEventListener( MouseEvent.ROLL_OUT, __checkVolumeHit );
			
			cbVolumeScrubberBG.addEventListener( MouseEvent.MOUSE_OVER, __checkVolumeHit );
			cbVolumeScrubberBG.addEventListener( MouseEvent.ROLL_OVER, __checkVolumeHit );
			cbVolumeScrubberBG.addEventListener( MouseEvent.MOUSE_OUT, __checkVolumeHit );
			cbVolumeScrubberBG.addEventListener( MouseEvent.ROLL_OUT, __checkVolumeHit );
			
			//Checks when mouse leaves and returns to the FP
			stage.addEventListener( Event.MOUSE_LEAVE, __checkVolumeHit );
			stage.addEventListener( MouseEvent.ROLL_OVER, __checkVolumeHit );
			
			streamScrubber = null;
			__checkVolumeHit();
		}
		
		protected function updateDisplayStates(): void
		{
			if ( !cbPlay ) return;
			
			//Play functionality
			if ( _sState == PlayStates.UNLOADED || _sState == PlayStates.READY )
			{
				cbPlay.visible = _bShowPlay;
				cbStop.visible = _bShowStop;
				cbRewind.visible = _bShowRewind;
				cbBigPlay.visible = _bShowPlay && !_bButtonMode;
				cbPause.visible = false;
				cbBuffer.visible = false;
			}else {
				cbPlay.visible = (_sState == PlayStates.PAUSED || _sState == PlayStates.UNLOADED || _sState == PlayStates.READY || _sState == PlayStates.BUFFERING ) && _bShowPlay && (_sDisplayMode == PRE_RECORDED || _sDisplayMode == DVR);
				cbPause.visible = _sState == PlayStates.PLAYING && _bShowPlay && (_sDisplayMode == PRE_RECORDED || _sDisplayMode == DVR);
				cbStop.visible = (cbPause.visible || _sState == PlayStates.PAUSED || _sState == PlayStates.BUFFERING) && _bShowStop && _sDisplayMode == PRE_RECORDED;
				cbRewind.visible = (cbPause.visible || _sState == PlayStates.PAUSED || _sState == PlayStates.BUFFERING) && _bShowRewind && _sDisplayMode != LIVE;
				cbBuffer.visible = _sState == PlayStates.BUFFERING && _bShowBuffer;// && _sDisplayMode == PRE_RECORDED;
				cbBigPlay.visible = (_sState == PlayStates.READY || _sState == PlayStates.PAUSED) && _bShowPlay && !_bButtonMode;
			}
			
			var bufferClip:MovieClip = cbBuffer as MovieClip;
			if ( bufferClip )
			{
				if ( bufferClip.visible )
				{
					bufferClip.play();
				}else{
					bufferClip.stop();
				}
			}
			
			//Mute
			cbMuted.visible = _bMuted && _bShowVolume;
			cbVolume.visible = !_bMuted && _bShowVolume;
			
			//FullScreen
			cbFullScreenOn.visible = _bFullScreen && _bShowFullScreen;
			cbFullScreenOff.visible = !_bFullScreen && _bShowFullScreen;
			
			lTime.visible = (_bShowTime || _bShowDuration) && (_sDisplayMode == PRE_RECORDED || _sDisplayMode == DVR);
			cbScrubber.visible = _bShowStreamScrubber && (_sDisplayMode == PRE_RECORDED || _sDisplayMode == DVR);
			if( initialized ) arrange();
		}
		
		protected function updateClock(): void
		{
			if ( _bSeeking ) return;
			
			var t:TextField = lTime as TextField;
			if ( t ) 
			{
				var nCurrentTime:Number = _bInverseTime ? (length == 0 ? 0 : length - currentTime) : currentTime;
				t.text = (_bShowTime?DateUtils.getTimeLength(nCurrentTime):"") +(_bShowDuration?((_bShowTime?" / ":"")+ DateUtils.getTimeLength(isNaN(length)?0:length)):"");
			}
		}
		
		protected function get calculateSeek(): Number
		{
			var scrubber:ISeekBar = cbScrubber as ISeekBar;
			if ( !scrubber ) return currentTime;
			
			var nSeekTime:Number = 0;
			if ( _sDisplayMode != DVR )
			{
				nSeekTime = scrubber.value;
			}else if ( _nMaxCache > 0 && _nLength > _nMaxCache )
			{
				nSeekTime = length - _nMaxCache;
				nSeekTime = nSeekTime + ((scrubber.value / 100) * _nMaxCache);
			}else{
				nSeekTime = ((scrubber.value / 100) * _nLength);
			}
			if ( _sDisplayMode == DVR && (_nLength-nSeekTime) < 3 ) nSeekTime = _nLength;
			return nSeekTime;
		}
		
		/**
		 * PRIVATE API
		 */
		
		private function __registerSource( source:IMediaHandler ): void
		{
			__removeOldSource();
			if ( !source ) return;
			
			_source = source;
			_source.addEventListener( SimpleEventConst.STATE, __onHandlerEvent );
			_source.addEventListener( SimpleEventConst.TIME, __onHandlerEvent );
			_source.addEventListener( SimpleEventConst.DURATION, __onHandlerEvent );
			
			_nCurrentTime = _source.currentTime;
			_nLength = _source.length;
			state = _source.state;
			updateClock();
		}
		
		private function __removeOldSource(): void
		{
			if ( !_source ) return;
			_source.removeEventListener( SimpleEventConst.STATE, __onHandlerEvent );
			_source.removeEventListener( SimpleEventConst.TIME, __onHandlerEvent );
			_source.removeEventListener( SimpleEventConst.DURATION, __onHandlerEvent );
			_source = null;
		}
		
		private function __checkVolumeHit( event:Event = null ): void
		{
			if ( event ) _bMouseOutsideFP = event.type == Event.MOUSE_LEAVE;
			
			//If mouse is outside then don't show volume and kill method
			if ( _bMouseOutsideFP )
			{
				cbVolumeScrubberBG.visible = cbVolumeScrubber.visible = false;
				return;
			}
			
			var bHitSource:Boolean = cbVolume.hitTestPoint( stage.mouseX, stage.mouseY, true );
			if( !bHitSource ) bHitSource = cbMuted.hitTestPoint( stage.mouseX, stage.mouseY, true );
			cbVolumeScrubberBG.visible = cbVolumeScrubber.visible = (bHitSource || cbVolumeScrubberBG.hitTestPoint(stage.mouseX, stage.mouseY, true));
		}
		
		private function __checkSeekTime(): void
		{
			if ( _nMaxCache < 1 ) return;
			
			if ( _nCurrentTime-_nLength > _nMaxCache && _source ) _source.seek( _nLength-(_nMaxCache-1) );
			updateClock();
		}
		
		private function __setNewDisplayMode( value:String ): void
		{
			if ( _sDisplayMode == value ) return;
			
			var streamScrubber:ISeekBar = cbScrubber as ISeekBar;
			if ( !streamScrubber ) 
			{
				_sDisplayMode = value;
				updateDisplayStates();
				return;
			}
			
			//If old value is dvr then set back to normal
			if ( _sDisplayMode == DVR )
			{
				streamScrubber.minimum = 0;
				streamScrubber.value = currentTime;
				streamScrubber.maximum = length;
			}
			
			//Set display and if dvr then set to dvr time
			_sDisplayMode = value;
			if ( _sDisplayMode == DVR )
			{
				streamScrubber.minimum = 0;
				streamScrubber.value = (currentTime/length) * 100;
				streamScrubber.maximum = 100;
			}else{
				streamScrubber.minimum = 0;
				streamScrubber.value = currentTime;
				streamScrubber.maximum = length;
			}
			updateDisplayStates();
		}
		
		private function __handleSeekChange( event:Boolean ): void
		{
			if ( !_bSeeking ) return;
			
			var t:TextField = lTime as TextField;
			if ( t ) t.text = DateUtils.getTimeLength(calculateSeek) + (!_bShowDuration ? "" : " / "+ DateUtils.getTimeLength(isNaN(length)?0:length));
		}
		
		/**
		 * HANDLERS
		 */
		
		 //Set source state
		private function __onHandlerEvent( p_e:Event ): void
		{
			if ( p_e.type == SimpleEventConst.STATE ) 
			{
				state = _source.state;
			}else if ( p_e.type == SimpleEventConst.TIME || p_e.type == SimpleEventConst.DURATION )
			{
				var streamScrubber:ISeekBar = cbScrubber as ISeekBar;
				if ( p_e.type == SimpleEventConst.TIME ) 
				{
					_nCurrentTime = _source.currentTime;
					if ( streamScrubber && !_bSeeking )
					{
						//trace( "__onHandlerEvent: " + _sDisplayMode );
						if ( _sDisplayMode != DVR )
						{
							streamScrubber.value = _nCurrentTime;
						}else if ( streamScrubber.value == 0 && _nCurrentTime > 0 && !_bDVRAutoScrubbed )
						{
							_bDVRAutoScrubbed = true;
							streamScrubber.value = (_nCurrentTime / length) * 100;
						}
					}
					updateClock();
				}else if( p_e.type == SimpleEventConst.DURATION )
				{
					_nLength = _source.length;
					if ( streamScrubber && !_bSeeking && _sDisplayMode != DVR ) streamScrubber.maximum = _nLength;
				}
				updateClock();
			}
		}
		
		protected function onControlEvent( p_e:Event, commandType:String = null ): void
		{
			if ( !commandType || _sState == PlayStates.UNLOADED || _sState == PlayStates.BUFFERING ) return;
			
			var e:Event;
			switch( commandType )
			{
				case PLAY_COMMAND : 
					if ( _source ) _source.play();
					e = new Event(SimpleEventConst.PLAY);
					break;
					
				case PAUSE_COMMAND : 
					if ( _source ) _source.pause();
					e = new Event(SimpleEventConst.PAUSE);
					break;
					
				case UNMUTE_COMMAND : 
					_bMuted = false;
					if ( _source ) 
					{
						_source.mute = _bMuted;
						if ( _nVolume == 0 )
						{
							volume = 50;
						}else{
							if ( cbVolumeScrubber is ISeekBar ) (cbVolumeScrubber as ISeekBar).value = _nVolume;
						}
					}
					updateDisplayStates();
					e = new Event(SimpleEventConst.UNMUTE);
					break;
					
				case MUTE_COMMAND : 
					_bMuted = true;
					if ( _source ) 
					{
						_source.mute = _bMuted;
						if ( cbVolumeScrubber is ISeekBar ) (cbVolumeScrubber as ISeekBar).value = 0;
					}
					updateDisplayStates();
					e = new Event(SimpleEventConst.MUTE);
					break;
					
				case FULLSCREEN_OFF_COMMAND : 
					_bFullScreen = false;
					updateDisplayStates();
					e = new Event(SimpleEventConst.FULLSCREEN_OFF);
					break;
					
				case FULLSCREEN_COMMAND : 
					_bFullScreen = true;
					updateDisplayStates();
					e = new Event(SimpleEventConst.FULLSCREEN);
					break;
					
				case SEEKING_COMMAND : 
					_bSeeking = true;
					e = new Event(SimpleEventConst.SEEKING);
					break;
					
				case SEEK_COMMAND : 
					_bSeeking = false;
					_nSeekSeconds = calculateSeek;
					if ( _source ) _source.seek( _nSeekSeconds );
					e = new Event(SimpleEventConst.SEEK);
					break;
					
				case VOLUME_COMMAND : 
					if ( cbVolumeScrubber is ISeekBar ) 
					{
						_nVolume = (cbVolumeScrubber as ISeekBar).value;
						if ( _nVolume > 0 && mute )
						{
							mute = false;
						}else if ( _nVolume == 0 && !mute )
						{
							mute = true;
						}
					}
					if ( _source ) _source.volume = volume;
					e = new Event(SimpleEventConst.VOLUME);
					break;
					
				case REWIND_COMMAND : 
					if ( _source ) 
					{
						if ( _sState == PlayStates.PAUSED ) _source.play();
						_source.seek(_nMaxCache > 0 && _nLength > _nMaxCache ? (_nLength - _nMaxCache):0);
						if ( cbScrubber is ISeekBar && _sDisplayMode == DVR ) (cbScrubber as ISeekBar).value = 0;
					}
					e = new Event(SimpleEventConst.REWIND);
					break;
					
				case STOP_COMMAND : 
					if ( _source ) _source.stop();
					e = new Event(SimpleEventConst.STOP);
					break;
			}
			dispatchEvent(e);
		}
		
		/**
		 * DISPLAY API
		 */
		
		override protected function measure():void 
		{
			super.measure();
			
			measuredWidth = 300;
			measuredHeight = 35;
		}
		
		override protected function createChildren(): void 
		{
			super.createChildren();
			
			cbBackground = new Sprite();
			cbPlay = new SimpleButton();
			cbPause = new SimpleButton();
			cbRewind = new SimpleButton();
			cbStop = new SimpleButton();
			cbMuted = new SimpleButton();
			cbVolume = new SimpleButton();
			cbFullScreenOn = new SimpleButton();
			cbFullScreenOff = new SimpleButton();
			cbBigPlay = new SimpleButton();
			cbBuffer = new MovieClip;
			
			cbScrubber = new SimpleButton();
			cbVolumeScrubber = new SimpleButton();
			cbVolumeScrubberBG = new Sprite();
			lTime = new TextField();
			
			updateDisplayStates();
			addChild( cbBackground ); addChild( cbPlay ); 
			addChild( cbPause ); addChild( cbRewind ); 
			addChild( cbStop ); addChild( cbMuted ); 
			addChild( cbVolume ); addChild( cbFullScreenOn ); 
			addChild( cbFullScreenOff ); addChild( cbScrubber ); 
			addChild( cbBigPlay ); addChild( cbBuffer );
			addChild( cbVolumeScrubberBG ); addChild( cbVolumeScrubber ); 
			addChild( lTime );
		}
		
		override protected function childrenCreated():void 
		{
			super.childrenCreated();
			_sensorBar.buttonMode = _bButtonMode;
			_sensorBar.useHandCursor = _bButtonMode;
		}
		
		override protected function arrange(): void 
		{
			super.arrange();
			
			var scrubberPercent:uint = styleExists( "scrubberSize" ) ? getStyle( "scrubberSize" ) as uint : 50;
			var innerGap:Number = styleExists( "innerGap" ) ? Number(getStyle("innerGap")) : 10;
			var timeGap:Number = styleExists( "timeGap" ) ? Number(getStyle("timeGap")) : 10;
			var buttonGap:Number = styleExists( "buttonGap" ) ? Number(getStyle("buttonGap")) : 0;
			_nControlsHeight = styleExists( "controlHeight" ) ? Number(getStyle( "controlHeight" )) : cbBackground.height;
			
			var xPos:Number = 0;
			var xPosEnd:Number = width;
			
			cbBackground.width = width;
			cbBackground.height = _nControlsHeight;
			
			cbVolumeScrubber.width = cbVolumeScrubberBG.width*(scrubberPercent/100);
			cbVolumeScrubber.height = cbVolumeScrubberBG.height - (innerGap * 2);
			cbScrubber.height = _nControlsHeight*(scrubberPercent/100)
			
			//Measure time text and set dimensions
			var t:TextField = lTime as TextField;
			if ( t ) 
			{
				t.width = t.textWidth + 4;
				t.height = t.textHeight + 4;
			}
			
			//Sets Assets Y Positions
			SizeUtils.moveY( cbBackground, height, _sControlsPosition );
			SizeUtils.moveByTargetY( cbPlay, cbBackground, SizeUtils.MIDDLE );
			SizeUtils.moveByTargetY( cbPause, cbBackground, SizeUtils.MIDDLE );
			SizeUtils.moveByTargetY( cbRewind, cbBackground, SizeUtils.MIDDLE );
			SizeUtils.moveByTargetY( cbStop, cbBackground, SizeUtils.MIDDLE );
			SizeUtils.moveByTargetY( cbMuted, cbBackground, SizeUtils.MIDDLE );
			SizeUtils.moveByTargetY( cbVolume, cbBackground, SizeUtils.MIDDLE );
			SizeUtils.moveByTargetY( cbFullScreenOn, cbBackground, SizeUtils.MIDDLE );
			SizeUtils.moveByTargetY( cbFullScreenOff, cbBackground, SizeUtils.MIDDLE );
			SizeUtils.moveByTargetY( cbScrubber, cbBackground, SizeUtils.MIDDLE );
			SizeUtils.moveByTargetY( lTime, cbBackground, SizeUtils.MIDDLE );
			
			//Buffer
			SizeUtils.moveByTargetX( cbBuffer, cbBackground, SizeUtils.CENTER );
			SizeUtils.moveY( cbBuffer, (height - _nControlsHeight), SizeUtils.MIDDLE );
			
			//Big Play
			SizeUtils.moveByTargetX( cbBigPlay, cbBackground, SizeUtils.CENTER );
			SizeUtils.moveY( cbBigPlay, (height - _nControlsHeight), SizeUtils.MIDDLE );
			
			tracer( "arrange: " + cbBackground.height, width, height );
			
			//Draw Sensor
			_sensorBar.graphics.clear();
			_sensorBar.graphics.beginFill( 0, 0 );
			_sensorBar.graphics.drawRect( 0, (_sControlsPosition==SizeUtils.TOP?cbBackground.height:0), width, (height-cbBackground.height) );
			_sensorBar.graphics.endFill();
			
			//Setup X position
			xPos = (_bShowStop && cbStop.visible) ? (cbStop.width+buttonGap) : xPos;
			
			//Play/Pause
			cbPause.x = cbPlay.x = xPos;
			xPos = (_bShowPlay && (cbPause.visible || cbPlay.visible)) ? (xPos + cbPlay.width + buttonGap) : xPos;
			
			//Rewind
			cbRewind.x = xPos;
			xPos = (_bShowRewind && cbRewind.visible) ? xPos + cbRewind.width : xPos;
			
			//FullScreen
			xPosEnd = cbFullScreenOff.x = cbFullScreenOn.x = (_bShowFullScreen && (cbFullScreenOff.visible||cbFullScreenOn.visible)) ? (xPosEnd - cbFullScreenOn.width) : xPosEnd;
			
			//Volume
			xPosEnd = cbVolume.x = cbMuted.x = (_bShowVolume && (cbVolume.visible||cbMuted.visible)) ? (xPosEnd - (cbVolume.width+(xPosEnd<width?buttonGap:0))) : xPosEnd;
			
			//Volume Controls
			SizeUtils.moveByTargetX( cbVolumeScrubberBG, cbVolume, SizeUtils.CENTER );
			SizeUtils.moveByTargetY( cbVolumeScrubberBG, cbVolume, (_sControlsPosition==SizeUtils.TOP?SizeUtils.BOTTOM:SizeUtils.TOP), -(cbVolumeScrubberBG.height) );
			SizeUtils.moveByTarget( cbVolumeScrubber, cbVolumeScrubberBG, SizeUtils.CENTER, SizeUtils.MIDDLE );
			
			//Time labels
			xPosEnd = lTime.x = lTime.visible ? (xPosEnd - (lTime.width+timeGap)) : xPosEnd;
			
			//Stream Scrubber
			xPos = cbScrubber.x = xPos+innerGap;
			cbScrubber.width = ((width - xPos) - (width - xPosEnd) - timeGap);
		}
		
		/**
		 * GETTER / SETTER
		 */
		
		public function set source( source:IMediaHandler ): void
		{
			__registerSource(source);
		}
		
		public function get source(): IMediaHandler
		{
			return _source;
		}
		
		public function set currentTime( currentTime:uint ): void
		{
			_nCurrentTime = currentTime;
			updateClock();
		}
		
		public function get currentTime(): uint
		{
			return _nCurrentTime;
		}
		
		public function set length( length:Number ): void
		{
			_nLength = isNaN(length) ? 0 : length;
			
			//Update scrubber
			var streamScrubber:ISeekBar = cbScrubber as ISeekBar;
			if ( streamScrubber ) streamScrubber.maximum = _nLength;
			
			updateClock();
		}
		
		public function get length(): Number
		{
			return _nLength;
		}
		
		public function set volume( volume:Number ): void
		{
			_nVolume = volume;
			
			//Check to see if implements iseekbar
			var seekBar:ISeekBar = cbVolumeScrubber as ISeekBar;
			if ( seekBar ) seekBar.value = _nVolume;
			
			//Update source controller as well
			if ( _source )  _source.volume = _nVolume;
		}
		
		public function get volume(): Number
		{
			return _nVolume;
		}
		
		public function set mute( mute:Boolean ): void
		{
			_bMuted = mute;
			
			//Update source controller and display
			if ( _source )  _source.mute = mute;
			updateDisplayStates();
		}
		
		public function get mute(): Boolean
		{
			return _bMuted;
		}
		
		public function set seekPosition( seekSeconds:uint ): void
		{
			_nSeekSeconds = seekSeconds;
		}
		
		public function get seekPosition(): uint
		{
			return _nSeekSeconds;
		}
		
		public function set fullScreen( fullScreen:Boolean ): void
		{
			_bFullScreen = fullScreen;
			updateDisplayStates();
		}
		
		public function get fullScreen(): Boolean
		{
			return _bFullScreen;
		}
		
		public function set state( state:String ): void
		{
			_sState = state;
			updateDisplayStates();
		}
		
		public function get state(): String
		{
			return _sState;
		}
		
		public function set displayMode( displayMode:String ): void
		{
			__setNewDisplayMode( displayMode );
		}
		
		public function get displayMode(): String
		{
			return _sDisplayMode;
		}
		
		public function set showPlay( showPlay:Boolean ): void
		{
			_bShowPlay = showPlay;
			updateDisplayStates();
		}
		 
		public function get showPlay(): Boolean
		{
			return _bShowPlay;
		}
		
		public function set showStop( showStop:Boolean ): void
		{
			_bShowStop = showStop;
			updateDisplayStates();
		}
		 
		public function get showStop(): Boolean
		{
			return _bShowStop;
		}
		
		public function set showRewind( showRewind:Boolean ): void
		{
			_bShowRewind = showRewind;
			updateDisplayStates();
		}
		 
		public function get showRewind(): Boolean
		{
			return _bShowRewind;
		}
		
		public function set showVolume( showVolume:Boolean ): void
		{
			_bShowVolume = showVolume;
			updateDisplayStates();
		}
		 
		public function get showVolume(): Boolean
		{
			return _bShowVolume;
		}
		
		public function set showFullScreen( showFullScreen:Boolean ): void
		{
			_bShowFullScreen = showFullScreen;
			updateDisplayStates();
		}
		 
		public function get showFullScreen(): Boolean
		{
			return _bShowFullScreen;
		}
		
		public function set showStreamScrubber( showStreamScrubber:Boolean ): void
		{
			_bShowStreamScrubber = showStreamScrubber;
			updateDisplayStates();
		}
		 
		public function get showStreamScrubber(): Boolean
		{
			return _bShowStreamScrubber;
		}
		
		public function set showDuration( value:Boolean ): void
		{
			_bShowDuration = value;
			updateDisplayStates();
			if( initialized ) updateClock();
		}
		 
		public function get showDuration(): Boolean
		{
			return _bShowDuration;
		}
		
		public function set inverseCurrentTime( value:Boolean ): void
		{
			_bInverseTime = value;
			if( initialized ) updateClock();
		}
		 
		public function get inverseCurrentTime(): Boolean
		{
			return _bInverseTime;
		}
		
		public function set showTime( showTime:Boolean ): void
		{
			_bShowTime = showTime;
			updateDisplayStates();
			if( initialized ) updateClock();
		}
		 
		public function get showTime(): Boolean
		{
			return _bShowTime;
		}
		
		public function set showBuffer( showBuffer:Boolean ): void
		{
			_bShowBuffer = showBuffer;
			updateDisplayStates();
		}
		 
		public function get showBuffer(): Boolean
		{
			return _bShowBuffer;
		}
		
		override public function set buttonMode( value:Boolean ): void
		{
			_bButtonMode = value;
			if ( _sensorBar )
			{
				_sensorBar.buttonMode = _bButtonMode;
				_sensorBar.useHandCursor = _bButtonMode;
			}
			updateDisplayStates();
		}
		 
		override public function get buttonMode(): Boolean
		{
			return _bButtonMode;
		}
		
		public function set maxCache( maxCache:uint ): void 
		{
			if ( _nMaxCache == maxCache ) return;
			_nMaxCache = maxCache;
			__checkSeekTime();
		}
		
		public function get maxCache(): uint 
		{
			return _nMaxCache;
		}
		
		public function set controlsPosition( value:String ): void
		{
			_sControlsPosition = value;
			if ( initialized ) arrange();
		}
		
		public function get controlsPosition(): String
		{
			return _sControlsPosition;
		}
		
		public function get controlsHeight(): Number
		{
			return _nControlsHeight;
		}
		
		public function get controlBar(): InteractiveObject
		{
			return cbBackground;
		}
		
		public function get sensorBar(): DisplayObject
		{
			return _sensorBar;
		}
	}
}