/**
 *  Divider - Copyright © 2010 Influxis All rights reserved.   
**/

package org.influxis.as3.containers
{	
	//Flash Classes
	import flash.geom.Point;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.display.InteractiveObject;
	
	//Influxis Classes
	import org.influxis.as3.events.SimpleEvent;
	import org.influxis.as3.events.SimpleEventConst;
	import org.influxis.as3.display.StyleCanvas;
	import org.influxis.as3.states.RotateState;
	import org.influxis.as3.display.SimpleSprite;
	import org.influxis.as3.interfaces.display.ISimpleSprite;
	
	public class Divider extends StyleCanvas
	{
		public static var DEFAULT_DIVIDER_HIT_SPACE:Number = 5;
		
		public static const DIVIDER_MOVED:String = "dividerMoved";
		public static const DIVIDER_SYNC:String = "dividerSync";
		
		private var _sIncreaseType:String = RotateState.NORMAL;
		private var _sdDivider:Divider;
		private var _nMaxPoint:Number;
		private var _nMinPoint:Number;
		private var _nMouseStartPoint:Number;
		private var _bMouseRegistered:Boolean;
		private var _uiGhostHandler:SimpleSprite;
		
		private var _sMouseState:String = MouseEvent.MOUSE_UP;
		private var _sDirection:String = RotateState.HORIZONTAL;
		private var _targetDisplay:ISimpleSprite;
		private var _brotherDisplay:ISimpleSprite;
		private var _nLastValue:Number;
		
		/**
		 * PRIVATE API
		**/
		
		private function __setDisplayTarget( p_targetDisplay:ISimpleSprite ): void
		{
			_targetDisplay = p_targetDisplay;
			_uiGhostHandler.useHandCursor = _uiGhostHandler.buttonMode = (_targetDisplay != null);
			_uiGhostHandler.mouseChildren = (_targetDisplay == null);
		}
		
		private function __registerMouse( p_bMouseRegistered:Boolean = true ): void
		{
			if( _bMouseRegistered == p_bMouseRegistered ) return;
			_bMouseRegistered = p_bMouseRegistered;
			try
			{
				if( _bMouseRegistered )
				{
					_nMouseStartPoint = _sDirection == RotateState.VERTICAL ? stage.mouseY : stage.mouseX;
					_nMaxPoint = _sDirection == RotateState.VERTICAL ? _targetDisplay.maxHeight : _targetDisplay.maxWidth;
					_nMinPoint = _sDirection == RotateState.VERTICAL ? _targetDisplay.minHeight : _targetDisplay.minWidth;
					
					InteractiveObject(stage).addEventListener( MouseEvent.MOUSE_MOVE, __onMouseEvent );
					InteractiveObject(stage).addEventListener( MouseEvent.MOUSE_UP, __onMouseEvent );
				}else{
					InteractiveObject(stage).removeEventListener( MouseEvent.MOUSE_MOVE, __onMouseEvent );
					InteractiveObject(stage).removeEventListener( MouseEvent.MOUSE_UP, __onMouseEvent );
					_nMouseStartPoint = _nMaxPoint = _nMinPoint = NaN;
				}
			}catch( e:Error )
			{
				trace(e);
			}
		}
		
		private function __resizeDisplayTarget(): void
		{
			if( !isNaN(_nMouseStartPoint) && _targetDisplay )
			{
				if( !_targetDisplay.visible ) return;
				
				var nNewVal:Number;
				var nAddedValue:Number;
				if( _sDirection == RotateState.VERTICAL )
				{
					nAddedValue = (_sIncreaseType == RotateState.NORMAL ? (stage.mouseY - _nMouseStartPoint) : (_nMouseStartPoint - stage.mouseY));
					if ( __brotherReached() && nAddedValue > -1 ) return;
					nNewVal = _targetDisplay.height+(nAddedValue);
					
					_targetDisplay.percentHeight = NaN;
					_targetDisplay.height = __getValue(nNewVal);
				}else if( _sDirection == RotateState.HORIZONTAL )
				{
					nAddedValue = (_sIncreaseType == RotateState.NORMAL ? (stage.mouseX-_nMouseStartPoint) : (_nMouseStartPoint-stage.mouseX));
					if ( __brotherReached() && nAddedValue > -1 ) return;
					nNewVal = _targetDisplay.width+nAddedValue;
					
					_targetDisplay.percentWidth = NaN;
					_targetDisplay.width = __getValue(nNewVal);
				}
				_nMouseStartPoint = _sDirection == RotateState.VERTICAL ? stage.mouseY : stage.mouseX;
				dispatchEvent(new SimpleEvent(DIVIDER_MOVED, null, {value:__getValue(nNewVal), minMax:__reached(nNewVal)}));
			}
		}
		
		private function __brotherReached(): Boolean
		{
			if ( !_brotherDisplay ) return false;
			return (_sDirection == RotateState.VERTICAL ? (_brotherDisplay.height <= _brotherDisplay.minHeight || _brotherDisplay.height <= 0) : (_brotherDisplay.width <= _brotherDisplay.minWidth || _brotherDisplay.width <= 0));
		}
		
		private function __reached( value:Number ): Boolean
		{
			return ((value >= _nMaxPoint && !isNaN(_nMaxPoint)) || (value <= _nMinPoint && !isNaN(_nMaxPoint)));
		}
		
		private function __getValue( value:Number ): Number
		{
			var nNewVal:Number = value;
			if ( value >= _nMaxPoint && !isNaN(_nMaxPoint) )
			{
				nNewVal = _nMaxPoint;
			}else if ( value <= _nMinPoint && !isNaN(_nMinPoint) )
			{
				nNewVal = _nMinPoint;
			}
			return nNewVal;
		}
		
		private function __setSyncDivider( p_sdDivider:Divider ): void
		{
			if( _sdDivider ) 
			{
				_sdDivider.removeEventListener( DIVIDER_MOVED, __onSyncDividerMoved );
				_sdDivider.removeEventListener( DIVIDER_SYNC, __onSyncDividerMoved );
			}
			
			_sdDivider = p_sdDivider;
			if( _sdDivider ) 
			{
				_sdDivider.addEventListener( DIVIDER_MOVED, __onSyncDividerMoved );
				_sdDivider.addEventListener( DIVIDER_SYNC, __onSyncDividerMoved );
			}
		}
		
		/**
		 * HANDLERS
		**/
		
		private function __onMouseEvent( p_e:Event ): void
		{
			if( !_targetDisplay ) return;
			
			_sMouseState = p_e.type == MouseEvent.MOUSE_DOWN || p_e.type == MouseEvent.MOUSE_UP ? p_e.type : _sMouseState;
			if( p_e.type == MouseEvent.MOUSE_DOWN )
			{
				__registerMouse();
			}else if( p_e.type == MouseEvent.MOUSE_UP && _bMouseRegistered )
			{
				__registerMouse(false);
				__checkGhostHit();
				//if ( !__checkGhostHit() ) ;//CursorManager.removeAllCursors();
			}else if( p_e.type == MouseEvent.MOUSE_MOVE && _bMouseRegistered )
			{
				__resizeDisplayTarget();
			}
		}
		
		private function __onParentDividerMoved( p_e:Event ): void
		{
			var pt:Point = stage.globalToLocal(parent.localToGlobal(new Point(x, y)));
			_uiGhostHandler.move( pt.x, pt.y );
		}
		
		private function __onSyncDividerMoved( p_e:SimpleEvent ): void
		{
			if( _targetDisplay )
			{
				if( !_targetDisplay.visible ) return;
				
				if( p_e.type == DIVIDER_SYNC )
				{
					var nDimen:Number;
					if( _sDirection == RotateState.VERTICAL )
					{
						nDimen = Number(p_e.data.height);
						_targetDisplay.height = nDimen >= _nMaxPoint ? _nMaxPoint : nDimen <= _nMinPoint ? _nMinPoint : nDimen;
					}else if( _sDirection == RotateState.HORIZONTAL )
					{
						nDimen = Number(p_e.data.width);
						_targetDisplay.width = nDimen >= _nMaxPoint ? _nMaxPoint : nDimen <= _nMinPoint ? _nMinPoint : nDimen;
					}
				}else if( p_e.type == DIVIDER_MOVED )
				{
					var nNewVal:Number = p_e.data.value as Number;
					var bMinMaxHit:Boolean = (p_e.data.minMax == true);
					
					if( _sDirection == RotateState.VERTICAL )
					{
						_targetDisplay.height = nNewVal >= _nMaxPoint ? _nMaxPoint : nNewVal <= _nMinPoint ? _nMinPoint : nNewVal;
					}else if( _sDirection == RotateState.HORIZONTAL )
					{
						_targetDisplay.width = nNewVal >= _nMaxPoint ? _nMaxPoint : nNewVal <= _nMinPoint ? _nMinPoint : nNewVal;
					}
				}
			}
		}
		
		public function reSyncDivider(): void
		{
			if(!_targetDisplay) return;
			dispatchEvent(new SimpleEvent(DIVIDER_SYNC, null, {width:_targetDisplay.width, height:_targetDisplay.height}));
		}
		
		private function __onMouseOverEvent( p_e:Event ): void
		{
			if( p_e.type == MouseEvent.MOUSE_OUT || p_e.type == MouseEvent.ROLL_OUT )
			{
				//if( !_bMouseRegistered ) CursorManager.removeAllCursors();
			}else if( p_e.type == MouseEvent.MOUSE_OVER )
			{
				//CursorManager.setCursor( StyleManager.getStyleDeclaration( "DividedBox" ).getStyle(_sDirection == RotateState.VERTICAL?"verticalDividerCursor":"horizontalDividerCursor") );
			}
		}
		
		private function __checkGhostHit(): Boolean
		{
			var pt:Point = localToGlobal(new Point(mouseX, mouseY));
			return (_uiGhostHandler.hitTestPoint(pt.x, pt.y, true));
		}
		
		/**
		 * DISPLAY API
		**/
		
		override protected function createChildren(): void
		{
			super.createChildren();
			
			_uiGhostHandler = getStyleGraphic( "ghost" ) as SimpleSprite;
			stage.addChildAt( _uiGhostHandler, stage.numChildren );
		}
		
		override protected function childrenCreated(): void
		{
			super.childrenCreated();
			addEventListener( SimpleEventConst.MOVE, __onParentDividerMoved );
			
			_uiGhostHandler.alpha = 0;
			_uiGhostHandler.addEventListener( MouseEvent.MOUSE_DOWN, __onMouseEvent );
			
			//Sets Cursor
			_uiGhostHandler.addEventListener( MouseEvent.MOUSE_OVER, __onMouseOverEvent );
			_uiGhostHandler.addEventListener( MouseEvent.MOUSE_OUT, __onMouseOverEvent );
			_uiGhostHandler.addEventListener( MouseEvent.ROLL_OUT, __onMouseOverEvent );
		}
		
		
		override protected function arrange():void
		{
			if( _sDirection == RotateState.VERTICAL )
			{
				_uiGhostHandler.width = width;
				_uiGhostHandler.height = height < DEFAULT_DIVIDER_HIT_SPACE ? DEFAULT_DIVIDER_HIT_SPACE : height;
			}else{
				_uiGhostHandler.width = width < DEFAULT_DIVIDER_HIT_SPACE ? DEFAULT_DIVIDER_HIT_SPACE : width;
				_uiGhostHandler.height = height;
			}
			var pt:Point = stage.globalToLocal(parent.localToGlobal(new Point(x, y)));
			_uiGhostHandler.move( pt.x, pt.y );
		}
		
		/**
		 * GETTER / SETTER
		**/
		
		public function set targetDisplay( p_targetDisplay:ISimpleSprite ): void
		{
			__setDisplayTarget(p_targetDisplay);
		}
		
		public function get targetDisplay(): ISimpleSprite
		{
			return _targetDisplay;
		}
		
		public function set brotherDisplay( value:ISimpleSprite ): void
		{
			_brotherDisplay = value;
		}
		
		public function get brotherDisplay(): ISimpleSprite
		{
			return _brotherDisplay;
		}
		
		public function set direction( p_sDirection:String ): void
		{
			_sDirection = p_sDirection == RotateState.VERTICAL ? RotateState.VERTICAL : RotateState.HORIZONTAL;
		}
		
		public function get direction(): String
		{
			return _sDirection;
		}
		
		public function set increaseType( p_sIncreaseType:String ): void
		{
			_sIncreaseType = p_sIncreaseType == RotateState.NORMAL ? RotateState.NORMAL : RotateState.REVERSE;
		}
		
		public function get increaseType(): String
		{
			return _sIncreaseType;
		}
		
		public function set syncDivider( p_sdDivider:Divider ): void
		{
			__setSyncDivider(p_sdDivider);	
		}
		
		public function get syncDivider(): Divider
		{
			return _sdDivider;
		}
		
		override public function set visible( value:Boolean ): void
		{
			super.visible = _uiGhostHandler.visible = value;
			arrange();
		}
	}
}