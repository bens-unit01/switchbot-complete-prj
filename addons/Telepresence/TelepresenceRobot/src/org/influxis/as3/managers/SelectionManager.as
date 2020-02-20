/**
 * SelectionManager - Copyright © 2011 Influxis All rights reserved.
**/

package org.influxis.as3.managers 
{
	//Flash Classes
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.events.MouseEvent;
	import flash.events.Event;
	
	//Influxis Classes
	import org.influxis.as3.data.DataProvider;
	import org.influxis.as3.states.DataStates;
	import org.influxis.as3.events.SimpleEvent;
	import org.influxis.as3.utils.handler;
	import org.influxis.as3.utils.doTimedLater;
	import org.influxis.as3.utils.ArrayUtils;
	import org.influxis.as3.states.MouseStates;
	import org.influxis.as3.interfaces.states.ISelectable;
	import org.influxis.as3.core.Display;
	
	[Event(name = "itemRollOver", type = "org.influxis.as3.events.SimpleEvent")]
	[Event(name = "itemRollOut", type = "org.influxis.as3.events.SimpleEvent")]
	[Event(name = "itemSelected", type = "org.influxis.as3.events.SimpleEvent")]
	[Event(name = "itemClick", type = "org.influxis.as3.events.SimpleEvent")]
	[Event(name = "itemDoubleClick", type = "org.influxis.as3.events.SimpleEvent")]
		
	public class SelectionManager extends DataProvider
	{
		public static const ITEM_CLICK:String = "itemClick";
		public static const ITEM_DOUBLE_CLICK:String = "itemDoubleClick";
		public static const ITEM_ROLL_OVER:String = "itemRollOver";
		public static const ITEM_ROLL_OUT:String = "itemRollOut";
		public static const ITEM_DOWN:String = "itemDown";
		public static const ITEM_UP:String = "itemUp";
		public static const ITEM_SELECTED:String = "itemSelected";
		
		private var _bDoubleClickEnabled:Boolean;
		private var _bToggle:Boolean;
		private var _bExitAdded:Boolean;
		private var _bCTRLDown:Boolean;
		private var _bShiftDown:Boolean;
		private var _nSelectedIndex:Number;
		private var _aSelectedIndeces:Array;
		private var _doubleClickChild:InteractiveObject;
		
		/**
		 * INIT API
		 */
		
		public function SelectionManager(): void
		{
			//Create indeces object
			_aSelectedIndeces = new Array();
			super();
		}
		
		/**
		 * PUBLIC API
		 */
		 
		public function setSelectedIndeces( value:Array, selected:Boolean = true ): void
		{
			for each( var i:Number in value )
			{
				onSelectionRequest( i, getItemAt(i) as ISelectable, selected, true );
			}
		}
		
		public function setEnabledAt( index:Object, enabled:Boolean ): void
		{
			var selectableItem:ISelectable = _data[index] as ISelectable;
			if ( selectableItem.enabled != enabled )
			{
				selectableItem.enabled = enabled;
				__refreshState(selectableItem);
			}
		}
		
		public function clearAllSelections(): void
		{
			setSelectedIndeces( ArrayUtils.duplicateArray(selectedIndeces), false );
		}
		
		public function setEnabledItems( value:Boolean ): void
		{
			setEnabledRequest(value);
		}
		
		/**
		 * PRIVATE API
		 */
		
		private function __checkOverState( selection:ISelectable ): void
		{
			if ( !selection ) return;
			if ( !selection.over ) return;
			
			//If the mouse is no longer over go to up state
			if ( !__stillHit(selection as DisplayObject) )
			{
				selection.down = selection.over = false;
				dispatchEvent( new SimpleEvent(ITEM_ROLL_OUT, null, getItemSlotAt(selection)) );
				__refreshState(selection);
			}else{
				doTimedLater( 50, __checkOverState, selection );
			}
		}
		
		private function __refreshState( selection:ISelectable ): void
		{
			var state:String = MouseStates.getState(selection.selected, selection.over, selection.down, selection.enabled);
			if ( state != selection.state ) selection.state = state;
		}
		
		private function __stillHit( display:DisplayObject ): Boolean
		{
			if ( !display ) return false;
			var bHit:Boolean = display.hitTestPoint( Display.STAGE.mouseX, Display.STAGE.mouseY, true );
			return bHit;
		}
		
		private function __checkForDoubleClick( child:InteractiveObject ): void
		{
			if ( !doubleClickEnabled || !child ) return;
			
			if ( !_doubleClickChild )
			{
				_doubleClickChild = child;
				doTimedLater( 300, __resetDoubleClickCheck );
			}else if ( _doubleClickChild == child )
			{
				__resetDoubleClickCheck();
				dispatchEvent(new SimpleEvent(ITEM_DOUBLE_CLICK, null, getItemSlotAt(child)));
			}
		}
		
		private function __resetDoubleClickCheck(): void
		{
			_doubleClickChild = null;
		}
		
		/**
		 * PROTECTED API
		 */
		
		override protected function updateDataContainer(command:String, slot:*, data:Object, omitEvent:Boolean = false):Boolean 
		{
			if ( !_bExitAdded && Display.STAGE ) 
			{
				_bExitAdded = true;
				Display.STAGE.addEventListener( Event.MOUSE_LEAVE, __onStageEvent );
			}
			
			if ( command == DataStates.ADD || command == DataStates.REMOVE )
			{
				var item:* = command == DataStates.ADD ? data : _data[slot];
				var selection:InteractiveObject = item as InteractiveObject;
				if ( selection )
				{
					if ( command == DataStates.ADD )
					{
						selection.addEventListener( MouseEvent.MOUSE_DOWN, handler(__onMouseEvent, item) );
						selection.addEventListener( MouseEvent.MOUSE_UP, handler(__onMouseEvent, item) );
						selection.addEventListener( MouseEvent.MOUSE_OUT, handler(__onMouseEvent, item) );
						selection.addEventListener( MouseEvent.MOUSE_OVER, handler(__onMouseEvent, item) );
						selection.addEventListener( MouseEvent.CLICK, handler(__onMouseEvent, item) );
						selection.addEventListener( MouseEvent.DOUBLE_CLICK, handler(__onMouseEvent, item) );
					}else{
						selection.removeEventListener( MouseEvent.MOUSE_DOWN, handler(__onMouseEvent, item) );
						selection.removeEventListener( MouseEvent.MOUSE_OUT, handler(__onMouseEvent, item) );
						selection.removeEventListener( MouseEvent.MOUSE_OVER, handler(__onMouseEvent, item) );
						selection.removeEventListener( MouseEvent.CLICK, handler(__onMouseEvent, item) );
						selection.removeEventListener( MouseEvent.DOUBLE_CLICK, handler(__onMouseEvent, item) );
						selection.removeEventListener( MouseEvent.MOUSE_UP, handler(__onMouseEvent, item) );
					}	
				}
				if ( slot == _nSelectedIndex ) setSelectedIndeces( [_nSelectedIndex], false );
			}
			return super.updateDataContainer(command, slot, data, omitEvent);
		}
		
		protected function onSelectionRequest( index:Number, selection:ISelectable, selected:Boolean = true, omitEvent:Boolean = false ): void
		{
			if ( selection.selected == selected ) return;
			
			selection.selected = selected;
			if ( selected )
			{
				_nSelectedIndex = index;
				_aSelectedIndeces.push(index);
				
				if( !omitEvent ) dispatchEvent( new SimpleEvent(ITEM_SELECTED, null, index) );
			}else {
				_nSelectedIndex = _nSelectedIndex == index ? NaN : _nSelectedIndex;
				var nLen:Number = _aSelectedIndeces.length - 1;
				for ( var i:Number = nLen; i > -1; i-- )
				{
					if ( index == _aSelectedIndeces[i] )
					{
						_aSelectedIndeces.splice(i, 1);
						break;
					}
				}
			}
			//Refresh state to update skin
			__refreshState(selection);
		}
		
		protected function setEnabledRequest( enabled:Boolean ): void
		{
			for each( var i:Object in _data )
			{
				setEnabledAt(i, enabled);
			}
		}
		
		/**
		 * HANDLERS
		 */
		
		private function __onStageEvent( event:Event ): void
		{
			if ( event.type == Event.MOUSE_LEAVE )
			{
				for each( var i:Object in _data )
				{
					__onMouseEvent( event, i );
				}
			}
		}
		
		private var _lastMouseY:Number;
		private function __onMouseEvent( event:Event, item:Object ): void
		{
			var newEvent:SimpleEvent;
			var selection:ISelectable = item as ISelectable;
			if ( selection )
			{
				if ( event.type == MouseEvent.MOUSE_DOWN )
				{
					//Down state is active and refresh state
					selection.down = true;
					
					//Have to keep this in mind for mobile
					if( Display.IS_MOBILE ) _lastMouseY = Display.STAGE.mouseY;
					
					//Clear all indeces if CTRL is not down and make selection if valid
					if ( !_bCTRLDown ) clearAllSelections();
					
					//Added this new down event for mobile support
					newEvent = new SimpleEvent(ITEM_DOWN, null, getItemSlotAt(item));
					
					if ( !selection.selected || _bToggle ) 
					{
						onSelectionRequest( (getItemSlotAt(item) as Number), selection, !selection.selected );
					}else{
						__refreshState(selection);
					}
				}else if ( event.type == MouseEvent.DOUBLE_CLICK && doubleClickEnabled )
				{
					newEvent = new SimpleEvent(ITEM_DOUBLE_CLICK, null, getItemSlotAt(item));
				}else if ( event.type == MouseEvent.ROLL_OVER || event.type == MouseEvent.ROLL_OUT || event.type == MouseEvent.MOUSE_UP || event.type == MouseEvent.MOUSE_OVER || event.type == MouseEvent.MOUSE_OUT )
				{
					//If down state and mouse up broadcast click
					if ( event.type == MouseEvent.MOUSE_UP && selection.down ) 
					{
						//Added this new down event for mobile support
						newEvent = new SimpleEvent(ITEM_UP, null, getItemSlotAt(item));
						
						if ( Display.IS_MOBILE ) 
						{
							var nMoveDiff:Number = (_lastMouseY - Display.STAGE.mouseY);
							if( (nMoveDiff<0?nMoveDiff*-1:nMoveDiff) < 25 ) newEvent = new SimpleEvent( ITEM_CLICK, null, getItemSlotAt(item) );
						}else{
							newEvent = new SimpleEvent( ITEM_CLICK, null, getItemSlotAt(item) );
						}
						
						//Check for a double click if enabled
						if( _bDoubleClickEnabled ) __checkForDoubleClick(InteractiveObject(item));
					}
					
					//Even if there is a roll over or roll out we want to cancel out the down state
					if( selection.down ) selection.down = event.type == MouseEvent.MOUSE_UP ? false : __stillHit( item as DisplayObject );
					
					//Check for roll over events
					if ( (event.type == MouseEvent.ROLL_OVER || event.type == MouseEvent.MOUSE_OVER) && !selection.over && !Display.IS_MOBILE )
					{
						selection.over = true;
						newEvent = new SimpleEvent(ITEM_ROLL_OVER, null, getItemSlotAt(item));
					}else if ( !__stillHit(item as DisplayObject) )
					{
						selection.over = false;
						newEvent = new SimpleEvent(ITEM_ROLL_OUT, null, getItemSlotAt(item));
					}
					
					if ( selection.over ) doTimedLater( 40, __checkOverState, selection );
					
					//Refresh skins
					__refreshState(selection);
				}else if ( event.type == Event.MOUSE_LEAVE )
				{
					//Should go up state silently
					selection.down = false;
					
					//If the mouse was over but pointer left stage then call roll out
					if ( selection.over )
					{
						selection.over = false;
						newEvent = new SimpleEvent(ITEM_ROLL_OUT, null, getItemSlotAt(item));
					}
					
					//Refresh skins
					__refreshState(selection);
				}
			}
			//Send event if exists
			if ( newEvent ) dispatchEvent(newEvent);
		}
		
		/**
		 * GETTER / SETTER
		 */
		
		public function set doubleClickEnabled( value:Boolean ): void
		{
			if ( _bDoubleClickEnabled == value ) return;
			_bDoubleClickEnabled = value;
		}
		
		public function get doubleClickEnabled(): Boolean
		{
			return _bDoubleClickEnabled;
		}
		
		public function set toggle( value:Boolean ): void
		{
			_bToggle = value;
		}
		
		public function get toggle(): Boolean
		{
			return _bToggle;
		}
		
		public function set selectedIndex( value:Number ): void
		{
			if ( value == _nSelectedIndex ) return;
			
			_nSelectedIndex = value;
			
			clearAllSelections();
			if ( _nSelectedIndex <= length )
			{
				onSelectionRequest( _nSelectedIndex, getItemAt(_nSelectedIndex) as ISelectable, true, true );
			}
		}
		
		public function get selectedIndex(): Number
		{
			return _nSelectedIndex;
		}
		
		public function set selectedIndeces( value:Array ): void
		{
			if ( !value ) return;
			setSelectedIndeces( value, true );
		}
		
		public function get selectedIndeces(): Array
		{
			return _aSelectedIndeces;
		}
	}
}