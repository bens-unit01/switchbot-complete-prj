package org.influxis.as3.display 
{
	//Flash Classes
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.events.Event;
	import flash.events.MouseEvent;
	 
	//Influxis Classes
	import org.influxis.as3.core.Display;
	import org.influxis.as3.display.StyleCanvas;
	import org.influxis.as3.display.Button;
	import org.influxis.as3.display.alertclasses.AlertPanel;
	import org.influxis.as3.interfaces.display.IAlert;
	import org.influxis.as3.events.SimpleEventConst;
	import org.influxis.as3.states.SizeStates;
	import org.influxis.as3.utils.SizeUtils;
	import org.influxis.as3.utils.StringUtils;
	import org.influxis.as3.utils.ScreenScaler;
	
	public class Alert extends StyleCanvas implements IAlert
	{
		public static const OK:String = "ok";
		public static const CANCEL:String = "cancel";
		
		private static var _CURR_PANEL_:DisplayObject;
		private static var _CURR_BG_:DisplayObject;
		private static var _CURR_APP_:Stage;
		
		private var _message:String;
		private var _okLabel:String;
		private var _cancelLabel:String;
		
		private var _tMessage:TextField;
		private var _okBtn:Button;
		private var _cancelBtn:Button;
		private var _icon:DisplayObject;
		
		/*
		 * STATIC API
		 */
		 
		//Launch simple alert
		public static function alert( message:String, title:String = null, okLabel:String = null, cancelLabel:String = null, icon:DisplayObject = null, skinName:String = null, backgroundClose:Boolean = false ): DisplayObject
		{
			var alertUI:Alert = new Alert();
				alertUI.message = message;
				alertUI.okLabel = okLabel;
				alertUI.cancelLabel = cancelLabel;
			
			__attachAlert( alertUI, title, icon, skinName, backgroundClose );
			return alertUI;
		}
		
		//Launch alert directly useful for more complex panels
		public static function launchAlertPanel( alertContainer:IAlert, title:String = null, icon:DisplayObject = null, skinName:String = null, backgroundClose:Boolean = false ): void
		{
			if ( !alertContainer ) return;
			__attachAlert( alertContainer, title, icon, skinName, backgroundClose );
		}
		
		private static function __attachAlert( alertContainer:IAlert, title:String = null, icon:DisplayObject = null, skinName:String = null, backgroundClose:Boolean = false ): void
		{
			if ( _CURR_PANEL_ ) __removeAlert();
			
			var alertPane:AlertPanel = new AlertPanel(alertContainer, icon);
				alertPane.title = !title ? "" : title;
				alertPane.skinName = skinName;
			
			_CURR_PANEL_ = alertPane;
			_CURR_PANEL_.addEventListener( SizeStates.MEASURE, __onDisplayEvent );
			_CURR_PANEL_.addEventListener( Event.CLOSE, __onDisplayEvent );
			_CURR_PANEL_.addEventListener( SizeStates.RESIZE, __onDisplayEvent );
			
			var alertBG:StyleCanvas = new StyleCanvas();
				alertBG.skinName = "alertBackground";
				if( backgroundClose ) alertBG.addEventListener( MouseEvent.CLICK, __onDisplayEvent );
				_CURR_BG_ = alertBG;
			
			if( !_CURR_APP_ ) _CURR_APP_ = Display.STAGE;
			_CURR_APP_.addChild(_CURR_BG_);
			_CURR_APP_.addChild(_CURR_PANEL_);
			_CURR_APP_.addEventListener( Event.RESIZE, __onDisplayEvent );
		}
		
		private static function __removeAlert(): void
		{
			if ( !_CURR_PANEL_ ) return;
			
			_CURR_PANEL_.removeEventListener( Event.CLOSE, __onDisplayEvent );
			_CURR_PANEL_.removeEventListener( SizeStates.MEASURE, __onDisplayEvent );
			_CURR_PANEL_.removeEventListener( SizeStates.RESIZE, __onDisplayEvent );
			
			var alertBG:StyleCanvas = _CURR_BG_ as StyleCanvas;
				alertBG.removeEventListener( MouseEvent.CLICK, __onDisplayEvent );
			
			_CURR_APP_.removeChild(_CURR_BG_);
			_CURR_APP_.removeChild(_CURR_PANEL_);
			_CURR_APP_.removeEventListener( SizeStates.RESIZE, __onDisplayEvent );
			_CURR_PANEL_ = null;
		}
		
		private static function __onDisplayEvent( event:Event ): void
		{
			if ( event.type == SizeStates.MEASURE || event.type == SizeStates.RESIZE || event.type == Event.RESIZE )
			{
				arrangeAlert();
			}else if ( event.type == Event.CLOSE || event.type == MouseEvent.CLICK )
			{
				__removeAlert();
			}
		}
		
		private static function arrangeAlert(): void
		{
			_CURR_BG_.width = _CURR_APP_.width;
			_CURR_BG_.height = _CURR_APP_.height;
			
			SizeUtils.moveX( _CURR_PANEL_, _CURR_APP_.stageWidth, SizeUtils.CENTER );
			SizeUtils.moveY( _CURR_PANEL_, _CURR_APP_.stageHeight, SizeUtils.MIDDLE );
		}
		
		/*
		 * HANDLERS
		 */
		
		private function __onButtonEvent( event:Event ): void
		{
			if ( event.type == SizeStates.RESIZE )
			{
				arrange();
				//invalidateDisplayList();
			}else if ( event.type == MouseEvent.CLICK || event.type == MouseEvent.MOUSE_DOWN )
			{
				if ( event.currentTarget == _cancelBtn )
				{
					dispatchEvent(new Event(CANCEL));
				}else{
					dispatchEvent(new Event(OK));
				}
				dispatchEvent(new Event(Event.CLOSE));
			}	
		}
		 
		/*
		 * DISPLAY API
		 */
		
		override protected function measure():void 
		{
			super.measure();
			measuredWidth = (_icon ? (_icon.width+innerPadding) : 0) + ScreenScaler.calculateSize(150) + paddingLeft + paddingRight;
			measuredHeight = StringUtils.measureText( _tMessage.text, _tMessage.defaultTextFormat, true, width - (paddingLeft + paddingRight+(_icon?(_icon.width+innerPadding):0)) ).height + _okBtn.height + paddingTop + paddingBottom + innerPadding;
		}
		 
		override protected function createChildren(): void 
		{
			super.createChildren();
			
			_tMessage = getStyleText( "message" );
			_okBtn = new Button();
			_okBtn.skinName = styleExists("okAlertBtnSkinName") ? getStyle("okAlertBtnSkinName") : "defaultOkAlertBtn";
			_cancelBtn = new Button();
			_cancelBtn.skinName = styleExists("cancelAlertBtnSkinName") ? getStyle("cancelAlertBtnSkinName") : "defaultCancelAlertBtn";
			_cancelBtn.visible = false;
			addChildren( _tMessage, _okBtn, _cancelBtn );
			
			//Add icon only if style exists
			if ( styleExists("icon") )
			{
				_icon = getStyleGraphic("icon");
				addChild(_icon);
			}
		}
		
		override protected function childrenCreated():void 
		{
			super.childrenCreated();
			_okBtn.label = _okLabel;
			_cancelBtn.label = _cancelLabel;
			_cancelBtn.visible = _cancelLabel && _cancelLabel != "";
			
			//_okBtn.addEventListener( SizeStates.MEASURE, __onButtonEvent );
			_okBtn.addEventListener( SizeStates.RESIZE, __onButtonEvent );
			_okBtn.addEventListener( Display.IS_MOBILE ? MouseEvent.MOUSE_DOWN : MouseEvent.CLICK, __onButtonEvent );
			_cancelBtn.addEventListener( Display.IS_MOBILE ? MouseEvent.MOUSE_DOWN : MouseEvent.CLICK, __onButtonEvent );
			
			_tMessage.wordWrap = true;
			_tMessage.text = _message;
		}
		
		override protected function arrange():void 
		{
			super.arrange();
			
			//Only if icon exist
			if ( _icon )
			{
				_icon.x = paddingLeft;
				_icon.y = paddingTop;
			}
			
			var textMeasure:Rectangle = StringUtils.measureText( _tMessage.text, _tMessage.defaultTextFormat, true, width - (paddingLeft + paddingRight + (_icon?(_icon.width + innerPadding):0)) );
			_tMessage.width = textMeasure.width; _tMessage.height = textMeasure.height+5;
			_tMessage.x = _icon ? _icon.x+_icon.width+innerPadding : paddingLeft; 
			_tMessage.y = paddingTop;
			
			if ( _cancelBtn.visible )
			{
				var totalWidth:Number = _cancelBtn.width + _okBtn.width + innerPadding;
				_okBtn.x = (width / 2) - (totalWidth / 2);
				SizeUtils.hookTarget( _cancelBtn, _okBtn, SizeUtils.RIGHT, innerPadding );
				SizeUtils.hookTarget( _cancelBtn, _tMessage, SizeUtils.BOTTOM, innerPadding );
				_okBtn.y = _cancelBtn.y;
			}else {
				SizeUtils.moveX( _okBtn, width, SizeUtils.CENTER );
				SizeUtils.hookTarget( _okBtn, _tMessage, SizeUtils.BOTTOM, innerPadding );
			}
		}
		
		/*
		 * GETTER / SETTER
		 */
		
		public function get message(): String
		{
			return _message;
		}
		 
		public function set message( value:String ): void
		{
			if ( _message == value ) return;
			_message = value;
			if ( initialized )
			{
				_tMessage.text = _message;
				refreshMeasures();
			}
		}
		
		public function get okLabel(): String
		{
			return _okLabel;
		}
		 
		public function set okLabel( value:String ): void
		{
			if ( _okLabel == value ) return;
			_okLabel = value;
			if ( initialized )
			{
				_okBtn.label = _okLabel;
				refreshMeasures();
			}
		}
		
		public function get cancelLabel(): String
		{
			return _cancelLabel;
		}
		 
		public function set cancelLabel( value:String ): void
		{
			if ( _cancelLabel == value ) return;
			_cancelLabel = value;
			if ( initialized )
			{
				_cancelBtn.label = _cancelLabel;
				refreshMeasures();
			}
		}
	}

}