package org.influxis.as3.containers 
{
	//Flash Classes
	import flash.events.Event;
	import flash.events.StageVideoAvailabilityEvent;
	import flash.events.StageVideoEvent;
	import flash.media.Camera;
	import flash.media.StageVideoAvailability;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Video;
	import flash.media.StageVideo;
	import flash.net.NetStream;
	import flash.utils.setTimeout;
	
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	//Influxis Classes
	import org.influxis.as3.display.SimpleComponent;
	import org.influxis.as3.utils.ScreenScaler;
	
	public class VideoContainer extends SimpleComponent
	{
		private var _video:*;
		private var _viewPort:Rectangle;
		private var _usingStageVideo:Boolean;
		private var _camera:Camera;
		private var _netstream:NetStream;
		private var _stageVideoEnabled:Boolean = true;
		
		/*
		 * INIT API
		 */
		
		override protected function preInitialize(): void 
		{
			super.preInitialize();
			stage.addEventListener(StageVideoAvailabilityEvent.STAGE_VIDEO_AVAILABILITY, __onStageVideoEvent );
		}
		
		/*
		 * PUBLIC API
		 */
		
		public function attachCamera( theCamera:Camera ): void
		{
			if ( _camera == theCamera ) return;
			_camera = theCamera;
			if ( _video ) _video.attachCamera( _camera );
		}
		
		public function attachNetStream( netStream:NetStream ): void
		{
			if ( _netstream == netStream ) return;
			_netstream = netStream;
			if ( _video != undefined ) _video.attachNetStream( _netstream );
		}
		
		/*
		 * PRIVATE API
		 */
		
		protected function enableStageVideo( value:Boolean, overrideCmd:Boolean = false ): void
		{
			if ( !overrideCmd && _usingStageVideo == value ) return;
			
			//Remove old attachment
			if ( _video != undefined )
			{
				if ( _camera )
				{
					_video.attachCamera(null);
				}else if ( _netstream )
				{
					_video.attachNetStream(null);
				}
				
				//Take off video from display if attached
				if ( _video is Video && contains(_video) ) 
				{
					removeChild(_video);
				}else{
					_video.viewPort = new Rectangle(0,0,0,0);
				}
				_video = null;
			}
			
			_usingStageVideo = value;
			//if( initialized ) _text.visible = _usingStageVideo;
			
			//If stage video then add else use regular
			if ( _usingStageVideo )
			{
				_video = stage.stageVideos[0];
			}else {
				_video = new Video();
				if( initialized ) addChildAt(_video, 0);
			}
			
			//Attach cam or netstream
			if ( _camera ) _video.attachCamera(_camera);
			if ( _netstream ) _video.attachNetStream(_netstream);
			
			arrange();
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		/*
		 * HANDLERS
		 */
		
		private function __onStageVideoEvent( event:StageVideoAvailabilityEvent ): void
		{
			//Remove old event
			stage.removeEventListener(StageVideoAvailabilityEvent.STAGE_VIDEO_AVAILABILITY, __onStageVideoEvent );
			
			//Check availability and add listener to check render state (sometimes video is there but then unavailable)
			if ( event.availability == StageVideoAvailability.AVAILABLE && stage.stageVideos.length > 0 ) 
			{
				stage.stageVideos[0].addEventListener( StageVideoEvent.RENDER_STATE, __onStageVideoEvent2 );
			}
			
			//Go ahead and run attachments
			enableStageVideo( !_usingStageVideo ? false : event.availability == StageVideoAvailability.AVAILABLE, true);
		}
		
		private function __onStageVideoEvent2( event:StageVideoEvent ): void
		{
			var available:Boolean = event.status != StageVideoAvailability.UNAVAILABLE;
			if( _usingStageVideo ) setTimeout( enableStageVideo, 10, available, _usingStageVideo != available );
		}
		
		/*
		 * DISPLAY API
		 */
		
		override protected function onPositionChanged(omitEvent:Boolean = false):void 
		{
			super.onPositionChanged(omitEvent);
			if ( _usingStageVideo ) arrange();
		}
		
		//private var _text:TextField;
		override protected function createChildren():void 
		{
			super.createChildren();
			
			/*_text = new TextField();
			_text.autoSize = TextFieldAutoSize.LEFT;
			_text.textColor = 0xcccccc;
			_text.defaultTextFormat.size = ScreenScaler.calculateSize(12);
			_text.text = "StageVideo PowerEnabled";
			_text.visible = usingStageVideo;
			addChild(_text);*/
		}
		
		override protected function childrenCreated():void 
		{
			super.childrenCreated();
			//Attach video if you havent done so yet
			if( _video is Video ) addChildAt(_video, 0);
		}
		
		override protected function arrange():void 
		{
			super.arrange();
			if ( _video != undefined )
			{
				if ( _usingStageVideo )
				{
					_viewPort = new Rectangle( x, y, width, height );
					if( visible ) _video.viewPort = _viewPort;	
				}else{
					_video.width = width;
					_video.height = height;
				}
			}	
		}
		
		/*
		 * GETTER / SETTER - API
		 */
		
		public function get video(): *
		{
			return _video;
		}
		
		public function get usingStageVideo(): Boolean
		{
			return _usingStageVideo;
		}
		
		public function set stageVideoEnabled( value:Boolean ): void
		{
			if ( _stageVideoEnabled == value ) return;
			_stageVideoEnabled = value;
			enableStageVideo( _stageVideoEnabled, true );
		}
		
		public function get stageVideoEnabled(): Boolean
		{
			return _stageVideoEnabled;
		}
		
		override public function set visible(value:Boolean):void 
		{
			super.visible = value;
			if ( _video != undefined && _stageVideoEnabled ) _video.viewPort = visible ? _viewPort : null;
		}
	}
}