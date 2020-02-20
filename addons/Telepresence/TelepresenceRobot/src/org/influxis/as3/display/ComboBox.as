package org.influxis.as3.display 
{
	//Flash Classes
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;
	
	//Influxis Classes
	import org.influxis.as3.display.StyleComponent;
	import org.influxis.as3.display.List;
	import org.influxis.as3.display.Button;
	import org.influxis.as3.core.Display;
	import org.influxis.as3.states.PositionStates;
	import org.influxis.as3.states.ToggleStates;
	import org.influxis.as3.states.SizeStates;
	import org.influxis.as3.managers.SelectionManager;
	import org.influxis.as3.data.DataProvider;
	import org.influxis.as3.utils.SizeUtils;
	import org.influxis.as3.list.ListLabelItem;
	
	public class ComboBox extends StyleComponent
	{
		private var _originData:Object;
		private var _nListHeight:Number;
		private var _nListGap:Number;
		private var _aSelectedIndeces:Array;
		private var _bOpenMenu:Boolean;
		private var _bDoubleClickEnabled:Boolean;
		private var _labelFunction:Function;
		private var _nSelectedIndex:Number;
		private var _cellRenderer:Class = org.influxis.as3.list.ListLabelItem;
		private var _sDirection:String = PositionStates.BOTTOM;
		private var _sVerticalScrollPolicy:String = ToggleStates.AUTO;
		
		private var _list:List;
		private var _button:Button;
		
		/**
		 * PUBLIC API
		 */
		
		public function toggleOpenMenu(): void 
		{
			open = !open;
		}
		 
		/**
		 * PRIVATE API
		 */
		
		private function __getItemLabel( value:Object, data:Object, index:Number ): String 
		{
			return (!value ? "" : value.label);
		}
		 
		/**
		 * PROTECTED API
		 */
		
		protected function refreshItemLabel(): void 
		{
			if ( !initialized || isNaN(selectedIndex) ) return;
			var fItemLabelFunction:Function = labelFunction == null ? __getItemLabel : labelFunction;
			_button.label = fItemLabelFunction.apply( null, [dataProvider.getItemAt(selectedIndex), dataProvider.source, selectedIndex] );
		}
		
		/**
		 * HANDLERS
		 */
		
		private function __onButtonPressed( event:Event ): void 
		{
			if ( event.type == MouseEvent.MOUSE_DOWN ) 
			{
				setTimeout( toggleOpenMenu, Display.IS_MOBILE?200:10 );
			}
		}
		
		private function __onListEvent( event:Event ): void 
		{	
			if ( event.type == SelectionManager.ITEM_SELECTED )
			{
				_nSelectedIndex = _list.selectedIndex;
				refreshItemLabel();
				toggleOpenMenu();
			}else if ( event.type == SizeStates.MEASURE_HEIGHT )
			{
				measuredWidth = _list.measuredWidth;
				arrange();
			}
			dispatchEvent(event);
		}
		
		private function __onListBGEvent( event:Event ): void
		{
			toggleOpenMenu();
		}
		
		private function __onStageResize( event:Event ): void
		{
			if( Display.IS_MOBILE ) arrange();
		}
		
		/**
		 * DISPLAY API
		 */
		
		override protected function measure():void 
		{
			super.measure();
			measuredWidth = _button.measuredWidth;
			measuredHeight = _button.measuredHeight
		}
		
		private var _listBackground:InteractiveObject;
		override protected function createChildren(): void 
		{
			super.createChildren();
			_list = new List();
			_list.skinName = !styleExists("listSkinName") ? "comboBoxListSkin" : getStyle( "listSkinName" );
			_button = new Button();
			_button.skinName = !styleExists("buttonSkinName") ? "comboBoxButtonSkin" : getStyle( "buttonSkinName" );
			
			stage.addEventListener( Event.RESIZE, __onStageResize );
			
			if ( Display.IS_MOBILE )
			{
				_listBackground = getStyleGraphic("listBackground");
				_listBackground.addEventListener( MouseEvent.MOUSE_DOWN, __onListBGEvent );
				addChildren( _button, _list );
			}else{
				addChildren( _button, _list );
			}
		}
		
		override protected function childrenCreated():void 
		{
			super.childrenCreated();
			
			//Button events
			_button.addEventListener( MouseEvent.MOUSE_DOWN, __onButtonPressed );
			
			//List events
			_list.addEventListener( SelectionManager.ITEM_CLICK, __onListEvent );
			_list.addEventListener( SelectionManager.ITEM_DOUBLE_CLICK, __onListEvent );
			_list.addEventListener( SelectionManager.ITEM_ROLL_OUT, __onListEvent );
			_list.addEventListener( SelectionManager.ITEM_ROLL_OVER, __onListEvent );
			_list.addEventListener( SelectionManager.ITEM_SELECTED, __onListEvent );
			_list.addEventListener( SizeStates.MEASURE_HEIGHT, __onListEvent );
			
			//_list.visible = _bOpenMenu;
			_list.cellRenderer = _cellRenderer;
			_list.doubleClickEnabled = _bDoubleClickEnabled;
			_list.verticalScrollPolicy = _sVerticalScrollPolicy;
			_list.selectedIndex = _nSelectedIndex;
			_list.selectedIndeces = _aSelectedIndeces;
			
			if ( Display.IS_MOBILE )
			{
				removeChild( _list );
				if ( _bOpenMenu )
				{
					stage.addChild( _listBackground );
					stage.addChild( _list );
				}
			}else{
				_list.visible = _bOpenMenu;
			}
			
			_list.source = _originData;
			refreshItemLabel();
		}
		
		override protected function arrange(): void 
		{
			super.arrange();
			_button.setActualSize( width, height );
			
			if ( Display.IS_MOBILE )
			{
				_list.setActualSize( (width*_listPercentWidth), _list.measuredHeight > 0 ? _list.measuredHeight > (stage.stageHeight/2) ? (stage.stageHeight/2) : _list.measuredHeight : 0 );// (styleExists("listHeight") ? Number(getStyle("listHeight")) : isNaN(_nListHeight) ? (_list.measuredHeight == 0 ? NaN : _list.measuredHeight) : _nListHeight) );
				_listBackground.width = stage.stageWidth; _listBackground.height = stage.stageHeight;
				SizeUtils.moveX( _list, stage.stageWidth, SizeUtils.CENTER );
				SizeUtils.moveY( _list, stage.stageHeight, SizeUtils.MIDDLE );
			}else{
				_list.setActualSize( width, (styleExists("listHeight") ? Number(getStyle("listHeight")) : isNaN(_nListHeight) ? (_list.measuredHeight == 0 ? NaN : _list.measuredHeight) : _nListHeight) );
				SizeUtils.hookTarget( _list, _button, _sDirection, (styleExists("listGap") ? Number(getStyle("listGap")) : isNaN(_nListGap) ? 0 : _nListGap));
			}
		}
		
		/**
		 * GETTER / SETTER
		 */
		
		public function set source( value:Object ): void
		{
			if ( _originData == value ) return;
			_originData = value;
			if ( initialized ) _list.source = value;
		}
		
		public function get source(): Object
		{
			return _originData;
		}
		
		public function get dataProvider(): DataProvider
		{
			return initialized ? _list.dataProvider : null;
		}
		
		public function set cellRenderer( value:Class ): void
		{
			if ( value == _cellRenderer || !value ) return;
			_cellRenderer = value;
			if ( initialized ) _list.cellRenderer = _cellRenderer;
		}
		
		public function get cellRenderer(): Class
		{
			return _cellRenderer;
		}
		
		override public function set doubleClickEnabled( value:Boolean ): void
		{
			_bDoubleClickEnabled = value;
			if ( initialized ) _list.doubleClickEnabled = value;
		}
		
		override public function get doubleClickEnabled(): Boolean
		{
			return _bDoubleClickEnabled;
		}
		
		public function set open( value:Boolean ): void 
		{
			if ( _bOpenMenu == value ) return;
			_bOpenMenu = value;
			if ( initialized ) 
			{
				if ( Display.IS_MOBILE )
				{
					if ( _bOpenMenu )
					{
						stage.addChild( _listBackground );
						stage.addChild( _list );
					}else{
						stage.removeChild( _listBackground );
						stage.removeChild( _list );
					}
				}else{
					_list.visible = _bOpenMenu;
				}
				arrange();
			}
		}
		
		public function get open(): Boolean 
		{ 
			return _bOpenMenu; 
		}
		
		public function set labelFunction( value:Function ): void 
		{
			_labelFunction = value;
		}
		
		public function get labelFunction(): Function
		{ 
			return _labelFunction; 
		}
		
		public function set direction( value:String ): void 
		{
			if ( _sDirection == value ) return;
			_sDirection = value;
			if ( initialized ) arrange();
		}
		
		public function get direction(): String 
		{ 
			return _sDirection; 
		}
		
		public function set listGap( value:Number ): void 
		{
			if ( _nListGap == value ) return;
			_nListGap = value;
			if ( initialized ) arrange();
		}
		
		public function get listGap(): Number
		{ 
			return _nListGap; 
		}
		
		public function set listHeight( value:Number ): void 
		{
			if ( _nListHeight == value ) return;
			_nListHeight = value;
			if ( initialized ) arrange();
		}
		
		public function get listHeight(): Number
		{ 
			return _nListHeight; 
		}
		
		public function set verticalScrollPolicy( value:String ): void
		{
			if ( _sVerticalScrollPolicy == value || !value ) return;
			_sVerticalScrollPolicy = value;
			if ( initialized ) _list.verticalScrollPolicy = _sVerticalScrollPolicy;
		}
		
		public function get verticalScrollPolicy(): String
		{
			return _sVerticalScrollPolicy;
		}
		
		public function set verticalScrollPosition( value:Number ): void
		{
			if ( !initialized ) return;
			_list.verticalScrollPosition = value;
		}
		
		public function get verticalScrollPosition(): Number
		{
			return (!_list ? 0 : _list.verticalScrollPosition);
		}
		
		public function get maxVerticalScrollPosition(): Number
		{
			return (!_list ? 0 : _list.maxVerticalScrollPosition);
		}
		
		public function get minVerticalScrollPosition(): Number
		{
			return (!_list ? 0 : _list.minVerticalScrollPosition);
		}
		
		public function get selectedItem(): Object
		{
			return (!_list ? null : _list.selectedItem);
		}
		
		public function set selectedIndex( value:Number ): void
		{
			_nSelectedIndex = value;
			if ( initialized ) 
			{
				_list.selectedIndex = _nSelectedIndex;
				refreshItemLabel();
			}
		}
		
		public function get selectedIndex(): Number
		{
			return (!_list ? NaN : _list.selectedIndex);
		}
		
		public function set selectedIndeces( value:Array ): void
		{
			_aSelectedIndeces = value;
			if ( initialized ) _list.selectedIndeces = _aSelectedIndeces;
		}
		
		public function get selectedIndeces(): Array
		{
			return (!_list ? null : _list.selectedIndeces);
		}
		
		public function get listPercentWidth(): Number
		{
			return _listPercentWidth;
		}
		private var _listPercentWidth:Number = 0.5;
		public function set listPercentWidth( value:Number ): void
		{
			if ( value == _listPercentWidth || isNaN(value) ) return;
			_listPercentWidth = value;
			if ( initialized ) arrange();
		}
	}
}