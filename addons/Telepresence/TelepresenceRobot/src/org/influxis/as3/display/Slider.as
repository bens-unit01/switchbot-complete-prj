/**
 * Slider - Copyright © 2010 Influxis All rights reserved.
**/

package org.influxis.as3.display 
{
	//Flash Classes
	import flash.display.InteractiveObject;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	//Influxis Classes
	import org.influxis.as3.display.StyleComponent;
	import org.influxis.as3.skins.StateSkin;
	import org.influxis.as3.states.PositionStates;
	import org.influxis.as3.interfaces.controls.ISeekBar;
	import org.influxis.as3.interfaces.display.ISimpleSprite;
	import org.influxis.as3.utils.ScreenScaler;
	import org.influxis.as3.utils.handler;
	
	//Events
	[Event( name = "thumbPress", type = "flash.events.Event" )]
	[Event( name = "thumbDrag", type = "flash.events.Event" )]
	[Event( name = "thumbRelease", type = "flash.events.Event" )]
	[Event( name = "change", type = "flash.events.Event" )]
	[Event( name = "trackClick", type = "flash.events.Event" )]
	
	public class Slider extends StyleComponent implements ISeekBar
	{
		public static var symbolName:String = "Slider";
		public static var symbolOwner:Object = org.influxis.as3.display.Slider;
		private var infxClassName:String = "Slider";
		private var _sVersion:String = "1.0.0.0";
		
		private static const _DELAY_RATE_:Number = 10;
		
		public static const THUMB_PRESS:String = "thumbPress";
		public static const THUMB_RELEASE:String = "thumbRelease";
		public static const THUMB_DRAG:String = "thumbDrag";
		public static const TRACK_CLICK:String = "trackClick";
		 
		private var _bMouseDown:Boolean;
		private var _nLastXPos:Number;
		private var _nLastYPos:Number;
		
		private var _aTicks:Vector.<Number>;
		private var _aSnaps:Vector.<Number>;
		private var _sDirection:String = PositionStates.RIGHT;
		private var _nMinimum:Number = 0;
		private var _nMaximum:Number = 100;
		private var _nValue:Number = 0;
		private var _nAvailable:Number = -1;
		private var _nAvailableStart:Number = -1;
		private var _timer:Timer;
		private var _nSnapMin:Number;
		private var _nSnapMax:Number;
		private var _bTrackClickEnabled:Boolean = true;
		private var _bDrawHighlightFromValue:Boolean;
		
		protected var THUMB_UP_SKIN:String = "thumb:up";
		protected var THUMB_DOWN_SKIN:String = "thumb:down";
		protected var THUMB_OVER_SKIN:String = "thumb:over";
		protected var THUMB_DISABLED_SKIN:String = "thumb:disabled";
		protected var TRACK_SKIN:String = "track";
		protected var HIGHLIGHT_SKIN:String = "highlight";
		protected var HIGHLIGHT_MASK_SKIN:String = "highlightMask";
		protected var AVAILABLE_SKIN:String = "available";
		protected var AVAILABLE_MASK_SKIN:String = "availableMask";
		
		protected var cbThumb:InteractiveObject;
		protected var bgTrack:InteractiveObject;
		protected var bgHighlight:InteractiveObject;
		protected var bgHighlightMask:InteractiveObject;
		protected var bgLoaded:InteractiveObject;
		protected var bgLoadedMask:InteractiveObject;
		protected var tickHolder:DisplayObjectContainer;
		protected var cbThumbDisabled:DisplayObject;
		
		/**
		 * INIT API
		 */
		
		override protected function init(): void
		{
			super.init();
			
			_timer = new Timer( _DELAY_RATE_ );
			_timer.addEventListener( TimerEvent.TIMER, __onTimer );
		}
		
		/**
		 * PROTECTED API
		 */
		
		protected function moveThumb( mouseXPos:Number, mouseYPos:Number ): void
		{
			if ( direction == PositionStates.UP || direction == PositionStates.DOWN )
			{
				cbThumb.y = mouseYPos;
			}else if ( direction == PositionStates.RIGHT || direction == PositionStates.LEFT )
			{
				cbThumb.x = mouseXPos;
			}
			
			updateValues();
			drawHighlight();
			//tracer( "moveThumb: " + direction + " : " + PositionStates.LEFT + " : " + mouseXPos + " : " + _nValue );
		}
		
		protected function drawHighlight(): void
		{
			if ( _bDrawHighlightFromValue )
			{
				if ( direction == PositionStates.UP || direction == PositionStates.DOWN )
				{
					bgHighlightMask.width = width;
					bgHighlightMask.height = calculatePixels( _nValue, height, _nMaximum, _nMinimum, 0, direction == PositionStates.UP );
				}else if ( direction == PositionStates.RIGHT || direction == PositionStates.LEFT )
				{
					bgHighlightMask.width = calculatePixels( _nValue, width, _nMaximum, _nMinimum, 0, direction == PositionStates.LEFT );
					bgHighlightMask.height = height;
				}
			}else{
				bgHighlightMask.width = direction == PositionStates.UP || direction == PositionStates.DOWN ? width : direction == PositionStates.RIGHT ? cbThumb.x : (width-cbThumb.x);
				bgHighlightMask.height = direction == PositionStates.RIGHT || direction == PositionStates.LEFT ? height : direction == PositionStates.DOWN ? cbThumb.y : (height - cbThumb.y);
			}
			bgHighlightMask.x = direction == PositionStates.RIGHT || direction == PositionStates.DOWN ? 0 : (width-bgHighlightMask.width);
			bgHighlightMask.y = direction == PositionStates.RIGHT || direction == PositionStates.DOWN ? 0 : (height-bgHighlightMask.height);
		}
		
		protected function drawAvailable(): void
		{
			if ( direction == PositionStates.UP || direction == PositionStates.DOWN )
			{
				bgLoadedMask.width = width;
				bgLoadedMask.height = _nAvailable < 1 ? 0 : calculatePixels( _nAvailable, height, _nMaximum, _nMinimum, 0, direction == PositionStates.UP );
			}else if ( direction == PositionStates.RIGHT || direction == PositionStates.LEFT )
			{
				bgLoadedMask.width = _nAvailable < 1 ? 0 : calculatePixels( _nAvailable, width, _nMaximum, _nMinimum, 0, direction == PositionStates.LEFT );
				bgLoadedMask.height = height;
			}
			bgLoadedMask.x = direction == PositionStates.RIGHT || direction == PositionStates.DOWN ? 0 : (width-bgLoadedMask.width);
			bgLoadedMask.y = direction == PositionStates.RIGHT || direction == PositionStates.DOWN ? 0 : (height-bgLoadedMask.height);
		}
		
		protected function updateValues(): void
		{
			var nValue:Number;
			if ( direction == PositionStates.UP || direction == PositionStates.DOWN )
			{
				nValue = calculateUnits( cbThumb.y, height, _nMaximum, _nMinimum, cbThumb.height, direction == PositionStates.UP ); //direction == DOWN ? (((height-cbThumb.height)/_nMaximum)*_nValue) : ((height-cbThumb.height)-(((height-cbThumb.height)/_nMaximum)*_nValue));
			}else if ( direction == PositionStates.RIGHT || direction == PositionStates.LEFT )
			{
				nValue = calculateUnits( cbThumb.x, width, _nMaximum, _nMinimum, cbThumb.width, direction == PositionStates.LEFT ); //direction == RIGHT ? (((width-cbThumb.width)/_nMaximum)*_nValue) : ((width-cbThumb.width)-(((width-cbThumb.width)/_nMaximum)*_nValue));
			}
			
			//trace("updateValues: " + maximum, minimum, nValue );
			//If snap interval was set then set based on those values
			if ( _aSnaps && _aSnaps.length > 1 )
			{
				//Only reset if min/max values changed (saves on looping)
				if ( isNaN(_nSnapMin) || isNaN(_nSnapMax) || _nSnapMin > nValue || _nSnapMax < nValue ) resetSnapValues(nValue);
				
				if ( !isNaN(_nSnapMin) && !isNaN(_nSnapMax) )
				{
					//Calculate which value wins :D
					var minVal:Number = Math.max(_nSnapMin, nValue) - Math.min(_nSnapMin, nValue);
					var maxVal:Number = Math.max(_nSnapMax, nValue) - Math.min(_nSnapMax, nValue);
					
					nValue = Math.min(minVal, maxVal) == minVal ? _nSnapMin : _nSnapMax;
				}
			}
			
			if ( nValue == _nValue ) return;
			_nValue = nValue;
			
			//Change only dispatched when thumb moves or track is clicked or else loop
			dispatchEvent( new Event(Event.CHANGE) );
		}
		
		protected function resetSnapValues( value:Number ): void
		{
			if ( !_aSnaps || _aSnaps.length < 2 ) return;
			
			for each( var i:Number in _aSnaps )
			{
				if ( i <= value ) _nSnapMin = Math.max(_nSnapMin, value) - Math.min(_nSnapMin, value) <= Math.max(i, value) - Math.min(i, value) ? _nSnapMin : i;
				if ( i >= value  ) _nSnapMax = Math.max(_nSnapMax, value) - Math.min(_nSnapMax, value) <= Math.max(i, value) - Math.min(i, value) ? _nSnapMax : i;
			}
		}
		
		protected function updateThumbPosition(): void
		{
			if ( direction == PositionStates.UP || direction == PositionStates.DOWN )
			{
				var yPos:Number = calculatePixels( _nValue, height, _nMaximum, _nMinimum, cbThumb.height, direction == PositionStates.UP );
				cbThumb.y = yPos;
			}else if ( direction == PositionStates.RIGHT || direction == PositionStates.LEFT )
			{
				var xPos:Number = calculatePixels( _nValue, width, _nMaximum, _nMinimum, cbThumb.width, direction == PositionStates.LEFT );
				cbThumb.x = xPos;
			}
			drawHighlight();
		}
		
		protected function updateAvailable(): void
		{
			__checkValue();
			arrange();
		}
		
		override protected function setEnabled(enabled:Boolean):void 
		{
			super.setEnabled(enabled);
			if ( !initialized ) return;
			
			//Set to enabled state
			var stateThumb:StateSkin = cbThumb as StateSkin;
				stateThumb.enabled = enabled;
		}
		
		protected function calculateUnits( pixels:Number, totalPixels:Number, maxUnits:Number, minUnits:Number, pixelOffset:Number = 0, reversed:Boolean = false ): Number
		{
			var total:Number = totalPixels - pixelOffset;
			if ( reversed ) pixels = total - pixels;
			return ((pixels /(total/(maxUnits - minUnits))) + minUnits);
		}
		
		protected function calculatePixels( units:Number, totalPixels:Number, maxUnits:Number, minUnits:Number, pixelOffset:Number = 0, reversed:Boolean = false ): Number
		{
			var total:Number = totalPixels - pixelOffset;
			var results:Number;
			
			results = ((total / (maxUnits-minUnits)) * (units-minUnits));
			if( reversed ) results = total-results;
			return results;
		}
		
		/**
		 * PRIVATE API
		 */
		
		private function __checkValue(): void
		{
			//Check for maximum and minimum values
			_nValue = _nValue < _nMinimum ? _nMinimum : _nValue > _nMaximum ? _nMaximum : _nValue;
			
			//Check for available values
			_nValue = _nValue < _nAvailableStart ? _nAvailableStart : _nValue > _nAvailable && _nAvailable > 0 ? _nAvailable : _nValue;
		}
		
		private function __checkValueExceeded(): Boolean
		{
			//if ( _nAvailableStart < 0 && _nAvailable < 0 ) return false;
			
			var xpos:Number = Math.floor(mouseX) - (cbThumb.width / 2);
				xpos = (xpos > (width - (cbThumb.width)) ? (width - cbThumb.width) : xpos < 0 ? 0 : xpos);
			
			var ypos:Number = Math.floor(mouseY) - (cbThumb.height / 2);
				ypos = (ypos > (height - cbThumb.height) ? (height - cbThumb.height) : ypos < 0 ? 0 : ypos);
				
			var bExceeded:Boolean;
			var nValue:Number;
			if ( direction == PositionStates.UP || direction == PositionStates.DOWN )
			{
				nValue = calculateUnits( ypos, height, _nMaximum, _nMinimum, cbThumb.height, direction == PositionStates.UP );
			}else if ( direction == PositionStates.RIGHT || direction == PositionStates.LEFT )
			{
				nValue = calculateUnits( xpos, width, _nMaximum, _nMinimum, cbThumb.width, direction == PositionStates.LEFT );
			}
			
			if ( (nValue < _nAvailableStart || (nValue > _nAvailable && _nAvailable > 0) ) ) bExceeded = true;
			if ( !bExceeded && nValue == _nValue ) bExceeded = true;
			return bExceeded;
		}
		
		/**
		 * HANDLERS
		 */
		
		private function __onTimer( p_e:Event = null ): void
		{
			var xpos:Number = mouseX - (cbThumb.width / 2);
			var ypos:Number = mouseY - (cbThumb.height / 2);
			
			//Make sure values actually change before allowing to move
			if ( _nLastXPos == xpos && _nLastYPos == ypos ) return;
			if ( __checkValueExceeded() ) return;
			
			_nLastXPos = xpos;
			_nLastYPos = ypos;
			moveThumb( (xpos > (width - (cbThumb.width))?
							(width - cbThumb.width):
							 xpos < 0?0:xpos), 
					   (ypos > (height - cbThumb.height)?
							(height - cbThumb.height):
							 ypos < 0?0:ypos) );
			
			//Fired when thumb is dragging
			if ( p_e && enabled ) dispatchEvent( new Event(THUMB_DRAG) );
		}
		
		private function __onMouseEvent( p_e:Event, trackEvent:Boolean = false ): void
		{
			if ( !enabled ) return;
			
			var type:String = p_e.type;
			if ( type == MouseEvent.MOUSE_DOWN && !_bMouseDown )
			{
				if ( !trackEvent )
				{
					_bMouseDown = true;
					_timer.start();
					dispatchEvent( new Event(THUMB_PRESS) );
				}else if ( _bTrackClickEnabled )
				{
					__onTimer();
					dispatchEvent( new Event(TRACK_CLICK) );
				}
			}else if ( type == MouseEvent.MOUSE_UP && _bMouseDown )
			{
				_bMouseDown = false;
				_timer.stop();
				
				//Only update thumb position if snaps were placed
				if ( _aSnaps && _aSnaps.length > 1 ) updateThumbPosition();
				dispatchEvent( new Event(THUMB_RELEASE) );
			}
		}
		
		/**
		 * DISPLAY API
		 */
		
		protected function drawTicks(): void
		{
			if ( !tickHolder ) return;
			
			//Remove odl ticks
			var nLen:Number = tickHolder.numChildren;
			for ( var i:Number = (nLen - 1); i > -1; i-- ) 
			{
				tickHolder.removeChildAt(i);
			}
			
			if ( !_aTicks || _aTicks.length == 0 ) return;
				
			//Add new ones
			nLen = _aTicks.length;
			for ( var n:Number = 0; n < nLen; n++ )
			{
				tickHolder.addChildAt(getStyleGraphic("tick" + (styleExists("tick"+n) ? String(n) : "")), n);
			}
			arrangeTicks();
		}
		
		override protected function measure():void 
		{
			super.measure();
			
			if ( direction == PositionStates.UP || direction == PositionStates.DOWN )
			{
				measuredWidth = cbThumb.width > bgTrack.width ? cbThumb.width : bgTrack.width;
				measuredHeight = ScreenScaler.calculateSize(100);
			}else{
				measuredHeight = cbThumb.height > bgTrack.height ? cbThumb.height : bgTrack.height;
				measuredWidth = ScreenScaler.calculateSize(100);
			}
		}
		
		override protected function createChildren():void 
		{
			super.createChildren();
			
			cbThumb = new StateSkin( skinName, "thumb" );
			bgTrack = getStyleGraphic(TRACK_SKIN);
			bgHighlight = getStyleGraphic(HIGHLIGHT_SKIN);
			bgHighlightMask = getStyleGraphic(HIGHLIGHT_MASK_SKIN);
			bgLoaded = getStyleGraphic(AVAILABLE_SKIN);
			bgLoadedMask = getStyleGraphic(AVAILABLE_MASK_SKIN);
			cbThumbDisabled = getStyleGraphic(THUMB_DISABLED_SKIN);
			tickHolder = new Sprite();
			
			bgHighlight.mask = bgHighlightMask;
			bgLoaded.mask = bgLoadedMask;
			
			bgTrack.visible = bgHighlight.visible = bgLoaded.visible = false;
			addChildren(bgTrack, bgLoaded, bgLoadedMask, bgHighlight, bgHighlightMask, tickHolder, cbThumb );
		}
		 
		override protected function childrenCreated():void 
		{
			__checkValue();
			super.childrenCreated();
			
			cbThumb.addEventListener( MouseEvent.MOUSE_DOWN, __onMouseEvent );
			stage.addEventListener( MouseEvent.MOUSE_UP, __onMouseEvent );
			
			//Used for clicks
			bgTrack.addEventListener( MouseEvent.MOUSE_DOWN, handler(__onMouseEvent, true) );
			bgHighlight.addEventListener( MouseEvent.MOUSE_DOWN, handler(__onMouseEvent, true) );
			bgLoaded.addEventListener( MouseEvent.MOUSE_DOWN, handler(__onMouseEvent, true) );
			
			bgTrack.visible = bgHighlight.visible = bgLoaded.visible = true;
			var stateThumb:StateSkin = cbThumb as StateSkin;
				stateThumb.enabled = enabled;
				
			drawTicks();
		}
		
		override protected function arrange():void 
		{
			super.arrange();
			
			bgTrack.width = width;
			bgTrack.height = height;
			bgHighlight.width = width;
			bgHighlight.height = height;
			bgLoaded.width = width;
			bgLoaded.height = height;
			
			//Sets thumb dimensions
			var uiSimpleThumb:ISimpleSprite = cbThumb as ISimpleSprite;
			if ( uiSimpleThumb )
			{
				if ( direction == PositionStates.UP || direction == PositionStates.DOWN )
				{
					uiSimpleThumb.setActualSize( width, uiSimpleThumb.measuredHeight );
				}else{
					uiSimpleThumb.setActualSize( uiSimpleThumb.measuredWidth, height );
				}
			}
			drawHighlight();
			drawAvailable();
			updateThumbPosition();
			arrangeTicks();
		}
		
		protected final function arrangeTicks(): void 
		{
			var xTickPos:Number = 0; var yTickPos:Number = 0;
			var displayTick:ISimpleSprite;
			var simpleTick:ISimpleSprite;
			
			var nLen:Number = tickHolder.numChildren;
			for ( var i:Number = 0; i < nLen; i++ ) 
			{
				displayTick = tickHolder.getChildAt(i) as ISimpleSprite;
				if ( displayTick )
				{
					if ( direction == PositionStates.RIGHT || direction == PositionStates.LEFT ) 
					{
						xTickPos = calculatePixels( _aTicks[i], width, _nMaximum, _nMinimum, displayTick.width, direction == PositionStates.LEFT );
						displayTick.setActualSize( displayTick.measuredWidth, height );
					}else if ( direction == PositionStates.UP || direction == PositionStates.DOWN ) 
					{
						yTickPos = calculatePixels( _aTicks[i], height, _nMaximum, _nMinimum, displayTick.height, direction == PositionStates.UP );
						displayTick.setActualSize( width, displayTick.measuredHeight );
					}
					displayTick.x = xTickPos; displayTick.y = yTickPos;
				}
			}
		}
		
		/**
		 * GETTER / SETTER
		 */
		
		public function set trackClickEnabled( value:Boolean ): void
		{
			if ( _bTrackClickEnabled == value ) return;
			_bTrackClickEnabled = value;
		}
		
		public function get trackClickEnabled(): Boolean
		{
			return _bTrackClickEnabled;
		}
		 
		public function set direction( direction:String ): void
		{
			if ( _sDirection == direction ) return;
			_sDirection = direction;
			if ( initialized ) refreshMeasures();//arrange();
		}
		
		public function get direction(): String
		{
			return _sDirection;
		}
		
		public function set minimum( minimum:Number ): void
		{
			if ( isNaN(minimum) || _nMinimum == minimum ) return;
			_nMinimum = minimum;
			__checkValue();
			if ( initialized ) arrange();
		}
		
		public function get minimum(): Number
		{
			return _nMinimum;
		}
		
		public function set maximum( maximum:Number ): void
		{
			if ( isNaN(maximum) || _nMaximum == maximum ) return;
			_nMaximum = maximum;
			__checkValue();
			if ( initialized ) arrange();
		}
		
		public function get maximum(): Number
		{
			return _nMaximum;
		}
		
		public function set value( value:Number ): void
		{
			if ( isNaN(value) || _nValue == value ) return;
			_nValue = value;
			__checkValue();
			if ( initialized ) arrange();
		}
		
		public function get value(): Number
		{
			return _nValue;
		}
		
		public function set available( available:Number ): void
		{
			if ( isNaN(available) ) return;
			_nAvailable = available;
			if ( initialized ) updateAvailable(); 
		}
		
		public function get available(): Number
		{
			return _nAvailable;
		}
		
		public function set startAvailable( available:Number ): void
		{
			if ( isNaN(available) ) return;
			_nAvailableStart = available;
			if ( initialized ) updateAvailable(); 
		}
		
		public function get startAvailable(): Number
		{
			return _nAvailableStart;
		}
		
		private function __parseTickValues( value:Vector.<Number> ): Vector.<Number>
		{
			var newTicks:Vector.<Number> = new Vector.<Number>();
			for each( var i:Number in value )
			{
				if ( i > -1 ) newTicks.push(i);
			}
			return newTicks;
		}
		
		public function set ticks( value:Vector.<Number> ): void
		{
			_aTicks = __parseTickValues(value);
			drawTicks();
		}
		
		public function get ticks(): Vector.<Number>
		{
			return _aTicks;
		}
		
		public function set snapInterval( value:Vector.<Number> ): void
		{
			_aSnaps = value;
		}
		
		public function get snapInterval(): Vector.<Number>
		{
			return _aSnaps;
		}
		
		public function get drawHighlightFromValue(): Boolean
		{
			return _bDrawHighlightFromValue;
		}
		
		public function set drawHighlightFromValue( value:Boolean ): void
		{
			if ( _bDrawHighlightFromValue == value) return;
			_bDrawHighlightFromValue = value;
			if ( initialized ) drawHighlight();
		}
	}
}