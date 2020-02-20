package org.influxis.flotools.display 
{
	//Flash Classes
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.media.Camera;
	import flash.media.Microphone;
	import flash.media.Video;
	import flash.events.Event;
	import flash.net.NetStream;
	
	//Influxis Classes
	import org.influxis.as3.core.infx_internal;
	import org.influxis.as3.containers.VideoContainer;
	import org.influxis.as3.display.StyleCanvas;
	import org.influxis.as3.states.AspectStates;
	import org.influxis.as3.utils.SizeUtils;
	import org.influxis.as3.utils.doTimedLater;
	import org.influxis.flotools.data.MediaSettings;
	import org.influxis.flotools.net.BWDetect;
	
	public class CamWindow extends StyleCanvas
	{
		use namespace infx_internal;
		private var _videoContainer:VideoContainer;
		private var _mask:Sprite; 
		private var _mediaSettings:MediaSettings;
		private var _check:BWDetect;
		private var _camInitialized:Boolean;
		private var _stageVideoEnabled:Boolean = true;
		private var _scaleMode:String = AspectStates.LETTERBOX;
		
		/*
		 * INIT API
		 */
		
		public function CamWindow(): void
		{
			_mediaSettings = MediaSettings.getInstance();
			super();
		}
		
		/*
		 * PUBLIC API
		 */
		
		public function toggleCamera(): void
		{
			if ( Camera.names.length < 2 ) return;
			_mediaSettings.cameraIndex = _mediaSettings.camera.index == 0 ? 1 : 0;
		}
		
		public function doCameraInit(): void
		{
			if ( _camInitialized ) return;
			
			if ( available ) 
			{
				_camInitialized = true;
				_mediaSettings.initDefaultMediaCaptures();
				if( initialized ) _videoContainer.attachCamera(_mediaSettings.camera);
				invalidateDisplayList();
			}
		}
		
		/*
		 * HANDLERS
		 */
		
		private function __onMediaEvent( event:Event ): void
		{
			if ( event.type == MediaSettings.CAMERA_CHANGE )
			{
				_videoContainer.attachCamera(_mediaSettings.camera);
				dispatchEvent(new Event(Event.CHANGE));
			}
			invalidateDisplayList();
		}
		
		private function __onContainerEvent( event:Event ): void
		{
			infx_internal::showBackground(!_videoContainer.usingStageVideo);
			if( _mainCaster != undefined ) _mainCaster.showBGGraphic = !_videoContainer.usingStageVideo;
		}
		
		/*
		 * DISPLAY API
		 */
		
		override protected function createChildren(): void 
		{
			super.createChildren();
			_videoContainer = new VideoContainer();
			_videoContainer.addEventListener( Event.CHANGE, __onContainerEvent );
			_mask = new Sprite();
			addChildren(_videoContainer, _mask);
		}
		
		override protected function childrenCreated(): void 
		{
			super.childrenCreated();
			
			_mediaSettings.addEventListener( MediaSettings.CAMERA_CHANGE, __onMediaEvent );
			_mediaSettings.addEventListener( Event.CHANGE, __onMediaEvent );
			_videoContainer.stageVideoEnabled = _stageVideoEnabled;
			
			if ( _camInitialized || _mediaSettings.initialized ) 
			{
				_camInitialized = true;
				_videoContainer.attachCamera(_mediaSettings.camera);
				dispatchEvent(new Event(Event.CHANGE));
			}
		}
		
		override protected function arrange():void 
		{
			super.arrange();
			
			//Draw Mask over so events can be triggered (mainly for stagevideo)
			_mask.graphics.beginFill(0x000000, 0);
			_mask.graphics.drawRect(0, 0, width, height);
			_mask.graphics.endFill();
			
			if ( _mediaSettings.camera )
			{
				var oSize:Object = SizeUtils.getAspectSizing( _scaleMode, width, height, _mediaSettings.camera.width, _mediaSettings.camera.height );
				_videoContainer.setActualSize( oSize.width, oSize.height );
				SizeUtils.movePosition( _videoContainer, width, height, SizeUtils.CENTER, SizeUtils.MIDDLE );
			}
		}
		
		/*
		 * GETTER / SETTER
		 */
		
		private var _mainCaster:*;
		public function set mainCasterBG( value:* ): void
		{
			if ( _mainCaster != undefined && value != _mainCaster ) _mainCaster.showBGGraphic = true;
			
			_mainCaster = value;
			if ( _mainCaster != undefined ) _mainCaster.showBGGraphic = !_videoContainer.usingStageVideo;
		}
		
		public function get multiCam(): Boolean
		{
			return Camera.names.length > 1;
		}
		
		public function get available(): Boolean
		{
			return Camera.names.length > 0;
		}
		
		public function get camera(): Camera
		{
			return _mediaSettings.camera;
		}
		
		public function get microphone(): Microphone
		{
			return _mediaSettings.microphone;
		}
		
		public function set netstream( value:NetStream ): void
		{
			_mediaSettings.netStream = value;
		}
		
		public function set bwChecker( value:BWDetect ): void
		{
			if ( _mediaSettings.bwChecker == value ) return;
			_mediaSettings.bwChecker = value;
		}
		
		public function get streamMetaData(): Object
		{
			return _mediaSettings.metaData;
		}
		
		public function get videoContainer(): DisplayObject
		{
			return _videoContainer;
		}
		
		public function get camInitialized(): Boolean
		{
			return _camInitialized;
		}
		
		public function get camWindow(): VideoContainer
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
		
		public function set qualityLimitationLevel( value:Number ): void
		{
			if ( _mediaSettings.qualityLimitationLevel == value ) return;
			_mediaSettings.qualityLimitationLevel = value;
		}
		
		public function get qualityLimitationLevel(): Number
		{
			return _mediaSettings.qualityLimitationLevel;
		}
		
		public function set scaleMode( value:String ): void
		{
			if ( _scaleMode == value ) return;
			_scaleMode = value;
			invalidateDisplayList();
		}
		
		public function get scaleMode(): String
		{
			return _scaleMode;
		}
	}
}