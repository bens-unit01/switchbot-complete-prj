package org.influxis.social.containers 
{
	//Flash Classes
	import flash.events.Event;
	import flash.events.ErrorEvent;
	import flash.events.FocusEvent;
	import flash.events.LocationChangeEvent;
	
	import flash.media.StageWebView;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	
	//Influxis Classes
	import org.influxis.as3.display.SimpleSprite;
	
	public class MobileWebWindow extends SimpleSprite
	{
		private var _sPath:String;
		private var _viewPort:Rectangle;
		private var _webView:StageWebView;
		
		/*
		 * INIT API
		 */
		
		public function MobileWebWindow(): void
		{
			super();
			_viewPort = new Rectangle(0, 0, 300, 300);
		}
		 
		/*
		 * PUBLIC API
		 */
		
		public function loadURL( path:String ): void
		{
			if ( _sPath == path || !StageWebView.isSupported ) return;
			
			_sPath = path;
			if ( _sPath )
			{
				if ( !_webView )
				{
					_webView = new StageWebView();
					_webView.viewPort = visible ? _viewPort : null;
					_webView.stage = visible ? stage : null;
					_webView.addEventListener( Event.COMPLETE, onWebViewEvent, false, Number.MAX_VALUE );
					_webView.addEventListener( ErrorEvent.ERROR, onWebViewEvent, false, Number.MAX_VALUE );
					_webView.addEventListener( FocusEvent.FOCUS_IN, onWebViewEvent, false, Number.MAX_VALUE );
					_webView.addEventListener( FocusEvent.FOCUS_OUT, onWebViewEvent, false, Number.MAX_VALUE );
					_webView.addEventListener( LocationChangeEvent.LOCATION_CHANGE, onWebViewEvent, false, Number.MAX_VALUE );
					_webView.addEventListener( LocationChangeEvent.LOCATION_CHANGING, onWebViewEvent, false, Number.MAX_VALUE );
				}
				_webView.loadURL(_sPath);
			}else{
				unload();
			}
		}
		
		public function unload(): void
		{
			if ( !_webView ) return;
			
			_webView.dispose();
			_webView.removeEventListener( Event.COMPLETE, onWebViewEvent );
			_webView.removeEventListener( ErrorEvent.ERROR, onWebViewEvent );
			_webView.removeEventListener( FocusEvent.FOCUS_IN, onWebViewEvent );
			_webView.removeEventListener( FocusEvent.FOCUS_OUT, onWebViewEvent );
			_webView.removeEventListener( LocationChangeEvent.LOCATION_CHANGE, onWebViewEvent );
			_webView.removeEventListener( LocationChangeEvent.LOCATION_CHANGING, onWebViewEvent );
			_webView = null;
		}
		
		/*
		 * HANDLERS
		 */
		
		protected function onWebViewEvent( event:Event ): void
		{
			dispatchEvent(event);
		}
		 
		/*
		 * DISPLAY API
		 */
		
		override protected function arrange(): void 
		{
			super.arrange();
			
			var gPoint:Point = localToGlobal(new Point(x, y));
			_viewPort = new Rectangle( gPoint.x, gPoint.y, width, height );
			if( _webView && visible ) _webView.viewPort = _viewPort;
		}
		
		/*
		 * GETTER / SETTER
		 */
		
		public function get webView(): StageWebView
		{
			return _webView;
		}
		
		override public function set visible(value:Boolean):void 
		{
			super.visible = value;
			if ( _webView )
			{
				_webView.viewPort = visible ? _viewPort : null;
				_webView.stage = visible ? stage : null;
			}
		}
	}
}