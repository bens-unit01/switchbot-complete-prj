/**
 * MouseSensor - Copyright © 2009-2010 Influxis All rights reserved.
**/

package org.influxis.as3.utils
{
	//Flash Classes
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	import flash.display.DisplayObject;
	
	//Influxis Classes
	import org.influxis.as3.core.Display;
	
	public class MouseSensor extends EventDispatcher
	{
		public static var symbolName:String = "MouseSensor";
		public static var symbolOwner:Object = org.influxis.as3.utils.MouseSensor;
		private var infxClassName:String = "MouseSensor";
		private var _sVersion:String = "1.0.0.1";
		
		public static const MOVE:String = "move";
		public static const STOP:String = "stop";
		
		private static var __sensor:MouseSensor;
		
		private var _displayTarget:DisplayObject;
		private var _clickTarget:DisplayObject;
		private var _timer:Timer;
		
		private var _nCheckTime:Number = 500;
		private var _nStopDelay:uint = 3;
		private var _nDelayCount:Number = 1;
		private var _nLastXMouse:Number = 0;
		private var _nLastYMouse:Number = 0;
		private var _bMoving:Boolean = false;
		private var _bStillAction:Boolean = true;
		private var _bStarted:Boolean;
		
		/**
		 * INIT API
		**/
		
		public function MouseSensor(): void
		{
			if( Display.STAGE ) _bStageHit = Display.STAGE.mouseX == 0 && Display.STAGE.mouseY == 0;
			
			resetTimer();
			__registerStageEvents();
		}
		
		/**
		 * INSTANCE API
		**/
		
		public static function getInstance(): MouseSensor
		{
			if( !__sensor ) __sensor = new MouseSensor();
			return __sensor;
		}
		
		public static function destroy(): void
		{
			__sensor = null;
		}
		
		/**
		 * PUBLIC API
		**/
		
		public function startSensor( p_bStart:Boolean = true ): void
		{
			if( _bStarted == p_bStart ) return;
			
			_bStarted = p_bStart;
			if( _bStarted )
			{
				_timer.start();
			}else{
				_timer.stop();
			}
		}
		
		/**
		 * PRIVATE API
		**/
		
		private function resetTimer(): void
		{
			if( _timer )
			{
				if( _bStarted )
				{
					_timer.stop();
					_timer.reset();
				}
				_timer.removeEventListener( TimerEvent.TIMER, __doSensorCheck );
				_timer = null;
			}
			_timer = new Timer( _nCheckTime, 0 );
			_timer.addEventListener( TimerEvent.TIMER, __doSensorCheck );
			if( _bStarted ) _timer.start();
		}
		
		private function __doSensorCheck( ...args ): void
		{
			if( !_bStageHit ) return;
			
			var nXMouse:Number, nYMouse:Number, _target:DisplayObject;
			if( _displayTarget )
			{
				_target = _displayTarget;
			}else{
				try
				{
					_target = DisplayObject(Display.STAGE);
				}catch( e:Error )
				{
					trace(e);
				}
			}
			
			if ( !_target ) return;
			
			var bHit:Boolean = _target.hitTestPoint( Display.STAGE.mouseX, Display.STAGE.mouseY, true );
			var pt:Point = _target.localToGlobal(new Point(_target.mouseX, _target.mouseY));
			
			nXMouse = bHit ? (pt.x) : _nLastXMouse;
			nYMouse = bHit ? (pt.y) : _nLastYMouse;
			
			if( _bStillAction )
			{
				if( nXMouse == _nLastXMouse && nYMouse == _nLastYMouse )
				{
					_nDelayCount = _nDelayCount+(_nCheckTime/1000);
					if( _nDelayCount >= _nStopDelay && _bMoving )
					{
						_bMoving = false;
						dispatchEvent(new Event(STOP));
					}
				}else{
					if( !_bMoving )
					{
						_bMoving = true;
						dispatchEvent(new Event(MOVE));
					}
					_nDelayCount = 1;
				}
				_nLastXMouse = nXMouse;
				_nLastYMouse = nYMouse;
			}else{
				if( bHit && !_bMoving )
				{
					_bClickActive = false;
					_bMoving = true;
					dispatchEvent(new Event(MOVE));
				}else if( !bHit && _bMoving && !_bClickActive )
				{
					_bMoving = false;
					dispatchEvent(new Event(STOP));
				}
			}
		}
		
		private function __registerStageEvents(): void
		{
			try
			{
				Display.STAGE.addEventListener( Event.MOUSE_LEAVE, __onMouseEventStage );
				Display.STAGE.addEventListener( MouseEvent.MOUSE_OVER, __onMouseEventStage );
				Display.STAGE.addEventListener( MouseEvent.MOUSE_DOWN, __onClickTarget );
			}catch( e:Error )
			{
				doTimedLater( 100, __registerStageEvents );
			}
		}
		
		private var _bStageHit:Boolean = true;
		private function __onMouseEventStage( p_e:Event ): void
		{
			var bHit:Boolean = p_e.type == MouseEvent.MOUSE_OVER;
			if( bHit == _bStageHit ) return;
			
			_bStageHit = bHit;
			if( !_bStageHit && (_bMoving || _bClickActive) )
			{
				_bClickActive = _bMoving = false;
				if( _bStarted ) dispatchEvent(new Event(STOP));
			}
		}
		
		private var _bClickActive:Boolean;
		private function __onClickTarget( p_e:Event ): void
		{
			if( !_clickTarget || _bMoving || !_bStarted ) return;
			
			var bHit:Boolean = _clickTarget.hitTestPoint( Display.STAGE.mouseX, Display.STAGE.mouseY, true );
			if( !bHit ) return;
			
			_bClickActive = !_bClickActive;
			dispatchEvent(new Event(_bClickActive ? MOVE : STOP));
		}
		
		/**
		 * GETTER / SETTER
		**/
		
		public function set checkRate( p_nCheckTime:uint ): void
		{
			if( _nCheckTime == p_nCheckTime || p_nCheckTime == 0 ) return;
			
			_nCheckTime = p_nCheckTime;
			resetTimer();
		}
		
		public function get checkRate(): uint
		{
			return _nCheckTime;
		}
		
		public function set mouseTarget( p_displayTarget:DisplayObject ): void
		{
			_displayTarget = p_displayTarget;
			if( _displayTarget ) __doSensorCheck();
		}
		
		public function get mouseTarget(): DisplayObject
		{
			return _displayTarget;
		}
		
		public function set clickTarget( clickTarget:DisplayObject ): void
		{
			_clickTarget = clickTarget;
		}
		
		public function get clickTarget(): DisplayObject
		{
			return _clickTarget;
		}
		
		public function set stillAction( p_bStillAction:Boolean ): void
		{
			_bStillAction = p_bStillAction;
		}
		
		public function get stillAction(): Boolean
		{
			return _bStillAction;
		}
		
		public function set stopDelay( p_nStopDelay:uint ): void
		{
			if( _nStopDelay == p_nStopDelay ) return;
			_nStopDelay = p_nStopDelay;
		}
		
		public function get stopDelay(): uint
		{
			return _nStopDelay;
		}
		
		public function get moving(): Boolean
		{
			return _bMoving;
		}
		
		public function get clicked(): Boolean
		{
			return _bClickActive;
		}
		
		public function get running(): Boolean
		{
			return _bStarted;
		}
	}
}