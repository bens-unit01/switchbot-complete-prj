package org.influxis.mobile.controls 
{
	//Flash Classes
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.TouchEvent;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	//Influxis Classes
	import org.influxis.as3.display.listclasses.ListBase;
	
	public class MobileScroller 
	{
		private var _lastYPos:Number;
		private var _timer:Timer;
		private var _targetDisplay:InteractiveObject;
		private var _targetContainer:InteractiveObject;
		private var _isListBase:Boolean;
		private var _savedYPos:Dictionary;
		
		/*
		 * INIT API
		 */
		
		public function MobileScroller( targetDisplay:InteractiveObject = null, targetContainer:InteractiveObject = null ): void
		{
			_timer = new Timer(1);
			_timer.addEventListener( TimerEvent.TIMER, __onTimerEvent );
			
			registerNewDisplay(targetDisplay);
			_targetContainer = targetContainer;			
		}
		
		/*
		 * PROTECTED API
		 */
		
		protected function registerNewDisplay( value:InteractiveObject ): void
		{
			if ( _targetDisplay )
			{
				_targetDisplay.removeEventListener( MouseEvent.MOUSE_DOWN, __onTouchEvent );
				_targetDisplay.removeEventListener( MouseEvent.MOUSE_UP, __onTouchEvent );
				_targetDisplay.stage.removeEventListener( Event.MOUSE_LEAVE, __onTouchEvent );
				_isListBase = false;
				
				//Save last y pos so if registered again it rememebers
				if ( !isNaN(_lastYPos) )
				{
					//Stop timer if running
					_timer.stop();
					
					//Save yPos
					if ( !_savedYPos ) _savedYPos = new Dictionary();
					_savedYPos[_targetDisplay] = _lastYPos;
				}
			}
			
			_targetDisplay = value;
			if ( !_targetDisplay ) return;
			
			//Load saved ypos and delete old entry
			if ( _savedYPos && !isNaN(_savedYPos[_targetDisplay]) )
			{
				_lastYPos = _savedYPos[_targetDisplay];
				delete _savedYPos[_targetDisplay];
			}
			
			_isListBase = (_targetDisplay as ListBase) != null;
			_targetDisplay.addEventListener( MouseEvent.MOUSE_DOWN, __onTouchEvent );
			_targetDisplay.addEventListener( MouseEvent.MOUSE_UP, __onTouchEvent );
			_targetDisplay.stage.addEventListener( Event.MOUSE_LEAVE, __onTouchEvent );
		}
		 
		protected function get targetHeight(): Number
		{
			return _isListBase ? ListBase(_targetDisplay).measuredHeight : _targetDisplay.height;
		}
		 
		/*
		 * HANDLERS
		 */
		
		private function __onTimerEvent( event:TimerEvent ): void
		{
			if ( _lastYPos == _targetContainer.mouseY ) 
			{
				
			}else{
				//trace("__onTimerEvent: " + _targetContainer.mouseY);
				if ( _targetContainer.mouseY < 0 ) 
				{
					_timer.stop(); _timer.reset();
					return;
				}
				
				var height:Number = targetHeight;
				var newYPos:Number = _targetDisplay.y - (_lastYPos - _targetContainer.mouseY);
				_targetDisplay.y = newYPos < (_targetContainer.height-height) ? (_targetContainer.height-height) : newYPos > 0 ? 0 : newYPos;
				_lastYPos = _targetContainer.mouseY;
			}
		}
		 
		private function __onTouchEvent( event:Event ): void
		{
			//trace( "__onTouchEvent: " + event.type, _targetDisplay.height, _targetContainer.height );
			
			if ( targetHeight < _targetContainer.height ) return;
			if ( event.type == MouseEvent.MOUSE_DOWN )
			{
				_lastYPos = _targetContainer.mouseY;
				_timer.start();
			}else if ( event.type == MouseEvent.MOUSE_UP || event.type == Event.MOUSE_LEAVE )
			{
				_timer.stop();
				_timer.reset();
			}	
		}
		
		/*
		 * GETTER / SETTER
		 */
		
		public function get targetContainer(): InteractiveObject
		{
			return _targetContainer;
		}
		
		public function set targetContainer( value:InteractiveObject ): void
		{
			if ( value == _targetContainer ) return;
			_targetContainer = value;
		}
		
		public function get targetDisplay(): InteractiveObject
		{
			return _targetDisplay
		}
		
		public function set targetDisplay( value:InteractiveObject ): void
		{
			if ( value == _targetDisplay ) return;
			registerNewDisplay(value);
		}
	}
}