/**
 * StateSkin - Copyright © 2010 Influxis All rights reserved.
**/

package org.influxis.as3.skins 
{
	//Flash Classes
	import flash.display.DisplayObject;
	import org.influxis.as3.events.SimpleEvent;
	
	//Influxis Classes
	import org.influxis.as3.core.infx_internal;
	import org.influxis.as3.display.StyleComponent;
	import org.influxis.as3.states.MouseStates;
	import org.influxis.as3.controls.StateController;
	import org.influxis.as3.interfaces.states.ISelectable;
	
	public class StateSkin extends StyleComponent implements ISelectable
	{		
		use namespace infx_internal;
		
		private var _sTargetSkin:String;
		private var _sTargetStyle:String;
		private var _state:StateController;
		private var _stateSkin:DisplayObject;
		private var _bSelected:Boolean;
		private var _bOver:Boolean;
		private var _bDown:Boolean;
		private var _oStates:Object = new Object();
		private var _sState:String = MouseStates.UP;
		private var _bAutoStateChange:Boolean = true;
		
		/**
		 * INIT API
		 */
		
		public function StateSkin( skin:String, targetStyle:String = "stateSkin", autoStateChange:Boolean = true ) 
		{
			_state = new StateController();
			_state.addEventListener( SimpleEvent.STATE, __onStateChange );
			_state.source = autoStateChange ? this : null;
			_bAutoStateChange = autoStateChange;
			
			_sTargetSkin = skin;
			_sTargetStyle = targetStyle;
			super();
		}
		
		override protected function init():void 
		{
			skinName = _sTargetSkin;
			super.init();
		}
		
		/**
		 * PRIVATE API
		 */
		
		//If autostate is not enabled you can assign custom states to redo state
		private function __checkSkinState(): void
		{
			if ( _bAutoStateChange ) return;
			state = MouseStates.getState(selected, over, down, enabled);
		}
		 
		/**
		 * HANDLERS
		 */
		
		//Fires when a new state is detected
		private function __onStateChange( event:SimpleEvent ): void
		{
			state = _state.currentState;
		}
		 
		/**
		 * PROTECTED API
		 */
		
		protected function stateChanged(): void
		{
			//Lock state so it does not change while replacing the child
			_state.lockState = true;
			
			//Remove and add new state
			//removeChildAt(0);
			removeAllChildren();
			_stateSkin = addChildAt( _oStates[state] as DisplayObject, 0 );
			
			//Unlock and re-measure
			_state.lockState = false;
			refreshMeasures();
		}
		
		override protected function setEnabled(enabled:Boolean):void 
		{
			super.setEnabled(enabled);
			
			if ( _bAutoStateChange )
			{
				_state.enabled = enabled;
			}else{
				__checkSkinState();
			}
		}
		
		protected final function registerStateSkins(): void
		{
			//Create state skins
			_oStates["up"] = getStyleGraphic( _sTargetStyle + ":up" );
			_oStates["down"] = getStyleGraphic( _sTargetStyle + ":down" );
			_oStates["over"] = getStyleGraphic( _sTargetStyle + ":over" );
			_oStates["selectedUp"] = getStyleGraphic( _sTargetStyle + ":selectedUp" );
			_oStates["selectedDown"] = getStyleGraphic( _sTargetStyle + ":selectedDown" );
			_oStates["selectedOver"] = getStyleGraphic( _sTargetStyle + ":selectedOver" );
			_oStates["disabled"] = getStyleGraphic( _sTargetStyle + ":disabled" );
		}
		
		/**
		 * DISPLAY API
		 */
		
		override protected function measure():void 
		{
			super.measure();
			measuredWidth = (_stateSkin as StyleGraphic).measuredWidth;
			measuredHeight = (_stateSkin as StyleGraphic).measuredHeight;
		}
		 
		override protected function checkDimensions(omitEvent:Boolean = false):void 
		{
			super.checkDimensions(omitEvent);
			tracer( "checkDimensions(); ", width, height, measuredWidth, measuredHeight, initialized );
		}
		
		override protected function createChildren():void 
		{
			super.createChildren();
			
			registerStateSkins();
			_stateSkin = _oStates[state] as DisplayObject;
			addChildAt(_stateSkin, 0);
		}
		
		override protected function arrange():void 
		{
			super.arrange();
			_stateSkin.width = width;
			_stateSkin.height = height;
		}
		
		//override public function get height():Number { return measuredHeight; }
		
		/**
		 * GETTER / SETTER
		 */
		
		infx_internal function get stateSkin(): DisplayObject
		{
			return _stateSkin;
		}
		 
		public function set state( value:String ): void
		{
			if ( _sState == value ) return;
			_sState = value;
			if( initialized ) stateChanged();
		}
		
		public function get state(): String 
		{
			return _sState;
		}
		
		override public function set skinName(value:String):void 
		{
			super.skinName = value;
			if ( initialized ) 
			{
				registerStateSkins();
				stateChanged();
			}
		}
		
		public function set selected( value:Boolean ): void
		{
			if ( _bSelected == value && !_bAutoStateChange ) return;
			_bSelected = value;
			__checkSkinState();
		}
		
		public function get selected(): Boolean
		{
			return _bSelected;
		}
		
		public function set over( value:Boolean ): void
		{
			if ( _bOver == value ) return;
			_bOver = value;
			__checkSkinState();
		}
		
		public function get over(): Boolean
		{
			return _bOver;
		}
		
		public function set down( value:Boolean ): void
		{
			if ( _bDown == value ) return;
			_bDown = value;
			__checkSkinState();
		}
		
		public function get down(): Boolean
		{
			return _bDown;
		}
		
		public function set autoStateChange( value:Boolean ): void
		{
			if ( _bAutoStateChange == value ) return;
			_bAutoStateChange = value;
			_state.source = _bAutoStateChange ? this : null;
			if ( !_bAutoStateChange ) __checkSkinState();
		}
		
		public function get autoStateChange(): Boolean
		{
			return _bAutoStateChange;
		}
	}
}