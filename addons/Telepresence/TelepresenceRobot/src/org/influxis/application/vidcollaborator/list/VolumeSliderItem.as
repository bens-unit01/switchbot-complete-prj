package org.influxis.application.vidcollaborator.list 
{
	//Flash Classes
	import flash.events.Event;
	
	//Influxis Classes
	import org.influxis.as3.display.StyleCanvas;
	import org.influxis.as3.display.Slider;
	import org.influxis.as3.display.ProgressBar;
	import org.influxis.as3.utils.ScreenScaler;
	
	//Influxis Flotools
	import org.influxis.flotools.data.MediaSettings;
	
	public class VolumeSliderItem extends StyleCanvas
	{
		private var _mediaSettings:MediaSettings;
		private var _volume:Slider;
		
		/*
		 * PUBLIC API
		 */
		
		public function VolumeSliderItem(): void
		{
			super();
			_mediaSettings = MediaSettings.getInstance();
			_mediaSettings.addEventListener( MediaSettings.INITIALIZED, __onMediaSettingsEvent );
		}
		
		/*
		 * HANDLERS
		 */
		
		private function __onMediaSettingsEvent( event:Event ): void
		{
			switch ( event.type ) 
			{
				case MediaSettings.INITIALIZED :
					if( initialized ) _volume.value = _mediaSettings.gain;
					break;
			}
		}
		
		private function __onMediaSettingsEvent( event:Event ): void
		{
			_mediaSettings.gain = _volume.value;
		}
		
		/*
		 * DISPLAY API
		 */
		
		override protected function measure():void 
		{
			super.measure();
			measuredWidth = ScreenScaler.calculateSize(100) + paddingLeft + paddingRight;
			measuredHeight = _volume.measuredHeight + paddingBottom + paddingTop;
		}
		 
		override protected function childrenCreated(): void 
		{
			super.childrenCreated();
			_volume = new Slider();
			_volume.skinName = "volumeGainSlider";
			addChild(_volume);
		}
		
		override protected function childrenCreated(): void 
		{
			super.childrenCreated();
			_volume.minimum = 0; _volume.maximum = 100;
			_volume.addEventListener( Event.CHANGE, __onSliderEvent );
			if ( _mediaSettings.initialized ) _volume.value = _mediaSettings.gain;
		}
		
		override protected function arrange():void 
		{
			super.arrange();
			_volume.move( paddingLeft, paddingRight );
			_volume.setActualSize( width-(paddingLeft+paddingRight), height-(paddingTop+paddingBottom) );
		}
	}
}