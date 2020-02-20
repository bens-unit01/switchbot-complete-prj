package org.influxis.as3.display 
{
	//Flash Classes
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.ProgressEvent;
	
	//Influxis Classes
	import org.influxis.as3.display.StyleCanvas;
	
	public class ProgressBar extends StyleCanvas
	{
		private var _source:Object;
		private var _highlight:DisplayObject;
		private var _mask:Sprite;
		
		/*
		 * PROTECTED API
		 */
		
		protected function onSourceChanged( value:Object ): void
		{
			if ( _source )
			{
				_source.removeEventListener( ProgressEvent.PROGRESS, __onProgressEvent );
				_source = null;
			}
			
			_source = value;
			if ( _source ) _source.addEventListener( ProgressEvent.PROGRESS, __onProgressEvent );
			drawHighlight();
		}
		 
		protected function drawHighlight(): void
		{
			var maskWidth:Number = !_source?0:((width / bytesTotal) * bytesLoaded);
			_mask.graphics.beginFill(0, 0);
			_mask.graphics.drawRect(0, 0, (isNaN(maskWidth)?0:maskWidth), (!_source?0:height));
			_mask.graphics.endFill();
		}
		
		/*
		 * HANDLERS
		 */
		
		private function __onProgressEvent( event:ProgressEvent ): void
		{
			drawHighlight();
		}
		 
		/*
		 * DISPLAY API
		 */
		
		override protected function createChildren(): void 
		{
			super.createChildren();
			_highlight = getStyleGraphic("highlight");
			_highlight.mask = _mask = new Sprite();
			addChildren(_highlight, _mask);
		}
		
		override protected function arrange():void 
		{
			super.arrange();
			_highlight.width = width;
			_highlight.height = height;
			drawHighlight();
		}
		
		/*
		 * GETTER / SETTER
		 */
		
		public function set source( value:Object ): void
		{
			if ( _source == value ) return;
			onSourceChanged(value);
		}
		
		public function get source(): Object
		{
			return _source;
		}
		
		public function get bytesLoaded(): Number
		{
			var nResult:Number;
			try {
				nResult = isNaN(_source.bytesLoaded) ? 0 : _source.bytesLoaded;
			}catch (e:Error)
			{
				nResult = 0;
			}
			return nResult;
		}
		
		public function get bytesTotal(): Number
		{
			var nResult:Number;
			try {
				nResult = isNaN(_source.bytesTotal) ? 0 : _source.bytesTotal;
			}catch (e:Error)
			{
				nResult = 0;
			}
			return nResult;
		}
	}
}