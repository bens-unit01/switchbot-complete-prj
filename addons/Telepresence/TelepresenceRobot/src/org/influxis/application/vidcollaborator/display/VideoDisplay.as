package org.influxis.application.vidcollaborator.display 
{
	//Flash Classes
	import flash.display.DisplayObject;
	import flash.media.Camera;
	import flash.net.NetConnection;
	import flash.events.Event;
	import flash.utils.Dictionary;
	import flash.net.GroupSpecifier;
	import flash.net.NetGroup;
	
	//Influxis Classes
	import org.influxis.as3.interfaces.net.IFMS;
	import org.influxis.as3.events.SimpleEvent;
	import org.influxis.as3.data.DataProvider;
	import org.influxis.as3.states.DataStates;
	import org.influxis.as3.utils.ScreenScaler;
	
	//Flotools Classes
	import org.influxis.flotools.containers.DisplayPositioner;
	import org.influxis.flotools.core.InfluxisComponent;
	import org.influxis.flotools.display.CamWindow;
	
	//VidCollaborator Classes
	import org.influxis.application.vidcollaborator.managers.VidCollaboratorManager;
	import org.influxis.application.vidcollaborator.display.LiveUserWindow;
	
	public class VideoDisplay extends InfluxisComponent
	{
		private var _vcm:VidCollaboratorManager;
		private var _netGroup:NetGroup;
		private var _groupSpec:GroupSpecifier;
		private var _activeList:DataProvider;
		private var _adminMode:Boolean;
		private var _windowRef:Dictionary;
		
		private var _display:DisplayPositioner;
		private var _mainWindow:DisplayObject;
		
		/*
		 * INIT API
		 */
		
		public function VideoDisplay(): void
		{
			_windowRef = new Dictionary();
			super();
		}
		 
		/*
		 * CONNECT API
		 */
		
		override protected function instanceClose():void 
		{
			super.instanceClose();
			
			_activeList.removeEventListener( DataStates.ADD, __onActiveListEvent );
			_activeList.removeEventListener( DataStates.REMOVE, __onActiveListEvent );
			_activeList.removeEventListener( DataStates.UPDATE, __onActiveListEvent );
			_activeList.removeEventListener( DataStates.CHANGE, __onActiveListEvent );
			_vcm = null;
			__removeAllWindows();
		}
		
		override protected function instanceChange():void 
		{
			super.instanceChange();
			
			_vcm = VidCollaboratorManager.getInstance(instance);
			_activeList = _vcm.castersList;
			_activeList.addEventListener( DataStates.ADD, __onActiveListEvent );
			_activeList.addEventListener( DataStates.REMOVE, __onActiveListEvent );
			_activeList.addEventListener( DataStates.UPDATE, __onActiveListEvent );
			_activeList.addEventListener( DataStates.CHANGE, __onActiveListEvent );
			__refreshWindows();
		}
		
		/*
		 * PROTECTED API
		 */
		
		 //Removes old and adds the main window to the display
		protected function onMainWindowChanged( value:DisplayObject ): void
		{
			var connectedWindow:IFMS;
			if ( _mainWindow )
			{
				connectedWindow = _mainWindow as IFMS;
				if ( connectedWindow ) 
				{
					closeMainWindowNetGroup();
					connectedWindow.close();
				}
				_display.removeChild(_mainWindow);
				_display.displayContainer = null;
			}
			
			_mainWindow = value;
			if ( !_mainWindow ) return;
			
			connectedWindow = _mainWindow as IFMS;
			if ( connectedWindow && connected ) 
			{
				connectedWindow.connect(_nc);
				checkMainWindowNetGroup();
			}
			_display.addChildAt(_mainWindow, 0);
		}
		
		protected function closeMainWindowNetGroup(): void
		{
			if ( !_mainWindow ) return;
			
			var liveWindow:LiveUserWindow = _mainWindow as LiveUserWindow;
			if ( !liveWindow ) return;
			liveWindow.groupSpec = null;
			liveWindow.netGroup = null;
		}
		
		protected function checkMainWindowNetGroup(): void
		{
			if ( !_mainWindow || !_netGroup || !_groupSpec ) return;
			
			var liveWindow:LiveUserWindow = _mainWindow as LiveUserWindow;
			if ( !liveWindow ) return;
			
			if ( _groupSpec ) liveWindow.groupSpec = _groupSpec;
			if ( _netGroup ) liveWindow.netGroup = _netGroup;
		}
		
		/*
		 * PRIVATE API
		 */
		
		private function __createWindowAt( index:Number, data:Object ): void
		{
			if ( !initialized || !connected ) return;
			
			var window:DisplayObject;
			if ( _vcm.localData.id == data.id )
			{
				window = new CamWindow();
				CamWindow(window).stageVideoEnabled = false;
			}else{
				var liveWindow:LiveUserWindow = new LiveUserWindow();
					liveWindow.streamName = data.streamName + ".mp4";
					liveWindow.showCloseBtn = _adminMode;
					liveWindow.connect(_nc);
				
				if ( _groupSpec ) liveWindow.groupSpec = _groupSpec;
				if ( _netGroup ) liveWindow.netGroup = _netGroup;
				liveWindow.addEventListener( Event.CLOSE, __onWindowClosed );
				window = liveWindow;
			}
			
			_windowRef[window] = {index:index, data:data};
			_display.addChildAt(window, index+1);
		}
		
		private function __destroyWindowAt( index:Number ): void
		{
			if ( !initialized || !connected ) return;
			
			var window:DisplayObject = _display.getChildAt(index + 1);
			if ( window is LiveUserWindow )
			{
				var liveWindow:LiveUserWindow = window as LiveUserWindow;
				
				//remove close listener
				liveWindow.removeEventListener( Event.CLOSE, __onWindowClosed );
				liveWindow.groupSpec = null;
				liveWindow.netGroup = null;
				
				//Close stream and connection to window
				liveWindow.streamName = null;
				liveWindow.close();	
			}
			
			//Clear out reference
			_windowRef[liveWindow] = null;
			delete _windowRef[liveWindow];
			
			//remove child from list
			_display.removeChildAt(index+1);
		}
		
		private function __updateWindowAt( index:Number, data:Object ): void
		{
			if ( !initialized || !connected ) return;
			var liveWindow:LiveUserWindow = _display.getChildAt(index+1) as LiveUserWindow;
			if ( liveWindow ) liveWindow.streamName = data.streamName+".mp4";
		}
		
		private function __refreshWindows(): void
		{
			__removeAllWindows();
			if ( !connected ) return;
			
			var nLen:Number = _activeList.length;
			for ( var i:Number = 0; i < nLen; i++ )
			{
				__createWindowAt(i, _activeList.getItemAt(i));
			}
		}
		
		private function __removeAllWindows(): void
		{
			var connectedItem:IFMS;
			var nLen:Number = _display.numChildren - 1;
			for ( var i:Number = nLen; i > 0; i-- )
			{
				//Minus one to update on real casters list
				if ( i > 0 ) __destroyWindowAt(i-1);
			}
		}
		
		/*
		 * HANDLERS
		 */
		
		private function __onActiveListEvent( event:SimpleEvent ): void
		{
			switch( event.type )
			{
				case DataStates.ADD : 
					__createWindowAt( event.data.slot, event.data.data );
					break;
				case DataStates.UPDATE : 
					__updateWindowAt( event.data.slot, event.data.data );
					break;
				case DataStates.REMOVE : 
					__destroyWindowAt( event.data.slot );
					break;
				case DataStates.CHANGE : 
					__refreshWindows();
					break;
			}
		}
		
		private function __onWindowClosed( event:Event ): void
		{
			if ( event.type == Event.CLOSE )
			{
				//Stop viewer publish and remove from publish list
				_vcm.sendMessageRequest( _windowRef[event.currentTarget].data.id, { type:VidCollaboratorManager.ADMIN_VIDEO_REQUEST, startVideoRequest:false } );
				_vcm.haveViewerJoinPublish( _windowRef[event.currentTarget].data.id, false );
			}
		}
		
		/*
		 * DISPLAY API
		 */
		
		override protected function createChildren():void 
		{
			super.createChildren();
			_display = new DisplayPositioner();
			_display.displayPadding = ScreenScaler.calculateSize(10);
			addChild(_display);
		}
		 
		override protected function arrange():void 
		{
			super.arrange();
			_display.setActualSize(width, height);
		}
		
		/*
		 * GETTER / SETTER
		 */
		
		public function set mainWindow( value:DisplayObject ): void
		{
			onMainWindowChanged(value);
		}
		
		public function get mainWindow(): DisplayObject
		{
			return _mainWindow;
		}
		
		public function get displayPositioner(): DisplayPositioner
		{
			return _display;
		}
		
		public function set adminMode( value:Boolean ): void
		{
			if ( _adminMode == value ) return;
			_adminMode = value;
			if( initialized && connected ) __refreshWindows();
		}
		
		public function get adminMode(): Boolean
		{
			return _adminMode;
		}
		
		public function set netGroup( value:NetGroup ): void
		{
			if ( _netGroup == value ) return;
			_netGroup = value;
			if ( _mainWindow ) checkMainWindowNetGroup();
			if( initialized && connected ) __refreshWindows();
		}
		
		public function get netGroup(): NetGroup
		{
			return _netGroup;
		}
		
		public function set groupSpec( value:GroupSpecifier ): void
		{
			if ( _groupSpec == value ) return;
			_groupSpec = value;
			if ( _mainWindow ) checkMainWindowNetGroup();
			if( initialized && connected ) __refreshWindows();
		}
		
		public function get groupSpec(): GroupSpecifier
		{
			return _groupSpec;
		}
	}
}