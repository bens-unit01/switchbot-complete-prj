package org.influxis.as3.containers 
{
	//Influxis Classes
	import org.influxis.as3.display.StyleCanvas;
	import org.influxis.as3.display.ScrollBar;
	
	public class ScrollBase extends StyleCanvas
	{
		protected var scrollerV:ScrollBase;
		protected var scrollerH:ScrollBase;
		
		/**
		 * PROTECTED API
		 */
		
		override protected function createChildren():void 
		{
			super.createChildren();
			
			_scrollerV = new ScrollBar();
			_scrollerH = new ScrollBar();
			
			addChildren( _scrollerV, _scrollerH );
		}
		
		override protected function arrange():void 
		{
			super.arrange();
			
			
		}
	}

}