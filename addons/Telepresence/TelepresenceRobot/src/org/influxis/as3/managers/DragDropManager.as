package org.influxis.as3.managers 
{
	//Flash Classes
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.utils.Dictionary;
	
	//Influxis Classes
	import org.influxis.as3.core.Display;
	import org.influxis.as3.events.DragDropEvent;
	
	public class DragDropManager extends EventDispatcher
	{
		private static var __instances:Object = new Object();
		
		private var _registeredDisplays:Vector.<DisplayObject>;
		private var _dragData:Object;
		private var _dragTimer:Timer;
		private var _dragImage:DisplayObject;
		private var _overReference:Dictionary;
		
		/*
		 * INIT API
		 */
		
		public function DragDropManager( instanceName:String ): void
		{
			_registeredDisplays = new Vector.<DisplayObject>();
			
			_dragTimer = new Timer(10);
			_dragTimer.addEventListener( TimerEvent.TIMER, __onTimerEvent );
			Display.STAGE.addEventListener( MouseEvent.MOUSE_UP, __onMouseEvent, false, Number.MAX_VALUE );
			super();
		}
		
		/*
		 * SINGLETON API
		 */
		
		public static function getInstance( instanceName:String = "_DEFAULT_" ): DragDropManager
		{
			if ( !instanceName ) return null;
			if ( __instances[instanceName] == undefined ) __instances[instanceName] = new DragDropManager(instanceName);
			return (__instances[instanceName] as DragDropManager);
		}
		 
		public function destroy( instanceName:String = "_DEFAULT_" ): void
		{
			if ( !instanceName || __instances[instanceName] == undefined ) return;
			
			__instances[instanceName].close();
			__instances[instanceName] = null;
			delete __instances[instanceName];
		}
		
		/*
		 * PUBLIC API
		 */
		
		public function startDrag( dragItemData:Object, dragImage:*, dragImageAlpha:Number = 0.5 ): void
		{
			if ( _dragData || !dragItemData ) return;
			
			_dragData = dragItemData;
			for each( var i:DisplayObject in _registeredDisplays )
			{
				if ( i.hasEventListener(DragDropEvent.DRAG_START) )
				{
					i.dispatchEvent(new DragDropEvent(DragDropEvent.DRAG_START, _dragData));
				}
			}
			
			_overReference = new Dictionary();
			__startImageDrag( dragImage, dragImageAlpha );
		}
		
		public function registerForDragEvents( targetDisplay:InteractiveObject ): void
		{
			if ( !targetDisplay || !isNaN(indexOfDragDisplay(targetDisplay)) ) return;
			
			_registeredDisplays.push(targetDisplay);
			targetDisplay.addEventListener( MouseEvent.ROLL_OVER, __onMouseEvent, false, Number.MAX_VALUE );
			targetDisplay.addEventListener( MouseEvent.ROLL_OUT, __onMouseEvent, false, Number.MAX_VALUE );
			targetDisplay.addEventListener( MouseEvent.MOUSE_OVER, __onMouseEvent, false, Number.MAX_VALUE );
			targetDisplay.addEventListener( MouseEvent.MOUSE_OUT, __onMouseEvent, false, Number.MAX_VALUE );
		}
		
		public function unregisterForDragEvents( targetDisplay:InteractiveObject ): void
		{
			var displayIndex:Number = indexOfDragDisplay(targetDisplay);
			if ( isNaN(displayIndex) ) return;
			
			_registeredDisplays.splice(displayIndex, 1);
		}
		
		/*
		 * PRIVATE API
		 */
		
		private function __startImageDrag( displayImage:*, displayAlpha:Number = 0.5 ): void
		{
			if ( _dragImage ) return;
			
			var bitmap:BitmapData;
			if ( displayImage is DisplayObject )
			{
				bitmap = new BitmapData( displayImage.width, displayImage.height );
				bitmap.draw( displayImage );
			}else if ( displayImage is BitmapData )
			{
				bitmap = displayImage as BitmapData;
			}
			
			if ( bitmap )
			{
				_dragImage = new Bitmap(bitmap);
				_dragImage.alpha = displayAlpha;
				_dragImage.width = bitmap.width;
				_dragImage.height = bitmap.height;
				
				Display.STAGE.addChild(_dragImage);
				_dragTimer.start();
			}
		}
		
		private function __stopImageDrag(): void
		{
			if ( !_dragImage ) return;
			
			_dragTimer.stop();
			Display.STAGE.removeChild(_dragImage);
			_dragImage = null;
		}
		
		private function __stillHit( display:DisplayObject ): Boolean
		{
			if ( !display ) return false;
			var bHit:Boolean = display.hitTestPoint( Display.STAGE.mouseX, Display.STAGE.mouseY, true );
			return bHit;
		}
		
		/*
		 * PROTECTED API
		 */
		
		protected final function refreshDragImagePosition(): void
		{
			if ( !_dragImage ) return;
			_dragImage.x = Display.STAGE.mouseX - (_dragImage.width / 2);
			_dragImage.y = Display.STAGE.mouseY - (_dragImage.height / 2);
		}
		
		protected final function indexOfDragDisplay( targetDisplay:DisplayObject ): Number
		{
			if ( !targetDisplay || _registeredDisplays.length == 0 ) return NaN;
			
			var index:Number;
			for ( var i:Number = 0; i < _registeredDisplays.length; i++ )
			{
				if ( targetDisplay == _registeredDisplays[i] )
				{
					index == i;
					break;
				}
			}
			return index;
		}
		
		protected function exitDragState(): void
		{
			if ( !_dragData ) return;
			__stopImageDrag();
			_overReference = null;
			_dragData = null;
		}
		
		/*
		 * HANDLERS
		 */
		
		private function __onTimerEvent( event:Event ): void
		{
			refreshDragImagePosition();
		}
		
		private function __onMouseEvent( event:MouseEvent ): void
		{
			if ( !_dragData ) return;
			
			var dragEventType:String;
			if ( event.type == MouseEvent.MOUSE_UP )
			{
				dragEventType = DragDropEvent.DRAG_DROP;
				for each( var i:DisplayObject in _registeredDisplays )
				{
					if ( __stillHit(i) ) i.dispatchEvent(new DragDropEvent(dragEventType, _dragData));
				}
				exitDragState();
			}else{
				dragEventType = event.type == MouseEvent.ROLL_OVER || event.type == MouseEvent.MOUSE_OVER ? DragDropEvent.DRAG_OVER : DragDropEvent.DRAG_OUT;
				if ( dragEventType == DragDropEvent.DRAG_OVER && _overReference[event.currentTarget] != true || 
					 dragEventType == DragDropEvent.DRAG_OUT && _overReference[event.currentTarget] == true )
				{
					_overReference[event.currentTarget] = dragEventType == DragDropEvent.DRAG_OVER;
					EventDispatcher(event.currentTarget).dispatchEvent( new DragDropEvent(dragEventType, _dragData) );
				}
			}
		}
	}
}