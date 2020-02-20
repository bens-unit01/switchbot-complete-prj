package org.influxis.application.vidcollaborator.display.videocollaboratorclasses.collabcontrolsclasses 
{
	//Flash Classes
	import flash.display.DisplayObject;
	
	//Influxis Classes
	import org.influxis.as3.display.StyleCanvas;
	import org.influxis.as3.utils.ScreenScaler;
	
	//Influxis Flotools
	import org.influxis.flotools.display.MicLevel;
	import org.influxis.flotools.display.CamWindow;
	import org.influxis.as3.states.AspectStates;
	import org.influxis.as3.utils.SizeUtils;
	
	public class CamPreview extends StyleCanvas
	{
		private var _camWindow:CamWindow;
		private var _micLevel:MicLevel;
		private var _camWindowMask:DisplayObject; 
		
		protected var camPaddingLeft:Number;
		protected var camPaddingTop:Number;
		protected var camPaddingBottom:Number;
		protected var camPaddingRight:Number;
		
		/*
		 * PROTECTED API
		 */
		
		protected function onCamWindowChanged( value:CamWindow ): void
		{
			if ( _camWindow )
			{
				_camWindow.mask = null;
				removeChild(_camWindowMask);
				removeChild(_camWindow);
				_camWindow.scaleMode = AspectStates.LETTERBOX;
			}
			
			_camWindow = value;
			if ( !_camWindow || !initialized ) return;
			
			//Set sizes and aspect
			_camWindow.scaleMode = AspectStates.STRETCH;
			_camWindow.setActualSize( ScreenScaler.calculateSize(149), ScreenScaler.calculateSize(74) );
			_camWindow.visible = true;
			addChild(_camWindow); addChild(_camWindowMask);
			_camWindow.mask = _camWindowMask;
			invalidateDisplayList();
		}
		 
		/*
		 * DISPLAY API
		 */
		
		override protected function measure():void 
		{
			super.measure();
			measuredWidth = getChildAt(0).width;
			
			//Idk why but the bg I import from the skin swf is not regestering the height sooo we're going to improvise with 94.9 :/
			measuredHeight = measuredHeight == 0 ? ScreenScaler.calculateSize(94.9) : measuredHeight;
		}
		
		override protected function measurePadding():void 
		{
			super.measurePadding();
			
			//General padding for when others are missing
			var camPadding:int = styleExists("camPadding") ? ScreenScaler.calculateSize(getStyle("camPadding") as int) : 0;
			
			//Set padding
			camPaddingLeft = styleExists("camPaddingLeft") ? ScreenScaler.calculateSize(getStyle("camPaddingLeft") as int) : camPadding;
			camPaddingTop = styleExists("camPaddingTop") ? ScreenScaler.calculateSize(getStyle("camPaddingTop") as int) : camPadding;
			camPaddingBottom = styleExists("camPaddingBottom") ? ScreenScaler.calculateSize(getStyle("camPaddingBottom") as int) : camPadding;
			camPaddingRight = styleExists("camPaddingRight") ? ScreenScaler.calculateSize(getStyle("camPaddingRight") as int) : camPadding;
		}
		
		override protected function createChildren():void 
		{
			super.createChildren();
			
			_micLevel = new MicLevel();
			_micLevel.skinName = "micLevelSkin";
			_micLevel.visible = false;
			_camWindowMask = getStyleGraphic("cameraMask");
			_camWindowMask.alpha = 0.5;
			addChild(_micLevel);
		}
		 
		override protected function childrenCreated():void 
		{
			super.childrenCreated();
			if ( _camWindow ) 
			{
				addChild(_camWindow);
				addChild(_camWindowMask);
				_camWindow.mask = _camWindowMask;
			}
		}
		
		override protected function arrange():void 
		{
			super.arrange();
			
			if ( _camWindow )
			{
				//_camWindow.setActualSize( width - (paddingLeft + paddingRight), height - (paddingTop + paddingBottom) );
				
				_camWindowMask.width = width - (camPaddingLeft + camPaddingRight); 
				_camWindowMask.height = height - (camPaddingTop + camPaddingBottom);
				_camWindowMask.x = camPaddingLeft; _camWindowMask.y = camPaddingTop;
				
				_camWindow.x = (width / 2) - (ScreenScaler.calculateSize(149) / 2);
				_camWindow.y = (height / 2) - (ScreenScaler.calculateSize(74) / 2);
				
				//SizeUtils.moveByTargetX( _camWindow, _camWindowMask, SizeUtils.CENTER );
				//SizeUtils.moveByTargetY( _camWindow, _camWindowMask, SizeUtils.MIDDLE );
				
				_micLevel.width = width - (paddingLeft + paddingRight); 
				_micLevel.height = height - (paddingTop + paddingBottom);
				_micLevel.x = paddingLeft; _micLevel.y = paddingTop;	
			}
		}
		
		/*
		 * GETTER / SETTER
		 */
		
		public function set camWindow( value:CamWindow ): void
		{
			if ( _camWindow == value ) return;
			onCamWindowChanged(value);
		}
		
		public function get camWindow(): CamWindow
		{
			return _camWindow;
		}
	}
}