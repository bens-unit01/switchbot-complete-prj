package org.influxis.as3.display 
{
	//Flash Classes
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	
	//Influxis Classes
	import org.influxis.as3.display.StyleCanvas;
	import org.influxis.as3.containers.ImageLight;
	import org.influxis.as3.net.loaderclasses.LoaderBase;
	import org.influxis.as3.utils.Structure3D;
	import org.influxis.as3.utils.SimpleZSorter;
	
	import flash.ui.Keyboard;
	
	public class ImageRotater extends StyleCanvas
	{
		private var _settingsPath:String;
		private var _loader:LoaderBase;
		private var _oCarouselInfo:Object;
		private var _aImageList:Vector.<ImageLight>;
		
		private var _holderContainer:Sprite;
		
		/**
		 * PUBLIC API
		 */
		
		public function loadSettings( path:String = null ): void 
		{
			if ( _settingsPath == path ) return;
			
			_settingsPath = path;
			if ( !_loader ) 
			{
				_loader = new LoaderBase();
				_loader.addEventListener( Event.COMPLETE, __onSettingsLoaded );
			}
			_loader.load(_settingsPath);
		}
		
		/**
		 * HANDLERS
		 */
		
		private function __onSettingsLoaded( event:Event = null ): void 
		{
			__createImages();
		}
		
		private function __loop( event:Event ): void
		{
			//_holderContainer.rotationX = mouseY - 250;
			_holderContainer.rotationY = mouseX - 250;
			SimpleZSorter.sortClips(_holderContainer);
		}
		
		private function __createImages(): void
		{
			if ( !initialized || _oCarouselInfo || !_loader ) return;
			if ( _loader.dataProvider )
			{
				var image:ImageLight;
				var displayList:Vector.<DisplayObject> = new Vector.<DisplayObject>();
				var imageList:XMLList = _loader.dataProvider.image;
				for each( var i:XML in imageList )
				{
					image = new ImageLight();
					image.source = i.@src;
					image.setActualSize(300, 300);
					displayList.push(image);
				}
				_oCarouselInfo = Structure3D.createCarousel( displayList, _holderContainer );
			}
		}
		
		/**
		 * DISPLAY API
		 */
		
		override protected function createChildren():void 
		{
			super.createChildren();
			
			_holderContainer = new Sprite();
			addChild(_holderContainer);
		}
		
		override protected function childrenCreated():void 
		{
			super.childrenCreated();
			__createImages();
			addEventListener(Event.ENTER_FRAME, __loop );
		}
		
		override protected function arrange():void 
		{
			super.arrange();
			trace( "arrange: " + _holderContainer.width );
			_holderContainer.x = width / 2;
			_holderContainer.y = height / 2;
		}
	}
}