/**
 * SimpleSprite - Copyright © 2010 Influxis All rights reserved.
**/

package org.influxis.as3.display 
{
	//Flash Classes
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.getQualifiedClassName;
	import flash.utils.Timer;
	
	//Influxis Classes
	import org.influxis.as3.states.SizeStates;
	import org.influxis.as3.core.Display;
	import org.influxis.as3.core.infx_internal;
	import org.influxis.as3.display.DisplayDebugger;
	import org.influxis.as3.utils.SizeUtils;
	import org.influxis.as3.interfaces.display.ISimpleSprite;
	
	//Events
	[Event(name = "infxResize", type = "flash.events.Event")]
	[Event(name = "infxResizeWidth", type = "flash.events.Event")]
	[Event(name = "infxResizeHeight", type = "flash.events.Event")]
	[Event(name = "infxMove", type = "flash.events.Event")]
	[Event(name = "infxMoveX", type = "flash.events.Event")]
	[Event(name = "infxMoveY", type = "flash.events.Event")]
	[Event(name = "measureWidthChange", type = "flash.events.Event")]
	[Event(name = "measureHeightChange", type = "flash.events.Event")]
	
	public class SimpleSprite extends Sprite implements ISimpleSprite
	{
		private static var ID_COUNT:uint = 0;
		use namespace infx_internal;
		
		private var _className:String;
		private var _bAutoPercent:Boolean = true;
		
		private var _width:Number = 0;
		private var _height:Number = 0;
		
		private var _measuredWidth:Number = 0;
		private var _measuredHeight:Number = 0;
		
		private var _minWidth:Number;
		private var _minHeight:Number;
		private var _maxWidth:Number;
		private var _maxHeight:Number;
		private var _originWidth:Number;
		private var _originHeight:Number;
		private var _percentWidth:Number;
		private var _percentHeight:Number;
		
		private var _minX:Number;
		private var _minY:Number;
		private var _maxX:Number;
		private var _maxY:Number;
		private var _originX:Number;
		private var _originY:Number;
		
		protected var paddingLeft:int = 0;
		protected var paddingTop:int = 0;
		protected var paddingBottom:int = 0;
		protected var paddingRight:int = 0;
		protected var innerPadding:int = 0;
		protected var outerPadding:int = 0;
		
		public var id:uint;
		public var allowDebug:Boolean;
		
		/**
		 * INIT API
		 */
		
		public function SimpleSprite() 
		{
			//Set classname
			_className = getQualifiedClassName(this).replace("::", ".");
			
			//Keep track of comp count
			id = ID_COUNT;
			ID_COUNT++;
		}
		
		/**
		 * HOOK API
		 */
		
		private var _hookTarget:ISimpleSprite;
		private var _hookContainer:ISimpleSprite;
		private var _hookPosition:String;
		private var _hookInner:Boolean;
		private var _hookAlign:String;
		private var _hookPadding:Number;
		
		public function hook( target:ISimpleSprite, container:ISimpleSprite = null, position:String = null, align:String = null, inner:Boolean = false, padding:int = 0 ): void
		{
			if ( target == _hookTarget ) return;
			
			__removeHook();
			
			_hookTarget = target;
			if ( !_hookTarget ) return;
			
			_hookPosition = !position ? SizeUtils.RIGHT : position;
			_hookAlign = !align ? SizeUtils.TOP : align;
			_hookPadding = padding;
			_hookContainer = !container ? target : container;
			_hookInner = inner;
			
			//Listen to size changes or movements
			_hookTarget.addEventListener( SizeStates.RESIZE, __onHookChange );
			_hookTarget.addEventListener( SizeStates.MOVE, __onHookChange );
			__onHookChange();
		}	 
		
		public function updateHook( position:String = null, align:String = null, inner:Boolean = false, padding:int = 0 ): void
		{
			if ( !_hookTarget ) return;
			
			_hookPosition = !position ? _hookPosition : position;
			_hookAlign = !align ? _hookAlign : align;
			_hookPadding = padding;
			_hookInner = inner;
			
			__onHookChange();
		}
		
		private function __removeHook(): void
		{
			if ( !_hookTarget ) return;
			
			_hookTarget.removeEventListener( SizeStates.RESIZE, __onHookChange );
			_hookTarget.removeEventListener( SizeStates.MOVE, __onHookChange );
		}
		
		private function __onHookChange( event:Event = null ): void
		{
			var oPos:Object = new Object();
			if ( _hookPosition == SizeUtils.TOP || _hookPosition == SizeUtils.BOTTOM || _hookPosition == SizeUtils.MIDDLE )
			{
				oPos.x = SizeUtils.getPositions( width, height, _hookContainer.width, _hookTarget.height, _hookAlign, _hookPosition, true, _hookPadding ).x;
				oPos.y = SizeUtils.getPositions( width, height, _hookContainer.width, _hookTarget.height, _hookAlign, _hookPosition, _hookInner, _hookPadding ).y;
				move( _hookContainer.x+oPos.x, _hookTarget.y+oPos.y, (_hookTarget.hookTarget == this) );
			}else if ( _hookPosition == SizeUtils.LEFT || _hookPosition == SizeUtils.RIGHT || _hookPosition == SizeUtils.CENTER )
			{
				oPos.x = SizeUtils.getPositions( width, height, _hookTarget.width, _hookContainer.height, _hookPosition, _hookAlign, _hookInner, _hookPadding ).x;
				oPos.y = SizeUtils.getPositions( width, height, _hookTarget.width, _hookContainer.height, _hookPosition, _hookAlign, true, _hookPadding ).y;
				move( _hookTarget.x+oPos.x, _hookContainer.y+oPos.y, (_hookTarget.hookTarget == this) );
			}
		}
		
		public function get hookTarget(): ISimpleSprite
		{
			return _hookTarget;
		}
		
		/**
		 * DISPLAY API
		**/
		
		//private function __checkMeasures(): void
		protected function checkDimensions( omitEvent:Boolean = false ): void
		{
			var w:Number = SizeUtils.getValue( isNaN(_originWidth) ? measuredWidth : (_originWidth*((isNaN(_percentWidth)||!_bAutoPercent?100:_percentWidth)/100)), _minWidth, _maxWidth, true );
			var h:Number = SizeUtils.getValue( isNaN(_originHeight) ? measuredHeight : (_originHeight*((isNaN(_percentHeight)||!_bAutoPercent?100:_percentHeight)/100)), _minHeight, _maxHeight, true );
			
			//tracer( "__checkMeasures: " + w, h, _width, _height, measuredWidth, measuredHeight, _originWidth, _originHeight );
			if ( _width != w || _height != h )
			{
				if ( _width != w ) 
				{
					_width = w;
					if( !omitEvent ) dispatchEvent( new Event(SizeStates.RESIZE_WIDTH) );
				}
				
				if ( _height != h ) 
				{
					_height = h;
					if( !omitEvent ) dispatchEvent( new Event(SizeStates.RESIZE_HEIGHT) );
				}
				onSizeChanged(omitEvent);
			}
		}
		
		//private function __checkPositions(): void
		protected final function checkPositions( omitEvent:Boolean = false ): void
		{ 
			var x:Number = SizeUtils.getValue( isNaN(_originX) ? this.x : _originX, _minX, _maxX );
			var y:Number = SizeUtils.getValue( isNaN(_originY) ? this.y : _originY, _minY, _maxY );
			
			//trace( "checkPositions: " + id, className, this.x, x, this.y, y );
			if ( this.x != x || this.y != y )
			{
				if ( this.x != x )
				{
					super.x = x;
					if( !omitEvent ) dispatchEvent( new Event(SizeStates.MOVE_X) );
				}
				
				if ( this.y != y )
				{
					super.y = y;
					if( !omitEvent ) dispatchEvent( new Event(SizeStates.MOVE_Y) );
				}
				onPositionChanged(omitEvent);
			}
			_originX = _originY = NaN;
		}
		
		protected function onSizeChanged( omitEvent:Boolean = false ): void
		{
			arrange();
			if( !omitEvent ) dispatchEvent(new Event(SizeStates.RESIZE));
		}
		
		protected function onPositionChanged( omitEvent:Boolean = false ): void
		{
			if( !omitEvent ) dispatchEvent(new Event(SizeStates.MOVE));
		}
		
		public function addChildren( ...children ): void
		{
			var aChildren:Array = children as Array;
			for each( var o:DisplayObject in aChildren )
			{
				addChild( o );
			}
		}
		
		public function removeAllChildren(): void
		{
			//Holds all the children to remove
			var aDisplays:Vector.<DisplayObject> = new Vector.<DisplayObject>();
			
			//Gather children
			var nLen:Number = numChildren;
			for ( var i:Number = (nLen - 1); i > -1; i-- )
			{
				aDisplays.push(getChildAt(i));
			}
			
			//Remove by child and not index cause this causses issues
			for each ( var o:DisplayObject in aDisplays ) 
			{
				removeChild(o);
			}
		}
		
		public function setActualSize( w:Number, h:Number, omitEvent:Boolean = false ): void
		{
			_originWidth = w;
			_originHeight = h;
			checkDimensions(omitEvent);	
		}
		
		public function move( x:Number, y:Number, omitEvent:Boolean = false ): void
		{
			_originX = x;
			_originY = y;
			checkPositions(omitEvent);
		}
		
		protected function arrange(): void
		{
			
		}
		
		public function invalidateDisplayList(): void
		{
			arrange();
		}
		
		/**
		 * INFXCORE API
		 */
		
		infx_internal function updateSize( width:Number, height:Number ): void
		{
			_width = width;
			_height = height;
			arrange();
		}
		
		infx_internal function updateMeasure( width:Number, height:Number ): void
		{
			_measuredWidth = width;
			_measuredHeight = height;
		}
		 
		/**
		 * GETTER / SETTER
		 */
		
		public function get className(): String
		{
			return _className;
		}
		
		override public function set width( value:Number ): void
		{
			if ( _width == value ) return;
			setActualSize(value,_originHeight);
		}
		
		override public function get width(): Number
		{
			return _width;
		}
		
		override public function set height( value:Number ): void
		{
			if ( _height == value ) return;
			setActualSize(_originWidth,value);
		}
		
		override public function get height(): Number
		{
			return _height;
		}
		
		public function set minWidth( value:Number ): void
		{
			if ( _minWidth == value ) return;
			_minWidth = value;
			checkDimensions();
		}
		
		public function get minWidth(): Number
		{
			return _minWidth;
		}
		
		public function set minHeight( value:Number ): void
		{
			if ( _minHeight == value ) return;
			_minHeight = value;
			checkDimensions();
		}
		
		public function get minHeight(): Number
		{
			return _minHeight;
		}
		
		public function set maxWidth( value:Number ): void
		{
			if ( _maxWidth == value ) return;
			_maxWidth = value;
			checkDimensions();
		}
		
		public function get maxWidth(): Number
		{
			return _maxWidth;
		}
		
		public function set maxHeight( value:Number ): void
		{
			if ( _maxHeight == value ) return;
			_maxHeight = value;
			checkDimensions();
		}
		
		public function get maxHeight(): Number
		{
			return _maxHeight;
		}
		
		public function set measuredWidth( value:Number ): void
		{
			if ( _measuredWidth == value ) return;
			_measuredWidth = value;
			checkDimensions();
			dispatchEvent( new Event(SizeStates.MEASURE_WITDH) );
		}
		
		public function get measuredWidth(): Number
		{
			return _measuredWidth;
		}
		
		public function set measuredHeight( value:Number ): void
		{
			if ( _measuredHeight == value ) return;
			_measuredHeight = value;
			checkDimensions();
			dispatchEvent( new Event(SizeStates.MEASURE_HEIGHT) );
		}
		
		public function get measuredHeight(): Number
		{
			return _measuredHeight;
		}
		
		public function set minX( value:Number ): void
		{
			if ( _minX == value ) return;
			_minX = value;
			checkPositions();
		}
		
		public function get minX(): Number
		{
			return _minX;
		}
		
		public function set minY( value:Number ): void
		{
			if ( _minY == value ) return;
			_minY = value;
			checkPositions();
		}
		
		public function get minY(): Number
		{
			return _minY;
		}
		
		public function set maxX( value:Number ): void
		{
			if ( _maxX == value ) return;
			_maxX = value;
			checkPositions();
		}
		
		public function get maxX(): Number
		{
			return _maxX;
		}
		
		public function set maxY( value:Number ): void
		{
			if ( _maxY == value ) return;
			_maxY = value;
			checkPositions();
		}
		
		public function get maxY(): Number
		{
			return _maxY;
		}
		
		override public function set x( value:Number ): void 
		{
			if ( x == value ) return;
			move( value, y );
		}
		
		override public function set y( value:Number ):void 
		{
			if ( y == value ) return;
			move( x, value );
		}
		
		public function set percentWidth( value:Number ): void
		{
			if ( _percentWidth == value ) return;
			_percentWidth = value;
		}
		
		public function get percentWidth(): Number
		{
			return _percentWidth;
		}
		
		public function set percentHeight( value:Number ): void
		{
			if ( _percentHeight == value ) return;
			_percentHeight = value;
		}
		
		public function get percentHeight(): Number
		{
			return _percentHeight;
		}
		
		public function autoPercent( value:Boolean ): void
		{
			if ( _bAutoPercent == value ) return;
			_bAutoPercent = value;
			checkDimensions();
		}
		
		/**
		 * DEBUGGER
		 */
		
		public static var DISPLAY_DEBUGGGER:Boolean;
		public var displayDebugger:Boolean;
		
		protected function tracer( ...args ): void
		{
			if ( !allowDebug ) return;
			var aArgs:Array = args as Array;
				aArgs.unshift( id +":"+className+":: " );
			if ( DISPLAY_DEBUGGGER || displayDebugger )
			{
				DisplayDebugger.tracer.apply( DisplayDebugger, aArgs );
			}else{
				trace.apply( null, aArgs );
			}	
		}
	}
}