/**
 *  ImageLight - Copyright © 2010 Influxis All rights reserved.   
**/

package org.influxis.as3.containers
{
	//Flash Classes
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.events.MouseEvent;
	
	//Influxis Classes
	import org.influxis.as3.display.StyleCanvas;
	import org.influxis.as3.states.AspectStates;
	import org.influxis.as3.utils.SizeUtils;
	import org.influxis.as3.utils.ImageUtils;
	import org.influxis.as3.utils.doTimedLater;
	import org.influxis.as3.utils.getURL;
	
	public class ImageLight extends StyleCanvas
	{
		public static var symbolName:String = "ImageLight";
		public static var symbolOwner:Object = org.influxis.as3.containers.ImageLight;
		private var _sVersion:String = "2.0.0.0";
		
		private var _sSource:String;
		private var _sURLLink:String;
		private var _bLoaded:Boolean;
		private var _loader:Loader;
		private var _bAutoSizeScale:Number;
		
		private var _sAspect:String = AspectStates.LETTERBOX;
		private var _nContentWidth:Number = 320;
		private var _nContentHeight:Number = 240;
		
		/**
		 * PUBLIC API
		**/
		
		public function load( p_sUrl:String = null ): void
		{
			if( !p_sUrl || p_sUrl == _sSource ) return;
			
			_bLoaded = false;
			_sSource = p_sUrl;
			if( _loader ) _loader.load(new URLRequest(ImageUtils.checkImageLocalPath(_sSource)));
		}
		
		public function clear(): void
		{
			_sSource = null;
			_bLoaded = false;
			
			if( _loader ) _loader.unload();
		}
		
		public function loadBytes( p_ba:ByteArray ): void
		{
			if( p_ba == null ) return;
			
			_loader.visible = true;
			_loader.loadBytes( p_ba );
			doTimedLater( 200, __handleEvent, new Event(Event.INIT) );
		}
		
		public function autoSize( scale:uint ): void
		{
			//trace( "autoSize: " + loaded, _loader.contentLoaderInfo );
			if ( loaded )
			{
				_bAutoSizeScale = NaN;
				setActualSize( (_nContentWidth*(scale/100)), (_nContentHeight*(scale/100)) );
			}else{
				_bAutoSizeScale = scale;
			}
		}
		
		/**
		 * HANDLERS
		 */
		
		private function __registerURL( path:String ): void
		{
			if ( _sURLLink == path ) return;
			
			if ( _sURLLink && !path )
			{
				_loader.removeEventListener( MouseEvent.MOUSE_DOWN, __onImageClick );
			}else if ( !_sURLLink && path )
			{
				_loader.addEventListener( MouseEvent.MOUSE_DOWN, __onImageClick );
			}
			_sURLLink = path;
		}
		
		/**
		 * HANDLERS
		**/
		
		private function __onImageClick( ...args ): void
		{
			getURL(_sURLLink);
		}
		
		private function __handleEvent( p_e:Event ): void
		{
			if( p_e.type == Event.INIT || p_e.type == IOErrorEvent.IO_ERROR || p_e.type == SecurityErrorEvent.SECURITY_ERROR  )
			{
				_loader.visible = true;
				_bLoaded = (p_e.type == Event.INIT);
				
				if ( _loader.contentLoaderInfo )
				{
					try 
					{
						_nContentWidth = _loader.contentLoaderInfo.width;
						_nContentHeight = _loader.contentLoaderInfo.height;
					}catch ( e:Error )
					{
						trace(e);
					}
				}
				
				if ( p_e.type == Event.INIT )
				{
					if ( !isNaN(_bAutoSizeScale) ) 
					{
						autoSize(_bAutoSizeScale);
					}else {
						arrange();
					}
				}
			}
			//tracer( "handleEvent: " + p_e.type );
			dispatchEvent( p_e );
		}
		
		/**
		 * DISPLAY API
		**/
		
		override protected function createChildren(): void
		{
			super.createChildren();
			
			_loader = new Loader();
			_loader.visible = false;
			
			addChild(_loader);
		}
		
		override protected function childrenCreated(): void
		{
			super.childrenCreated();
			
			_loader.contentLoaderInfo.addEventListener( Event.COMPLETE, __handleEvent );
			_loader.contentLoaderInfo.addEventListener( Event.INIT, __handleEvent );
			_loader.contentLoaderInfo.addEventListener( Event.OPEN, __handleEvent );
			_loader.contentLoaderInfo.addEventListener( Event.UNLOAD, __handleEvent );
			_loader.contentLoaderInfo.addEventListener( ProgressEvent.PROGRESS, __handleEvent );
			_loader.contentLoaderInfo.addEventListener( HTTPStatusEvent.HTTP_STATUS, __handleEvent );
			_loader.contentLoaderInfo.addEventListener( SecurityErrorEvent.SECURITY_ERROR, __handleEvent );
			_loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, __handleEvent );
			
			if( _sSource ) _loader.load(new URLRequest(_sSource));
		}
		
		override protected function arrange():void
		{
			super.arrange();
			SizeUtils.sizeTarget( _loader, _sAspect, width, height, _nContentWidth, _nContentHeight );
			SizeUtils.movePosition( _loader, width, height, SizeUtils.CENTER, SizeUtils.MIDDLE );
		}
		
		/**
		 * SETTER / GETTER
		**/
		
		public function set source( p_sSource:String ): void
		{
			if( p_sSource == _sSource ) return;
			
			_bLoaded = false;
			_sSource = p_sSource;
			
			if ( !_sSource || _sSource == "" || _sSource == "0" ) 
			{
				clear();
				return;
			}
			
			//Unload and load in new
			if ( _loader ) 
			{
				_loader.unload();
				if( _sSource && _sSource != "" ) _loader.load(new URLRequest(ImageUtils.checkImageLocalPath(p_sSource)));
			}
		}
		
		public function get source(): String
		{
			return _sSource;
		}
		
		public function set clickURL( value:String ): void 
		{
			__registerURL(value);
		}
		
		public function get clickURL(): String
		{
			return _sURLLink;
		}
		
		public function set scaleMode( value:String ): void 
		{
			_sAspect = value;
			arrange();
		}
		
		public function get scaleMode(): String
		{
			return _sAspect;
		}
		
		public function get loaded(): Boolean
		{
			return _bLoaded;
		}
		
		public function get loader(): Loader
		{
			return _loader;
		}
	}
}
