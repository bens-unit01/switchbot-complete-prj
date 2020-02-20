package org.influxis.social.display.shareoptionsclasses 
{
	//Flash Classes
	import flash.text.TextField;
	import flash.geom.Rectangle;
	import flash.events.MouseEvent;
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	
	//Influxis Classes
	import org.influxis.as3.display.StyleComponent;
	import org.influxis.as3.interfaces.display.IAlert;
	import org.influxis.as3.display.TextInput;
	import org.influxis.as3.display.Button;
	import org.influxis.as3.utils.StringUtils;
	import org.influxis.as3.utils.SizeUtils;
	import org.influxis.as3.utils.ScreenScaler;
	
	public class PlayerLinkAlert extends StyleComponent implements IAlert
	{
		private var _tLink:TextInput;
		private var _lLink:TextField;
		private var _playerLink:String;
		private var _copyBtn:Button;
		
		/*
		 * HANDLERS
		 */
		
		private function __onMouseEvent( event:MouseEvent ): void
		{
			Clipboard.generalClipboard.setData( ClipboardFormats.TEXT_FORMAT, _tLink.text );
		}
		 
		/*
		 * DISPLAY API 
		 */
		
		override protected function measure():void 
		{
			super.measure();
			measuredWidth = ScreenScaler.calculateSize(200);
			measuredHeight = paddingTop + paddingBottom + _lLink.height + _tLink.height + _copyBtn.height + innerPadding;
		}
		 
		override protected function createChildren():void 
		{
			super.createChildren();
			
			_lLink = getStyleText("text");
			_tLink = new TextInput();
			_tLink.skinName = styleExists("textInputSkinName") ? getStyle("textInputSkinName") : "linkAlertTextInput";
			_copyBtn = new Button();
			_copyBtn.skinName = styleExists("buttonSkinName") ? getStyle("buttonSkinName") : "linkAlertButton";
			addChildren(_lLink, _tLink, _copyBtn);
		}
		
		override protected function childrenCreated():void 
		{
			super.childrenCreated();
			
			_lLink.text = getLabelAt("pathLabel");
			var rec:Rectangle = StringUtils.measureText( _lLink.text, _lLink.defaultTextFormat );
			_lLink.width = rec.width; _lLink.height = rec.height;
			_tLink.text = !_playerLink ? "" : _playerLink;
			_tLink.editable = false;
			_copyBtn.label = getLabelAt("copyBtn");
			_copyBtn.addEventListener( MouseEvent.MOUSE_DOWN, __onMouseEvent );
		}
		
		override protected function arrange():void 
		{
			super.arrange();
			_tLink.x = _lLink.x = paddingLeft; _lLink.y = paddingTop;
			SizeUtils.hookTarget( _tLink, _lLink, SizeUtils.BOTTOM );
			_tLink.width = width - (paddingLeft + paddingRight);
			SizeUtils.hookTarget( _copyBtn, _tLink, SizeUtils.BOTTOM, innerPadding ); 
			SizeUtils.moveX( _copyBtn, width, SizeUtils.RIGHT, paddingRight );
		}
		
		/*
		 * GETTER / SETTER API
		 */
		
		public function set playerLink( value:String ): void
		{
			if ( _playerLink == value ) return;
			_playerLink = value;
			if( initialized ) _tLink.text = _playerLink;
		}
		
		public function get playerLink(): String
		{
			return _playerLink;
		}
	}
}