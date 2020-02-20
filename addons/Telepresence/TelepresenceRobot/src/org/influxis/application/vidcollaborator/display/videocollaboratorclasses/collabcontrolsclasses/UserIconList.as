package org.influxis.application.vidcollaborator.display.videocollaboratorclasses.collabcontrolsclasses 
{
	//Flash Classes
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.NetConnection;
	import flash.text.TextField;
	import flash.geom.Rectangle;
	import flash.events.MouseEvent;
	
	//Influxis Classes
	import org.influxis.as3.display.Alert;
	import org.influxis.as3.states.DataStates;
	import org.influxis.as3.data.DataProvider;
	import org.influxis.as3.display.StyleCanvas;
	import org.influxis.as3.display.Button;
	import org.influxis.as3.utils.StringUtils;
	import org.influxis.as3.utils.SizeUtils;
	import org.influxis.as3.utils.ScreenScaler;
	import org.influxis.as3.managers.SelectionManager;
	import org.influxis.as3.events.SimpleEventConst;
	
	//Influxis Flotools
	import org.influxis.flotools.core.InfluxisComponent;
	
	//VideoCollaborator Classes
	import org.influxis.application.vidcollaborator.managers.VidCollaboratorManager;
	import org.influxis.application.vidcollaborator.list.ViewersList;
	
	public class UserIconList extends InfluxisComponent
	{
		private var _vcm:VidCollaboratorManager;
		private var _cameraList:DataProvider;
		
		private var _compsHolder:Sprite;
		private var _viewerList:ViewersList;
		private var _openCloseBtn:Button;
		private var _cameraCount:TextField;
		private var _requestLabel:TextField;
		private var _bShowList:Boolean;
		private var _listViewInitialized:Boolean;
		
		/*
		 * INIT API
		 */
		
		override protected function preInitialize():void 
		{	
			super.preInitialize();
		}
		
		/*
		 * CONNECT API
		 */
		
		override public function connect(p_nc:NetConnection):Boolean 
		{
			if ( !super.connect(p_nc) ) return false;
			
			if ( initialized )
			{
				_viewerList.connect(_nc);
			}
			
			return true;
		}
		 
		override public function close():void 
		{
			super.close();
			if ( initialized )
			{
				_viewerList.close();
			}
		}
		
		override protected function instanceClose():void 
		{
			super.instanceClose();
			
			_cameraList.removeEventListener( DataStates.ADD, __onDataChanged );
			_cameraList.removeEventListener( DataStates.UPDATE, __onDataChanged );
			_cameraList.removeEventListener( DataStates.REMOVE, __onDataChanged );
			_cameraList.removeEventListener( DataStates.CHANGE, __onDataChanged );
			_cameraList = null;
			
			//Since its not part of the display tree we have to manually put in the instance
			if ( initialized ) _viewerList.instance = null;
			
			_vcm = null;
			
			if ( initialized )
			{
				_cameraCount.text = "0000";
				_bShowList = false;
				refreshListView();
			}
		}
		
		override protected function instanceChange():void 
		{
			super.instanceChange();
			
			_vcm = VidCollaboratorManager.getInstance(instance);
			
			_cameraList = _vcm.cameraList;
			_cameraList.addEventListener( DataStates.ADD, __onDataChanged );
			_cameraList.addEventListener( DataStates.UPDATE, __onDataChanged );
			_cameraList.addEventListener( DataStates.REMOVE, __onDataChanged );
			_cameraList.addEventListener( DataStates.CHANGE, __onDataChanged );
			
			//Since its not part of the display tree we have to manually put in the instance
			if ( initialized ) 
			{
				_viewerList.instance = instance;
				invalidateDisplayList();
			}
		}
		
		/*
		 * PROTECTED API
		 */
		
		protected final function toggleListView(): void
		{
			if ( !instance ) return;
			_bShowList = !_bShowList;
			refreshListView();
		}
		
		protected function refreshListView(): void
		{
			_compsHolder.x = _bShowList ? 0 : width - _viewerList.x;
		}
		
		protected function refreshRequestCount(): void
		{
			if ( !initialized || !_cameraList ) return;
			
			if ( _cameraList.length > 0 && _cameraCount.text == "0" && !_bShowList ) toggleListView();
			_cameraCount.text = String(_cameraList.length);
		}
		
		/*
		 * HANDLERS
		 */
		
		private function __onToggleListEvent( event:Event ): void
		{
			if ( event.type == MouseEvent.MOUSE_DOWN )
			{
				toggleListView();
			}
		}
		
		private function __onDataChanged( event:Event ): void
		{
			refreshRequestCount();
		}
		
		private function __onViewerListEvent( event:Event ): void
		{
			
		}
		
		/*
		 * DISPLAY API
		 */
		
		override protected function measure():void 
		{
			super.measure();
			measuredWidth = _openCloseBtn.width;
			measuredHeight = _viewerList.measuredHeight+_openCloseBtn.height;
		}
		
		override protected function createChildren():void 
		{
			super.createChildren();
			
			_viewerList = new ViewersList();
			_viewerList.skinName = "userIconList";
			_openCloseBtn = new Button();
			_openCloseBtn.skinName = "userIconToggleBtn";
			
			_cameraCount = getStyleText("cameraCount");
			_cameraCount.selectable = false;
			_requestLabel = getStyleText("requestLabel");
			_requestLabel.selectable = false;
			
			_compsHolder = new Sprite();
			addChildren(_openCloseBtn, _cameraCount, _requestLabel, _viewerList, _compsHolder);
		}
		
		override protected function childrenCreated():void 
		{
			super.childrenCreated();
			
			_compsHolder.addChild(_openCloseBtn);
			_compsHolder.addChild(_cameraCount);
			_compsHolder.addChild(_requestLabel);
			_compsHolder.addChild(_viewerList);
			
			_viewerList.addEventListener( SelectionManager.ITEM_CLICK, __onViewerListEvent );
			
			_cameraCount.text = "0000";
			var measuredText:Rectangle = StringUtils.measureText( _cameraCount.text, _cameraCount.defaultTextFormat );
			_cameraCount.height = measuredText.height;
			
			_requestLabel.text = getLabelAt("requests");
			measuredText = StringUtils.measureText( _requestLabel.text, _requestLabel.defaultTextFormat );
			_requestLabel.width = measuredText.width; _requestLabel.height = measuredText.height;
			
			_openCloseBtn.addEventListener( MouseEvent.MOUSE_DOWN, __onToggleListEvent );
			
			//Connect comps if not connected
			if ( connected ) _viewerList.connect(_nc);
			if ( instance ) _viewerList.instance = instance;  
			refreshRequestCount();
			refreshListView();
		}
		
		override protected function arrange(): void 
		{
			super.arrange();
			
			_openCloseBtn.width = width;
			
			//Size and arrange list
			_viewerList.move( paddingLeft, _openCloseBtn.height );
			_viewerList.setActualSize( width - _viewerList.x, height - _viewerList.y );
			
			//Size and arrange labels
			_cameraCount.width = _viewerList.width;
			_cameraCount.y = (_openCloseBtn.height / 2) - ((_cameraCount.height + (_requestLabel.height-ScreenScaler.calculateSize(7))) / 2);
			SizeUtils.hookTarget( _requestLabel, _cameraCount, SizeUtils.BOTTOM, -ScreenScaler.calculateSize(7) );
			SizeUtils.hookTarget( _cameraCount, _viewerList, SizeUtils.CENTER, 0, true );
			SizeUtils.hookTarget( _requestLabel, _viewerList, SizeUtils.CENTER, 0, true );
			
			if ( !_listViewInitialized && _cameraList )
			{
				_listViewInitialized = true;
				if ( _cameraList.length > 0 ) _bShowList = true;
				refreshListView();
			}
		}
	}
}