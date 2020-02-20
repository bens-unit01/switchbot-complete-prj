package org.influxis.flotools.containers 
{
	//Flash Classes
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.display.Loader;
	import flash.geom.Rectangle;
	import flash.net.NetConnection;
	import flash.net.URLRequest;
	import flash.events.SecurityErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	
	//Influxis Classes
	import org.influxis.flotools.core.InfluxisComponent;
	import org.influxis.as3.states.AspectStates;
	import org.influxis.as3.codecs.JPEGAsyncEncoder;
	import org.influxis.as3.utils.SizeUtils;
	import org.influxis.as3.utils.doTimedLater;
	import org.influxis.as3.utils.StringUtils;
	import org.influxis.as3.utils.ScreenScaler;
	
	//Flotools Classes
	import org.influxis.flotools.managers.VideoThumbCacher;
	
	//Video Thumb used in the Archive Panel to display thumbs in the list and big thumb in the view after clicking on the item
	public class VideoThumb extends InfluxisComponent
	{
		private static var _ID_COUNT_:uint;
		private static var _CURRENT_LOAD_ID_:Number;
		private var _internalID:Number;
		
		private var _thumbLibrary:VideoThumbCacher;
		private var _thumbSlot:String;
		private var _thumb:Loader;
		private var _mask:Sprite;
		private var _lStatus:TextField;
		private var _bLoading:Boolean;
		private var _bLoaded:Boolean;
		
		protected var maskPaddingLeft:Number;
		protected var maskPaddingTop:Number;
		protected var maskPaddingBottom:Number;
		protected var maskPaddingRight:Number;
		
		/*
		 * INIT API
		 */
		
		public function VideoThumb(): void
		{
			super();
			_internalID = _ID_COUNT_;
			_ID_COUNT_++;
		}
		 
		override protected function preInitialize():void 
		{
			
			super.preInitialize();
		}
		 
		/*
		 * CONNECT API
		 */
		
		override protected function instanceClose():void 
		{
			super.instanceClose();
			
			_thumbLibrary = null;
			unloadThumb();
		}
		
		override protected function instanceChange():void 
		{
			super.instanceChange();
			
			_thumbLibrary = VideoThumbCacher.getInstance(instance);
			if( connected ) _thumbLibrary.connect(_nc);
			__doThumbLoad();
		}
		
		/*
		 * PUBLIC API
		 */
		
		public function loadThumb( thumbSlot:String ): void
		{
			unloadThumb();
			
			_thumbSlot = thumbSlot;
			__doThumbLoad();
		}
		
		public function unloadThumb(): void
		{
			if ( !_bLoaded ) return;
			
			_bLoaded = false;
			
			_thumb.unload();
			_thumb.visible = false;
			
			_lStatus.visible = false;
			_thumbSlot = null;
		}
		
		/*
		 * PROTECTED API
		 */
		
		protected function __doThumbLoad(): void
		{
			if ( !_thumbSlot || !initialized || !connected || _bLoading ) return;
			
			_lStatus.visible = true;
			if ( !isNaN(_CURRENT_LOAD_ID_) && !_bLoaded )
			{
				_lStatus.text = getLabelAt("loading");
				setTimeout(__doThumbLoad, 100);
				return;
			}
			
			_bLoading = true;
			_thumb.unload();
			
			if( !_bLoaded ) _CURRENT_LOAD_ID_ = _internalID;
			
			//If thumb does not exist then get from server
			if ( _lStatus.text != getLabelAt("thumbProcessing") ) _lStatus.text = getLabelAt("loading");
			_thumbLibrary.requestImageDataAt( _thumbSlot, __onImageResult );
		}
		
		/*
		 * PRIVATE API
		 */
		
		private function __onImageResult( image:Object ): void
		{
			if ( !image ) 
			{
				//Cancel loaders so it can load again later
				_bLoading = false;
				_bLoaded = true;
				
				//Since thumb didnt load show processing by another device
				_lStatus.visible = true;
				_lStatus.text = getLabelAt("thumbProcessing");
				
				//Reset index so can load others
				if ( _CURRENT_LOAD_ID_ == _internalID ) _CURRENT_LOAD_ID_ = NaN;
				
				//Try again in about 5 secs
				doTimedLater(5000, __doThumbLoad);
			}else{
				_thumb.unload();
				_thumb.loadBytes(image.bitmap as ByteArray);
				
				//Wait to resize since it takes a bit to load
				__onCheckBytesLoaded();
			}
		}
		
		private function __onCheckBytesLoaded(): void
		{
			var empty:Boolean = true;
			
			try
			{
				if ( _thumb.content.width > 0 && _thumb.content.height > 0 ) empty = false;
			}catch ( e:Error ) {}
			
			if ( !empty )
			{
				__showThumb();
			}else{
				doTimedLater( 50, __onCheckBytesLoaded );
			}
		}
		
		private function __showThumb(): void
		{
			if ( !initialized ) return;
			
			//Clear out loader id if local
			if ( _CURRENT_LOAD_ID_ == _internalID ) _CURRENT_LOAD_ID_ = NaN;
			
			//Set loaded to true and show display
			_bLoading = false;
			_bLoaded = true;
			_thumb.visible = true;
			
			//Clear status text if visible
			_lStatus.visible = false;
			_lStatus.text = "";
			arrange();
		}
		
		/*
		 * DISPLAY API
		 */
		
		override protected function measurePadding():void 
		{
			super.measurePadding();
			
			//General padding for when others are missing
			var maskPadding:int = styleExists("maskPadding") ? ScreenScaler.calculateSize(getStyle("maskPadding") as int) : 0;
			
			//Set padding
			maskPaddingLeft = styleExists("maskPaddingLeft") ? ScreenScaler.calculateSize(getStyle("maskPaddingLeft") as int) : maskPadding;
			maskPaddingTop = styleExists("maskPaddingTop") ? ScreenScaler.calculateSize(getStyle("maskPaddingTop") as int) : maskPadding;
			maskPaddingBottom = styleExists("maskPaddingBottom") ? ScreenScaler.calculateSize(getStyle("maskPaddingBottom") as int) : maskPadding;
			maskPaddingRight = styleExists("maskPaddingRight") ? ScreenScaler.calculateSize(getStyle("maskPaddingRight") as int) : maskPadding;
		}
		 
		override protected function createChildren():void 
		{
			super.createChildren();
			_thumb = new Loader();
			_thumb.visible = false;
			_lStatus = getStyleText("status");
			_lStatus.visible = false;
			
			_mask = styleExists("mask") ? getStyleGraphic("mask") as Sprite : new Sprite();
			mask = _mask;
			addChildren(_thumb, _lStatus, _mask);
		}
		
		override protected function childrenCreated():void 
		{
			super.childrenCreated();
						
			//Size text height
			_lStatus.height = StringUtils.measureText("DummyText", _lStatus.defaultTextFormat).height;
			
			//load thumb
			if( _thumbSlot ) __doThumbLoad();
		}
		
		override protected function arrange(): void 
		{
			super.arrange();
			
			_lStatus.width = width;
			SizeUtils.movePosition( _lStatus, width, height, SizeUtils.CENTER, SizeUtils.MIDDLE );
			
			if ( styleExists("mask") )
			{
				if ( !styleExists("sizeMask") || getStyle("sizeMask") == true )
				{
					_mask.x = maskPaddingLeft; mask.y = maskPaddingTop;
					_mask.width = width - (maskPaddingLeft + maskPaddingRight);
					_mask.height = height - (maskPaddingTop + maskPaddingBottom);
				}else{
					SizeUtils.moveX( _mask, width, SizeUtils.CENTER );
					SizeUtils.moveY( _mask, height, SizeUtils.MIDDLE );
				}
			}else{
				_mask.graphics.clear();
				_mask.graphics.beginFill( 0, 1 );
				_mask.graphics.drawRect( maskPaddingLeft, maskPaddingTop, (width - (maskPaddingLeft + maskPaddingRight)), (height - (maskPaddingTop + maskPaddingBottom)) );
				_mask.graphics.endFill();
			}
			
			try {
				SizeUtils.maintainAspectRatio( _thumb, width, height, _thumb.contentLoaderInfo.content.width, _thumb.contentLoaderInfo.content.height );
				SizeUtils.movePosition( _thumb, width, height, SizeUtils.CENTER, SizeUtils.MIDDLE );
			}catch(e:Error)
			{
				_thumb.width = width; _thumb.height = height;
				_thumb.x = 0; _thumb.y = 0;
			}
		}
		
		/*
		 * GETTER / SETTER
		 */
		
		public function get thumbPath(): String 
		{
			return _thumbSlot;	
		}
	}
}