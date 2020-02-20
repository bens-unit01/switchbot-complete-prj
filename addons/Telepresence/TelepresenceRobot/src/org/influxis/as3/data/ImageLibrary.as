/**
 * ImageLibrary - Copyright © 2010 Influxis All rights reserved.
**/

package org.influxis.as3.data 
{
	//Flash Classes
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.utils.getDefinitionByName;
	import __AS3__.vec.Vector;
	
	//Influxis Classes
	import org.influxis.as3.net.ClassLoader;
	import org.influxis.as3.utils.handler;
	import org.influxis.as3.events.SimpleEvent;
	import org.influxis.as3.utils.ImageUtils;
	import org.influxis.as3.data.imagelibraryclass.ImageLoader;
	import org.influxis.as3.skins.BitmapWrapper;
	
	[Event( name = "complete", type = "org.influxis.as3.events.SimpleEvent" )]
	
	public class ImageLibrary extends EventDispatcher
	{
		public static var symbolName:String = "ImageLibrary";
		public static var symbolOwner:Object = org.influxis.as3.data.ImageLibrary;
		private var infxClassName:String = "ImageLibrary";
		private var _sVersion:String = "1.0.0.0";
		
		private static var __img:ImageLibrary;
		private static const CLASS_LOADER:String = "classLoader";
		private static const IMAGE_LOADER:String = "imageLoader";
		
		private var _loaderImages:Object = new Object();
		private var _vLoadingImages:Vector.<String>;
		//private var _regSWFSym:RegExp = /\.swf/gi;
		
		/**
		 * INIT API
		 */
		
		public function ImageLibrary(): void
		{
			_vLoadingImages = new Vector.<String>();
		}
		 
		/**
		 * SINGLETON API
		**/
		
		//Returns singleton instance
		public static function getInstance() : ImageLibrary
		{
			if( __img == null ) __img = new ImageLibrary();
			return __img;
		}
		
		/**
		 * PUBLIC API
		 */
		
		//If target image does not exist then load it in
		public function loadImage( imagePath:String ): void
		{
			if ( exists(imagePath) ) return;
			
			var bIsSWFSym:Boolean = (imagePath.indexOf(".swf:") != -1);//_regSWFSym.test( imagePath );
			var o:Object = new Object();
				o["loaded"] = false;
				o["type"] = bIsSWFSym ? CLASS_LOADER : IMAGE_LOADER;
			
			if( bIsSWFSym )
			{
				var sImage:String = imagePath.substring(0, imagePath.lastIndexOf(":"));
				var clLoader:ClassLoader = new ClassLoader();
					clLoader.addEventListener( ClassLoader.CLASS_LOADED, handler(__onImageLoaded, sImage) );
					clLoader.addEventListener( ClassLoader.LOAD_ERROR, handler(__onImageLoaded, sImage) );
					clLoader.load( sImage, imagePath.substring(imagePath.lastIndexOf(":")+1));// ImageUtils.checkImageLocalPath(sImage) );
				
				_vLoadingImages.push( sImage );
				o["loader"] = clLoader;
				_loaderImages[sImage] = o;
			}else {
				var loader:Loader = new ImageLoader();
					loader.contentLoaderInfo.addEventListener( Event.INIT, handler(__onImageLoaded, imagePath) );
					loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, handler(__onImageLoaded, imagePath) );
					loader.load( new URLRequest( imagePath ));// ImageUtils.checkImageLocalPath(imagePath)) );
				
				_vLoadingImages.push( imagePath );
				o["loader"] = loader;
				_loaderImages[imagePath] = o;
			}
		}
		
		//Get image container (this could either be a display object or loader)
		public function getImage( imagePath:String ): *
		{
			if ( !imagePath || !loaded(imagePath) ) return; 
			
			var bIsSWFSym:Boolean = (imagePath.indexOf(".swf:") != -1) || (imagePath.indexOf("class:") != -1) || (imagePath.indexOf("embed:") != -1);//_regSWFSym.test( imagePath );
			var image:*;
			if( bIsSWFSym )
			{
				var cImage:Class;
				if ( (imagePath.indexOf("class:") != -1) )
				{
					cImage = getDefinitionByName(imagePath.substring(imagePath.lastIndexOf(":")+1)) as Class;
				}else if ( (imagePath.indexOf("embed:") != -1) )
				{
					try {
						cImage = getDefinitionByName("assets.Skins")[imagePath.substring(imagePath.lastIndexOf(":") + 1)];
						image = new BitmapWrapper( new cImage() as Bitmap);
					}catch ( e:Error )
					{
						//Skin doesnt exist :S
					}
				}else{
					cImage = (_loaderImages[__getImagePath(imagePath)].loader as ClassLoader).getClass(imagePath.substring(imagePath.lastIndexOf(":") + 1));
				}
				if( !image ) image = new cImage();
			}else{
				var loader:Loader = new ImageLoader();
					loader.loadBytes((_loaderImages[imagePath].loader as Loader).contentLoaderInfo.bytes);
				image = loader;
			}
			return image;
		}
		
		//Get image container (this could either be a display object or loader)
		public function getImageClass( imagePath:String ): Class
		{
			if ( !imagePath || !loaded(imagePath) ) return null; 
			
			var bIsSWFSym:Boolean = (imagePath.indexOf(".swf:") != -1) || (imagePath.indexOf("class:") != -1);
			var imageClass:Class;
			
			if( bIsSWFSym )
			{
				var cImage:Class;
				if ( (imagePath.indexOf("class:") != -1) )
				{
					imageClass = getDefinitionByName(imagePath.substring(imagePath.lastIndexOf(":")+1)) as Class;
				}else{
					imageClass = (_loaderImages[__getImagePath(imagePath)].loader as ClassLoader).getClass(imagePath.substring(imagePath.lastIndexOf(":") + 1));
				}
			}else if ( (imagePath.indexOf("embed:") != -1) )
			{
				try {
					imageClass = getDefinitionByName("assets.Skins")[imagePath.substring(imagePath.lastIndexOf(":") + 1)];
				}catch ( e:Error )
				{
					//Skin doesnt exist :S
				}
			}
			return imageClass;
		}
		
		//Destroy image slot and resources
		public function destroyImage( imagePath:String ): void
		{
			if ( !exists(imagePath) ) return;
			
			_loaderImages[__getImagePath(imagePath)].loader.unload();
			_loaderImages[__getImagePath(imagePath)].loader = null;
			_loaderImages[__getImagePath(imagePath)] = null;
			
			delete _loaderImages[__getImagePath(imagePath)];
		}
		
		public function exists( imagePath:String ): Boolean
		{
			if (imagePath.indexOf("class:") != -1 || imagePath.indexOf("embed:") != -1) return true;
			return (_loaderImages[__getImagePath(imagePath)] != undefined);
		}
		
		public function loaded( imagePath:String ): Boolean
		{
			if (imagePath.indexOf("class:") != -1 || imagePath.indexOf("embed:") != -1) return true;
			if ( !exists(imagePath) ) return false;
			return (_loaderImages[__getImagePath(imagePath)].loaded==true);
		}
		
		/**
		 * PRIVATE API
		 */
		
		//Parses image path to get true image path
		private function __getImagePath( imagePath:String ): String
		{
			if ( !imagePath ) return null;
			return ((imagePath.indexOf(".swf:")!=-1)?imagePath.substring(0, imagePath.lastIndexOf(":")):imagePath);
		}
		 
		/**
		 * HANDLERS
		 */
		
		private function __onImageLoaded( event:Event, p_sImage:String ): void
		{
			if ( event.type == Event.INIT || event.type == ClassLoader.CLASS_LOADED )
			{
				_loaderImages[p_sImage].loaded = true;
				__removePending( p_sImage );
				dispatchEvent( new SimpleEvent(Event.COMPLETE, null, p_sImage) );
			}else if ( event.type == IOErrorEvent.IO_ERROR || event.type == ClassLoader.LOAD_ERROR )
			{
				if ( _loaderImages[p_sImage].localPath == true )
				{
					__removePending( p_sImage );
					_loaderImages[p_sImage].loaded = false;
					dispatchEvent( new SimpleEvent(Event.COMPLETE, null, p_sImage) );
				}else {
					var sLocalPath:String = ImageUtils.checkImageLocalPath(p_sImage);
					_loaderImages[p_sImage].localPath = true;
					_loaderImages[p_sImage].loader.load( event.type == ClassLoader.LOAD_ERROR ? sLocalPath : new URLRequest(sLocalPath) );
				}	
			}
		}
		
		private function __removePending( p_sImage:String ): void
		{
			var nLen:uint = _vLoadingImages.length;
			for ( var i:int = nLen-1; i > -1; i-- )
			{
				if ( _vLoadingImages[i] == p_sImage ) 
				{
					_vLoadingImages.splice( i, 1 );
					break;
				}
			}
		}
		
		/**
		 * GETTER / SETTER
		 */
		
		public function get pendingImages(): Boolean
		{
			return (_vLoadingImages.length > 0);
		}
	}
}