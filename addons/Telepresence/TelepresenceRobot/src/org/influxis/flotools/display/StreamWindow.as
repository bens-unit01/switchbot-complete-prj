package org.influxis.flotools.display 
{
	//Flash Classes
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.media.Video;
	import flash.events.Event;
	import flash.net.NetStream;
	import flash.events.NetStatusEvent;
	
	//Influxis Classes
	import org.influxis.as3.core.infx_internal;
	import org.influxis.as3.containers.VideoContainer;
	import org.influxis.as3.display.StyleCanvas;
	import org.influxis.as3.states.AspectStates;
	import org.influxis.as3.utils.SizeUtils;
	import org.influxis.as3.utils.doTimedLater;
	
	public class StreamWindow extends StyleCanvas
	{
		public static const VIDEO_DIMENSIONS:String = "videoDimensions";
		private static var _AUTO_RESIZE_INTERVAL_:Number = 50;
		private var _nVideoWidth:int = 0;
		private var _nVideoHeight:int = 0;
		private var _netStream:NetStream;
		private var _bSizingReady:Boolean;
		private var _mainCaster:*;
		
		private var _videoContainer:VideoContainer;
		private var _mask:Sprite; 
		private var _stageVideoEnabled:Boolean = true;
		
		/*
		 * PUBLIC API
		 */
		
		/*
		 * PROTECTED API
		 */
		 
		protected function onStreamChanged( value:NetStream ): void
		{
			if ( _netStream )
			{
				if ( initialized ) _videoContainer.attachNetStream(null);
				_netStream.removeEventListener(NetStatusEvent.NET_STATUS, __handleStreamEvent);
			}
			
			_netStream = value;
			if ( !_netStream ) return;
			
			_netStream.addEventListener(NetStatusEvent.NET_STATUS, __handleStreamEvent);
			if ( initialized ) _videoContainer.attachNetStream(_netStream);
			
			//trace("onStreamChanged: " + initialized, _netStream, _videoContainer.video.videoWidth, _videoContainer.video.videoHeight );
			if ( _videoContainer.video.videoWidth != 0 || _videoContainer.video.videoHeight != 0 ) __checkVideoDimensions();
		}
		 
		/*
		 * PRIVATE API
		 */
		
		private function __checkVideoDimensions(): void
		{
			if( !_netStream ) return;
			
			if( _videoContainer.video.videoWidth == 0 && _videoContainer.video.videoHeight == 0 )
			{
				doTimedLater( _AUTO_RESIZE_INTERVAL_, __checkVideoDimensions );
			}else{
				//Need to set this before we call resize
				_nVideoWidth = _videoContainer.video.videoWidth;
				_nVideoHeight = _videoContainer.video.videoHeight;
				invalidateDisplayList();
				doTimedLater( _AUTO_RESIZE_INTERVAL_, __showVideo );
			}
		}
		
		private function __reCheckVidDimensions(): void
		{
			if( !_netStream ) return;
			
			if( _nVideoWidth != _videoContainer.video.videoWidth || _nVideoHeight != _videoContainer.video.videoHeight )
			{
				_nVideoWidth = _videoContainer.video.videoWidth;
				_nVideoHeight = _videoContainer.video.videoHeight;
				invalidateDisplayList();
			}
			doTimedLater( _AUTO_RESIZE_INTERVAL_, __reCheckVidDimensions );
		}
		
		private function __showVideo(): void
		{
			_videoContainer.visible = true;
		}
		
		/*
		 * HANDLERS
		 */
		
		private function __handleStreamEvent( event:NetStatusEvent ): void
		{
			//trace("__handleStreamEvent: " + event.info.code, _videoContainer.video.videoWidth, _videoContainer.video.videoHeight );
			switch( event.info.code )
			{
				case "NetStream.Video.DimensionChange" : 
					_bSizingReady = false;
					_nVideoWidth = _videoContainer.video.videoWidth;
					_nVideoHeight = _videoContainer.video.videoHeight;
					invalidateDisplayList();
					dispatchEvent(new Event(VIDEO_DIMENSIONS));
					doTimedLater( _AUTO_RESIZE_INTERVAL_, __showVideo );
					break;
				case "NetStream.Play.Start" : 
					_bSizingReady = true;
					break;
				case "NetStream.Buffer.Full" : 
					if ( _bSizingReady )
					{
						_bSizingReady = false;
						doTimedLater( _AUTO_RESIZE_INTERVAL_, __checkVideoDimensions );
					}
					break;
			}
		}
		
		private function __onContainerEvent( event:Event ): void
		{
			infx_internal::showBackground(!_videoContainer.usingStageVideo);
			if( _mainCaster != undefined ) _mainCaster.showBGGraphic = !_videoContainer.usingStageVideo;
		}
		
		/*
		 * DISPLAY API
		 */
		
		override protected function createChildren():void 
		{
			super.createChildren();
			_videoContainer = new VideoContainer();
			_videoContainer.addEventListener( Event.CHANGE, __onContainerEvent );
			_videoContainer.visible = false;
			_mask = new Sprite();
			addChildren(_videoContainer, _mask);
		}
		
		override protected function childrenCreated():void 
		{
			super.childrenCreated();
			_videoContainer.stageVideoEnabled = _stageVideoEnabled;
			if ( _netStream ) _videoContainer.attachNetStream(_netStream);
		}
		
		override protected function arrange():void 
		{
			super.arrange();
			
			//Draw Mask over so events can be triggered (mainly for stagevideo)
			_mask.graphics.beginFill(0x000000, 0);
			_mask.graphics.drawRect(0, 0, width, height);
			_mask.graphics.endFill();
			
			var oSize:Object = SizeUtils.getAspectSizing( AspectStates.LETTERBOX, width, height, _nVideoWidth, _nVideoHeight );
			_videoContainer.width = oSize.width; _videoContainer.height = oSize.height;
			SizeUtils.movePosition( _videoContainer, width, height, SizeUtils.CENTER, SizeUtils.MIDDLE );
		}
		
		/*
		 * GETTER / SETTER
		 */
		
		public function set mainCasterBG( value:* ): void
		{
			if ( _mainCaster != undefined && value != _mainCaster ) _mainCaster.showBGGraphic = true;
			
			_mainCaster = value;
			if ( _mainCaster != undefined ) _mainCaster.showBGGraphic = !_videoContainer.usingStageVideo;
		}
		
		public function set netstream( value:NetStream ): void
		{
			if ( value == _netStream ) return;
			onStreamChanged(value);
		}
		
		public function get netstream(): NetStream
		{
			return _netStream
		}
		
		public function get videoContainer(): VideoContainer
		{
			return _videoContainer;
		}
		
		public function set stageVideoEnabled( value:Boolean ): void
		{
			if ( _stageVideoEnabled == value ) return;
			_stageVideoEnabled = value;
			if ( _videoContainer ) _videoContainer.stageVideoEnabled = _stageVideoEnabled;
		}
		
		public function get stageVideoEnabled(): Boolean
		{
			return _stageVideoEnabled;
		}
	}
}