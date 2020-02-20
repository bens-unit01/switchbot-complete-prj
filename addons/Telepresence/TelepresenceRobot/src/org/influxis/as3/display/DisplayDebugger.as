package org.influxis.as3.display 
{
	//Flash Classes
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	//Influxis Classes
	import org.influxis.as3.core.Display;
	import org.influxis.as3.states.SizeStates;
	import org.influxis.as3.utils.doTimedLater;
	import org.influxis.as3.display.SimpleComponent;
	import org.influxis.as3.utils.ScreenScaler;
	
	public class DisplayDebugger
	{
		private static var _debugText:TextField;
		private static var _sDebuggerCache:String = "";
		private static var _bChecking:Boolean;
		
		/**
		 * PUBLIC API
		 */
		
		public static function tracer( ...args ): void
		{
			if ( !args ) return;
			
			_sDebuggerCache += (args as Array).join( " " ) + "\n";
			if ( _debugText )
			{
				_debugText.text = _sDebuggerCache;
				//_sDebuggerCache = "";
			}else if ( !_bChecking )
			{
				_bChecking = true;
				__checkApp();
			}
		}
		 
		/**
		 * HANDLERS
		 */
		
		private static function __onAppResize( event:Event = null ): void
		{
			var mainApp:SimpleComponent = Display.APPLICATION as SimpleComponent;
			if ( mainApp )
			{
				_debugText.width = mainApp.width;// - (mainApp.width / 3);
				_debugText.height = ScreenScaler.calculateSize(300);//mainApp.height - 
				_debugText.y = ScreenScaler.calculateSize(300);
				//trace( "__onAppResize: " + mainApp.width, mainApp.height );
			}
		}
		 
		/**
		 * PRIVATE API
		**/
		
		private static function __checkApp(): void
		{
			var mainApp:SimpleComponent;
			var app:SimpleComponent = Display.APPLICATION as SimpleComponent;
			if ( app )
			{
				if ( app.initialized ) mainApp = app;
			}
			
			if ( mainApp )
			{
				_debugText = new TextField();
				_debugText.defaultTextFormat = new TextFormat( "arial", "11", 0xcccccc );
				_debugText.addEventListener( MouseEvent.MOUSE_DOWN, function( event:Event ): void
				{
					_debugText.text = _sDebuggerCache = "";
				});
				if ( _sDebuggerCache ) _debugText.text = _sDebuggerCache;
				
				mainApp.addChild( _debugText );
				__onAppResize();
				mainApp.addEventListener( SizeStates.RESIZE, __onAppResize );
			}else {
				doTimedLater( 1000, __checkApp );
			}
		}
	}

}