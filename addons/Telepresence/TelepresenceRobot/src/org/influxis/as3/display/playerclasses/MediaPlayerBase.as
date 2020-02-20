package org.influxis.as3.display.playerclasses 
{
	//Flash Classes
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.FullScreenEvent;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	
	//Influxis Classes
	import org.influxis.as3.utils.MouseSensor;
	import org.influxis.as3.utils.handler;
	import org.influxis.as3.core.Display;
	import org.influxis.as3.states.PlayStates;
	import org.influxis.as3.states.ToggleStates;
	import org.influxis.as3.states.PositionStates;
	
	//Influxis Flotools Classes
	import org.influxis.flotools.core.InfluxisComponent;
	
	public class MediaPlayerBase extends InfluxisComponent
	{
		private static var _FULLSCREEN_PLAYER_:Number;
		
		protected var originalWidth:Number;
		protected var originalHeight:Number;
		protected var originalX:Number;
		protected var originalY:Number;
		protected var originalParent:DisplayObjectContainer;
		
		private var _video:DisplayObject;
		private var _sensor:MouseSensor;
		private var _content:*;
		
		private var _sLogoImage:String;
		private var _sLogoPosition:String;
		private var _bMuted:Boolean;
		private var _bIgnoreFullScreen:Boolean;
		private var _bFullScreen:Boolean;
		private var _nLogoScale:int;
		private var _nLogoPadding:uint;
		private var _nBuffer:Number;
		private var _nTime:Number;
		private var _nDuration:Number;
		private var _sShowControls:String = ToggleStates.AUTO;
		private var _sControlsPosition:String = PositionStates.BOTTOM;
		private var _sState:String = PlayStates.UNLOADED;
		private var _bAutoPlay:Boolean = true;
		private var _bAutoRewind:Boolean = true;
		private var _bSmoothing:Boolean = true;
		private var _bUseDualBuffer:Boolean = true;
		private var _bFullScreenSizing:Boolean = true;
		private var _bFullScreenSwap:Boolean = true;
		private var _nVolume:uint = 100;
		private var _nStartTime:int = -1;
		
		/**
		 * INIT API
		 */
		
		override protected function init():void 
		{
			_sensor = MouseSensor.getInstance();
			_sensor.addEventListener( MouseSensor.MOVE, __mouseSensorEvent );
			_sensor.addEventListener( MouseSensor.STOP, __mouseSensorEvent );
			
			super.init();
			stage.addEventListener( FullScreenEvent.FULL_SCREEN, handler(onFullScreen, id) );
		}
		
		/**
		 * PUBLIC API
		 */
		
		//Play the stream
		public function play(): void
		{
			
		}
		
		//Play the stream
		public function stop(): void
		{
			
		}
		
		//Pause the stream
		public function pause(): void
		{
			
		}
		
		//Seek stream
		public function seek( seekSeconds:uint ): void
		{
			
		}
		
		public function clear(): void
		{
			if ( playing ) stop();
			
		}
		
		public function next(): void
		{
			
		}
		
		public function previous(): void
		{
			
		}
		
		public function skipTo( index:* ): void
		{
			
		}
		
		/**
		 * PROTECTED API
		 */
		
		protected function doScreenSizing(): void
		{
			if ( !_bFullScreenSizing ) return;
			
			//Set size and positions
			setActualSize( (_bFullScreen?Display.STAGE.stageWidth:originalWidth), (_bFullScreen?Display.STAGE.stageHeight:originalHeight) );
			x = _bFullScreen ? 0 : originalX;
			y = _bFullScreen ? 0 : originalY;
		}
		 
		protected function showPlayControls( value:Boolean ): void
		{
			
		}
		
		/**
		 * PRIVATE API
		 */
		
		protected function setFullScreen( fullScreen:Boolean = true ): void
		{
			//These should be set before going into full screen mode
			if ( fullScreen )
			{
				originalWidth = width; originalHeight = height;
				originalX = x; originalY = y;
			}
			
			if ( fullScreen ) _FULLSCREEN_PLAYER_ = id;
			stage.displayState = fullScreen ? StageDisplayState.FULL_SCREEN : StageDisplayState.NORMAL;
		}
		 
		/**
		 * HANDLERS
		 */
		 
		private function __mouseSensorEvent( event:Event ): void
		{
			showPlayControls( event.type == MouseSensor.MOVE );
		}
		
		protected function onFullScreen( p_e:FullScreenEvent, id:uint = 0 ): void
		{
			
			_bFullScreen = p_e.fullScreen;
			
			if ( _FULLSCREEN_PLAYER_ != id || !_bFullScreenSizing ) return;
			var bSize:Boolean;
			if( _bFullScreen )
			{
				//_bFullScreen = true;
				
				//Only set this if not set before full screen
				if ( isNaN(originalWidth) && isNaN(originalHeight) )
				{
					originalWidth = width; originalHeight = height;
					originalX = x; originalY = y;
				}
				
				//Make sure you save a reference of the parent here
				if( parent != Display.STAGE && _bFullScreenSwap )
				{
					originalParent = DisplayObjectContainer( parent );
					addEventListener( Event.ADDED_TO_STAGE, onAddedToRootStage );
					DisplayObjectContainer(Display.STAGE).addChild( this );
				}else{
					bSize = true;
				}
			}else {
				//_bFullScreen = false;
				_FULLSCREEN_PLAYER_ = NaN;
				if ( originalParent && _bFullScreenSwap ) 
				{
					originalParent.addChild( this );
					originalParent = null;
				}else{
					bSize = true;
				}
			}
			
			if ( bSize ) 
			{
				doScreenSizing();
				if( !_bFullScreen ) originalWidth = originalHeight = originalX = originalY = NaN;
			}
			
			//If sensor is set to auto then make sure to have still action set to true when in full screen
			if ( showControls == ToggleStates.AUTO ) _sensor.stillAction = _bFullScreen;
		}
		
		protected function onAddedToRootStage( p_e:Event ): void
		{
			//Set size and positions
			doScreenSizing();
			
			//Nan old vals and remove listener
			if ( !_bFullScreen ) 
			{
				originalWidth = originalHeight = originalX = originalY = NaN;
				removeEventListener( Event.ADDED_TO_STAGE, onAddedToRootStage );
			}
		}
		
		protected function refreshMouseSensor(): void
		{
			if ( !initialized ) return;
			
			showPlayControls( _sShowControls == ToggleStates.AUTO ? _sensor.moving : (_sShowControls == ToggleStates.ON) );
			_sensor.startSensor( showControls == ToggleStates.AUTO );
		}
		
		/**
		 * GETTER / SETTER
		 */
		
		public function set content( value:* ): void
		{
			_content = value;
		}
		
		public function get content(): *
		{
			return _content;
		}
		
		public function set logo( value:String ): void
		{
			_sLogoImage = value;
		}
		
		public function get logo(): String
		{ 
			return _sLogoImage;
		}
		
		public function set logoPosition( value:String ): void
		{
			_sLogoPosition = value;
			if( initialized ) arrange();
		}
		
		public function get logoPosition(): String
		{ 
			return _sLogoPosition;
		}
		
		public function set scaleLogo( value:uint ):void 
		{
			_nLogoScale = value;
			if ( initialized ) arrange();
		}
		
		public function get scaleLogo(): uint
		{ 
			return _nLogoScale; 
		}
		
		[Inspectable(defaultValue=5)] 
		public function set logoPadding( value:uint ):void 
		{
			_nLogoPadding = value;
			if ( initialized ) arrange();
		}
		
		public function get logoPadding(): uint
		{ 
			return _nLogoPadding; 
		}
		
		public function set autoPlay( autoPlay:Boolean ): void
		{
			_bAutoPlay = autoPlay;
		}
		
		public function get autoPlay(): Boolean
		{
			return _bAutoPlay;
		}
		
		public function set autoRewind( autoRewind:Boolean ): void
		{
			_bAutoRewind = autoRewind;
		}
		
		public function get autoRewind(): Boolean
		{
			return _bAutoRewind;
		}
		
		public function set smoothing( smoothing:Boolean ): void
		{
			_bSmoothing = smoothing;
		}
		
		public function get smoothing(): Boolean
		{
			return _bSmoothing;
		}
		
		public function set muted( mute:Boolean ): void
		{
			_bMuted = mute;
			
		}
		
		public function get muted(): Boolean
		{
			return _bMuted;
		}
		
		public function set buffer( bufferTime:Number ): void
		{
			_nBuffer = bufferTime;
		}
		
		public function get buffer(): Number
		{
			return _nBuffer;
		}
		
		public function set useDualBuffer( value:Boolean ):void 
		{
			_bUseDualBuffer = value;
		}
		
		public function get useDualBuffer(): Boolean
		{ 
			return _bUseDualBuffer; 
		}
		
		public function set fullScreen( fullScreen:Boolean ): void
		{
			if ( !initialized ) return;
			setFullScreen( fullScreen );
		}
		
		public function get fullScreen(): Boolean
		{
			return _bFullScreen;
		}
		
		public function set fullScreenSizing( fullScreenSizing:Boolean ): void
		{
			_bFullScreenSizing = fullScreenSizing;
		}
		
		public function get fullScreenSizing(): Boolean
		{
			return _bFullScreenSizing;
		}
		
		public function set volume( volume:uint ): void
		{
			_nVolume = volume;
		}
		
		public function get volume(): uint
		{
			return _nVolume;
		}
		
		public function set startTime( value:int ): void
		{
			_nStartTime = value;
		}
		
		public function get startTime(): int
		{
			return _nStartTime;
		}
		
		public function set showControls( value:String ): void
		{
			if ( _sShowControls == value ) return;
			_sShowControls = value;
			refreshMouseSensor();
		}
		
		public function get showControls(): String
		{
			return _sShowControls;
		}
		
		public function set controlsPosition( value:String ): void
		{
			_sControlsPosition = value;
		}
		
		public function get controlsPosition(): String
		{
			return _sControlsPosition;
		}
		
		public function get playing(): Boolean
		{
			return (state == PlayStates.PLAYING);
		}
		
		public function get paused(): Boolean
		{
			return (state == PlayStates.PAUSED);
		}
		
		/*protected function set state( value:String ): void
		{
			_sState = value;
		}*/
		
		public function get state(): String
		{
			return _sState;
		}
		
		protected function set time( value:Number ): void
		{
			_nTime = value;
		}
		
		public function get time(): Number
		{
			return _nTime;
		}
		
		protected function set length( value:Number ): void
		{
			_nDuration = value;
		}
		
		public function get length(): Number
		{
			return _nDuration;
		}
		
		public function set ignoreFullScreen( value:Boolean ): void
		{
			_bIgnoreFullScreen = value;
		}
		 
		public function get ignoreFullScreen(): Boolean
		{
			return _bIgnoreFullScreen;
		}
		
		public function set fullScreenSwap( value:Boolean ):void 
		{
			_bFullScreenSwap = value;
		}
		
		public function get fullScreenSwap(): Boolean
		{
			return _bFullScreenSwap;
		}
		
		protected function get sensor(): MouseSensor
		{
			return _sensor;
		}
	}
}