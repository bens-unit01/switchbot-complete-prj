/**
 * LayoutManager - Copyright © 2010 Influxis All rights reserved.
**/

package org.influxis.as3.managers 
{
	//Flash Classes
	import flash.display.DisplayObject;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	import flash.events.Event;
	
	//Influxis Classes
	import org.influxis.as3.data.DataProviderOld;
	import org.influxis.as3.interfaces.display.ISimpleSprite;
	import org.influxis.as3.states.RotateState;
	import org.influxis.as3.utils.SizeUtils;
	import org.influxis.as3.events.SimpleEventConst;
	
	public class LayoutManager extends DataProviderOld implements ISimpleSprite
	{
		private var _bAutoPercent:Boolean = true;
		private var _dSizeQueue:Dictionary = new Dictionary();
		
		private var _width:Number = 0;
		private var _height:Number = 0;
		private var _x:Number = 0;
		private var _y:Number = 0;
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
		private var _bVisible:Boolean = true;
		private var _nInnerGap:Number = 0;
		
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
		
		/**
		 * INIT API
		 */
		
		public function LayoutManager( ...children ): void 
		{
			super();
			__addChildren( children as Array );
		}
		
		/**
		 * PUBLIC API
		 */
		
		override public function addItemAt( index:uint, data:Object, omitEvent:Boolean = false ): void 
		{
			if( !__addChild(index, data as ISimpleSprite) ) throw new Error( "DisplayObject must implement ISimpleSprite interface" );
		}
		
		override public function removeItemAt( index:uint, omitEvent:Boolean = false ): void 
		{
			__removeChild( index, _data[index] as ISimpleSprite, true );
		}
		
		override public function clear( omitEvent:Boolean = false ):void 
		{
			if ( length == 0 ) return;
			__removeChildren();
		}
		
		override public function setArray(data:Array, append:Boolean, omitEvent:Boolean = false):void 
		{
			__addChildren( data );
		}
		
		/**
		 * PRIVATE API
		 */
		
		private function __addChildren( children:Array ): void
		{
			if ( !children ) return;
			
			_bLock = true;
			for ( var i:int; i < children.length; i++ )
			{
				__addChild(i, children[i] as ISimpleSprite);
			}
			_bLock = false;
			if ( children.length > 0 ) 
			{
				__alignLeader();
				arrange();
			}
		}
		
		private function __removeChildren(): void
		{
			if ( _data.length == 0 ) return;
			
			_bLock = true;
			for ( var i:int = _data.length-1; i > -1; i-- )
			{
				__removeChild(i, _data[i] as ISimpleSprite);
			}
			lock = false;
		}
		
		private function __addChild( index:int, display:ISimpleSprite, adjustHook:Boolean = false ): Boolean
		{
			if ( !display ) return false;
			
			if ( _data.length > 0 && index != 0 ) display.hook( _data[_data.length - 1] as ISimpleSprite, this, (direction==RotateState.VERTICAL?SizeUtils.BOTTOM:SizeUtils.RIGHT), (direction==RotateState.VERTICAL?SizeUtils.LEFT:SizeUtils.TOP), false, _nInnerGap );  
			display.addEventListener( _sDirection == RotateState.HORIZONTAL ? SimpleEventConst.RESIZE_WIDTH : SimpleEventConst.RESIZE_HEIGHT, handleResize );
			
			_data.push(display);
			if ( !lock ) 
			{
				if ( index == 0 ) __alignLeader();
				arrange();
			}
			
			return true;
		}
		
		private function __removeChild( index:int, display:ISimpleSprite, adjustHook:Boolean = false ): Boolean
		{
			if ( !display ) return false;
			
			display.hook( null );
			display.removeEventListener( _sDirection == RotateState.VERTICAL ? SimpleEventConst.RESIZE_WIDTH : SimpleEventConst.RESIZE_HEIGHT, handleResize );
			_data.splice( index, 1 );
			
			if( _data.length > index ) display = _data[index] as ISimpleSprite;
			if ( adjustHook && display ) display.hook(  _data[_data.length - 1] as ISimpleSprite, null, (direction == RotateState.VERTICAL?SizeUtils.BOTTOM:SizeUtils.RIGHT), (direction == RotateState.VERTICAL?SizeUtils.LEFT:SizeUtils.TOP), false );
			if ( !lock ) 
			{
				if ( index == 0 ) __alignLeader();
				arrange();
			}
			
			return true;
		}
		
		private function __changeSizeListeners(): void
		{
			var display:ISimpleSprite;
			for each ( var o:Object in _data )
			{
				display = o as ISimpleSprite;
				display.removeEventListener( _sDirection == RotateState.VERTICAL ? SimpleEventConst.RESIZE_WIDTH : SimpleEventConst.RESIZE_HEIGHT, handleResize );
				display.addEventListener( _sDirection == RotateState.HORIZONTAL ? SimpleEventConst.RESIZE_WIDTH : SimpleEventConst.RESIZE_HEIGHT, handleResize );
				display.updateHook( (direction == RotateState.VERTICAL?SizeUtils.BOTTOM:SizeUtils.RIGHT), (direction == RotateState.VERTICAL?SizeUtils.CENTER:SizeUtils.MIDDLE), false, _nInnerGap );
			}
		}
		
		/**
		 * HANDLERS
		 */
		
		private function handleResize( event:Event ): void
		{
			if ( _dSizeQueue[event.currentTarget] == true )
			{
				delete _dSizeQueue[event.currentTarget];
			}else{
				arrange(true);
			}
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
			_hookTarget.addEventListener( SimpleEventConst.RESIZE, __onHookChange );
			_hookTarget.addEventListener( SimpleEventConst.MOVE, __onHookChange );
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
			
			_hookTarget.removeEventListener( SimpleEventConst.RESIZE, __onHookChange );
			_hookTarget.removeEventListener( SimpleEventConst.MOVE, __onHookChange );
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
		
		protected final function checkDimensions( omitEvent:Boolean = false ): void
		{
			var w:Number = SizeUtils.getValue( isNaN(_originWidth) ? measuredWidth : (_originWidth*((isNaN(_percentWidth)||!_bAutoPercent?100:_percentWidth)/100)), _minWidth, _maxWidth );
			var h:Number = SizeUtils.getValue( isNaN(_originHeight) ? measuredHeight : (_originHeight*((isNaN(_percentHeight)||!_bAutoPercent?100:_percentHeight)/100)), _minHeight, _maxHeight );
			
			//tracer( "__checkMeasures: " + w, h, _width, _height, measuredWidth, measuredHeight, _originWidth, _originHeight );
			if ( _width != w || _height != h )
			{
				if ( _width != w ) 
				{
					_width = w;
					if( !omitEvent ) dispatchEvent( new Event(SimpleEventConst.RESIZE_WIDTH) );
				}
				
				if ( _height != h ) 
				{
					_height = h;
					if( !omitEvent ) dispatchEvent( new Event(SimpleEventConst.RESIZE_HEIGHT) );
				}
				onSizeChanged();
			}
		}
		
		//private function __checkPositions(): void
		protected final function checkPositions( omitEvent:Boolean = false ): void
		{ 
			var x:Number = SizeUtils.getValue( isNaN(_originX) ? this.x : _originX, _minX, _maxX );
			var y:Number = SizeUtils.getValue( isNaN(_originY) ? this.y : _originY, _minY, _maxY );
			
			if ( this.x != x || this.y != y )
			{
				if ( _x != x )
				{
					_x = x;
					if( !omitEvent ) dispatchEvent( new Event(SimpleEventConst.MOVE_X) );
				}
				
				if ( _y != y )
				{
					_y = y;
					if( !omitEvent ) dispatchEvent( new Event(SimpleEventConst.MOVE_Y) );
				}
				onPositionChanged();
			}
			_originX = _originY = NaN;
		}
		
		protected function onSizeChanged( omitEvent:Boolean = false ): void
		{
			arrange();
			if( !omitEvent ) dispatchEvent(new Event(SimpleEventConst.RESIZE));
		}
		
		protected function onPositionChanged( omitEvent:Boolean = false ): void
		{
			if ( length == 0 ) return;
			
			__alignLeader();
			if( !omitEvent ) dispatchEvent(new Event(SimpleEventConst.MOVE));
		}
		
		private function __alignLeader(): void
		{
			var display:ISimpleSprite = getItemAt(0) as ISimpleSprite;
			if ( display )
			{
				display.x = x;
				display.y = y;
			}
		}
		
		public function setActualSize( w:Number, h:Number, omitEvent:Boolean = false ): void
		{
			_originWidth = w < 0 ? 0 : w;
			_originHeight = h < 0 ? 0 : h;
			checkDimensions(omitEvent);	
		}
		
		public function move( x:Number, y:Number, omitEvent:Boolean = false ): void
		{
			_originX = x;
			_originY = y;
			checkPositions(omitEvent);
		}
		
		protected function arrange( resized:Boolean = false ): void
		{
			if ( length == 0 ) return;
			
			var percentProp:String = direction == RotateState.VERTICAL ? "percentHeight" : "percentWidth";
			var sizeProp:String = direction == RotateState.VERTICAL ? "height" : "width";
			var percentOther:String = direction == RotateState.VERTICAL ? "percentWidth" : "percentHeight";
			var sizeOther:String = direction == RotateState.VERTICAL ? "width" : "height";
			var percentDisplays:Vector.<ISimpleSprite> = new Vector.<ISimpleSprite>();
			var totalPixels:int = 0;
			
			var display:ISimpleSprite;
			for each( var i:Object in _data )
			{
				display = i as ISimpleSprite;
				if ( display )
				{
					if ( !isNaN(display[percentProp]) )
					{
						percentDisplays.push( display );
					}else{
						totalPixels = totalPixels + display[sizeProp];
					}
					if ( !isNaN(display[percentOther]) ) display[sizeOther] = this[sizeOther];
				}
			}
			
			totalPixels = this[sizeProp] - (totalPixels+(_data.length < 2?0:(_nInnerGap*(_data.length-1))));
			totalPixels = totalPixels < 0 ? 0 : totalPixels;
			
			for ( var z:int = 0; z < percentDisplays.length; z++ )
			{
				display = percentDisplays[z];
				_dSizeQueue[display] = true;
				
				display[sizeProp] = totalPixels / (percentDisplays.length - z);
				totalPixels = totalPixels - display[sizeProp];
			}
		}
		
		/**
		 * GETTER / SETTER
		 */
		
		override public function set source(value:Vector.<Object>):void 
		{
			clear();
			if ( !value ) return;
			
			_bLock = true;
			for ( var i:int = 0; i < value.length; i++ )
			{
				__addChild(i, value[i] as ISimpleSprite);
			}
			_bLock = false;
			if ( value.length > 0 ) arrange();
		}
		 
		private var _bLock:Boolean;
		public function set lock( value:Boolean ): void
		{
			if ( value == _bLock ) return;
			_bLock = value;
			if ( !_bLock ) 
			{
				if ( _data.length > 0 ) __alignLeader();
				arrange();
			}
		}
		
		public function get lock(): Boolean
		{
			return _bLock;
		}
		
		private var _sDirection:String = RotateState.HORIZONTAL;
		public function set direction( value:String ): void
		{
			if ( value == _sDirection || !value ) return;
			_sDirection = value == RotateState.HORIZONTAL ? RotateState.HORIZONTAL : RotateState.VERTICAL;
			__changeSizeListeners();
			arrange();
		}
		
		public function get direction(): String
		{
			return _sDirection;
		}
		 
		public function set width( value:Number ): void
		{
			if ( _width == value ) return;
			setActualSize(value,_height);
		}
		
		public function get width(): Number
		{
			return _width;
		}
		
		public function set height( value:Number ): void
		{
			if ( _height == value ) return;
			setActualSize(_width,value);
		}
		
		public function get height(): Number
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
		
		public function set x( value:Number ): void 
		{
			if ( x == value ) return;
			move( value, y );
		}
		
		public function get x(): Number 
		{
			return _x;
		}
		
		public function set y( value:Number ):void 
		{
			if ( y == value ) return;
			move( x, value );
		}
		
		public function get y(): Number 
		{
			return _y;
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
		
		public function set visible( value:Boolean ): void
		{
			if ( _bVisible == value ) return;
			_bVisible = value;
		}
		
		public function get visible(): Boolean
		{
			return _bVisible;
		}
		
		public function autoPercent( value:Boolean ): void
		{
			if ( _bAutoPercent == value ) return;
			_bAutoPercent = value;
			checkDimensions();
		}
		
		public function set gap( value:Number ): void
		{
			if ( _nInnerGap == value ) return;
			_nInnerGap = value;
			__changeSizeListeners();
		}
		
		public function get gap(): Number
		{
			return _nInnerGap;
		}
	}
}