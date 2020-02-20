package org.influxis.as3.interfaces.display 
{
	//Flash Classes
	import flash.events.IEventDispatcher;
	
	//Events
	[Event(name = "infxResize", type = "flash.events.Event")]
	[Event(name = "infxMove", type = "flash.events.Event")]
	
	public interface ISimpleSprite extends IEventDispatcher
	{
		function setActualSize( w:Number, h:Number, omitEvent:Boolean = false ): void;
		function move( x:Number, y:Number, omitEvent:Boolean = false ): void;
		
		function set visible( value:Boolean ): void;
		function get visible(): Boolean;
		
		function set width( value:Number ): void;
		function get width(): Number;
		
		function set height( value:Number ): void;
		function get height(): Number;
		
		function set minWidth( value:Number ): void;
		function get minWidth(): Number;
		
		function set minHeight( value:Number ): void;
		function get minHeight(): Number;
		
		function set maxWidth( value:Number ): void;
		function get maxWidth(): Number;
		
		function set maxHeight( value:Number ): void;
		function get maxHeight(): Number;
		
		function set measuredWidth( value:Number ): void;
		function get measuredWidth(): Number;
		
		function set measuredHeight( value:Number ): void;
		function get measuredHeight(): Number;
		
		function set minX( value:Number ): void;
		function get minX(): Number
		
		function set minY( value:Number ): void;
		function get minY(): Number;
		
		function set maxX( value:Number ): void;
		function get maxX(): Number;
		
		function set maxY( value:Number ): void;
		function get maxY(): Number;
		
		function set x( value:Number ): void;
		function get x(): Number;
		
		function set y( value:Number ):void;
		function get y(): Number;
		
		function set percentWidth( value:Number ): void;
		function get percentWidth(): Number;
		
		function set percentHeight( value:Number ): void;
		function get percentHeight(): Number;
		
		function hook( target:ISimpleSprite, container:ISimpleSprite = null, position:String = null, align:String = null, inner:Boolean = false, padding:int = 0 ): void;
		function updateHook( position:String = null, align:String = null, inner:Boolean = false, padding:int = 0 ): void;
		function get hookTarget(): ISimpleSprite;
	}
}