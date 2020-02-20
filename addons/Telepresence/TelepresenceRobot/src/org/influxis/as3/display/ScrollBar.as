/**
 * ScrollBar - Copyright © 2010 Influxis All rights reserved.
**/

package org.influxis.as3.display 
{
	//Flash Classes
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	//Influxis Classes
	import org.influxis.as3.display.StyleComponent;
	import org.influxis.as3.skins.StateSkin;
	import org.influxis.as3.states.RotateState;
	import org.influxis.as3.utils.SizeUtils;
	import org.influxis.as3.display.scrollbarclasses.ScrollTrack;
	import org.influxis.as3.utils.handler;
	
	[Event(name = "scroll", type = "flash.events.Event" )]
	[Event(name = "scrollerEnabled", type="flash.events.Event" )]
	
	public class ScrollBar extends StyleComponent
	{
		private var _sVersion:String = "1.0.0.0";
		
		public static const SCROLL:String = "scroll";
		public static const SCROLL_ENABLED:String = "scrollerEnabled";
		private static const _MOVE_UNIT_RATE_:Number = 30;
		
		private var _bAutoScroll:Boolean;
		private var _nPageSize:Number;
		private var _bScrollerEnabled:Boolean;
		private var _nPosition:Number = 0;
		private var _nMinPosition:Number = 0;
		private var _nMaxPosition:Number = 0;
		private var _nLineScrollSize:Number = 10;
		private var _sDirection:String = RotateState.VERTICAL;
		private var _moveUnits:Number;
		private var _mouseTarget:InteractiveObject;
		
		private var uiUp:InteractiveObject;
		private var uiDown:InteractiveObject;
		private var uiTrack:InteractiveObject;
		private var uiTrackSlider:ScrollTrack;
		
		/**
		 * PRIVATE API
		 */
		
		private function __updateSliderProps( prop:String, value:* ): void
		{
			if ( !initialized || !prop ) return;
			uiTrackSlider[prop] = value;
		}
		
		private function __checkScrollerEnabled():void 
		{
			var bEnabled:Boolean = maxScrollPosition > 0;
			if ( bEnabled == _bScrollerEnabled ) return;
			_bScrollerEnabled = bEnabled;
			dispatchEvent(new Event(SCROLL_ENABLED));
		}
		
		/**
		 * HANDLERS
		 */
		
		private function __onSliderChange( event:Event ): void
		{
			_nPosition = uiTrackSlider.value;
			dispatchEvent(new Event(SCROLL));
		}
		
		private function __onArrowClicks( event:Event, arrow:String ): void
		{
			_nPosition = arrow == "up" ? ((_nPosition - _nLineScrollSize)<minScrollPosition?minScrollPosition:(_nPosition-_nLineScrollSize)) : ((_nPosition+_nLineScrollSize)>maxScrollPosition?maxScrollPosition:(_nPosition+_nLineScrollSize));
			__updateSliderProps( "value", _nPosition );
			dispatchEvent(new Event(SCROLL));
		}
		
		private function __onTargetMouseEvent( event:MouseEvent ): void
		{
			if ( !_bScrollerEnabled ) return;
			uiTrackSlider.value = uiTrackSlider.value + ((event.delta*(_moveUnits))*(-1));
			_nPosition = uiTrackSlider.value;
			dispatchEvent(new Event(SCROLL));
		}
		
		/**
		 * PROTECTED API
		 */
		
		//Not using this yet so for now blank
		protected function setDirection( value:String ): void
		{
			if ( value == _sDirection ) return;
			_sDirection = value;
		}
		
		protected function calculateMoveUnits(): void
		{
			_moveUnits = ((uiTrackSlider.maximum < 0 ? (uiTrackSlider.maximum * -1) : uiTrackSlider.maximum) - 
						  (uiTrackSlider.minimum < 0 ? (uiTrackSlider.minimum * -1) : uiTrackSlider.minimum)) / _MOVE_UNIT_RATE_;
		}
		
		/**
		 * DISPLAY API
		 */
		
		override protected function measure():void 
		{
			super.measure();
			measuredWidth = uiTrack.width;
			measuredHeight = uiTrack.height;
		}
		 
		override protected function createChildren(): void 
		{
			super.createChildren();
			
			uiUp = new StateSkin( className, "upArrow" );
			uiUp.addEventListener( MouseEvent.MOUSE_DOWN, handler(__onArrowClicks, "up") );
			
			uiDown = new StateSkin( className, "downArrow" );
			uiDown.addEventListener( MouseEvent.MOUSE_DOWN, handler(__onArrowClicks, "down") );
			
			uiTrack = getStyleGraphic( "scrollTrack" );
			uiTrackSlider = new ScrollTrack();
			uiTrackSlider.skinName = skinName;
			uiTrackSlider.addEventListener( Event.CHANGE, __onSliderChange );
			
			__updateSliderProps( "minimum", _nMinPosition );
			__updateSliderProps( "maximum", _nMaxPosition );
			__updateSliderProps( "value", _nPosition );
			
			addChildren( uiTrack, uiTrackSlider, uiUp, uiDown );
		}
		
		override protected function arrange():void 
		{
			super.arrange();
			
			uiDown.width = uiUp.width = width;
			uiTrack.width = width;
			uiTrack.height = height;
			
			SizeUtils.moveY( uiDown, height, SizeUtils.BOTTOM );
			
			uiTrackSlider.width = width;
			uiTrackSlider.y = uiUp.height;
			uiTrackSlider.height = ((height-uiDown.height)-uiTrackSlider.y);
		}
		
		/**
		 * GETTER / SETTER
		 */
		
		public function set mouseTarget( value:InteractiveObject ): void
		{
			if ( _mouseTarget == value ) return;
			if ( _mouseTarget ) _mouseTarget.removeEventListener( MouseEvent.MOUSE_WHEEL, __onTargetMouseEvent );
			
			_mouseTarget = value;
			if ( _mouseTarget ) _mouseTarget.addEventListener( MouseEvent.MOUSE_WHEEL, __onTargetMouseEvent );
		}
		 
		public function get mouseTarget(): InteractiveObject
		{
			return _mouseTarget;
		}
		
		public function set scrollPosition(value:Number):void 
		{
			if ( _nPosition == value ) return;
			_nPosition = value;
			__updateSliderProps( "value", _nPosition );
		}
		
		public function get scrollPosition(): Number
		{ 
			return _nPosition; 
		}
		
		public function get scrollDifference(): Number
		{ 
			return (((_nMaxPosition-_nPageSize)/_nMaxPosition)*_nPosition); 
		}
		
		public function set minScrollPosition( value:Number ): void 
		{
			if ( _nMinPosition == value ) return;
			_nMinPosition = value;
			calculateMoveUnits();
			__updateSliderProps( "minimum", _nMinPosition );
		}
		
		public function get minScrollPosition(): Number
		{ 
			return _nMinPosition; 
		}
		
		public function set maxScrollPosition( value:Number ): void 
		{
			if ( _nMaxPosition == value ) return;
			
			var oldMax:Number = _bAutoScroll ? _nMaxPosition : NaN;
			_nMaxPosition = value;
			
			__checkScrollerEnabled();
			calculateMoveUnits();
			__updateSliderProps( "maximum", _nMaxPosition );
			
			//If auto scroll enabled then go ahead and scroll if max changes
			if ( !isNaN(oldMax) )
			{
				//Update position if it needs updating
				_nPosition = _nMaxPosition == _nPosition ? value : value < _nPosition ? value : _nPosition;
				__updateSliderProps( "value", _nPosition );
			}
		}
		
		public function get maxScrollPosition(): Number
		{ 
			return _nMaxPosition; 
		}
		
		public function set autoScroll( value:Boolean ): void
		{
			_bAutoScroll = value;
		}
		
		public function get autoScroll(): Boolean
		{
			return _bAutoScroll;
		}
		
		public function set pageSize( value:Number ): void 
		{
			if ( _nPageSize == value ) return;
			_nPageSize = value;
			__checkScrollerEnabled();
		}
		
		public function get pageSize(): Number
		{ 
			return _nPageSize; 
		}
		
		public function set lineScrollSize( value:Number ): void 
		{
			if ( _nLineScrollSize == value ) return;
			_nLineScrollSize = value;
		}
		
		public function get lineScrollSize(): Number
		{ 
			return _nLineScrollSize; 
		}
		
		public function get scrollBarEnabled(): Boolean
		{ 
			return _bScrollerEnabled; 
		}
		
		public function set direction( value:String ): void 
		{
			setDirection(value);
		}
		
		public function get direction(): String
		{ 
			return _sDirection; 
		}
		
		public function get trackVisible(): Boolean
		{
			var bVisible:Boolean;
			if ( initialized ) bVisible = uiTrackSlider.height > 10;
			return bVisible;
		}
		
		override public function set skinName(value:String):void 
		{
			super.skinName = value;
			if( initialized ) uiTrackSlider.skinName = skinName;
		}
	}
}