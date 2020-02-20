/**
 * JSStreamController - Copyright � 2010 Influxis All rights reserved.
**/

package org.influxis.as3.controls 
{
	//Flash Classes
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.system.Security;
	
	//Influxis Classes
	import org.influxis.as3.events.SimpleEventConst
	import org.influxis.as3.utils.handler;
	
	//Influxis OSMF Classes
	import org.influxis.osmf.display.OSMFPlayer;
	
	public class JSStreamController
	{
		private var _controller:OSMFPlayer;
		
		/**
		 * INIT
		 */
		
		//Setup commands to run through from JS
		public function JSStreamController() 
		{
			if ( ExternalInterface.available )
			{
				//Allows js calls to the script
				Security.allowDomain( "*" );
				
				try 
				{
					ExternalInterface.addCallback( "playVideo", handler(__runCommand, "play") );
					ExternalInterface.addCallback( "pauseVideo", handler(__runCommand, "pause") );
					ExternalInterface.addCallback( "stopVideo", handler(__runCommand, "stop") );
					ExternalInterface.addCallback( "seekVideo", handler(__runCommand, "seek") );
					ExternalInterface.addCallback( "setVolume", handler(__runCommand, "volume") );
					ExternalInterface.addCallback( "setMute", handler(__runCommand, "mute") );
					ExternalInterface.addCallback( "setFullScreen", handler(__runCommand, "fullScreen") );
					ExternalInterface.addCallback( "setContentPath", handler(__runCommand, "contentPath") );
					ExternalInterface.addCallback( "setIsYT", handler(__runCommand, "isYT") );
					ExternalInterface.addCallback( "setMediaUrl", handler(__runCommand, "mediaUrl") );
					ExternalInterface.addCallback( "setIsMulticast", handler(__runCommand, "isMulticast") );
					ExternalInterface.addCallback( "setIsLive", handler(__runCommand, "isLive") );
					ExternalInterface.addCallback( "setIsDVR", handler(__runCommand, "isDVR") );
					ExternalInterface.addCallback( "setIsProgressive", handler(__runCommand, "isProgressive") );
					ExternalInterface.addCallback( "setYoutubeQuality", handler(__runCommand, "youtubeQuality") );
					ExternalInterface.addCallback( "setScaleMode", handler(__runCommand, "scaleMode") );
					ExternalInterface.addCallback( "setImage", handler(__runCommand, "image") );
					ExternalInterface.addCallback( "setLogo", handler(__runCommand, "logo") );
					ExternalInterface.addCallback( "setAutoPlay", handler(__runCommand, "autoPlay") );
					ExternalInterface.addCallback( "setAutoDetect", handler(__runCommand, "autoDetect") );
					ExternalInterface.addCallback( "setSmoothing", handler(__runCommand, "smoothing") );
					ExternalInterface.addCallback( "setBuffer", handler(__runCommand, "buffer") );
					ExternalInterface.addCallback( "setUseDualBuffer", handler(__runCommand, "useDualBuffer") );
					ExternalInterface.addCallback( "setStartTime", handler(__runCommand, "startTime") );
					ExternalInterface.addCallback( "setShowControls", handler(__runCommand, "showControls") );
					ExternalInterface.addCallback( "setControlsPosition", handler(__runCommand, "controlsPosition") );
					ExternalInterface.addCallback( "setAvailableControls", handler(__runCommand, "availableControls") );
					ExternalInterface.addCallback( "setInverseCurrentTime", handler(__runCommand, "inverseCurrentTime") );
					ExternalInterface.addCallback( "getPlaying", handler(__runCommand, "playing") );
					ExternalInterface.addCallback( "getPaused", handler(__runCommand, "paused") );
					ExternalInterface.addCallback( "getTime", handler(__runCommand, "time") );
					ExternalInterface.addCallback( "getLength", handler(__runCommand, "length") );
					ExternalInterface.addCallback( "setGroupSpec", handler(__runCommand, "groupSpec") );
					ExternalInterface.addCallback( "setMulticastGroup", handler(__runCommand, "multicastGroup") );
					ExternalInterface.addCallback( "setMulticastPassword", handler(__runCommand, "multicastPassword") );
					ExternalInterface.addCallback( "setMulticastAddress", handler(__runCommand, "multicastAddress") );
				}catch ( e:Error )
				{
					trace( ":: ExternalInterface ERROR :: " + e.message );
				}
			}
		}
		
		/**
		 * PRIVATE API
		 */
		
		private function __unregister(): void
		{
			if ( !_controller ) return;
			
			_controller.removeEventListener( SimpleEventConst.STATE, __onPlayerEvent );
			_controller.removeEventListener( SimpleEventConst.TIME, __onPlayerEvent );
			_controller.removeEventListener( SimpleEventConst.DURATION, __onPlayerEvent );
			_controller = null;
		}
		 
		private function __register( value:OSMFPlayer ): void
		{
			__unregister();
			if ( !value ) return;
			
			_controller = value;
			_controller.addEventListener( SimpleEventConst.STATE, __onPlayerEvent );
			_controller.addEventListener( SimpleEventConst.TIME, __onPlayerEvent );
			_controller.addEventListener( SimpleEventConst.DURATION, __onPlayerEvent );
		}
		
		//Runs commands sent in from JS
		private function __runCommand( ...args ): *
		{
			if ( !_controller ) return;
			
			var aArgs:Array = args as Array;
			var command:String = aArgs[aArgs.length == 1?0:1];
			var value:* = aArgs.length > 1 ? aArgs[0] : undefined;
			var returnValue:*;
			
			switch( command )
			{
				case "play" : 
					_controller.pause();
					break;
				case "pause" : 
					_controller.pause();
					break;
				case "stop" : 
					_controller.stop();
					break;
				case "seek" : 
					if( !isNaN(value) ) _controller.seek(Number(value));
					break;
				case "volume" : 
					if( !isNaN(value) ) _controller.volume = Number(value);
					break;
				case "mute" : 
					if( value != undefined ) _controller.muted = (value == true||value=="true");
					break;
				case "fullScreen" : 
					if( value != undefined ) _controller.fullScreen = (value == true||value=="true");
					break;
				case "contentPath" : 
					if( value != undefined ) _controller.contentPath = String(value);
					break;
				case "isYT" : 
					if( value != undefined ) _controller.isYoutube = (value == true||value=="true");
					break;
				case "isMulticast" :
					if( value != undefined ) _controller.isMulticast = (value == true||value=="true");
					break;
				case "isLive" : 
					if( value != undefined ) _controller.isLive = (value == true||value=="true");
					break;
				case "isDVR" : 
					if( value != undefined ) _controller.isDVR = (value == true||value=="true");
					break;
				case "isProgressive" : 
					if( value != undefined ) _controller.isProgressive = (value == true||value=="true");
					break;
				case "youtubeQuality" : 
					if( value != undefined ) _controller.youtubeQuality = String(value);
					break;
				case "scaleMode" : 
					if( value != undefined ) _controller.scaleMode = String(value);
					break;
				case "image" : 
					if( value != undefined ) _controller.image = String(value);
					break;
				case "logo" : 
					if( value != undefined ) _controller.logo = String(value);
					break;
				case "autoPlay" : 
					if( value != undefined ) _controller.autoPlay = (value == true||value=="true");
					break;
				case "autoDetect" : 
					if( value != undefined ) _controller.noServerDetect = !(value == true||value=="true");
					break;
				case "smoothing" : 
					if( value != undefined ) _controller.smoothing = (value == true||value=="true");
					break;
				case "buffer" : 
					if( !isNaN(value) ) _controller.buffer = Number(value);
					break;
				case "useDualBuffer" : 
					if( value != undefined ) _controller.useDualBuffer = (value == true||value=="true");
					break;
				case "startTime" : 
					if( !isNaN(value) ) _controller.startTime = Number(value);
					break;
				case "showControls" : 
					if( value != undefined ) _controller.showControls = String(value);
					break;
				case "controlsPosition" : 
					if( value != undefined ) _controller.controlsPosition = String(value);
					break;
				case "availableControls" : 
					if( value != undefined ) _controller.availableControls = String(value);
					break;
				case "inverseCurrentTime" : 
					if( value != undefined ) _controller.inverseCurrentTime = (value == true||value=="true");
					break;
				case "playing" :
					returnValue = _controller.playing;
					break;
				case "paused" :
					returnValue = _controller.paused;
					break;
				case "time" :
					returnValue = _controller.time;
					break;
				case "length" :
					returnValue = _controller.length;
					break;
				case "groupSpec" : 
					if( value != undefined ) _controller.groupSpec = String(value);
					break;
				case "multicastGroup" : 
					if( value != undefined ) _controller.multicastGroup = String(value);
					break;
				case "multicastPassword" : 
					if( value != undefined ) _controller.multicastPassword = String(value);
					break;
				case "multicastAddress" : 
					if( value != undefined ) _controller.multicastAddress = String(value);
					break;
				case "mediaUrl" : 
					if( value != undefined ) _controller.url = String(value);
					break;
			}
			return returnValue;
		}
		
		/**
		 * HANDLERS
		**/
		
		private function __onPlayerEvent( event:Event ): void
		{
			if ( !ExternalInterface.available ) return;
			
			if ( event.type == SimpleEventConst.STATE )
			{
				ExternalInterface.call( "onState", _controller.state );
			}else if ( event.type == SimpleEventConst.TIME )
			{
				ExternalInterface.call( "onTime", _controller.time );
			}else if ( event.type == SimpleEventConst.DURATION )
			{
				ExternalInterface.call( "onDuration", _controller.length );
			}
		}
		
		/**
		 * GETTER / SETTER
		**/
		
		public function set controller( value:OSMFPlayer ): void
		{
			if ( value == _controller ) return;
			__register(value) ;
		}
		
		public function get controller(): OSMFPlayer
		{
			return _controller;
		}
	}
}