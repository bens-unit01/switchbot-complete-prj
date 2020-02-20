package org.influxis.application.vidcollaborator.list 
{
	//Flash Classes
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	//Influxis Classes
	import org.influxis.as3.display.StyleCanvas;
	import org.influxis.as3.display.List;
	import org.influxis.as3.display.Label;
	import org.influxis.as3.display.Button;
	import org.influxis.as3.events.SimpleEvent;
	import org.influxis.as3.utils.SizeUtils;
	import org.influxis.as3.states.DataStates;
	import org.influxis.as3.list.ItemStates;
	import org.influxis.as3.data.DataProvider;
	import org.influxis.as3.utils.ObjectUtils;
	import org.influxis.as3.list.ListLabelItem;
	
	//VidCollaborator Classes
	import org.influxis.application.vidcollaborator.data.Sessions;
	
	public class SessionsList extends StyleCanvas
	{
		public static const CREATE:String = "createSession";
		public static const REMOVE:String = "removeSession";
		
		private var _adminMode:Boolean;
		private var _sessions:Sessions;
		private var _sessionData:DataProvider;
		private var _listData:DataProvider;
		
		private var _sessionList:List;
		private var _noSessions:Label;
		private var _sessionsTitle:Label;
		private var _addBtn:Button;
		private var _removeBtn:Button;
		
		/*
		 * INIT API
		 */
		
		public function SessionsList(): void
		{
			super();
			
			_listData = new DataProvider();
			
			_sessions = Sessions.getInstance();
			_sessionData = _sessions.dataProvider;
			_sessionData.addEventListener( DataStates.ADD, __onDataChanged );
			_sessionData.addEventListener( DataStates.UPDATE, __onDataChanged );
			_sessionData.addEventListener( DataStates.REMOVE, __onDataChanged );
			_sessionData.addEventListener( DataStates.CHANGE, __onDataChanged );	
		}
		
		/*
		 * PRIVATE API
		 */
		
		private function __formatSessionData(): void
		{
			var aNewData:Array = new Array(); var itemData:Object;
			for ( var i:Number = 0; i < _sessionData.length; i++ )
			{
				itemData = ObjectUtils.duplicateObject(_sessionData.getItemAt(i));
				itemData.label = itemData.title;
				aNewData.push(itemData);
			}
			_listData.setArray(aNewData, false);
		}
		 
		/*
		 * HANDLERS
		 */
		
		private function __onDataChanged( event:SimpleEvent ): void
		{
			if ( initialized ) _noSessions.visible = _sessionData.length == 0;
			
			var formattedData:Object;
			switch( event.type )
			{
				case DataStates.ADD : 
					formattedData = event.data.data;
					formattedData.label = formattedData.title;
					_listData.addItem(formattedData);
					break;
				case DataStates.REMOVE : 
					_listData.removeItemAt(event.data.slot);
					break;
				case DataStates.UPDATE : 
					formattedData = event.data.data;
					formattedData.label = formattedData.title;
					_listData.updateItemAt(event.data.slot, formattedData);
					break;
				case DataStates.CHANGE : 
					__formatSessionData();
					break;
			}
			
			if( initialized && _sessionList.selectedItem == null ) _removeBtn.enabled = false;
		}
		
		private function __onListEvent( event:Event ): void
		{
			if ( event.type == ItemStates.ITEM_CLICK ) _removeBtn.enabled = true;
			dispatchEvent(event);
		}
		
		private function __onButtonEvent( event:MouseEvent ): void
		{
			if ( event.currentTarget.enabled != true ) return;
			dispatchEvent(new Event(event.currentTarget == _addBtn ? CREATE : REMOVE));
		}
		
		/*
		 * DISPLAY API
		 */
		
		override protected function createChildren():void 
		{
			super.createChildren();
			
			_sessionsTitle = new Label( "sessionsListTitle", "activeSessions" );
			
			_sessionList = new List();
			_sessionList.cellRenderer = ListLabelItem;
			_sessionList.skinName = "sessionsList";
			
			_noSessions = new Label( skinName, "noSessions", "label" );
			_noSessions.visible = false;
			
			_addBtn = new Button();
			_addBtn.skinName = "greenBtn";
			_addBtn.visible = _adminMode;
			
			_removeBtn = new Button();
			_removeBtn.skinName = "redBtn";
			_removeBtn.visible = _adminMode;
			
			addChildren( _sessionsTitle, _sessionList, _noSessions, _addBtn, _removeBtn );
		}
		
		override protected function childrenCreated(): void 
		{
			super.childrenCreated();
			
			//Events used to dispatch out
			_sessionList.addEventListener( ItemStates.ITEM_CLICK, __onListEvent );
			_sessionList.addEventListener( ItemStates.ITEM_DOUBLE_CLICK, __onListEvent );
			_sessionList.addEventListener( ItemStates.ITEM_DOWN, __onListEvent );
			_sessionList.addEventListener( ItemStates.ITEM_ROLL_OUT, __onListEvent );
			_sessionList.addEventListener( ItemStates.ITEM_ROLL_OVER, __onListEvent );
			_sessionList.addEventListener( ItemStates.ITEM_SELECTED, __onListEvent );
			_sessionList.addEventListener( ItemStates.ITEM_UP, __onListEvent );
			
			_addBtn.addEventListener( MouseEvent.CLICK, __onButtonEvent );
			_removeBtn.addEventListener( MouseEvent.CLICK, __onButtonEvent );
			_removeBtn.enabled = false;
			
			_addBtn.label = getLabelAt("addBtn");
			_removeBtn.label = getLabelAt("removeBtn");
			
			_sessionList.doubleClickEnabled = true;
			_sessionList.source = _listData;
		}
		
		override protected function arrange():void 
		{
			super.arrange();
			
			_sessionsTitle.move( paddingLeft, paddingTop );
			_sessionsTitle.width = width - (paddingLeft + paddingRight);
			
			if ( _adminMode )
			{
				_sessionList.setActualSize( width - (paddingLeft + paddingRight), height - (paddingTop + paddingBottom + innerPadding + _addBtn.height + _sessionsTitle.height) );
			}else{
				_sessionList.setActualSize( width - (paddingLeft + paddingRight), height - (paddingTop + paddingBottom + _sessionsTitle.height) );
			}
			
			_sessionList.x = paddingLeft;
			SizeUtils.hookTarget( _sessionList, _sessionsTitle, SizeUtils.BOTTOM, -1 );
			
			SizeUtils.moveByTarget( _noSessions, _sessionList, SizeUtils.CENTER, SizeUtils.MIDDLE );
			
			SizeUtils.moveX( _removeBtn, width, SizeUtils.RIGHT, paddingRight );
			SizeUtils.moveY( _removeBtn, height, SizeUtils.BOTTOM, paddingBottom );
			
			SizeUtils.hookTarget( _addBtn, _removeBtn, SizeUtils.LEFT, innerPadding );
			SizeUtils.moveY( _addBtn, height, SizeUtils.BOTTOM, paddingBottom );
		}
		
		/*
		 * GETTER / SETTER
		 */
		
		public function get dataProvider(): DataProvider
		{
			return _listData;
		}
		 
		public function get selectedIndex(): Number
		{
			return _sessionList ? _sessionList.selectedIndex : NaN;
		}
		 
		public function get selectedItem(): Object
		{
			return _sessionList ? _sessionList.selectedItem : null;
		}
		
		public function set adminMode( value:Boolean ): void
		{
			if ( _adminMode == value ) return;
			_adminMode = value;
			if ( initialized )
			{
				_addBtn.visible = _adminMode;
				_removeBtn.visible = _adminMode;
				invalidateDisplayList();
			}
		}
		
		public function get adminMode(): Boolean
		{
			return _adminMode;
		}
	}
}