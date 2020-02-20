/**
 * Application - Copyright © 2010 Influxis All rights reserved.
**/

package org.influxis.as3.core 
{
	//Flash Classes
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	import flash.events.Event;
	
	//Influxis Classes
	import org.influxis.as3.core.infx_internal;
	import org.influxis.as3.core.Display;
	import org.influxis.as3.display.StyleCanvas;
	import org.influxis.as3.utils.FlashDetection;
	
	public class Application extends StyleCanvas
	{
		use namespace infx_internal;
		private var _bStageAutoSize:Boolean = true;
		protected var requiredFlashVersion:String = "10.1";
		
		/**
		 * INIT API
		 */
		
		override protected function preInitialize():void 
		{
			if ( !Display.APPLICATION ) Display.APPLICATION = this;
			
			//Set stage to no scale with top left position
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			//Check if custom settings path exists
			var params:Object = (Display.ROOT.loaderInfo).parameters;
			if ( params )
			{
				if ( params.requiredFlashVersion != undefined ) requiredFlashVersion = params.requiredFlashVersion;
			}
			
			//Check required flash version
			if ( !FlashDetection.checkRequiredVersion(requiredFlashVersion) )
			{
				//Forces the framework to init
				infx_internal::__setInitialize();
				
				//Attach alert and show
				FlashDetection.wrongVersionAlert(this);
				visible = true;
				return;
			}
			
			super.preInitialize();
		}
		
		override protected function init(): void
		{
			super.init();
			
			stage.addEventListener( Event.RESIZE, __onMainStageResize );
			if ( stageAutoSize ) __onMainStageResize( new Event(Event.RESIZE) );
		}
		
		/**
		 * HANDLERS
		 */
		
		private function __onMainStageResize( p_e:Event ): void 
		{
			if( stageAutoSize ) setActualSize( stage.stageWidth, stage.stageHeight );
		}
		
		/**
		 * GETTER / SETTER
		 */
		
		public function set stageAutoSize( value:Boolean ): void
		{
			_bStageAutoSize = value;
		}
		
		public function get stageAutoSize(): Boolean
		{ 
			return _bStageAutoSize; 
		}
	}
}