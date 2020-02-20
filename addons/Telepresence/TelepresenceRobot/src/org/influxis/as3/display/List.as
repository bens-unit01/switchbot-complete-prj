/**
 * List - Copyright © 2011 Influxis All rights reserved.
**/

package org.influxis.as3.display 
{
	//Flash Classes
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.getDefinitionByName;
	
	//Influxis Classes
	import org.influxis.as3.core.Display;
	import org.influxis.as3.events.SimpleEvent;
	import org.influxis.as3.managers.LayoutManager;
	import org.influxis.as3.display.StyleCanvas;
	import org.influxis.as3.display.listclasses.ListBase;
	import org.influxis.as3.display.ScrollBar;
	import org.influxis.as3.data.DataProvider;
	import org.influxis.as3.managers.SelectionManager;
	import org.influxis.as3.states.DataStates;
	import org.influxis.as3.states.SizeStates;
	import org.influxis.as3.states.ToggleStates;
	import org.influxis.as3.containers.Mask;
	import org.influxis.as3.utils.SizeUtils;
	import org.influxis.as3.interfaces.data.IDatable;
	import org.influxis.mobile.controls.MobileScroller;
	import org.influxis.as3.utils.ScreenScaler;
	
	public class List extends StyleCanvas
	{
		private var _cellRenderer:Class = org.influxis.as3.display.listclasses.ListItem;
		private var _data:DataProvider;
		private var _originData:Object;
		private var _bDoubleClickEnabled:Boolean;
		private var _bToggle:Boolean;
		private var _sVerticalScrollPolicy:String = ToggleStates.AUTO;
		private var _sVerticalScrollPosition:Number;
		private var _displayList:Vector.<DisplayObject>;
		private var _mobileScroller:MobileScroller;
		
		private var _mask:Sprite;
		private var _listMask:Sprite;
		private var _scroller:ScrollBar;
		private var _itemHolder:ListBase;
		private var _selection:SelectionManager = new SelectionManager();
		
		protected var maskPaddingLeft:Number;
		protected var maskPaddingTop:Number;
		protected var maskPaddingBottom:Number;
		protected var maskPaddingRight:Number;
		
		/**
		 * INIT API
		 */
		
		override protected function init(): void 
		{
			//Add selection events
			_selection.addEventListener( SelectionManager.ITEM_CLICK, __onSelectionEvent );
			_selection.addEventListener( SelectionManager.ITEM_DOUBLE_CLICK, __onSelectionEvent );
			_selection.addEventListener( SelectionManager.ITEM_ROLL_OVER, __onSelectionEvent );
			_selection.addEventListener( SelectionManager.ITEM_ROLL_OUT, __onSelectionEvent );
			_selection.addEventListener( SelectionManager.ITEM_DOWN, __onSelectionEvent );
			_selection.addEventListener( SelectionManager.ITEM_UP, __onSelectionEvent );
			_selection.addEventListener( SelectionManager.ITEM_SELECTED, __onSelectionEvent );
			
			super.init();
		}
		
		/**
		 * PUBLIC API
		 */
		
		public function getCellItemAt( index:Number ): *
		{
			if ( !initialized || isNaN(index) ) return;
			return _displayList[index];
		}
		
		public function scrollTo( index:Number ): void
		{
			if ( !initialized || isNaN(index) ) return;
			if ( !_scroller.scrollBarEnabled ) return;
			
			//Do something here ?
		}
		
		public function clear(): void 
		{
			unRegisterData();
		}
		
		/**
		 * PROTECTED API
		 */
		
		protected function unRegisterData(): void
		{
			if ( !_data ) return;
			
			//Remove all children from item holder
			removeAllItems();
			
			//Remove events
			_data.removeEventListener( DataStates.ADD, __onDataChange );
			_data.removeEventListener( DataStates.ADD_MULTI, __onDataChange );
			_data.removeEventListener( DataStates.REMOVE, __onDataChange );
			_data.removeEventListener( DataStates.REMOVE_MULTI, __onDataChange );
			_data.removeEventListener( DataStates.CHANGE, __onDataChange );
			_data.removeEventListener( DataStates.CLEAR, __onDataChange );
			_data.removeEventListener( DataStates.UPDATE, __onDataChange );
			
			//Clear Data
			_data.clear(true);
			_data = null;
		}
		 
		protected function registerData( data:Object ): void
		{
			//Set origin data
			_originData = data;
			
			unRegisterData();
			_data = data as DataProvider;
			if ( !_data )
			{
				_data = new DataProvider();
				if ( data is Array )
				{
					_data.setArray( data as Array, false, true );
				}else if ( data is Vector.<Object> )
				{
					_data.source = data as Vector.<Object>;
				}else{
					for ( var i:String in data )
					{
						_data.addItem(data[i], true);
					}
				}
			}
			
			_data.addEventListener( DataStates.ADD, __onDataChange );
			_data.addEventListener( DataStates.ADD_MULTI, __onDataChange );
			_data.addEventListener( DataStates.REMOVE, __onDataChange );
			_data.addEventListener( DataStates.REMOVE_MULTI, __onDataChange );
			_data.addEventListener( DataStates.CHANGE, __onDataChange );
			_data.addEventListener( DataStates.CLEAR, __onDataChange );
			_data.addEventListener( DataStates.UPDATE, __onDataChange );
			
			if( initialized ) refreshItemList();
		}
		
		//Refresh all Cells
		protected function refreshItemList(): void
		{
			_displayList = new Vector.<DisplayObject>();
			var data:Vector.<Object> = _data.source as Vector.<Object>;
			for ( var i:Number = 0; i < data.length; i++ )
			{
				createItemAt(i, data[i]);
			}
			__refreshCandidates();
		}
		
		//Create cell item
		protected function createItemAt( index:Number, data:Object ): void
		{
			var itemData:Object = !data ? new Object() : data;
			//Get cell renderer
			var cellRenderer:Class = !(itemData is String) && itemData.cellRenderer != undefined ? itemData.cellRenderer : _cellRenderer;
			
			//Create objects from renderer
			if ( cellRenderer )
			{
				var listItem:DisplayObject;
				try 
				{
					//Try to see if this is a list item
					listItem = new cellRenderer(skinName) as DisplayObject;
				}catch ( e:Error )
				{
					//If not and throws an error then no skin assignment
					listItem = new cellRenderer() as DisplayObject;
				}
				
				//If implements IDatable then assign data
				if ( listItem is IDatable )
				{
					(listItem as IDatable).data = data;
				}
				
				//Add to managers
				_displayList.push(listItem);
				_itemHolder.addChild(listItem);
				_selection.addItemAt( index, listItem );
			}
		}
		
		//Remove Cell Item
		protected function removeItemAt( index:Number ): void
		{
			if ( !_displayList ) return;
			if ( _displayList[index] == undefined ) return;
			
			//Remove from managers
			_displayList.splice( index, 1 );
			_itemHolder.removeChildAt( index );
			_selection.removeItemAt( index );
		}
		
		//Update cell item
		protected function updateItemAt( index:Number, data:Object ): void
		{
			if ( !_displayList ) return;
			if ( _displayList[index] == undefined ) return;
			
			var listItem:IDatable = _displayList[index] as IDatable;
			if ( listItem ) listItem.data = data;
		}
		
		protected function removeAllItems(): void
		{
			if ( !initialized ) return;
			_itemHolder.removeAllChildren();
			_selection.clear();
			_displayList = null;
		}
		
		/**
		 * PRIVATE API
		 */
		
		private function __refreshCandidates(): void
		{
			
		}
		
		private function __refreshScroller(): void
		{
			var bVisible:Boolean = _scroller.visible;
			_scroller.visible = verticalScrollPolicy == ToggleStates.AUTO ? _scroller.scrollBarEnabled : (verticalScrollPolicy == ToggleStates.ON);
			if ( bVisible != _scroller.visible )
			{
				//Do something here
			}
		}
		
		/**
		 * HANDLERS
		 */
		
		private function __onDataChange( event:SimpleEvent ): void
		{
			if ( event.type == DataStates.ADD )
			{
				createItemAt( event.data.slot, event.data.data );
			}else if ( event.type == DataStates.REMOVE )
			{
				removeItemAt( event.data.slot );
			}else if ( event.type == DataStates.UPDATE )
			{
				updateItemAt( event.data.slot, event.data.data );
			}else if ( event.type == DataStates.CHANGE )
			{
				removeAllItems();
				refreshItemList();
			}
		}
		
		private function __dimensionsChange( event:Event ): void
		{
			if ( event.type == SizeStates.RESIZE_HEIGHT || event.type == SizeStates.MEASURE_HEIGHT )
			{
				measuredWidth = _itemHolder.measuredWidth;
				measuredHeight = _itemHolder.measuredHeight;
				_scroller.maxScrollPosition = (_itemHolder.measuredHeight - height) > 0 ? (_itemHolder.measuredHeight - height) : 0;
				arrange();
			}
		}
		
		private function __onScrollerEvent( event:Event ): void
		{
			if ( !initialized ) return;
			
			if ( event.type == ScrollBar.SCROLL )
			{
				onScrollChanged();
			}else if ( event.type == ScrollBar.SCROLL_ENABLED )
			{
				__refreshScroller();
			}
		}
		
		private function __onSelectionEvent( event:Event ): void
		{
			dispatchEvent(event);
		}
		
		protected function onScrollChanged(): void
		{
			if ( !initialized ) return;
			_itemHolder.y = -_scroller.scrollPosition;
		}
		
		/**
		 * DISPLAY API
		 */
		
		override protected function measurePadding():void 
		{
			super.measurePadding();
			
			//General padding for when others are missing
			var maskPadding:int = styleExists("maskPadding") ? ScreenScaler.calculateSize(getStyle("maskPadding") as int) : 0;
			
			//Set padding
			maskPaddingLeft = styleExists("maskPaddingLeft") ? ScreenScaler.calculateSize(getStyle("maskPaddingLeft") as int) : maskPadding;
			maskPaddingTop = styleExists("maskPaddingTop") ? ScreenScaler.calculateSize(getStyle("maskPaddingTop") as int) : maskPadding;
			maskPaddingBottom = styleExists("maskPaddingBottom") ? ScreenScaler.calculateSize(getStyle("maskPaddingBottom") as int) : maskPadding;
			maskPaddingRight = styleExists("maskPaddingRight") ? ScreenScaler.calculateSize(getStyle("maskPaddingRight") as int) : maskPadding;
		}
		 
		override protected function createChildren():void 
		{
			super.createChildren();
			
			_itemHolder = new ListBase();
			_scroller = new ScrollBar();
			if ( styleExists("listSkinName") ) _scroller.skinName = getStyle("listSkinName");
			
			_mask = styleExists("mask") ? getStyleGraphic("mask") as Sprite : new Sprite();
			_listMask = styleExists("listMask") ? getStyleGraphic("listMask") as Sprite : new Sprite();
			_itemHolder.mask = _listMask;
			mask = _mask;
			
			addChildren( _itemHolder, _scroller, _listMask, _mask );
		}
		
		override protected function childrenCreated():void 
		{
			super.childrenCreated();
			
			_scroller.minScrollPosition = 0;
			_scroller.addEventListener( ScrollBar.SCROLL, __onScrollerEvent );
			_scroller.addEventListener( ScrollBar.SCROLL_ENABLED, __onScrollerEvent );
			_itemHolder.addEventListener( SizeStates.RESIZE_HEIGHT, __dimensionsChange );
			_itemHolder.addEventListener( SizeStates.MEASURE_HEIGHT, __dimensionsChange );
			
			if ( Display.IS_MOBILE ) 
			{
				_mobileScroller = new MobileScroller(_itemHolder, this);
			}else{
				_scroller.mouseTarget = this;
			}
			__refreshScroller();
			if ( _data ) refreshItemList();//&& _data.length > 0
		}
		
		override protected function onSizeChanged(omitEvent:Boolean = false): void 
		{
			super.onSizeChanged(omitEvent);
			_scroller.pageSize = height;
			__refreshCandidates();
		}
		
		override protected function arrange(): void 
		{
			super.arrange();
			
			
			if ( styleExists("listMask") )
			{
				_listMask.x = maskPaddingLeft; _listMask.y = maskPaddingTop;
				_listMask.width = width - (maskPaddingLeft + maskPaddingRight);
				_listMask.height = height - (maskPaddingTop + maskPaddingBottom);
			}else{
				_listMask.graphics.clear();
				_listMask.graphics.beginFill( 0, 1 );
				_listMask.graphics.drawRect( maskPaddingLeft, maskPaddingTop, (width - (maskPaddingLeft + maskPaddingRight)), (height - (maskPaddingTop + maskPaddingBottom)) );
				_listMask.graphics.endFill();
			}
			
			if ( styleExists("mask") )
			{
				_mask.width = width;
				_mask.height = height;
			}else{
				_mask.graphics.clear();
				_mask.graphics.beginFill( 0, 1 );
				_mask.graphics.drawRect( 0, 0, width, height );
				_mask.graphics.endFill();
			}
			
			_itemHolder.width = width;
			if ( styleExists("scrollerWidth") ) _scroller.width = Number(getStyle("scrollerWidth"));
			_scroller.height = height;
			SizeUtils.hookTarget( _scroller, _listMask, SizeUtils.RIGHT, 0, true );
		}
		
		/**
		 * GETTER / SETTER
		 */
		
		public function set source( data:Object ): void
		{
			registerData(data);
		}
		
		public function get source(): Object
		{
			return _originData;
		}
		
		public function get dataProvider(): DataProvider
		{
			return _data;
		}
		
		public function set cellRenderer( value:Class ): void
		{
			if ( value == _cellRenderer || !value ) return;
			_cellRenderer = value;
			if( initialized && _data ) refreshItemList();
		}
		
		public function get cellRenderer(): Class
		{
			return _cellRenderer;
		}
		
		override public function set doubleClickEnabled( value:Boolean ): void
		{
			super.doubleClickEnabled = value;
			_bDoubleClickEnabled = value;
			_selection.doubleClickEnabled = _bDoubleClickEnabled;
		}
		
		override public function get doubleClickEnabled(): Boolean
		{
			return _bDoubleClickEnabled;
		}
		
		public function set toggle( value:Boolean ): void
		{
			_bToggle = value;
			_selection.toggle = _bToggle;
		}
		
		public function get toggle(): Boolean
		{
			return _bToggle;
		}
		
		public function set verticalScrollPolicy( value:String ): void
		{
			if ( _sVerticalScrollPolicy == value || !value ) return;
			_sVerticalScrollPolicy = value;
			__refreshScroller();
		}
		
		public function get verticalScrollPolicy(): String
		{
			return _sVerticalScrollPolicy;
		}
		
		public function set verticalScrollPosition( value:Number ): void
		{
			if ( !initialized ) return;
			if ( !_scroller.scrollBarEnabled ) return;
			_scroller.scrollPosition = value;
		}
		
		public function get verticalScrollPosition(): Number
		{
			var nValue:Number;
			if ( initialized ) nValue = !_scroller.scrollBarEnabled ? NaN : _scroller.scrollPosition;
			return nValue;
		}
		
		public function get maxVerticalScrollPosition(): Number
		{
			var nValue:Number;
			if ( initialized ) nValue = !_scroller.scrollBarEnabled ? NaN : _scroller.maxScrollPosition;
			return nValue;
		}
		
		public function get minVerticalScrollPosition(): Number
		{
			var nValue:Number;
			if ( initialized ) nValue = !_scroller.scrollBarEnabled ? NaN : _scroller.minScrollPosition;
			return nValue;
		}
		
		public function set selectedIndex( value:Number ): void
		{
			_selection.selectedIndex = value;
		}
		
		public function get selectedItem(): Object
		{
			return selectedIndex > -1 ? _data.getItemAt(selectedIndex) : null;
		}
		
		public function get selectedIndex(): Number
		{
			return _selection.selectedIndex;
		}
		
		public function set selectedIndeces( value:Array ): void
		{
			_selection.selectedIndeces = value;
		}
		
		public function get selectedIndeces(): Array
		{
			return _selection.selectedIndeces;
		}
		
		public function get rowCount(): Number
		{
			return !_displayList ? NaN : _displayList.length;
		}
	}
}