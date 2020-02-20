package org.influxis.flotools.display 
{
	//Flash Classes
	import flash.display.DisplayObject;
	import flash.events.ActivityEvent;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.media.Microphone;
	import flash.utils.Timer;
	
	//Influxis Classes
	import org.influxis.as3.display.StyleCanvas;
	import org.influxis.as3.utils.SizeUtils;
	
	//MobileCaster Classes
	import org.influxis.flotools.data.MediaSettings;
	
	public class MicLevel extends StyleCanvas
	{
		private var _mediaSettings:MediaSettings;
		private var _mic:Microphone;
		private var _timer:Timer;
		
		private var uiMicLvMeter:DisplayObject;
		private var uiMicMask:DisplayObject;
		
		/*
		 * INIT API
		 */
		
		override protected function preInitialize():void 
		{
			_mediaSettings = MediaSettings.getInstance();
			if ( _mediaSettings.microphone )
			{
				onMicrophone(_mediaSettings.microphone);
			}else{
				_mediaSettings.addEventListener( MediaSettings.INITIALIZED, __onMediaEvent );
			}
			_mediaSettings.addEventListener( MediaSettings.MICROPHONE_CHANGE, __onMediaEvent );
			super.preInitialize();
		}
		 
		override protected function init():void 
		{
			visible = Microphone.isSupported;
			super.init();
			
			_timer = new Timer(50);
			_timer.addEventListener( TimerEvent.TIMER, drawMeter );
		}
		
		/*
		 * HANDLERS
		 */
		
		private function __onMediaEvent( event:Event ): void
		{
			if ( event.type == MediaSettings.INITIALIZED ) _mediaSettings.removeEventListener( MediaSettings.INITIALIZED, __onMediaEvent );
			onMicrophone(_mediaSettings.microphone);
		}
		 
		private function __onMicEvent( event:ActivityEvent ): void
		{
			if ( event.activating )
			{
				_timer.start();
			}else{
				_timer.stop();
				_timer.reset();
			}
		}
		
		/*
		 * PROTECTED
		 */
		
		protected function onMicrophone( value:Microphone ): void
		{
			if ( _mic == value ) return;
			
			if ( _mic ) 
			{
				_timer.stop();
				_timer.reset();
				_mic.removeEventListener( ActivityEvent.ACTIVITY, __onMicEvent );
			}
			
			_mic = value;
			if ( _mic ) 
			{
				_mic.addEventListener( ActivityEvent.ACTIVITY, __onMicEvent );
				_timer.start();
			}
			drawMeter();
		}
		
		protected function drawMeter( ...args ): void
		{
			if ( !_mic )
			{
				uiMicMask.height = 0;
			}else {
				var newHeight:Number = (((uiMicLvMeter.height) / 100) * _mic.activityLevel);
				uiMicMask.height = newHeight;
				SizeUtils.moveY( uiMicMask, height, SizeUtils.BOTTOM, paddingBottom );
			}
		}
		
		/*
		 * DISPLAY API
		 */
		 
		override protected function createChildren():void 
		{
			super.createChildren();
			uiMicLvMeter = getStyleGraphic("meter");
			uiMicMask = getStyleGraphic(styleExists("meterMask") ? "meterMask" : "background");
			uiMicMask.alpha = 0;
			addChildren( uiMicLvMeter, uiMicMask );
		}
		
		override protected function childrenCreated():void 
		{
			super.childrenCreated();
			uiMicLvMeter.mask = uiMicMask;
		}
		
		override protected function arrange():void 
		{
			super.arrange();
			
			uiMicMask.width = width - (paddingLeft + paddingRight);
			uiMicMask.x = paddingLeft;
			
			uiMicLvMeter.width = width - (paddingLeft + paddingRight);
			uiMicLvMeter.height = height - (paddingTop + paddingBottom);
			uiMicLvMeter.x = paddingLeft; uiMicLvMeter.y = paddingTop;
			drawMeter();
		}
	}
}