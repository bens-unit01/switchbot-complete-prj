package org.influxis.flotools.data 
{
	//Flash Classes
	import flash.media.Camera;
	import flash.media.Microphone;
	import flash.media.SoundCodec;
	import flash.net.SharedObject;
	import flash.net.NetStream;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.media.H264VideoStreamSettings;
	import flash.media.VideoStreamSettings;
	import flash.media.H264Level;
	import flash.media.H264Profile;
	
	//Influxis Classes
	import org.influxis.as3.utils.ObjectUtils;
	import org.influxis.flotools.net.BWDetect;
	import org.influxis.as3.core.Display;
	
	//Handles all the camera and stream settings for quality and also manages and saves presets
	public class MediaSettings extends EventDispatcher
	{
		private static var __mds:MediaSettings;
		
		//Events
		public static const CAMERA_CHANGE:String = "cameraChange";
		public static const MICROPHONE_CHANGE:String = "microphoneChange";
		public static const INITIALIZED:String = "mediaInitialized";
		public static var USE_ECHO_CANCELLATION:Boolean = false;
		
		public static const EDGE:String = "edge";
		public static const LOW_3G:String = "low";
		public static const SMALL:String = "small";
		public static const MEDIUM:String = "medium";
		public static const HIGH:String = "high";
		public static const HD_480:String = "hd480";
		public static const HD_540:String = "hd540";
		public static const HD_720:String = "hd720";
		public static const HD_900:String = "hd900";
		public static const FULL_HD:String = "fullhd";
		public static const CUSTOM:String = "custom";
		
		public static const SPARK_CODEC:String = "spark";
		public static const H264_CODEC:String = "h264";
		//public static const VP6_CODEC:String = "vp6";
		
		public static var PRESET_SETTINGS:Object;
		public static const PRESET_SETTINGS_BOX:Object = 
		{
			edge:	{ width:128, height:96, fps:10, bandwidth:32000, quality:90, bwDetect:0.15, encodeQuality:3 },
			low:	{ width:256, height:192, fps:10, bandwidth:32000, quality:90, bwDetect:0.15, encodeQuality:5 },
			small:	{ width:384, height:288, fps:12, bandwidth:32000, quality:90, bwDetect:0.15, encodeQuality:6 },
			medium:	{ width:512, height:384, fps:15, bandwidth:56000, quality:90, bwDetect:0.12, encodeQuality:6 },
			high: 	{ width:640, height:480, fps:18, bandwidth:96000, quality:90, bwDetect:0.95, encodeQuality:6 }
		}
		
		private var _cam:Camera;
		private var _mic:Microphone;
		private var _ls:SharedObject;
		private var _settings:Object;
		private var _stream:NetStream;
		private var _slotID:String;
		private var _codec:String;
		private var _initMedia:Boolean;
		private var _useSpeex:Boolean;
		private var _gain:Number;
		private var _bwChecker:BWDetect;
		private var _metaData:Object;
		private var _bAutoMode:Boolean;
		private var _bUseWideScreen:Boolean;
		private var _qualityLimitationLevel:Number = -1;
		
		/*
		 * INIT API
		 */
		
		public function MediaSettings(): void
		{
			if ( Display.IS_MOBILE )
			{
				PRESET_SETTINGS = 
				{
					edge:	{ width:128, height:72, fps:10, encodeQuality:4, keyFrames:18 },
					low:	{ width:256, height:144, fps:10, encodeQuality:5, keyFrames:18 },
					small:	{ width:384, height:216, fps:12, keyFrames:18 },
					medium:	{ width:512, height:288, fps:13, keyFrames:19 },
					high: 	{ width:640, height:360, fps:14, keyFrames:19 },
					hd480: 	{ width:832, height:468, fps:15, keyFrames:20 },
					hd540: 	{ width:960, height:540, fps:15, keyFrames:20 },
					hd720: 	{ width:1280, height:720, fps:15, keyFrames:21 },
					hd900: 	{ width:1600, height:900, fps:15, encodeQuality:7, keyFrames:21 },
					fullhd: { width:1920, height:1080, fps:15, encodeQuality:7, keyFrames:21 }
				}
			}else{
				PRESET_SETTINGS = 
				{
					edge:	{ width:128, height:72, fps:10, encodeQuality:3 },
					low:	{ width:256, height:144, fps:10, encodeQuality:5 },
					small:	{ width:384, height:216, fps:12, encodeQuality:6 },
					medium:	{ width:512, height:288, fps:15, encodeQuality:6 },
					high: 	{ width:640, height:360, fps:18, encodeQuality:6 },
					hd480: 	{ width:832, height:468, fps:18, encodeQuality:6 },
					hd540: 	{ width:960, height:540, fps:18, encodeQuality:6 },
					hd720: 	{ width:1280, height:720, fps:18, encodeQuality:6 },
					hd900: 	{ width:1600, height:900, fps:18, encodeQuality:6 },
					fullhd: { width:1920, height:1080, fps:18, encodeQuality:6 }
				}
			}
			
			_ls = SharedObject.getLocal( "MediaSettings.settings", "/" );
		}
		
		/*
		 * STATIC API
		 */
		
		public static function getInstance(): MediaSettings
		{
			if ( __mds == null ) __mds = new MediaSettings();
			return __mds;
		}
		 
		/*
		 * PUBLIC API
		 */
		
		//Inits the camera and settings
		public function initDefaultMediaCaptures(): void
		{
			if ( _initMedia ) return;
			
			_initMedia = true;
			var micIndex:Number = _ls.data.defaultMicrophone == undefined ? 0 : _ls.data.defaultMicrophone;
			
			_cam = Camera.getCamera(_ls.data.defaultCamera == undefined ? "0" : String(_ls.data.defaultCamera));
			_mic = USE_ECHO_CANCELLATION ? Microphone.getEnhancedMicrophone(micIndex) : Microphone.getMicrophone(micIndex);
			_codec = _ls.data.defaultVideoCodec == undefined ? H264_CODEC : _ls.data.defaultVideoCodec;
			_slotID = _ls.data.defaultPreset == undefined ? MEDIUM : _ls.data.defaultPreset;
			_useSpeex = _ls.data.useSpeex == undefined ? true : _ls.data.useSpeex;
			_gain = _ls.data.defaultGain == undefined ? 70 : Number(_ls.data.defaultGain);
			_settings = checkSettingsDefault(getPresetSettings(_slotID));
			_bAutoMode = _ls.data.autoMode == undefined ? true : _ls.data.autoMode == true;
			_bUseWideScreen = _ls.data.useWideScreen == undefined ? true : _ls.data.useWideScreen == true;
			
			//Set this from the get go :P
			_mic.codec = _useSpeex ? SoundCodec.SPEEX : SoundCodec.NELLYMOSER;
			
			refreshCodecSettings();
			refreshCameraSettings();
			refreshMicrophoneSettings();
			refreshMetaData();
			
			dispatchEvent(new Event(INITIALIZED));
			dispatchEvent(new Event(CAMERA_CHANGE));
			dispatchEvent(new Event(MICROPHONE_CHANGE));
		}
		
		public function loadPreset( id:String, overrideCMD:Boolean = false ): void
		{
			if ( !id || getPresetSettings(id) == null ) return;
			if ( id == _slotID && !overrideCMD ) return;
			
			if ( !_initMedia )
			{
				_ls.setProperty( "defaultPreset", id );
			}else{
				_slotID = id;
				_settings = checkSettingsDefault(getPresetSettings(id));
				_ls.setProperty( "defaultPreset", _slotID );
				
				//Refresh Microphone settings
				refreshCameraSettings();
				refreshMicrophoneSettings();
				refreshMetaData();
				dispatchEvent(new Event(Event.CHANGE));
			}	
		}
		
		public function save(): void
		{
			if ( _slotID == EDGE || 
				 _slotID == LOW_3G || 
				 _slotID == SMALL || 
				 _slotID == MEDIUM || 
				 _slotID == HIGH || 
				 _slotID == HD_480 || 
				 _slotID == HD_540 || 
				 _slotID == HD_720 || 
				 _slotID == HD_900 || 
				 _slotID == FULL_HD
			) return;
			
			//Save current settings
			savePreset( _slotID == CUSTOM?"custom" + new Date().getTime():_slotID, _settings, false );
		}
		
		public function savePreset( id:String, settings:Object, refreshSettings:Boolean = true ): void
		{
			if ( !id ) return;
			
			//Create settings holder if not exist
			if ( _ls.data.settings == undefined ) _ls.setProperty( "settings", { } );
			
			//Get settings holder and assign
			var saved:Object = _ls.data.settings;
				saved[id] = settings;
			
			//Save settings
			_ls.setProperty( "settings", saved );
			if ( id == _slotID && refreshSettings ) loadPreset( id, true );
		}
		
		public function getPresetSettings( id:String ): Object
		{
			var isPreset:Boolean = id == EDGE || 
								   id == LOW_3G || 
								   id == SMALL || 
								   id == MEDIUM || 
								   id == HIGH || 
								   id == HD_480 || 
								   id == HD_540 || 
								   id == HD_720 || 
								   id == HD_900 || 
								   id == FULL_HD;
			
			if ( !id || !_ls.data || _ls.data.settings == undefined ) return isPreset ? PRESET_SETTINGS[id] : null;
			return ObjectUtils.cloneObject(_ls.data.settings[id] != undefined ? checkSettingsDefault(_ls.data.settings[id]) : isPreset ? checkSettingsDefault(PRESET_SETTINGS[id]) : null);
		}
		
		public function deletePreset( id:String ): void
		{
			if ( !id || !_ls.data || _ls.data.settings == undefined ) return;
			
			var saved:Object = _ls.data.settings;
			if ( saved[id] != undefined ) 
			{
				saved[id] = undefined;
				delete saved[id];
			}
			
			//Save settings
			_ls.setProperty( "settings", saved );
			if ( id == _slotID ) loadPreset( MEDIUM, true );
		}
		
		/*
		 * PROTECTED API
		 */
		
		protected function refreshMetaData(): void
		{
			if ( !_cam ) return;
			
			try 
			{
				_metaData = new Object();
				_metaData.fps = _cam.fps;
				_metaData.bandwith = _cam.bandwidth;
				_metaData.height = _cam.height;
				_metaData.width = _cam.width;
				_metaData.keyFrameInterval = _cam.keyFrameInterval;
				_metaData.copyright = "Influxis, 2012-2013";
				
				if ( _stream )
				{
					_metaData.codec = _stream.videoStreamSettings.codec;
					if ( _stream.videoStreamSettings is H264VideoStreamSettings )
					{
						var h264Settings:H264VideoStreamSettings = _stream.videoStreamSettings as H264VideoStreamSettings;
						_metaData.profile = h264Settings.profile;
						_metaData.level = h264Settings.level;
					}
				}
			}catch ( e:Error )
			{
				
			}
		}
		 
		protected function refreshCodecSettings(): void
		{
			if ( !_stream ) return;
			
			if ( _codec == H264_CODEC )
			{
				var codecSettings:H264VideoStreamSettings = new H264VideoStreamSettings();
					codecSettings.setProfileLevel( H264Profile.BASELINE, H264Level.LEVEL_3 );
					//codecSettings.setMode( _settings.width, _settings.height, _settings.fps );
					//codecSettings.setQuality( _settings.bandwidth, _settings.quality );
					//codecSettings.setKeyFrameInterval(15);
				
				//Register new codec and refresh settings
				_stream.videoStreamSettings = codecSettings;
			}else{
				//Register new codec and refresh settings
				_stream.videoStreamSettings = new VideoStreamSettings();
			}
			
			//Redo meta info
			refreshMetaData();
		}
		 
		protected function onCameraChanged( value:Camera, overrideCmd:Boolean = false ): void
		{
			if ( value == _cam && !overrideCmd ) return;
			
			_cam = value;
			refreshCameraSettings();
			refreshMetaData();
			dispatchEvent(new Event(CAMERA_CHANGE));
		}
		
		protected function onMicrophoneChanged( value:Microphone, overrideCmd:Boolean = false ): void
		{
			if ( value == _mic && !overrideCmd ) return;
			
			_mic = value;
			_mic.codec = _useSpeex ? SoundCodec.SPEEX : SoundCodec.NELLYMOSER;
			
			refreshMicrophoneSettings();
			dispatchEvent(new Event(MICROPHONE_CHANGE));
		}
		
		protected function refreshCameraSettings(): void
		{
			if ( !_cam || !_settings ) return;
			_cam.setMode( _settings.width, _settings.height, _settings.fps );
			_cam.setQuality( 0, _settings.quality );
			_cam.setKeyFrameInterval(_settings.keyFrames == undefined ? 15 : _settings.keyFrames);
		}
		
		protected function refreshMicrophoneSettings(): void
		{
			if ( !_mic || !_settings ) return;
			
			_mic.setSilenceLevel( useSpeex ? 0 : _settings.silenceLevel );
			_mic.rate = _settings.rate;
			_mic.gain = _gain;
			_mic.encodeQuality = _settings.encodeQuality;
			_mic.enableVAD = useSpeex;
		}
		
		protected function checkSettingsDefault( settings:Object ): Object
		{
			if ( !settings ) return null;
			if( settings.width == undefined ) settings.width = 640;
			if( settings.height == undefined ) settings.height = 360;
			if( settings.fps == undefined ) settings.fps = 15;
			if( settings.bandwidth == undefined ) settings.bandwidth = 0;
			if( settings.quality == undefined ) settings.quality = 90;
			if( settings.motionLevel == undefined ) settings.motionLevel = 10;
			if( settings.motionTimeout == undefined ) settings.motionTimeout = 20000;
			if( settings.rate == undefined ) settings.rate = 11;
			//if( settings.gain == undefined ) settings.gain = 100;
			if( settings.keyFrames == undefined ) settings.keyFrames = 15;
			if( settings.encodeQuality == undefined ) settings.encodeQuality = 5;
			if( settings.silenceLevel == undefined ) settings.silenceLevel = 0;
			if( settings.silenceTimeout == undefined ) settings.silenceTimeout = 2000;
			//if( settings.loopback == undefined ) settings.loopback = true;
			return settings;
		}
		
		/*
		 * HANDLERS
		 */
		
		private function __onCheckerEvent( ...args ): void
		{
			if ( !_cam || !_settings || !_bAutoMode || !_bwChecker ) return;
			
			//Based on a .384 * Target BW
			if ( _bwChecker.bw_in > 700 && _qualityLimitationLevel < 1 )
			{
				loadPreset(HD_540);
			}else if( _bwChecker.bw_in > 575 && _qualityLimitationLevel < 2 )
			{
				loadPreset(HD_480);
			}else if( _bwChecker.bw_in > 375 && _qualityLimitationLevel < 3 )
			{
				loadPreset(HIGH);
			}else if( _bwChecker.bw_in > 225 && _qualityLimitationLevel < 4 )
			{
				loadPreset(MEDIUM);
			}else if( _bwChecker.bw_in > 125 && _qualityLimitationLevel < 5 )
			{
				loadPreset(SMALL);
			}else if ( _bwChecker.bw_in > 60 && _qualityLimitationLevel < 6 )
			{
				loadPreset(LOW_3G);
			}else{
				loadPreset(EDGE);
			}
			//trace( "__onCheckerEvent: " + _bwChecker.bw_in );
		}
		 
		/*
		 * GETTER / SETTER
		 */
		
		public function set autoMode( value:Boolean ): void
		{
			_bAutoMode = value;
			_ls.setProperty( "autoMode", _bAutoMode );
		}
		 
		public function get autoMode(): Boolean
		{
			return _bAutoMode;// && _bwChecker != null;
		}
		
		public function get initialized(): Boolean
		{
			return _initMedia;
		}
		 
		public function get cameraIndex(): Number
		{
			return _cam ? _cam.index : NaN;
		}
		
		public function set cameraIndex( value:Number ): void
		{
			if ( isNaN(value) || cameraIndex == value ) return;
			_ls.setProperty("defaultCamera", value);
			onCameraChanged(Camera.getCamera(String(value)));	
		}
		
		public function get microphoneIndex(): Number
		{
			return _mic ? _mic.index : NaN;
		}
		
		public function set microphoneIndex( value:Number ): void
		{
			if ( isNaN(value) || microphoneIndex == value ) return;
			_ls.setProperty("defaultMicrophone", value);
			onMicrophoneChanged(USE_ECHO_CANCELLATION?Microphone.getEnhancedMicrophone(value):Microphone.getMicrophone(value));
		}
		
		public function get videoCodec(): String
		{
			return _codec;
		}
		
		public function set videoCodec( value:String ): void
		{
			if ( !value || value == _codec ) return;
			_codec = value;
			_ls.setProperty( "defaultVideoCodec", _codec );
			refreshCodecSettings();
			refreshMetaData();
		}
		
		public function get useSpeex(): Boolean
		{
			return _useSpeex;
		}
		
		public function set useSpeex( value:Boolean ): void
		{
			if( _useSpeex == value ) return;
			_useSpeex = value;
			_ls.setProperty( "useSpeex", _useSpeex );
			if( _mic ) _mic.codec = _useSpeex ? SoundCodec.SPEEX : SoundCodec.NELLYMOSER;
		}
		
		public function get netStream(): NetStream
		{
			return _stream;
		}
		
		public function set netStream( value:NetStream ): void
		{
			if ( value == _stream ) return;
			_stream = value;
			refreshCodecSettings();
		}
		
		public function get gain(): Number
		{
			return _gain;
		}
		
		public function set gain( value:Number ): void
		{
			if ( value == _gain ) return;
			_gain = value;
			_ls.setProperty("defaultGain", _gain);
			if ( _mic ) _mic.gain = _gain;
		}
		
		public function get camera(): Camera
		{
			return _cam;
		}
		
		public function get microphone(): Microphone
		{
			return _mic;
		}
		
		public function get presets(): Vector.<String>
		{
			var savedPresets:Vector.<String> = new Vector.<String>();
				savedPresets.push( EDGE, LOW_3G, SMALL, MEDIUM, HIGH, HD_480, HD_540 );//, HD_720, HD_900, FULL_HD );
				
			if ( !Display.IS_MOBILE ) savedPresets.push( HD_720, HD_900, FULL_HD );
			
			var settings:Object = _ls.data.settings;
			for ( var i:String in settings )
			{
				savedPresets.push(i);
			}
			return savedPresets;
		}
		
		public function get bwChecker(): BWDetect
		{
			return _bwChecker;
		}
		
		public function set bwChecker( value:BWDetect ): void
		{
			if ( _bwChecker == value ) return;
			
			if ( _bwChecker )
			{
				_bwChecker.removeEventListener( Event.CHANGE, __onCheckerEvent );
				_bwChecker = null;
			}
			
			_bwChecker = value;
			if ( !_bwChecker ) return;
			
			_bwChecker.addEventListener( Event.CHANGE, __onCheckerEvent );
			refreshCameraSettings();
			refreshMetaData();
		}
		
		public function get metaData(): Object
		{
			return _metaData;
		}
		
		public function get currentPreset(): String
		{
			return _slotID;
		}
		
		public function set qualityLimitationLevel( value:Number ): void
		{
			if ( _qualityLimitationLevel == value ) return;
			_qualityLimitationLevel = value;
			__onCheckerEvent();
		}
		
		public function get qualityLimitationLevel(): Number
		{
			return _qualityLimitationLevel;
		}
	}
}