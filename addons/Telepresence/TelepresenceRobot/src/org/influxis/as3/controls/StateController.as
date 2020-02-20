/**
 * StateController - Copyright © 2010 Influxis All rights reserved.
**/

package org.influxis.as3.controls 
{
	//Flash Classes
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	
	//Influxis Classes
	import org.influxis.as3.core.Display;
	import org.influxis.as3.states.MouseStates;
	import org.influxis.as3.events.SimpleEvent;
	
	[Event(name = "state", type = "org.influxis.as3.events.SimpleEvent")]
	public class StateController extends EventDispatcher
	{
		protected var overState:Boolean;
		protected var downState:Boolean;
		protected var buttonState:String = MouseStates.UP;
		
		private var _bSelected:Boolean;
		private var _bToggle:Boolean;
		private var _bEnabled:Boolean;
		private var _bLock:Boolean;
		private var _source:InteractiveObject;
		
		/**
		 * PRIVATE API
		 */
		
		private function __setSource( value:InteractiveObject ): void
		{
			if ( _source ) 
			{
				unregister();
				_source = null;
			}
			
			_source = value;
			if ( _source ) register();
		}
		
		private function __refreshState(): void
		{
			var state:String = MouseStates.getState(selected, overState, downState, enabled);
			if ( state != buttonState ) 
			{
				buttonState = state;
				setState( state );
				dispatchEvent( new SimpleEvent(SimpleEvent.STATE, null, state) );
			}
		}
		
		private function get stillHit(): Boolean
		{
			if ( !_source ) return false;
			var bHit:Boolean = _source.hitTestPoint( Display.STAGE.mouseX, Display.STAGE.mouseY, true );
			return bHit;
		}
		
		/**
		 * HANDLERS
		 */
		
		private function __mouseEvent( event:Event ): void
		{
			if ( _bLock ) return;
			if ( event.type == MouseEvent.MOUSE_DOWN )
			{
				if ( !_source.doubleClickEnabled && toggle ) selected = !_bSelected;
				downState = true;
				__refreshState();
			}else if ( event.type == MouseEvent.DOUBLE_CLICK && toggle )
			{
				selected = !_bSelected;
			}else if ( event.type == MouseEvent.ROLL_OVER || event.type == MouseEvent.ROLL_OUT || event.type == MouseEvent.MOUSE_UP || event.type == MouseEvent.MOUSE_OVER || event.type == MouseEvent.MOUSE_OUT )
			{
				downState = false;
				if ( !Display.IS_MOBILE ) overState = event.type == MouseEvent.ROLL_OVER || event.type == MouseEvent.MOUSE_OVER ? true : stillHit;
				__refreshState();
			}else if ( event.type == Event.MOUSE_LEAVE )
			{
				downState = overState = false;
				__refreshState();
			}
		}
		 
		/**
		 * PROTECTED API
		 */
		
		public function register(): void
		{
			_source.addEventListener( MouseEvent.MOUSE_UP, __mouseEvent );
			_source.addEventListener( MouseEvent.MOUSE_DOWN, __mouseEvent );
			_source.addEventListener( MouseEvent.DOUBLE_CLICK, __mouseEvent );
			_source.addEventListener( MouseEvent.ROLL_OVER, __mouseEvent );
			_source.addEventListener( MouseEvent.ROLL_OUT, __mouseEvent );
			_source.addEventListener( MouseEvent.MOUSE_OVER, __mouseEvent );
			_source.addEventListener( MouseEvent.MOUSE_OUT, __mouseEvent );
			Display.STAGE.addEventListener( Event.MOUSE_LEAVE, __mouseEvent );
		}
		 
		public function unregister(): void
		{
			_source.removeEventListener( MouseEvent.MOUSE_UP, __mouseEvent );
			_source.removeEventListener( MouseEvent.MOUSE_DOWN, __mouseEvent );
			_source.removeEventListener( MouseEvent.DOUBLE_CLICK, __mouseEvent );
			_source.removeEventListener( MouseEvent.ROLL_OVER, __mouseEvent );
			_source.removeEventListener( MouseEvent.ROLL_OUT, __mouseEvent );
			_source.removeEventListener( MouseEvent.MOUSE_OVER, __mouseEvent );
			_source.removeEventListener( MouseEvent.MOUSE_OUT, __mouseEvent );
			Display.STAGE.removeEventListener( Event.MOUSE_LEAVE, __mouseEvent );
		}
		
		protected function setSelected( value:Boolean ): void
		{
			
			
		}
		
		protected function setState( state:String ): void
		{
			
		}
		
		/**
		 * GETTER / SETTER
		 */
		
		public function set source( value:InteractiveObject ): void
		{
			__setSource(value);
		}
		
		public function get source(): InteractiveObject
		{
			return _source;
		}
		
		public function set selected( value:Boolean ): void
		{
			if ( _bSelected == value ) return;
			_bSelected = value;
			__refreshState();
			setSelected(value);
		}
		
		public function get selected(): Boolean
		{
			return _bSelected;
		}
		
		public function set over( value:Boolean ): void
		{
			if ( overState == value || Display.IS_MOBILE ) return;
			overState = value;
			__refreshState();
		}
		
		public function get over(): Boolean
		{
			return overState;
		}
		
		public function set down( value:Boolean ): void
		{
			if ( downState == value ) return;
			downState = value;
			__refreshState();
		}
		
		public function get down(): Boolean
		{
			return downState;
		}
		
		public function set toggle( value:Boolean ): void
		{
			_bToggle = value;
		}
		
		public function get toggle(): Boolean
		{
			return _bToggle;
		}
		
		public function set enabled( value:Boolean ): void
		{
			_bEnabled = value;
			__refreshState();
		}
		
		public function get enabled(): Boolean
		{
			return _bEnabled;
		}
		
		public function get currentState(): String
		{
			return buttonState;
		}
		
		public function set lockState( value:Boolean ): void
		{
			if ( _bLock == value ) return;
			_bLock = value;
		}
		
		public function get lockState(): Boolean
		{
			return _bLock;
		}
	}
}