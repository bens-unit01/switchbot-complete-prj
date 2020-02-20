package org.influxis.application.vidcollaborator.display.videocollaboratorclasses.collabcontrolsclasses 
{
	//Flash Classes
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	//Influxis Classes
	import org.influxis.as3.display.Button;
	import org.influxis.as3.data.DataProvider;
	import org.influxis.as3.states.DataStates;
	import org.influxis.as3.utils.SizeUtils;
	
	//Flotools Classes
	import org.influxis.flotools.core.InfluxisComponent;
	import org.influxis.flotools.states.DisplayPositionStates;
	import org.influxis.flotools.containers.DisplayPositioner;
	
	//VidCollaborator Classes
	import org.influxis.application.vidcollaborator.managers.VidCollaboratorManager;
	 
	public class ScreenOptions extends InfluxisComponent
	{
		private var _vcm:VidCollaboratorManager;
		private var _activeList:DataProvider;
		private var _nCastersCount:Number;
		private var _displayPosition:DisplayPositioner;
		private var _modeLibrary:Object;
		private var _displayState:String;
		private var _displayOrder:Array;
		
		private var _picInPicBtn:Button;
		private var _sideBySide:Button;
		private var _oneByManyVert:Button;
		private var _oneByManyHor:Button;
		
		/*
		 * INIT API
		 */
		
		public function ScreenOptions(): void
		{
			_displayState = DisplayPositionStates.PICTURE_IN_PICTURE;
			super();
		}
		
		/*
		 * CONNECT API
		 */
		
		override protected function instanceClose():void 
		{
			super.instanceClose();
			
			_activeList.removeEventListener( DataStates.ADD, __onCastersListEvent );
			_activeList.removeEventListener( DataStates.REMOVE, __onCastersListEvent );
			_activeList.removeEventListener( DataStates.CHANGE, __onCastersListEvent );
			_activeList = null;
			
			_vcm.removeEventListener( VidCollaboratorManager.ADMIN_UPDATE, __onVidCastersEvent );
			_vcm.removeEventListener( VidCollaboratorManager.LOCAL_DATA_UPDATE, __onVidCastersEvent );
			_vcm = null;
			
			_nCastersCount = 0;
			refreshDisplay();
		}
		
		override protected function instanceChange():void 
		{
			super.instanceChange();
			
			_vcm = VidCollaboratorManager.getInstance(instance);
			_vcm.addEventListener( VidCollaboratorManager.ADMIN_UPDATE, __onVidCastersEvent );
			_vcm.addEventListener( VidCollaboratorManager.LOCAL_DATA_UPDATE, __onVidCastersEvent );
			
			_activeList = _vcm.castersList;
			_activeList.addEventListener( DataStates.ADD, __onCastersListEvent );
			_activeList.addEventListener( DataStates.REMOVE, __onCastersListEvent );
			_activeList.addEventListener( DataStates.CHANGE, __onCastersListEvent );
			
			checkCastersCount();
		}
		
		/*
		 * PROTECTED API
		 */
		
		protected function refreshDisplay(): void
		{
			if ( !initialized ) return;
			
			_picInPicBtn.visible = _nCastersCount < 2;
			_sideBySide.visible = _nCastersCount < 3;
			_oneByManyVert.visible = _nCastersCount > 1;
			_oneByManyHor.visible = _nCastersCount > 1;
			visible = _nCastersCount > 0;
			refreshMeasures();
		}
		
		protected final function checkCastersCount(): void
		{
			//trace( "checkCastersCount: " + initialized, _nCastersCount, _activeList.length, _vcm.localData, _displayState );
			if ( !initialized || !_vcm || _nCastersCount == _activeList.length || _vcm.localData == null ) return;
			
			//Get new count and refresh display
			_nCastersCount = _activeList.length;
			refreshDisplay();
			
			//If the old mode is no longer on display because it changed as a result then change to default (Admin Only)
			if ( _modeLibrary[_displayState].visible != true && _vcm.localData.isAdmin == true )
			{
				updateClientsDisplayState( _nCastersCount < 2 ? DisplayPositionStates.PICTURE_IN_PICTURE : DisplayPositionStates.ONE_BY_MANY_VERTICAL );
			}
		}
		
		protected function checkCastersDisplayState(): void
		{
			if ( _vcm.adminData == null && _vcm.localData == null ) return;
			var adminData:Object = _vcm.adminData != null ? _vcm.adminData : 
								   _vcm.localData.isAdmin == true ? _vcm.localData : null;
								   
			if ( adminData == null ) return;
			
			_displayState = adminData.infoData.displayState == undefined ? DisplayPositionStates.PICTURE_IN_PICTURE : adminData.infoData.displayState;
			if ( _displayPosition ) _displayPosition.displayState = _displayState;
		}
		
		protected function updateClientsDisplayState( value:String ): void
		{
			if ( _displayState == value ) return;
			
			var adminData:Object = _vcm.localData.infoData == undefined ? new Object() : _vcm.localData.infoData;
				adminData.displayState = value;
				
			_vcm.updateLocalData(adminData);
			_displayState = value;
			if( _displayPosition ) _displayPosition.displayState = _displayState;
		}
		
		/*
		 * HANDLERS
		 */
		
		private function __onCastersListEvent( event:Event ): void
		{
			checkCastersCount();
		}
		 
		private function __onVidCastersEvent( event:Event ): void
		{
			if ( event.type == VidCollaboratorManager.ADMIN_UPDATE || event.type == VidCollaboratorManager.LOCAL_DATA_UPDATE )
			{
				checkCastersCount();
				checkCastersDisplayState();
			}
		}
		
		private function __onDisplayBtnEvent( event:Event ): void
		{
			var newPosition:String;
			switch( event.currentTarget )
			{
				case _picInPicBtn : 
					newPosition = DisplayPositionStates.PICTURE_IN_PICTURE;
					break;
				case _sideBySide : 
					newPosition = DisplayPositionStates.SIDE_BY_SIDE;
					break;
				case _oneByManyVert : 
					newPosition = DisplayPositionStates.ONE_BY_MANY_VERTICAL;
					break;
				case _oneByManyHor : 
					newPosition = DisplayPositionStates.ONE_BY_MANY_HORIZONTAL;
					break;
			}
			updateClientsDisplayState(newPosition);	
		}
		
		/*
		 * DISPLAY
		 */
		
		override protected function measure():void 
		{
			var newMeasuredWidth:Number = paddingLeft + paddingRight;
			var newMeasuredHeight:Number = 0;	
			if ( _displayOrder )
			{
				var nLen:Number = _displayOrder.length;
				for ( var i:Number = 0; i < nLen; i++ )
				{
					if ( _displayOrder[i].visible )
					{
						if ( newMeasuredHeight < _displayOrder[i].height ) newMeasuredHeight = _displayOrder[i].height + paddingBottom + paddingTop;
						newMeasuredWidth = newMeasuredWidth + (_displayOrder[i].width + (i==nLen-1?0:innerPadding));
					}
				}
			}
			measuredWidth = newMeasuredWidth;
			measuredHeight = newMeasuredHeight;
			super.measure();
		}
		 
		override protected function createChildren():void 
		{
			super.createChildren();
			
			_picInPicBtn = new Button();
			_picInPicBtn.skinName = "screenOpsPicInPicBtn";
			_picInPicBtn.visible = false;
			
			_sideBySide = new Button();
			_sideBySide.skinName = "screenOpsSideBySide";
			_sideBySide.visible = false;
			
			_oneByManyVert = new Button();
			_oneByManyVert.skinName = "screenOpsOneByManyVert";
			_oneByManyVert.visible = false;
			
			_oneByManyHor = new Button();
			_oneByManyHor.skinName = "screenOpsOneByManyHor";
			_oneByManyHor.visible = false;
			
			//Keeps a reference so when the count changes if still available then we keep it
			_modeLibrary = new Object();
			_modeLibrary[DisplayPositionStates.PICTURE_IN_PICTURE] = _picInPicBtn;
			_modeLibrary[DisplayPositionStates.SIDE_BY_SIDE] = _sideBySide;
			_modeLibrary[DisplayPositionStates.ONE_BY_MANY_VERTICAL] = _oneByManyVert;
			_modeLibrary[DisplayPositionStates.ONE_BY_MANY_HORIZONTAL] = _oneByManyHor;
			
			//Used when arranging items
			_displayOrder = [ _picInPicBtn, _oneByManyVert, _oneByManyHor, _sideBySide ];
			addChildren( _picInPicBtn, _sideBySide, _oneByManyVert, _oneByManyHor );
		}
		
		override protected function childrenCreated(): void 
		{
			super.childrenCreated();
			
			_picInPicBtn.addEventListener( MouseEvent.MOUSE_DOWN, __onDisplayBtnEvent );
			_sideBySide.addEventListener( MouseEvent.MOUSE_DOWN, __onDisplayBtnEvent );
			_oneByManyVert.addEventListener( MouseEvent.MOUSE_DOWN, __onDisplayBtnEvent );
			_oneByManyHor.addEventListener( MouseEvent.MOUSE_DOWN, __onDisplayBtnEvent );
			
			//Checks the cast numbers
			checkCastersCount();
		}
		
		override protected function arrange(): void 
		{
			super.arrange();
			
			if ( _displayOrder )
			{
				var lastUsedDisplay:DisplayObject;
				var nLen:Number = _displayOrder.length;
				for ( var i:Number = 0; i < nLen; i++ )
				{
					if ( _displayOrder[i].visible )
					{
						if ( !lastUsedDisplay )
						{
							_displayOrder[i].x = paddingLeft;
						}else{
							SizeUtils.hookTarget( _displayOrder[i], lastUsedDisplay, SizeUtils.RIGHT, innerPadding );
						}
						SizeUtils.moveY( _displayOrder[i], height, SizeUtils.MIDDLE );
						lastUsedDisplay = _displayOrder[i];
					}
				}
			}	
		}
		
		/*
		 * GETTER / SETTER
		 */
		
		protected function onDisplayPositionChanged( value:DisplayPositioner ): void
		{
			if ( _displayPosition == value ) return;
			
			_displayPosition = value;
			if ( !_displayPosition ) return;
			
			_displayPosition.displayState = _displayState;
			invalidateDisplayList();
		}
		 
		public function set displayPositioner( value:DisplayPositioner ): void
		{
			onDisplayPositionChanged(value);	
		} 
		
		public function get displayPositioner(): DisplayPositioner
		{
			return _displayPosition;
		}
	}
}