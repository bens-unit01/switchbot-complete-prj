package org.influxis.application.vidcollaborator.display.videocollaboratorclasses.collabcontrolsclasses 
{
	//Flash Classes
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.media.Camera;
	import flash.media.Microphone;
	
	//Influxis Classes
	import org.influxis.as3.display.List;
	import org.influxis.as3.display.Label;
	import org.influxis.as3.core.Display;
	import org.influxis.as3.events.SimpleEvent;
	import org.influxis.as3.display.StyleComponent;
	import org.influxis.as3.list.IconLabelItem;
	import org.influxis.as3.utils.ScreenScaler;
	import org.influxis.as3.utils.SizeUtils;
	import org.influxis.as3.states.SizeStates;
	import org.influxis.as3.list.ItemStates;
	import org.influxis.as3.managers.SelectionManager;
	
	//Flotools Classes
	import org.influxis.flotools.data.MediaSettings;
	
	//VidCollaborator Classes
	import org.influxis.application.vidcollaborator.list.SettingsListItem;
	
	public class SettingsUI extends StyleComponent
	{
		private static var _SETTINGS_LIST_ITEMS_:Array;
		
		private static const _CAM_TYPE_:Object = "cam";
		private static const _MIC_TYPE_:Object = "mic";
		private static const _QUALITY_TYPE_:Object = "quality";
		private static const _EXIT_TYPE_:Object = "sessionExit";
		private static const _VOLUME_TYPE_:Object = "volume";
		
		private static const _SETTINGS_LIST_ITEM_CAM_:Object = {type:_CAM_TYPE_};
		private static const _SETTINGS_LIST_ITEM_MIC_:Object = {type:_MIC_TYPE_};
		private static const _SETTINGS_LIST_ITEM_QUALITY_:Object = {type:_QUALITY_TYPE_};
		private static const _SETTINGS_LIST_ITEM_EXIT_:Object = {type:_EXIT_TYPE_};
		private static const _SETTINGS_LIST_ITEM_VOLUME_:Object = {type:_VOLUME_TYPE_};
		
		private var _includeExit:Boolean;
		private var _mediaSettings:MediaSettings;
		private var _camUseMeasured:Boolean;
		private var _micUseMeasured:Boolean;
		private var _qualityUseMeasured:Boolean;
		private var _lastListDisplayed:DisplayObject;
		private var _adminMode:Boolean;
		
		//UI Displays
		private var _background:DisplayObject;
		private var _settingsList:List;		
		private var _camsList:List;
		private var _micList:List;
		private var _qualityList:List;
		private var _lSettings:Label;
		private var _settingsIcon:DisplayObject;
		
		/*
		 * INIT API
		 */
		
		public function SettingsUI(): void
		{
			//Default list items
			_SETTINGS_LIST_ITEMS_ = Display.IS_MOBILE ? [_SETTINGS_LIST_ITEM_CAM_] : [_SETTINGS_LIST_ITEM_CAM_, _SETTINGS_LIST_ITEM_MIC_];
			if ( _adminMode ) _SETTINGS_LIST_ITEMS_.push( _SETTINGS_LIST_ITEM_QUALITY_ );
			
			//Volume is a must for both parties
			_SETTINGS_LIST_ITEMS_.push( _SETTINGS_LIST_ITEM_VOLUME_ );
			
			//Only include exit when needed
			if ( _includeExit ) _SETTINGS_LIST_ITEMS_.push( _SETTINGS_LIST_ITEM_EXIT_ );
			
			super();
			
			//Init media settings instance to grab info (cam,mic,quality)
			_mediaSettings = MediaSettings.getInstance();
			_mediaSettings.addEventListener( MediaSettings.INITIALIZED, __onMediaSettingsChanged );
		}
		
		/*
		 * PROTECTED API
		 */
		
		//Load sub list for cams and mics
		protected function loadSubLists(): void
		{
			if ( !initialized || !_mediaSettings.initialized ) return;
			
			var nLen:Number; var i:Number;
			var camLists:Array = new Array();
			nLen = Camera.names.length;
			for ( i = 0; i < nLen; i++ )
			{
				camLists.push({label:Camera.names[i]});
			}
			
			var micLists:Array = new Array();
			nLen = Microphone.names.length;
			for ( i = 0; i < nLen; i++ )
			{
				micLists.push({label:Microphone.names[i]});
			}
			
			var qualityLists:Array = new Array({label:getLabelAt("autoLabel")});
			var selectedQuality:Number;
			nLen = _mediaSettings.presets.length;
			for ( i = 0; i < nLen; i++ )
			{
				if ( !_mediaSettings.autoMode && _mediaSettings.presets[i] == _mediaSettings.currentPreset ) selectedQuality = i+1;
				qualityLists.push({label:getLabelAt(_mediaSettings.presets[i]+"Label"), value:_mediaSettings.presets[i]});
			}
			
			//Input sources
			_camsList.source = camLists;
			_micList.source = micLists;
			_qualityList.source = qualityLists;
			
			//Set selected presets
			_camsList.selectedIndex = _mediaSettings.cameraIndex;
			_micList.selectedIndex = _mediaSettings.microphoneIndex;
			_qualityList.selectedIndex = _mediaSettings.autoMode ? 0 : selectedQuality;
		}
		
		protected function onAdminModeChanged( value:Boolean ): void
		{
			if ( _adminMode == value ) return;
			_adminMode = value;
			refreshListItems();
		}
		
		protected function refreshListItems(): void
		{
			_SETTINGS_LIST_ITEMS_ = Display.IS_MOBILE ? [_SETTINGS_LIST_ITEM_CAM_] : [_SETTINGS_LIST_ITEM_CAM_, _SETTINGS_LIST_ITEM_MIC_];
			if ( _adminMode ) _SETTINGS_LIST_ITEMS_.push( _SETTINGS_LIST_ITEM_QUALITY_ );
			_SETTINGS_LIST_ITEMS_.push( _SETTINGS_LIST_ITEM_VOLUME_ );
			if ( _includeExit ) _SETTINGS_LIST_ITEMS_.push( _SETTINGS_LIST_ITEM_EXIT_ );
			if ( initialized ) _settingsList.source = _SETTINGS_LIST_ITEMS_;
		}
		
		/*
		 * HANDLERS
		 */
		
		//Once we have lists measurements decide which actual sizing to use
		private function __onListSized( event:Event ): void
		{
			switch( event.currentTarget )
			{
				case _settingsList : 
					_camUseMeasured = _camsList.measuredHeight <= _settingsList.measuredHeight;
					_micUseMeasured = _micList.measuredHeight <= _settingsList.measuredHeight;
					measuredHeight = _lSettings.height + _settingsList.measuredHeight + paddingTop + innerPadding;
					_qualityUseMeasured = _qualityList.measuredHeight <= _settingsList.measuredHeight;
					break;
				case _camsList : 
					_camUseMeasured = _camsList.measuredHeight <= _settingsList.measuredHeight;
					invalidateDisplayList();
					break;
				case _micList : 
					_micUseMeasured = _micList.measuredHeight <= _settingsList.measuredHeight;
					invalidateDisplayList();
					break;
				case _qualityList : 
					_qualityUseMeasured = _qualityList.measuredHeight <= _settingsList.measuredHeight;
					invalidateDisplayList();
					break;
			}
		}
		
		private function __onMediaSettingsChanged( event:Event ): void
		{
			if ( event.type == MediaSettings.INITIALIZED ) 
			{
				loadSubLists();
			}
		}
		
		private function __onSettingsListItemEvent( event:SimpleEvent ): void
		{
			var itemOverEvent:Boolean;
			switch( event.type )
			{
				case ItemStates.ITEM_CLICK : 
					if ( _settingsList.selectedItem.type == _EXIT_TYPE_ ) dispatchEvent(new Event(Event.CLOSE));
					break;
				case ItemStates.ITEM_ROLL_OVER : 
					if ( _lastListDisplayed ) _lastListDisplayed.visible = false;
					if ( event.data < 2 || _SETTINGS_LIST_ITEMS_[event.data].type == _QUALITY_TYPE_ )
					{
						if ( _SETTINGS_LIST_ITEMS_[event.data].type == _EXIT_TYPE_ ) return;
						_lastListDisplayed = event.data == 0 ? _camsList : event.data == 1 ? _micList : _qualityList;
						_lastListDisplayed.visible = true;
					}else{
						//In case I add support for other items here
					}
					break;
				case ItemStates.ITEM_DOWN : 
					if ( _lastListDisplayed ) _lastListDisplayed.visible = false;
					if ( _SETTINGS_LIST_ITEMS_[event.data].type == _QUALITY_TYPE_ )
					{
						if ( _SETTINGS_LIST_ITEMS_[event.data].type == _EXIT_TYPE_ ) return;
						_lastListDisplayed = _qualityList;
						_lastListDisplayed.visible = true;
					}else{
						//In case I add support for other items here
					}
					break;
			}
			
		}
		
		private function __onListItemSelection( event:Event ): void
		{
			var currentList:List = event.currentTarget as List;
			//trace("__onListItemSelection: " + (event.currentTarget == _qualityList), (currentList == _qualityList) );
			if ( event.currentTarget == _camsList )
			{
				_mediaSettings.cameraIndex = currentList.selectedIndex;
			}else if ( event.currentTarget == _micList )
			{
				_mediaSettings.microphoneIndex = currentList.selectedIndex;
			}else if ( event.currentTarget == _qualityList )
			{
				//trace("__onListItemSelection2: " + currentList.selectedIndex, currentList.selectedItem.value );
				_mediaSettings.autoMode = currentList.selectedIndex == 0;
				if ( currentList.selectedIndex > 0 ) _mediaSettings.loadPreset( currentList.selectedItem.value );
			}
		}
		
		/*
		 * DISPLAY API
		 */
		
		override protected function measure():void 
		{
			super.measure();
			measuredWidth = ScreenScaler.calculateSize(250);
			measuredHeight = _lSettings.height + _settingsList.measuredHeight + paddingTop + innerPadding;
		}
		 
		override protected function createChildren():void 
		{
			super.createChildren();
			
			_background = getStyleGraphic("background");
			_settingsIcon = getStyleGraphic("settingsIcon");
			_lSettings = new Label( skinName, "settingsLabel", "settingsLabel" );
			
			_settingsList = new List();
			_settingsList.skinName = "settingsList";
			_settingsList.cellRenderer = SettingsListItem;
			_settingsList.toggle = false;
			
			_camsList = new List();
			_camsList.skinName = "settingsSubList";
			_camsList.cellRenderer = IconLabelItem;
			
			_micList = new List();
			_micList.skinName = "settingsSubList";
			_micList.cellRenderer = IconLabelItem;
			
			_qualityList = new List();
			_qualityList.skinName = "settingsSubList";
			_qualityList.cellRenderer = IconLabelItem;
			
			addChildren( _background, _settingsIcon, _lSettings, 
						 _settingsList, _camsList, _micList, _qualityList );
		}
		
		override protected function childrenCreated(): void 
		{
			super.childrenCreated();
			
			//Feed main list content and listen for sizing
			_settingsList.source = _SETTINGS_LIST_ITEMS_;
			
			//Need to find out when these list get measured
			_settingsList.addEventListener( SizeStates.MEASURE_HEIGHT, __onListSized );
			_camsList.addEventListener( SizeStates.MEASURE_HEIGHT, __onListSized );
			_micList.addEventListener( SizeStates.MEASURE_HEIGHT, __onListSized );
			_qualityList.addEventListener( SizeStates.MEASURE_HEIGHT, __onListSized );
			
			//Need to detect main list rollovers to display sub menus
			if ( Display.IS_MOBILE )
			{
				_settingsList.addEventListener( ItemStates.ITEM_DOWN, __onSettingsListItemEvent );
				_settingsList.addEventListener( ItemStates.ITEM_DOWN, __onSettingsListItemEvent );
			}else{
				_settingsList.addEventListener( ItemStates.ITEM_ROLL_OVER, __onSettingsListItemEvent );
				_settingsList.addEventListener( ItemStates.ITEM_CLICK, __onSettingsListItemEvent );
			}
			
			
			
			//Detect item clicks for sub menu
			_camsList.addEventListener( ItemStates.ITEM_CLICK, __onListItemSelection );
			_micList.addEventListener( ItemStates.ITEM_CLICK, __onListItemSelection );
			_qualityList.addEventListener( ItemStates.ITEM_CLICK, __onListItemSelection );
			
			//All sub menu list should be invisible by default
			_camsList.visible = _micList.visible = _qualityList.visible = false;
			
			//Load sub lists
			if ( _mediaSettings.initialized && !_camsList.source ) loadSubLists();
		}
		
		override protected function arrange():void 
		{
			super.arrange();
			
			//Size background header
			_background.width = width;
			_background.height = _lSettings.height + paddingTop + innerPadding;
			
			//Position and size list
			_settingsList.y = _background.height;
			_settingsList.width = width;
			
			//Size list headers on top
			_settingsIcon.x = paddingLeft;
			_lSettings.y = paddingTop;
			
			//Size and position sub lists
			_camsList.setActualSize( width, _camUseMeasured ? _camsList.measuredHeight : _settingsList.height );
			_micList.setActualSize( width, _micUseMeasured ? _micList.measuredHeight : _settingsList.height );
			_qualityList.setActualSize( width, _qualityUseMeasured ? _qualityList.measuredHeight : _settingsList.height );
			SizeUtils.hookTarget( _camsList, _settingsList, SizeUtils.RIGHT );
			SizeUtils.hookTarget( _micList, _settingsList, SizeUtils.RIGHT );
			SizeUtils.hookTarget( _qualityList, _settingsList, SizeUtils.RIGHT );
			
			//Mid position on y axis 
			_camsList.y = _settingsList.y;
			SizeUtils.hookTarget( _micList, _settingsList, SizeUtils.MIDDLE, 0, true );
			SizeUtils.hookTarget( _qualityList, _settingsList, SizeUtils.BOTTOM, 0, true );
			SizeUtils.hookTarget( _lSettings, _settingsIcon, SizeUtils.RIGHT, innerPadding );
			SizeUtils.hookTarget( _settingsIcon, _lSettings, SizeUtils.MIDDLE, 0, true );
		}
		
		/*
		 * GETTER / SETTER
		 */
		
		//If comp is set to not be seen then make sure to affect sub lists
		override public function set visible(value:Boolean): void 
		{
			super.visible = value;
			if ( initialized && !visible ) _camsList.visible = _micList.visible = _qualityList.visible = false;
		}
		
		public function set adminMode( value:Boolean ): void
		{
			if ( _adminMode == value ) return;
			onAdminModeChanged(value);
		}
		
		public function get adminMode(): Boolean
		{
			return _adminMode;
		}
		
		public function set includeExit( value:Boolean ): void
		{
			if ( _includeExit == value ) return;
			_includeExit = value;
			refreshListItems();
		}
		
		public function get includeExit(): Boolean
		{
			return _includeExit;
		}
	}
}