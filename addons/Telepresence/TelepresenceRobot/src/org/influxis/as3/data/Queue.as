package org.influxis.as3.data 
{
	//Flash Classes
	import flash.events.Event;
	import flash.utils.getQualifiedClassName;
	
	//Influxis Classes
	import org.influxis.as3.data.DataProvider;
	
	[Event(name = "indexChange", type = "flash.events.Event")]
	[Event(name = "firstIndex", type = "flash.events.Event")]
	[Event(name = "lastIndex", type = "flash.events.Event")]
	
	public class Queue extends DataProvider
	{
		public static const FIRST_INDEX:String = "firstIndex";
		public static const LAST_INDEX:String = "lastIndex";
		public static const INDEX_CHANGE:String = "indexChange";
		
		public static var DEBUG:Boolean = false;
		
		private var _activeIndex:uint;
		private var _activeItem:Object;
		private var _bAutoRewind:Boolean;
		private var _bAutoForward:Boolean;
		
		/**
		 * INIT API
		 */
		
		public function Queue() 
		{
			clear();
		}
		
		/**
		 * PUBLIC API
		 */
		
		override public function clear( omitEvent:Boolean = false ): void
		{
			_activeItem = null;
			_activeIndex = 0;
			
			//Call super to clear data
			super.clear(omitEvent);
		}
		
		public function next(): Object
		{
			var newIndex:int = _activeIndex + 1;
			setIndex( newIndex == length ? _bAutoRewind ? 0 : _activeIndex : newIndex );
			return _activeItem;
		}
		
		public function previous(): Object
		{
			var len:int = length == 0 ? 0 : length - 1;
			var newIndex:int = _activeIndex - 1;
			setIndex( newIndex < 0 ? _bAutoForward ? len : 0 : newIndex );
			return _activeItem;
		}
		
		public function rewind(): Object
		{
			setIndex(0);
			return _activeItem;
		}
		
		public function last(): Object
		{
			setIndex( length - 1 );
			return _activeItem;
		}
		
		public function seek( value:uint ): Object
		{
			setIndex(value);
			return _activeItem;
		}
		
		/**
		 * PROTECTED API
		 */
		
		protected function setCurrent(): void
		{
			if( _data ) _activeItem = _data[_activeIndex];
		}
		
		protected function setIndex( value:uint ): void
		{
			var len:int = length == 0 ? 0 : length - 1;
			
			var newIndex:uint = value > len ? len : value;
			if( newIndex == _activeIndex )
			
			_activeIndex = newIndex;
			setCurrent();
			dispatchEvent( new Event(INDEX_CHANGE) );
			if ( _activeIndex == 0 )
			{
				dispatchEvent( new Event(FIRST_INDEX) );
			}else if (_activeIndex == len)
			{
				dispatchEvent( new Event(LAST_INDEX) );
			}
		}
		
		/**
		 * GETTER / SETTER
		 */
		
		override public function set source( value:Vector.<Object> ):void 
		{
			super.source = value;
			setCurrent();
		}
		
		public function get currentItem(): Object
		{
			return _activeItem;
		}
		
		public function get currentIndex(): void
		{
			return _activeIndex;
		}
		
		public function set autoRewind( value:Boolean ):void 
		{
			_bAutoRewind = value;
		}
		
		public function get autoRewind() 
		{ 
			return _bAutoRewind; 
		}
		
		public function set autoForward( value:Boolean ):void 
		{
			_bAutoForward = value;
		}
		
		public function get autoForward() 
		{ 
			return _bAutoForward; 
		}
		
		/** 
		 * DEBUGGER 
		**/
		
		private function tracer( ...args ) : void
		{
			if( DEBUG ) trace("##" + getQualifiedClassName(this) + "##  "+args);
		}
	}
}