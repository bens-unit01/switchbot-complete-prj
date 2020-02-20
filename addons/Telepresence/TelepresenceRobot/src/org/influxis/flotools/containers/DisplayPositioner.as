package org.influxis.flotools.containers 
{
	//Flash Classes
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	//Influxis Flotools Classes
	import org.influxis.flotools.states.DisplayPositionStates;
	
	//Influxis Classes
	import org.influxis.as3.display.SimpleSprite;
	import org.influxis.as3.display.SimpleComponent;
	import org.influxis.as3.events.SimpleEventConst;
	
	public class DisplayPositioner extends SimpleSprite
	{
		private var _displayPadding:Number = 0;
		private var _displayContainer:DisplayObject;
		private var _displayState:String = DisplayPositionStates.PICTURE_IN_PICTURE;
		private var _displayList:Vector.<DisplayObject>;
		
		/*
		 * PROTECTED API
		 */
		
		protected function refreshDisplayList(): void
		{
			_displayList = new Vector.<DisplayObject>();
			var nLen:Number = numChildren;
			for ( var i:Number = 0; i < nLen; i++ )
			{
				_displayList.push(getChildAt(i));
			}
			invalidateDisplayList();
		}
		
		/*
		 * PUBLIC API
		 */
		
		override public function addChild(child:DisplayObject):DisplayObject 
		{
			var childAdded:DisplayObject = super.addChild(child);
			if ( child is SimpleComponent )
			{
				SimpleComponent(child).addEventListener( SimpleEventConst.INITIALIZED, __onComponentInit );
			}else{
				refreshDisplayList();
			}
			return childAdded;
		}
		
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject 
		{
			var childAdded:DisplayObject = super.addChildAt(child, index);
			if ( child is SimpleComponent )
			{
				SimpleComponent(child).addEventListener( SimpleEventConst.INITIALIZED, __onComponentInit );
			}else{
				refreshDisplayList();
			}
			return childAdded;
		}
		
		override public function addChildren(...children):void 
		{
			super.addChildren.apply( this, (children as Array) ); 
			refreshDisplayList();
		}
		
		override public function removeChild(child:DisplayObject):DisplayObject 
		{
			var child:DisplayObject = super.removeChild(child);
			refreshDisplayList();
			return child;
		}
		
		override public function removeChildAt(index:int):DisplayObject 
		{
			var child:DisplayObject = super.removeChildAt(index);
			refreshDisplayList();
			return child;
		}
		
		override public function removeChildren(beginIndex:int = 0, endIndex:int = 2147483647):void 
		{
			super.removeChildren(beginIndex, endIndex);
			refreshDisplayList();
		}
		
		override public function removeAllChildren():void 
		{
			super.removeAllChildren();
			refreshDisplayList();
		}
		
		override public function setChildIndex(child:DisplayObject, index:int):void 
		{
			super.setChildIndex(child, index);
			refreshDisplayList();
		}
		
		override public function swapChildren(child1:DisplayObject, child2:DisplayObject):void 
		{
			super.swapChildren(child1, child2);
			refreshDisplayList();
		}
		
		override public function swapChildrenAt(index1:int, index2:int):void 
		{
			super.swapChildrenAt(index1, index2);
			refreshDisplayList();
		}
		
		/*
		 * HANDLERS
		 */
		
		private function __onComponentInit( event:Event ): void
		{
			event.currentTarget.removeEventListener( SimpleEventConst.INITIALIZED, __onComponentInit );
			refreshDisplayList();
		}
		 
		/*
		 * DISPLAY API
		 */
		
		override protected function arrange():void 
		{
			super.arrange();
			if ( _displayList && _displayList.length > 0 ) DisplayPositionStates.organizeWindows( _displayState, _displayList, width, height, _displayPadding, _displayContainer );
		}
		
		/*
		 * GETTER / SETTER
		 */
		
		public function set displayState( value:String ): void
		{
			if ( value == _displayState ) return;
			_displayState = value;
			invalidateDisplayList();
		}
		
		public function get displayState(): String
		{
			return _displayState;
		}
		
		public function set displayPadding( value:Number ): void
		{
			if ( _displayPadding == value || isNaN(value) ) return;
			_displayPadding = value;
			invalidateDisplayList();
		}
		
		public function set displayContainer( value:DisplayObject ): void
		{
			if ( _displayContainer == value ) return;
			_displayContainer = value;
			invalidateDisplayList();
		}
	}
}