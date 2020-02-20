/**
 * ListBase - Copyright © 2011 Influxis All rights reserved.
**/

package org.influxis.as3.display.listclasses 
{
	//Flash Classes
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	//Influxis Classes
	import org.influxis.as3.display.SimpleSprite;
	import org.influxis.as3.interfaces.display.ISimpleSprite;
	import org.influxis.as3.states.PositionStates;
	import org.influxis.as3.states.SizeStates;
	import org.influxis.as3.events.SimpleEventConst;
	
	public class ListBase extends SimpleSprite
	{
		
		/**
		 * HANDLERS
		 */
		
		private function __onChildResize( event:Event ): void
		{
			if ( event.type == SizeStates.RESIZE_HEIGHT || event.type == SizeStates.MEASURE_WITDH || event.type == SimpleEventConst.INITIALIZED )
			{
				__redoMeasures();
			}
		}
		 
		/**
		 * PRIVATE API
		 */
		
		private function __redoMeasures(): void
		{
			var nMeasureWidth:Number = 0;
			var nMeasureHeight:Number = 0;
			for ( var i:Number = 0; i < numChildren; i++ )
			{
				if ( nMeasureWidth < getChildAt(i).width ) nMeasureWidth = getChildAt(i).width;
				nMeasureHeight = nMeasureHeight + getChildAt(i).height;
			}
			measuredWidth = nMeasureWidth
			measuredHeight = nMeasureHeight;
		}
		 
		private function __addChildIndexAt( child:DisplayObject, index:int ): void
		{
			var currentSimple:ISimpleSprite = child as ISimpleSprite;
			if ( currentSimple )
			{
				if ( index > 0 )
				{		
					var targetSimple:ISimpleSprite = getChildAt(index - 1) as ISimpleSprite;
					if ( targetSimple ) currentSimple.hook( targetSimple, currentSimple, PositionStates.BOTTOM, PositionStates.CENTER );
				}else{
					currentSimple.hook(null);
				}
			}
			
			//If there is children in front of this one then hook those to the new child
			if ( numChildren > (index+1) )
			{
				var holderSimple:ISimpleSprite = getChildAt(index+1) as ISimpleSprite;
				if ( holderSimple ) holderSimple.hook( currentSimple, holderSimple, PositionStates.BOTTOM, PositionStates.CENTER );	
			}
		}
		
		private function __removeChildIndexAt( child:DisplayObject, index:int ): void
		{
			var currentSimple:ISimpleSprite = child as ISimpleSprite;
			if ( currentSimple )
			{
				if ( numChildren > (index + 1) )
				{
					var targetSimple:ISimpleSprite = getChildAt(index + 1) as ISimpleSprite;
					if ( targetSimple ) 
					{
						targetSimple.hook( (index > 0 ? getChildAt(index - 1) as ISimpleSprite : null), this, PositionStates.BOTTOM, PositionStates.CENTER );
						if( index == 0 ) targetSimple.y = 0;
					}
				}
				currentSimple.hook(null);
			}
		}
		
		/**
		 * CHILD API
		 */
		
		override public function addChild(child:DisplayObject):DisplayObject 
		{
			return addChildAt(child, numChildren);
		}
		
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject 
		{
			//Add child to display tree first
			var returnVal:DisplayObject = super.addChildAt(child, index);
			
			//The child should have the same width as the list by default
			child.width = width;
			
			var simpleDisplay:ISimpleSprite = child as ISimpleSprite;
			if ( simpleDisplay ) 
			{
				simpleDisplay.addEventListener( SizeStates.MEASURE_WITDH, __onChildResize );
				simpleDisplay.addEventListener( SizeStates.RESIZE_HEIGHT, __onChildResize );
				simpleDisplay.addEventListener( SimpleEventConst.INITIALIZED, __onChildResize );
			}
			
			measuredWidth = measuredWidth < child.width ? child.width : measuredWidth;
			measuredHeight = isNaN(measuredHeight) ? child.height : (measuredHeight + child.height);
			
			//Add to hook list under new index
			__addChildIndexAt( child, index );
			return returnVal
		}
		
		override public function removeChild(child:DisplayObject):DisplayObject 
		{
			return removeChildAt(getChildIndex(child));
		}
		
		override public function removeChildAt(index:int):DisplayObject 
		{
			var child:DisplayObject = getChildAt(index);
			
			var simpleDisplay:ISimpleSprite = child as ISimpleSprite;
			if ( simpleDisplay ) 
			{
				simpleDisplay.removeEventListener( SizeStates.MEASURE_WITDH, __onChildResize );
				simpleDisplay.removeEventListener( SizeStates.RESIZE_HEIGHT, __onChildResize );
				simpleDisplay.removeEventListener( SimpleEventConst.INITIALIZED, __onChildResize );
			}
			
			//Remove from the hook list
			__removeChildIndexAt( child, index );
			if ( measuredWidth == child.width )
			{
				__redoMeasures();
			}else {
				measuredHeight = isNaN(measuredHeight) ? 0 : (measuredHeight - child.height);
			}
			return super.removeChildAt(index);
		}
		
		override public function setChildIndex(child:DisplayObject, index:int):void 
		{
			//Remove from the hook list
			__removeChildIndexAt(child, getChildIndex(child) );	
			
			//Set index
			super.setChildIndex(child, index);
			
			//Add back to hook list under new index
			__addChildIndexAt(child, index);
		}
		
		override public function swapChildren(child1:DisplayObject, child2:DisplayObject):void 
		{
			swapChildrenAt(getChildIndex(child1), getChildIndex(child2));
		}
		
		override public function swapChildrenAt(index1:int, index2:int):void 
		{
			//Remove from the hook list
			__removeChildIndexAt(getChildAt(index1), index1 );	
			__removeChildIndexAt(getChildAt(index2), index2 );	
			
			super.swapChildrenAt(index1, index2);
			
			//Add them back to hook list under new indeces
			__addChildIndexAt(getChildAt(index1), index1 );	
			__addChildIndexAt(getChildAt(index2), index2 );	
		}
		
		/**
		 * DISPLAY API
		 */
		
		//Setting size should not affect height since height is calculated by the items it holds
		override public function setActualSize(w:Number, h:Number, omitEvent:Boolean = false):void 
		{
			super.setActualSize(w, height, omitEvent);
		}
		
		override protected function arrange():void 
		{
			super.arrange();
			
			var simpleChild:ISimpleSprite;
			for ( var i:Number = 0; i < numChildren; i++ )
			{
				simpleChild = getChildAt(i) as ISimpleSprite;
				if ( simpleChild ) simpleChild.width = width;
			}
		}
		
		/**
		 * GETTER / SETTER
		 */
		
		//Height by default can't be set
		override public function set height(value:Number):void 
		{
			//super.height = height;
		}
	}
}