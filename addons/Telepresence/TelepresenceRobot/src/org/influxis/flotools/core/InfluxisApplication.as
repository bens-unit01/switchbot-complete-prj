/**
 * InfluxisApplication - Copyright © 2010 Influxis All rights reserved.
**/

package org.influxis.flotools.core 
{
	//Flash Classes
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.NetStatusEvent;
	import flash.events.Event;
	import flash.net.NetConnection;
	import flash.net.ObjectEncoding;
	
	//Influxis Classes
	import org.influxis.as3.core.infx_internal;
	import org.influxis.as3.core.Display;
	//import org.influxis.as3.net.ClientSideCallHandler;
	import org.influxis.as3.net.SettingsLoader;
	import org.influxis.as3.states.ConnectStates;
	import org.influxis.as3.interfaces.net.IFMS;
	import org.influxis.as3.display.StyleComponent;
	import org.influxis.as3.events.SimpleEventConst;
	import org.influxis.as3.utils.FlashDetection;
	import org.influxis.as3.utils.ObjectUtils;
	
	//Influxis P2P Classes
	import org.influxis.p2p.net.P2PConnection;
	
	//Influxis Flotools Classes
	import org.influxis.flotools.core.InfluxisComponent;
	import org.influxis.flotools.utils.InfluxisDetection;
	
	public class InfluxisApplication extends InfluxisComponent implements IFMS
	{
		use namespace infx_internal;
		private var _sVersion:String = "1.0.0.0";
		infx_internal var byPassAppDetection:Boolean;
		
		//protected var callHandler:ClientSideCallHandler = ClientSideCallHandler.getInstance();
		protected var connectParams:Array = new Array();
		protected var settingsPath:String;
		protected var useSettings:Boolean = true;
		protected var useFullScreenSizing:Boolean;
		protected var requiredFlashVersion:String = "10.1";
		protected var settingsLoader:SettingsLoader;
		protected var initScreen:DisplayObject;
		
		private var _rtmp:String;
		private var _autoConnect:Boolean = true;
		private var _bStageAutoSize:Boolean = true;
		private var _bConnecting:Boolean;
		
		/**
		 * INIT API
		 */
		
		public function InfluxisApplication(): void
		{
			super();
		}
		
		override protected function preInitialize(): void 
		{
			if ( initScreen )
			{
				initScreen.width = stage.fullScreenWidth;//useFullScreenSizing ? stage.fullScreenWidth : stage.stageWidth;
				initScreen.height = stage.fullScreenHeight;//useFullScreenSizing ? stage.fullScreenHeight : stage.stageHeight;
				stage.addChild(initScreen);
			}
			
			if ( !Display.APPLICATION ) Display.APPLICATION = this;
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			//Check if custom settings path exists
			var params:Object = (Display.ROOT.loaderInfo).parameters;
			if ( params )
			{
				if ( params.settingsPath != undefined ) settingsPath = params.settingsPath;
				if ( params.requiredFlashVersion != undefined ) requiredFlashVersion = params.requiredFlashVersion;
			}
			
			//Check required flash version
			if ( !FlashDetection.checkRequiredVersion(requiredFlashVersion) )
			{
				//Forces the framework to init
				infx_internal::__setInitialize();
				
				//Attach alert and show
				FlashDetection.wrongVersionAlert(this);
				visible = true;
				return;
			}
			
			if ( useSettings )
			{
				loadSettings();
			}else{
				super.preInitialize();
				if ( autoConnect ) connection();
			}
		}
		
		override protected function init(): void
		{
			if ( !appAllowed() && !byPassAppDetection )
			{
				//Forces the framework to init
				infx_internal::__setInitialize();
				
				//Attach alert and show
				InfluxisDetection.wrongVersionAlert(this);
				visible = true;
				return;
			}else{
				super.init();
				stage.addEventListener( Event.RESIZE, __onMainStageResize );
				if ( stageAutoSize ) __onMainStageResize( new Event(Event.RESIZE) );
			}	
		}
		
		/**
		 * PROTECTED API
		 */
		
		protected final function appAllowed(): Boolean
		{
			if ( __isMobileSite() ) return true;
			return !rtmp ? false : (rtmp.indexOf( "rtmphost.com" ) != -1 || 
									rtmp.indexOf( "rtmpserver.com" ) != -1 || 
									rtmp.indexOf( "devoffice.influxis.com" ) != -1 );
		}
		
		private function __isMobileSite(): Boolean
		{
			var bIsMobile:Boolean;
			try 
			{
				bIsMobile = Display.ROOT.loaderInfo.url.indexOf( "mobile.influxis.com" ) != -1 || 
							Display.ROOT.loaderInfo.url.indexOf( "mobile3.influxis.com" ) != -1;
			}catch ( e:Error )
			{
				//Do nothing is params are null
			}
			return bIsMobile;
		}
		 
		protected function connectAccepted( info:Object = null, reconnection:Boolean = false ): void 
		{
			_bConnected = true;
			instanceChange();
			connectAllChildren();
		}
		
		protected function connectionOpened( info:Object = null ): void
		{
			
		}
		
		protected function connectionFailed( info:Object = null ): void
		{
			
		}
		
		protected function connectionClosed( info:Object = null ): void
		{
			
		}
		
		protected function loadSettings(): void
		{
			if ( settingsLoader ) 
			{
				settingsLoader.load(settingsPath);
			}else {
				settingsLoader = SettingsLoader.getInstance(settingsPath);
				settingsLoader.addEventListener(Event.COMPLETE, __onSettingsLoaded);
			}
		}
		
		protected function onSettingsReady( p_bConnect:Boolean = true ): void
		{
			if ( !_rtmp ) _rtmp = settingsLoader.rtmp;
			if ( settingsLoader.skin ) StyleComponent.SKINS_PATH = settingsLoader.skin.indexOf(".xml") == -1 ? settingsLoader.skin+".xml" : settingsLoader.skin;
			if ( autoConnect && p_bConnect ) connection();
			super.preInitialize();
		}
		
		/**
		 * CONNECT API
		**/
		
		protected function connection(): void
		{
			if ( !_rtmp || connected || _bConnecting ) return;
			
			_bConnecting = true;
			if( !_nc )
			{
				_nc = new P2PConnection();
				_nc.addEventListener( NetStatusEvent.NET_STATUS, onConnect );
				_nc.addEventListener( SimpleEventConst.STATE, onConnectState );
			}
			
			_nc.connect.apply( _nc, new Array(_rtmp).concat(connectParams) );
			connectionOpened();
		}
		
		override public function close(): void 
		{
			_bConnected = false;
			_nc.close();
		}
		
		protected function onConnect( p_nse:NetStatusEvent ): void
		{
			/*var code:String = p_nse.info.code;
			_bConnecting = false;
			trace( "onConnect: " + code );
			
			var infxnc:INFXConnection = _nc as INFXConnection;
			if( code == INFXConnection.CONNECTED )
			{
				connectAccepted();
			}else if( code == INFXConnection.REJECTED || code == INFXConnection.FAILED )
			{
				connectionFailed();
			}else if( code == INFXConnection.CLOSED )
			{
				connectionClosed();
			}*/
		}
		
		protected function onConnectState( event:Event ): void
		{
			_bConnecting = false;
			var infxConnect:P2PConnection = _nc as P2PConnection;
			if ( infxConnect )
			{
				if ( infxConnect.state == ConnectStates.CONNECTED )
				{
					connectAccepted(infxConnect.lastInfo, infxConnect.reconnected);
				}else if ( infxConnect.state == ConnectStates.FAILED || infxConnect.state == ConnectStates.REJECTED )
				{
					connectionFailed(ObjectUtils.duplicateObject(infxConnect.lastInfo));
				}else if ( infxConnect.state == ConnectStates.CLOSED || infxConnect.state == ConnectStates.RECONNECTING )
				{
					connectionClosed(infxConnect.lastInfo);
					
				}
			}
		}
		
		/**
		 * HANDLERS
		 */
		
		private function __onMainStageResize( p_e:Event ): void 
		{
			if ( stageAutoSize ) 
			{
				if ( useFullScreenSizing )
				{
					setActualSize( stage.fullScreenWidth, stage.fullScreenHeight );
				}else {
					setActualSize( stage.stageWidth, stage.stageHeight );
				}
			}
		}
		
		private function __onSettingsLoaded( p_e:Event ): void
		{
			onSettingsReady();
		}
		
		/**
		 * DISPLAY API
		 */
		
		override protected function childrenCreated(): void 
		{
			super.childrenCreated();
			
			if ( initScreen )
			{
				initScreen.width = 0;
				initScreen.height = 0;
				stage.removeChild(initScreen);
				initScreen = null;
			}
		}
		 
		/*import flash.text.TextField;
		public function writeDebugger( ...args ): void
		{
			var aArgs:Array = args as Array;
			if ( !aArgs ) return;
			
			sDebugMsg = sDebugMsg +(aArgs.join(" : ")) + "\n";
			if ( lDebugger ) 
			{
				lDebugger.text = sDebugMsg;
				lDebugger.width = width;
				lDebugger.height = height;
			}
		}
		
		private var sDebugMsg:String = "";
		private var lDebugger:TextField;
		
		override protected function childrenCreated():void 
		{
			super.childrenCreated();
			
			if ( !lDebugger )
			{
				lDebugger = new TextField();
				lDebugger.textColor = 0xcccccc;
				lDebugger.text = sDebugMsg;
				addChild(lDebugger);
			}
		}*/
		
		/**
		 * GETTER / SETTER
		 */
		
		public function set rtmp( value:String ):void 
		{
			if ( _rtmp == value || !value ) return;
			
			_rtmp = value;
			if ( connected ) close();
			if( _autoConnect ) connection();
		}
		
		public function get rtmp(): String
		{ 
			return _rtmp;
		}
		
		public function set autoConnect( value:Boolean ): void 
		{
			if ( _autoConnect == value ) return;
			
			_autoConnect = value;
			if ( rtmp && !connected && _autoConnect ) connection();
		}
		
		public function get autoConnect(): Boolean
		{ 
			return _autoConnect; 
		}
		
		public function set stageAutoSize( value:Boolean ): void
		{
			_bStageAutoSize = value;
		}
		
		public function get stageAutoSize(): Boolean
		{ 
			return _bStageAutoSize; 
		}
	}
}