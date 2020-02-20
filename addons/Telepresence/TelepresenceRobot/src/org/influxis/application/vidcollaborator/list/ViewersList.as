package org.influxis.application.vidcollaborator.list 
{
	//Influxis Classes
	import flash.events.Event;
	import flash.net.NetConnection;
	import flash.text.TextField;
	import flash.geom.Rectangle;
	import org.influxis.as3.interfaces.net.IFMS;
	
	//Influxis Classes
	import org.influxis.as3.data.DataProvider;
	import org.influxis.as3.states.DataStates;
	import org.influxis.as3.display.List;
	import org.influxis.as3.utils.SizeUtils;
	import org.influxis.as3.utils.StringUtils;
	import org.influxis.as3.utils.ScreenScaler;
	
	//Flotools Classes
	import org.influxis.flotools.list.ConnectedList;
	
	//VideoCollaboration Classes
	import org.influxis.application.vidcollaborator.managers.VidCollaboratorManager;
	import org.influxis.application.vidcollaborator.list.viewerslistclasses.ViewerListItem;
	
	public class ViewersList extends ConnectedList implements IFMS
	{
		private var _vcm:VidCollaboratorManager;
		private var _cameraList:DataProvider;
		private var _noUserLabel:TextField;
		
		/*
		 * INIT API
		 */
		
		override protected function preInitialize(): void 
		{
			cellRenderer = ViewerListItem;
			super.preInitialize();
		}
		
		/*
		 * CONNECT API
		 */
		
		override protected function instanceClose():void 
		{
			super.instanceClose();
			
			_cameraList.removeEventListener( DataStates.ADD, __onDataChanged );
			_cameraList.removeEventListener( DataStates.UPDATE, __onDataChanged );
			_cameraList.removeEventListener( DataStates.REMOVE, __onDataChanged );
			_cameraList.removeEventListener( DataStates.CHANGE, __onDataChanged );
			_cameraList = null;
			
			source = null;
			_vcm = null;
			
			if ( initialized ) _noUserLabel.visible = true;
		}
		
		override protected function instanceChange():void 
		{
			super.instanceChange();
			
			_vcm = VidCollaboratorManager.getInstance();
			_cameraList = _vcm.cameraList;
			_cameraList.addEventListener( DataStates.ADD, __onDataChanged );
			_cameraList.addEventListener( DataStates.UPDATE, __onDataChanged );
			_cameraList.addEventListener( DataStates.REMOVE, __onDataChanged );
			_cameraList.addEventListener( DataStates.CHANGE, __onDataChanged );
			source = _cameraList;
			
			if ( initialized ) _noUserLabel.visible = _cameraList.length == 0;
		}
		
		/*
		 * HANDLERS
		 */
		
		private function __onDataChanged( event:Event ): void
		{
			if ( initialized ) _noUserLabel.visible = _cameraList.length == 0;
		}
		 
		/*
		 * DISPLAY API
		 */
		
		override protected function measure():void 
		{
			super.measure();
			measuredWidth = _noUserLabel.width + (paddingLeft + paddingRight);
			measuredHeight = ScreenScaler.calculateSize(200);
		}
		 
		override protected function createChildren():void 
		{
			super.createChildren();
			_noUserLabel = getStyleText("noUsers");
			_noUserLabel.selectable = false;
			addChild(_noUserLabel);
		}
		
		override protected function childrenCreated():void 
		{
			super.childrenCreated();
			_noUserLabel.text = getLabelAt("noUsers");
			var measured:Rectangle = StringUtils.measureText( _noUserLabel.text, _noUserLabel.defaultTextFormat );
			_noUserLabel.width = measured.width; _noUserLabel.height = measured.height;
			_noUserLabel.visible = !_cameraList ? true : _cameraList.length == 0;
		}
		
		override protected function arrange():void 
		{
			super.arrange();
			SizeUtils.moveX( _noUserLabel, width, SizeUtils.CENTER );
			SizeUtils.moveY( _noUserLabel, height, SizeUtils.MIDDLE );
		}
	}
}