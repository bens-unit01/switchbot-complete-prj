package org.influxis.as3.display.buttonclasses 
{
	//Flash Classes
	import flash.display.InteractiveObject;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	import flash.events.Event;
	
	//Influxis Classes
	import org.influxis.as3.display.StyleComponent;
	import org.influxis.as3.managers.SkinsManager;
	import org.influxis.as3.skins.SkinElement;
	import org.influxis.as3.skins.DefaultButtonSkin;
	import org.influxis.as3.skins.StateSkin;
	import org.influxis.as3.utils.SizeUtils;
	import org.influxis.as3.utils.doTimedLater;
	import org.influxis.as3.states.MouseStates;
	import org.influxis.as3.core.Display;
	
	public class ButtonBase extends StyleComponent
	{
		private var _sVersion:String = "1.0.0.0";
		public static var STYLE_CONSTRUCTED:Boolean;
		
		protected var overState:Boolean;
		protected var downState:Boolean;
		protected var buttonState:String = MouseStates.UP;
		
		private var _bSelected:Boolean;
		private var _bToggle:Boolean;
		
		//Skins
		private var uiBackground:InteractiveObject;
		
		override protected function init(): void 
		{
			if ( !STYLE_CONSTRUCTED ) styleConstructed();
			super.init();
			
			//Detects button presses to change state
			addEventListener( MouseEvent.MOUSE_UP, __mouseEvent );
			addEventListener( MouseEvent.MOUSE_DOWN, __mouseEvent );
			addEventListener( MouseEvent.DOUBLE_CLICK, __mouseEvent );
			addEventListener( MouseEvent.ROLL_OVER, __mouseEvent );
			addEventListener( MouseEvent.ROLL_OUT, __mouseEvent );
			addEventListener( MouseEvent.MOUSE_OVER, __mouseEvent );
			addEventListener( MouseEvent.MOUSE_OUT, __mouseEvent );
			Display.STAGE.addEventListener( Event.MOUSE_LEAVE, __mouseEvent );
		}
		
		/**
		 * STYLE API
		 */
		
		protected function styleConstructed(): void
		{
			STYLE_CONSTRUCTED = true;
			var skm:SkinsManager = SkinsManager.getInstance();
			if ( !skm.exists(className) ) skm.setSkinElement( className, new SkinElement(className, DefaultButtonSkin.defaultSkin), true );
		}
		
		/**
		 * PRIVATE API
		 */
		
		private function __refreshState(): void
		{
			var state:String = MouseStates.getState(selected, overState, downState, enabled);
			if ( state != buttonState ) 
			{
				buttonState = state;
				setState( state );
			}
		}
		
		private function get stillHit(): Boolean
		{
			var bHit:Boolean = hitTestPoint( Display.STAGE.mouseX, Display.STAGE.mouseY, true );
			return bHit;
		}
		
		/**
		 * PROTECTED API
		 */
		
		protected function setSelected( value:Boolean ): void
		{
			if ( !initialized ) return;
			
		}
		
		protected function setState( state:String ): void
		{
			var bgState:StateSkin = uiBackground as StateSkin;
			if ( bgState ) 
			{
				bgState.state = buttonState;
				refreshMeasures();
			}
		}
		
		override protected function setEnabled(enabled:Boolean):void 
		{
			super.setEnabled(enabled);
			__refreshState();
		}
		
		/**
		 * HANDLERS
		 */
		
		private function __mouseEvent( event:Event ): void
		{
			if ( event.type == MouseEvent.MOUSE_DOWN )
			{
				if ( !doubleClickEnabled && toggle ) selected = !_bSelected;
				downState = true;
				__refreshState();
			}else if ( event.type == MouseEvent.DOUBLE_CLICK && toggle )
			{
				selected = !_bSelected;
			}else if ( event.type == MouseEvent.ROLL_OVER || event.type == MouseEvent.ROLL_OUT || event.type == MouseEvent.MOUSE_UP || event.type == MouseEvent.MOUSE_OVER || event.type == MouseEvent.MOUSE_OUT )
			{
				downState = false;
				if ( !Display.IS_MOBILE ) 
				{
					overState = event.type == MouseEvent.ROLL_OVER || event.type == MouseEvent.MOUSE_OVER ? true : stillHit;
					if ( overState ) doTimedLater( 50, __checkOverState );
				}
				__refreshState();
			}else if ( event.type == Event.MOUSE_LEAVE )
			{
				downState = overState = false;
				__refreshState();
			}
		}
		
		private function __checkOverState(): void
		{
			if ( !overState ) return;
			
			if ( !stillHit )
			{
				downState = false;
				overState = false;
				__refreshState();
			}else{
				doTimedLater( 50, __checkOverState );
			}
		}
		
		/**
		 * DISPLAY API
		 */
		
		override protected function measure():void 
		{
			super.measure();
			measuredWidth = (uiBackground as StyleComponent).measuredWidth;
			measuredHeight = (uiBackground as StyleComponent).measuredHeight;
		}
		 
		override protected function createChildren(): void 
		{
			super.createChildren();
			
			uiBackground = new StateSkin( skinName, "background", false );
			setSelected(_bSelected);
			addChild(uiBackground);
		}
		
		override protected function arrange():void 
		{
			super.arrange();
			uiBackground.width = width;
			uiBackground.height = height;
		}
		
		/**
		 * GETTER / SETTER
		 */
		
		override public function set skinName( value:String ):void 
		{
			super.skinName = value;
			if ( uiBackground ) 
			{
				(uiBackground as StateSkin).skinName = value;
			}
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
		
		public function set toggle( value:Boolean ): void
		{
			_bToggle = value;
		}
		
		public function get toggle(): Boolean
		{
			return _bToggle;
		}
		
		protected function get background(): StyleComponent
		{
			return (uiBackground as StyleComponent);
		}
	}
}