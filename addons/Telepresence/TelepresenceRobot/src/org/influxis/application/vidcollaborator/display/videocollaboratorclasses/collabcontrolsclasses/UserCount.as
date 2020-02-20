package org.influxis.application.vidcollaborator.display.videocollaboratorclasses.collabcontrolsclasses 
{
	//Flash Classes
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	//Influxis Classes
	import org.influxis.flotools.core.InfluxisComponent;
	import org.influxis.as3.display.Label;
	import org.influxis.as3.core.infx_internal;
	import org.influxis.as3.data.DataProvider;
	import org.influxis.as3.states.DataStates;
	import org.influxis.as3.utils.SizeUtils;
	
	//VidCollaborator Classes
	import org.influxis.application.vidcollaborator.managers.VidCollaboratorManager;
	
	public class UserCount extends InfluxisComponent
	{
		use namespace infx_internal;
		private var _vcm:VidCollaboratorManager;
		private var _nUserCount:uint;
		private var _countLabel:Label;
		private var _countIcon:DisplayObject;
		private var _countBG:DisplayObject;
		
		/*
		 * INIT API
		 */
		
		public function UserCount(): void
		{
			super();
		}
		
		/*
		 * CONNECTED API
		 */
		
		override protected function instanceClose():void 
		{
			super.instanceClose();
			
			_vcm.viewerList.removeEventListener( DataStates.ADD, __onViewerListEvent );
			_vcm.viewerList.removeEventListener( DataStates.UPDATE, __onViewerListEvent );
			_vcm.viewerList.removeEventListener( DataStates.REMOVE, __onViewerListEvent );
			_vcm.viewerList.removeEventListener( DataStates.CHANGE, __onViewerListEvent );
			_vcm = null;
			
			userCount = 0;
		}
		
		override protected function instanceChange():void 
		{
			super.instanceChange();
			
			_vcm = VidCollaboratorManager.getInstance();
			_vcm.viewerList.addEventListener( DataStates.ADD, __onViewerListEvent );
			_vcm.viewerList.addEventListener( DataStates.UPDATE, __onViewerListEvent );
			_vcm.viewerList.addEventListener( DataStates.REMOVE, __onViewerListEvent );
			_vcm.viewerList.addEventListener( DataStates.CHANGE, __onViewerListEvent );
			userCount = _vcm.viewerList.length;
		}
		
		/*
		 * PROTECTED API
		 */
		
		protected function refreshDisplay(): void
		{
			if ( !initialized ) return;
			_countLabel.text = String(_nUserCount);
		}
		 
		/*
		 * HANDLERS
		 */
		
		private function __onViewerListEvent( event:Event ): void
		{
			userCount = _vcm.viewerList.length;
		}
		 
		/*
		 * DISPLAY API
		 */
		
		override protected function measure():void 
		{
			super.measure();
			var backgroundDisplay:DisplayObject = getStyleGraphic("background");
			var backgroundIcon:DisplayObject = getStyleGraphic("icon");
			measuredWidth = backgroundDisplay.width + (backgroundIcon.width/2);
			measuredHeight = backgroundIcon.height;
		}
		 
		override protected function createChildren():void 
		{
			super.createChildren();
			_countLabel = new Label( skinName, null, "label" );
			_countIcon = getStyleGraphic("icon");
			_countBG = getStyleGraphic("background");
			
			addChildren(_countBG, _countIcon, _countLabel);	
		}
		
		override protected function childrenCreated():void 
		{
			super.childrenCreated();
			infx_internal::showBackground(false);
			refreshDisplay();
		}
		
		override protected function arrange(): void 
		{
			super.arrange();
			//_countLabel.width = width - (paddingLeft + paddingRight);
			//_countLabel.height = height - (paddingTop + paddingBottom);
			//_countLabel.x = paddingLeft; _countLabel.y = paddingTop;
			
			_countBG.width = width - (_countIcon.width / 2);
			_countLabel.width = _countBG.width;
			
			SizeUtils.moveX( _countIcon, width, SizeUtils.RIGHT );
			SizeUtils.hookTarget( _countBG, _countIcon, SizeUtils.BOTTOM, 0, true );
			SizeUtils.hookTarget( _countLabel, _countBG, SizeUtils.BOTTOM, 0, true );
		}
		 
		/*
		 * GETTER / SETTER
		 */
		
		public function set userCount( value:uint ): void
		{
			if ( _nUserCount == value ) return;
			_nUserCount = value;
			refreshDisplay();
		}
		
		public function get userCount(): uint
		{
			return _nUserCount;
		}
	}
}