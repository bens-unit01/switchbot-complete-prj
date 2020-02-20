package org.influxis.application.vidcollaborator.list 
{
	//Flash Classes
	import flash.events.Event;
	import flash.media.Camera;
	import flash.media.Microphone;
	import flash.geom.Rectangle;
	import flash.events.MouseEvent;
	
	//Influxis Classes
	import org.influxis.flotools.data.MediaSettings;
	import org.influxis.as3.display.Slider;
	import org.influxis.as3.core.Display;
	import org.influxis.as3.list.TwoLabelItem;
	import org.influxis.as3.utils.StringUtils;
	import org.influxis.as3.utils.SizeUtils;
	
	public class SettingsListItem extends TwoLabelItem
	{
		private static const CAM_TYPE:String = "cam";
		private static const MIC_TYPE:String = "mic";
		private static const QUALITY_TYPE:String = "quality";
		private static const EXIT_TYPE:String = "sessionExit";
		private static const VOLUME_TYPE:String = "volume";
		
		private var _mediaSettings:MediaSettings;
		private var _itemType:String;
		private var _volumeSlider:Slider;
		
		/*
		 * INIT API
		 */
		
		public function SettingsListItem(skinName:String): void
		{
			super(skinName);
			
			_mediaSettings = MediaSettings.getInstance();
			_mediaSettings.addEventListener( MediaSettings.INITIALIZED, __onMediaSettingsEvent );
			_mediaSettings.addEventListener( MediaSettings.CAMERA_CHANGE, __onMediaSettingsEvent );
			_mediaSettings.addEventListener( MediaSettings.MICROPHONE_CHANGE, __onMediaSettingsEvent );
			_mediaSettings.addEventListener( Event.CHANGE, __onMediaSettingsEvent );
		}
		
		/*
		 * PROTECTED API
		 */
		
		override protected function refreshDisplay():void 
		{
			//Set initial types and label
			_itemType = data.type;
			data.label = getLabelAt(_itemType + "Label");
			
			//Show volume only if this is volume type
			if( initialized ) _volumeSlider.visible = _itemType == VOLUME_TYPE;
			
			refreshSlotLabel();
			super.refreshDisplay();
		}
		
		override protected function stateChanged():void 
		{
			super.stateChanged();
			addChild(_volumeSlider);
			icon.visible = (_itemType != CAM_TYPE && Display.IS_MOBILE != true) && 
						   _itemType != EXIT_TYPE && 
						   _itemType != VOLUME_TYPE;
		}
		
		protected function refreshSlotLabel(): void
		{
			if ( !initialized || !_mediaSettings.initialized || 
				 _itemType == EXIT_TYPE || 
				 _itemType == VOLUME_TYPE || 
				 (_itemType == CAM_TYPE && Display.IS_MOBILE) ) return;
			
			var newLabel2:String;
			switch( _itemType )
			{
				case CAM_TYPE : 
					newLabel2 = _mediaSettings.camera.name;
					break;
				case MIC_TYPE : 
					newLabel2 = _mediaSettings.microphone.name;
					break;
				case QUALITY_TYPE : 
					newLabel2 = getLabelAt(_mediaSettings.currentPreset+"Label");
					break;
			}
			
			//Update label, measure, and size
			updateLabel2(newLabel2);
			label2.height = StringUtils.measureText( label2.text, label2.defaultTextFormat ).height;
			invalidateDisplayList();
		}
		
		/*
		 * HANDLERS
		 */
		
		private function __onMediaSettingsEvent( event:Event ): void
		{
			if ( (event.type == MediaSettings.CAMERA_CHANGE && _itemType == CAM_TYPE) || 
				 (event.type == MediaSettings.MICROPHONE_CHANGE && _itemType == MIC_TYPE) ||
				 (event.type == Event.CHANGE && _itemType == QUALITY_TYPE ) || 
				  event.type == MediaSettings.INITIALIZED ) refreshSlotLabel();
			
			if ( initialized && _itemType == VOLUME_TYPE && event.type == MediaSettings.INITIALIZED )
			{
				_volumeSlider.value = _mediaSettings.gain;
			}
		}
		
		private function __onSliderEvent( event:Event ): void
		{
			_mediaSettings.gain = Math.floor(_volumeSlider.value);
		}
		
		private function __onItemDownEvent( event:Event ): void
		{
			if ( _itemType == CAM_TYPE )
			{
				_mediaSettings.cameraIndex = _mediaSettings.cameraIndex == 0 ? 1 : 0;
			}
		}
		
		/*
		 * DISPLAY API
		 */
		
		override protected function createChildren():void 
		{
			super.createChildren();
			
			_volumeSlider = new Slider();
			_volumeSlider.skinName = "volumeGainSlider";
			_volumeSlider.visible = false;
			addChild(_volumeSlider);
		}
		 
		override protected function childrenCreated():void 
		{
			super.childrenCreated();
			
			//Icon2 only visible to top 2 items
			icon.visible = (_itemType != CAM_TYPE && Display.IS_MOBILE != true) && 
						   _itemType != EXIT_TYPE && 
						   _itemType != VOLUME_TYPE;
			
			//Set volume props
			_volumeSlider.drawHighlightFromValue = true;
			_volumeSlider.visible = _itemType == VOLUME_TYPE;
			_volumeSlider.minimum = 0; _volumeSlider.maximum = 100;
			_volumeSlider.addEventListener( Event.CHANGE, __onSliderEvent );
			if ( _mediaSettings.initialized ) _volumeSlider.value = _mediaSettings.gain;
			
			//Only in mobile mode
			if ( Display.IS_MOBILE ) addEventListener( MouseEvent.MOUSE_DOWN, __onItemDownEvent );
		}
		
		override protected function arrange(): void 
		{
			super.arrange();
			
			//if ( _volumeSlider.visible )
			//{
				_volumeSlider.setActualSize( width - (paddingLeft+label.width+(innerPadding*3)), height-(paddingTop+paddingBottom) );
				SizeUtils.moveX( _volumeSlider, width, SizeUtils.RIGHT, paddingRight );
				_volumeSlider.y = paddingTop;
			//}	
		}
	}
}