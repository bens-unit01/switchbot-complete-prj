package org.influxis.application.vidcollaborator.display 
{
	//Flash Classes
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.NetConnection;
	import flash.net.GroupSpecifier;
	import flash.net.NetGroup;
	
	//Influxis Classes
	import org.influxis.as3.display.Button;
	import org.influxis.as3.utils.SizeUtils;
	
	//Flotools Classes
	import org.influxis.flotools.core.InfluxisComponent;
	import org.influxis.flotools.display.StreamWindow;
	import org.influxis.flotools.managers.PlaybackManager;
	
	public class LiveUserWindow extends InfluxisComponent
	{
		private var _netGroup:NetGroup;
		private var _groupSpec:GroupSpecifier;
		private var _playbackManager:PlaybackManager;
		private var _showCloseBtn:Boolean;
		
		private var _window:StreamWindow;
		private var _closeBtn:Button;
		
		/*
		 * INIT API
		 */
		
		public function LiveUserWindow(): void
		{
			_playbackManager = new PlaybackManager();
			_playbackManager.addEventListener( PlaybackManager.NETSTREAM_CHANGE, __onPlaybackManagerEvent );
			_playbackManager.isLive = true;
			super();
		}
		
		/*
		 * CONNECT API
		 */
		
		override public function connect( p_nc:NetConnection ):Boolean 
		{
			if ( !super.connect(p_nc) ) return false;
			_playbackManager.netConnection = p_nc;
			return true;
		}
		 
		override public function close(): void 
		{
			super.close();
			_playbackManager.netConnection = null;
		}
		
		/*
		 * HANDLERS 
		 */
		
		private function __onPlaybackManagerEvent( event:Event ): void
		{
			if ( event.type == PlaybackManager.NETSTREAM_CHANGE )
			{
				if( initialized ) _window.netstream = _playbackManager.netStream;
			}
		}
		
		/*
		 * HANDLERS
		 */
		
		private function __onCloseBtnClicked( event:Event ): void
		{
			if ( event.type == MouseEvent.MOUSE_DOWN )
			{
				dispatchEvent(new Event(Event.CLOSE));
			}
		}
		
		private function __onVideoDimenstions( event:Event ): void
		{
			invalidateDisplayList();
		}
		
		/*
		 * DISPLAY API
		 */
		
		override protected function createChildren():void 
		{
			super.createChildren();
			_window = new StreamWindow();
			_window.stageVideoEnabled = false;
			
			_closeBtn = new Button();
			_closeBtn.skinName = "liveUserWindowCloseBtnSkin";
			_closeBtn.visible = false;
			
			addChildren(_window, _closeBtn);
		}
		
		override protected function childrenCreated():void 
		{
			super.childrenCreated();
			_window.addEventListener( StreamWindow.VIDEO_DIMENSIONS, __onVideoDimenstions );
			_closeBtn.addEventListener( MouseEvent.MOUSE_DOWN, __onCloseBtnClicked );
			_closeBtn.visible = _showCloseBtn;
			if ( _playbackManager.netStream ) _window.netstream = _playbackManager.netStream;
		}
		
		override protected function arrange():void 
		{
			super.arrange();
			_window.setActualSize(width, height);
			SizeUtils.hookTarget( _closeBtn, _window.videoContainer, SizeUtils.LEFT, paddingRight, true );
			SizeUtils.hookTarget( _closeBtn, _window.videoContainer, SizeUtils.TOP, paddingTop, true );
			
			//SizeUtils.moveX( _closeBtn, width, SizeUtils.RIGHT, paddingRight );
			//SizeUtils.moveY( _closeBtn, height, SizeUtils.TOP, paddingTop );
		}
		
		/*
		 * GETTER / SETTER
		 */
		
		public function set streamName( value:String ): void
		{
			_playbackManager.streamName = value;
		}
		
		public function get streamName(): String
		{
			return _playbackManager.streamName;
		}
		
		public function set showCloseBtn( value:Boolean ): void
		{
			_showCloseBtn = value;
			if ( initialized ) _closeBtn.visible = _showCloseBtn;
		}
		
		public function get showCloseBtn(): Boolean
		{
			return _showCloseBtn;
		}
		
		public function set netGroup( value:NetGroup ): void
		{
			if ( _netGroup == value ) return;
			_netGroup = value;
			_playbackManager.netGroup = _netGroup;
		}
		
		public function get netGroup(): NetGroup
		{
			return _netGroup;
		}
		
		public function set groupSpec( value:GroupSpecifier ): void
		{
			if ( _groupSpec == value ) return;
			_groupSpec = value;
			_playbackManager.groupSpec = _groupSpec;
		}
		
		public function get groupSpec(): GroupSpecifier
		{
			return _groupSpec;
		}
	}
}