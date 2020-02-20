package org.influxis.mobile.managers 
{
	//Flash Classes
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.display.StageOrientation;
	import flash.events.StageOrientationEvent;
	import flash.display.Stage;
	//import org.influxis.as3.display.DisplayDebugger;
	
	//Influxis Classes
	import org.influxis.as3.core.Display;
	
	public class ScreenManager extends EventDispatcher
	{
		public static const PORTRAIT:String = "portrait";
		public static const LANDSCAPE:String = "landscape";
		public static const AUTO:String = "auto";
		
		private static var __screen:ScreenManager;
		private static var __landScapeReverse:Boolean;
		private static var __landScapeInitialized:Boolean;
		private var _orientation:String;
		
		/*
		 * INIT API
		 */
		
		public function ScreenManager(): void
		{
			if ( !__landScapeInitialized )
			{
				__landScapeInitialized = true;
				if ( Display.STAGE.orientation == StageOrientation.UPSIDE_DOWN || Display.STAGE.orientation == StageOrientation.DEFAULT )
				{
					__landScapeReverse = Display.STAGE.fullScreenWidth > Display.STAGE.fullScreenHeight;	
				}else{
					__landScapeReverse = Display.STAGE.fullScreenWidth < Display.STAGE.fullScreenHeight;	
				}
			}
			Display.STAGE.addEventListener( StageOrientationEvent.ORIENTATION_CHANGING, __onOrientationChanging );
		}
		
		/*
		 * STATIC API
		 */
		
		public static function getInstance(): ScreenManager
		{
			if ( !__screen ) __screen = new ScreenManager();
			return __screen;
		}
		 
		/*
		 * PUBLIC API
		 */
		
		public function forceOrientation( value:String ): void
		{
			//DisplayDebugger.tracer( "forceOrientation: " + value+" : "+_orientation );
			if ( _orientation == value ) return;
			
			if ( value == AUTO || (value == PORTRAIT && isPortraitView) || (value == LANDSCAPE && !isPortraitView) )
			{
				_orientation = value;
				return;
			}
			
			Display.STAGE.setOrientation( value == PORTRAIT ? (__landScapeReverse?StageOrientation.ROTATED_RIGHT:StageOrientation.DEFAULT) : (__landScapeReverse?StageOrientation.DEFAULT:StageOrientation.ROTATED_RIGHT) );
			_orientation = value;
		}
		
		/*
		 * PROTECTED API
		 */
		
		protected final function checkIsPortrait( value:String ): Boolean
		{
			return __landScapeReverse ? (value == StageOrientation.ROTATED_RIGHT || value == StageOrientation.ROTATED_LEFT) : (value == StageOrientation.UPSIDE_DOWN || value == StageOrientation.DEFAULT); 
		}
		 
		/*
		 * HANDLERS
		 */
		
		private function __onOrientationChanging( event:StageOrientationEvent ): void 
		{
			//DisplayDebugger.tracer( "__onOrientationChanging: " + _orientation + " : " + event.afterOrientation + " : " + checkIsPortrait(event.afterOrientation)+" : "+__landScapeReverse );
			if ( _orientation == AUTO ) return;
			
			if ( _orientation == PORTRAIT && !checkIsPortrait(event.afterOrientation) || _orientation == LANDSCAPE && checkIsPortrait(event.afterOrientation) ) 
			{
				event.preventDefault();
			}
		}
		
		/*
		 * GETTER / SETTER API
		 */
		
		public function get isPortraitView(): Boolean
		{
			return checkIsPortrait(Display.STAGE.orientation); 
		}
	}
}