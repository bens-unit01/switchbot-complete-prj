package org.influxis.as3.display.alertclasses 
{
	//Flash Classes
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.text.TextField;
	
	//Influxis Classes
	import org.influxis.as3.display.StyleCanvas;
	import org.influxis.as3.interfaces.display.IAlert;
	import org.influxis.as3.states.SizeStates;
	import org.influxis.as3.utils.StringUtils;
	import org.influxis.as3.utils.SizeUtils;
	
	public class AlertPanel extends StyleCanvas
	{
		private var _tTitle:TextField;
		private var _header:DisplayObject;
		private var _icon:DisplayObject;
		private var _closeIcon:InteractiveObject;
		private var _alertContainer:DisplayObject;
		private var _title:String;
		
		/*
		 * INIT API
		 */
		
		public function AlertPanel( alertContainer:IAlert, icon:DisplayObject ): void
		{
			_alertContainer = alertContainer as DisplayObject;
			_icon = icon;
			super();
		}
		
		/*
		 * HANDLERS
		 */
		
		private function __onDisplayEvent( event:Event ): void
		{
			if ( event.type == SizeStates.RESIZE )
			{
				refreshMeasures();
			}else if ( event.type == Event.CLOSE )
			{
				dispatchEvent(event);
			}
		}
		 
		/*
		 * DISPLAY API
		 */
		
		override protected function measure(): void 
		{
			super.measure();
			measuredWidth = paddingLeft + paddingRight + _alertContainer.width;
			measuredHeight = (_header ? _header.height : _tTitle.text == "" ? 0 : _tTitle.height) + _alertContainer.height + paddingTop + paddingBottom;
		}
		 
		override protected function createChildren():void 
		{
			super.createChildren();
			var usedChildren:Array = new Array();
			
			if ( styleExists("header") )
			{
				_header = getStyleGraphic("header");
				usedChildren.push(_header);
			}
			
			_tTitle = getStyleText("title");
			usedChildren.push(_tTitle);
			
			if ( !_icon && styleExists("icon") ) _icon = getStyleGraphic("icon");
			if ( _icon ) usedChildren.push(_icon);
			
			usedChildren.push(_alertContainer);
			addChildren.apply( this, usedChildren );
		}
		
		override protected function childrenCreated(): void 
		{
			super.childrenCreated();
			_tTitle.text = !_title ? "" : _title;
			_tTitle.height = StringUtils.measureText( _tTitle.text, _tTitle.defaultTextFormat ).height;
			_alertContainer.addEventListener( SizeStates.RESIZE, __onDisplayEvent );
			_alertContainer.addEventListener( SizeStates.MEASURE, __onDisplayEvent );
			_alertContainer.addEventListener( Event.CLOSE, __onDisplayEvent );
		}
		
		override protected function arrange(): void 
		{
			super.arrange();
			
			if ( _header )
			{
				_header.width = width;
				SizeUtils.hookTarget( _tTitle, _header, SizeUtils.MIDDLE );
				if ( _icon ) SizeUtils.hookTarget( _icon, _header, SizeUtils.MIDDLE );
			}else {
				
			}
			
			if ( _icon )
			{
				_icon.x = paddingLeft;
				SizeUtils.hookTarget( _tTitle, _icon, SizeUtils.RIGHT, innerPadding );
			}else{
				_tTitle.x = paddingLeft;
			}
			
			_alertContainer.x = paddingLeft;
			if ( _tTitle.text == "" )
			{
				_alertContainer.y = (_header ? _header.height : 0) + paddingTop;
			}else{
				SizeUtils.hookTarget( _alertContainer, (_header ? _header : _tTitle), SizeUtils.BOTTOM, paddingTop );
			}
			_tTitle.width = width - (_tTitle.x + paddingRight);
		}
		
		/*
		 * GETTER / SETTER API
		 */
		
		public function get title(): String
		{
			return _title;
		}
		 
		public function set title( value:String ): void
		{
			if ( _title == value ) return;
			_title = value;
			refreshMeasures();
		}
	}

}