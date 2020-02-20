/**
 * SimpleMediaControls - Copyright © 2010 Influxis All rights reserved.
**/

package org.influxis.as3.display 
{
	//Flash Classes
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	
	//Influxis Classes
	import org.influxis.as3.display.simplemediacontrolsclasses.SimpleMediaControlsBase;
	import org.influxis.as3.display.Slider;
	import org.influxis.as3.states.PositionStates;
	import org.influxis.as3.utils.doTimedLater;
	import org.influxis.as3.managers.SkinsManager;
	import org.influxis.as3.skins.SkinElement;
	
	public class SimpleMediaControls extends SimpleMediaControlsBase
	{
		private var _sVersion:String = "1.0.0.0";
		
		/**
		 * STYLE API
		 */
		
		private static var STYLE_CONSTRUCTED:Boolean;
		protected function styleConstruct(): void
		{
			if ( STYLE_CONSTRUCTED ) return;
			
			STYLE_CONSTRUCTED = true;
			var sk:SkinsManager = SkinsManager.getInstance();
			if ( !sk.exists(className) )
			{
				var oSkins:Object = 
				{
					background:
					{
						backgroundColor: 0xffffff
					},
					volumeBackground:
					{
						backgroundColor: 0xffffff
					},
					timeLabel:
					{
						font:"arial",
						bold:true
					}
				}
				sk.setSkinElement( className, SkinElement.getInstance(className, oSkins), true );
			}
		}
		
		/**
		 * DISPLAY API
		 */
		
		private function __setupDefaults(): void 
		{
			var volumeScrubber:Slider = cbVolumeScrubber as Slider;
				volumeScrubber.direction = PositionStates.UP;
				volumeScrubber.maximum = 100;
				volumeScrubber.value = volume;
				volumeScrubber.width = 15;
		}
		
		protected function setTimeLabelProps(): void
		{
			if ( styleExists("timeLabel") )
			{
				var t:TextField = lTime as TextField;
					t.defaultTextFormat = getTextFormat("timeLabel");
					t.embedFonts = embeddedFontExists(t.defaultTextFormat.font);
					t.selectable = false;
					updateClock();
					//t.width = t.textWidth+3;
					//t.autoSize = TextFieldAutoSize.CENTER;
			}
		}
		
		override protected function createChildren(): void
		{
			cbBackground = getStyleGraphic( "background" );
			cbBigPlay = getStyleGraphic( "bigPlay" );
			cbPlay = getStyleGraphic( "play" );
			cbPause = getStyleGraphic( "pause" );
			cbRewind = getStyleGraphic( "rewind" );
			cbStop = getStyleGraphic( "stop" );
			cbMuted = getStyleGraphic( "mute" );
			cbVolume = getStyleGraphic( "volume" );
			cbFullScreenOn = getStyleGraphic( "fullscreenOn" );
			cbFullScreenOff = getStyleGraphic( "fullscreen" );
			cbVolumeScrubberBG = getStyleGraphic( "volumeBackground" );
			cbBuffer = getStyleGraphic( "buffer" );
			
			cbScrubber = new Slider();
			lTime = new TextField();
			
			var volumeScrubber:Slider = new Slider();
				volumeScrubber.skinName = "volumeScrubber";
			
			cbVolumeScrubber = volumeScrubber;
			doTimedLater( 1000, __setupDefaults );
			
			addChild( cbBackground ); addChild( cbPlay ); 
			addChild( cbPause ); addChild( cbRewind ); 
			addChild( cbStop ); addChild( cbMuted ); 
			addChild( cbVolume ); addChild( cbFullScreenOn ); 
			addChild( cbFullScreenOff ); addChild( cbScrubber );
			addChild( cbBigPlay ); addChild( cbBuffer );
			addChild( cbVolumeScrubberBG ); addChild( cbVolumeScrubber ); 
			addChild( lTime );
			
			updateClock();
			updateDisplayStates();
			registerEvents();
			setTimeLabelProps();
		}
		
		override protected function arrange(): void 
		{
			if( cbPlay ) super.arrange();
		}
	}
}