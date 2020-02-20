/**
 * SimpleComponent - Copyright © 2010 Influxis All rights reserved.
**/

package org.influxis.as3.display 
{
	//Flash Classes
	import flash.events.Event;
	import flash.display.DisplayObject;
	
	//Influxis Classes
	import org.influxis.as3.core.Display;
	import org.influxis.as3.core.infx_internal;
	import org.influxis.as3.display.SimpleSprite;
	import org.influxis.as3.events.SimpleEventConst;
	import org.influxis.as3.states.SizeStates;
	import org.influxis.as3.utils.doTimedLater;
	
	//Events
	[Event(name = "infxInitialized", type = "flash.events.Event")]
	[Event(name = "measureChange", type = "flash.events.Event")]
	
	public class SimpleComponent extends SimpleSprite
	{
		use namespace infx_internal;
		private var _bInitialized:Boolean;
		private var _visible:Boolean = true;
		
		/**
		 * INIT API
		 */
		
		public function SimpleComponent() 
		{
			super();
			
			//lets not show comp before its full initialized
			super.visible = false;
			
			//Call to handle pre-init tasks
			__checkStage();
		}
		
		//Make all beginning calls here before init is actually called
		protected function preInitialize(): void
		{
			init();
		}
		
		//Init the sprite
		protected function init(): void
		{
			createChildren();
			__setInitialized();
		}
		
		protected function onInitialize(): void
		{
			
		}
		
		private function __checkStage(): void
		{
			if ( stage && root )
			{
				if ( !Display.STAGE ) Display.STAGE = stage;
				if ( !Display.ROOT ) Display.ROOT = root;
				preInitialize();
			}else{
				doTimedLater( 50, __checkStage );
			}
		}
		
		private function __setInitialized(): void
		{
			if ( _bInitialized ) return;
			
			if ( !__checkCreated() )
			{
				doTimedLater( 50, __setInitialized );
			}else{
				_bInitialized = true;
				
				childrenCreated();
				measure();
				checkDimensions();
				arrange();
				
				onInitialize();
				super.visible = _visible;
				dispatchEvent( new Event(SimpleEventConst.INITIALIZED) );
			}
		}
		
		private function __checkCreated(): Boolean
		{
			if ( numChildren == 0 ) return true;
			
			var simpleChild:SimpleComponent;
			for ( var i:uint = 0; i < numChildren; i++ )
			{
				simpleChild = getChildAt(i) as SimpleComponent;
				if ( simpleChild )
				{
					if ( !simpleChild.initialized ) return false;
				}
			}
			return true;
		}
		
		infx_internal function __setInitialize(): void
		{
			_bInitialized = true;
		}
		
		/**
		 * DISPLAY API
		 */
		
		override protected function checkDimensions(omitEvent:Boolean = false):void 
		{
			if( initialized ) super.checkDimensions(omitEvent);
		}
		 
		override protected function onSizeChanged( omitEvent:Boolean = false ):void 
		{
			if( initialized ) super.onSizeChanged(omitEvent);
		}
		
		protected function refreshMeasures(): void
		{
			if ( !initialized ) return;
			measure();
			arrange();
		}
		
		protected function measure(): void
		{
			//doTimedLater( 1, dispatchEvent, new Event(SizeStates.MEASURE));
			dispatchEvent(new Event(SizeStates.MEASURE));
		}
		
		protected function createChildren(): void
		{
			
		}
		
		protected function childrenCreated(): void
		{
			
		}
		
		override public function invalidateDisplayList():void 
		{
			if( _bInitialized ) super.invalidateDisplayList();
		}
		
		/**
		 * GETTER / SETTER
		 */
		
		public function get initialized(): Boolean
		{
			return _bInitialized;
		}
		
		override public function set visible( value:Boolean ): void 
		{ 
			_visible = value;
			if ( initialized ) super.visible = value;
		}
		
		override public function get visible():Boolean 
		{ 
			return _visible;
		}
	}
}