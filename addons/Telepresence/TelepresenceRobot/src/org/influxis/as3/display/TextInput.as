/**
 * TextInput - Copyright © 2010 Influxis All rights reserved.
**/

package org.influxis.as3.display 
{
	//Flash Classes
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.display.DisplayObject;
	import flash.text.TextFieldType;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	//Influxis Classes
	import org.influxis.as3.display.StyleCanvas;
	import org.influxis.as3.managers.SkinsManager;
	import org.influxis.as3.skins.SkinElement;
	import org.influxis.as3.skins.DefaultTextAreaSkin;
	import org.influxis.as3.utils.StringUtils;
	
	//Events
	[Event(name="enter",type="flash.events.Event")]
	public class TextInput extends StyleCanvas
	{
		private var _sVersion:String = "1.0.0.0";
		public static var STYLE_CONSTRUCTED:Boolean;
		
		public static const ENTER:String = "enter";
		
		private var _sRestrict:String;
		private var _bIsHtmlText:Boolean;
		private var _bUsePassword:Boolean;
		private var _nMaxChars:uint;
		private var _nSelectBegin:int;
		private var _nSelectEnd:int;
		private var _sText:String = "";
		private var _bEditable:Boolean = true;
		private var _textField:TextField;
		
		/**
		 * INIT API
		 */	
		 
		override protected function init(): void 
		{
			if ( !STYLE_CONSTRUCTED ) styleConstructed();
			super.init();
		}
		
		/**
		 * STYLES API
		 */	
			 
		protected function styleConstructed(): void
		{
			STYLE_CONSTRUCTED = true;
			var skm:SkinsManager = SkinsManager.getInstance();
			if ( !skm.exists(className) ) skm.setSkinElement( className, new SkinElement(className, DefaultTextAreaSkin.defaultSkin), true );
		}
		
		override protected function onStyleChanged(style:String = null, styleItem:String = null):void 
		{
			super.onStyleChanged(style, styleItem);
			if ( initialized ) 
			{
				_textField.defaultTextFormat = getTextFormat("text");
				arrange();
			}
		}
		 
		/**
		 * PRIVATE API
		 */
		
		//Set text props
		private function __updateTextValue( prop:String, value:* ): void
		{
			if ( !prop || !_textField ) return;
			_textField[prop] = value;
		}
		
		/**
		 * HANDLERS
		 */
		
		private function __onTextChange( event:Event ): void
		{
			if ( event.type == Event.CHANGE )
			{
				_sText = _bIsHtmlText ? _textField.htmlText : _textField.text;
			}
		}
		
		private function __handleKeyEvent( p_e:KeyboardEvent ): void
		{
			if( p_e.type == KeyboardEvent.KEY_DOWN && p_e.keyCode == Keyboard.ENTER ) dispatchEvent(new Event(ENTER));
		}
		
		/**
		 * DISPLAY
		 */
		
		override protected function measure():void 
		{
			super.measure();
			
			measuredWidth = 100;
			measuredHeight = StringUtils.measureText( "Dummy Text", _textField.defaultTextFormat ).height+paddingTop+paddingBottom;
		}
		 
		override protected function createChildren():void 
		{
			super.createChildren();
			
			_textField = new TextField();
			_textField.addEventListener( Event.CHANGE, __onTextChange );
			_textField.addEventListener( KeyboardEvent.KEY_DOWN, __handleKeyEvent );
			_textField.defaultTextFormat = getTextFormat("text");
			
			//Update text props
			if( !_bIsHtmlText ) __updateTextValue( "text", _sText );
			if( _bIsHtmlText ) __updateTextValue( "htmlText", _sText );
			__updateTextValue( "type", _bEditable ? TextFieldType.INPUT : TextFieldType.DYNAMIC );
			__updateTextValue( "displayAsPassword", _bUsePassword );
			__updateTextValue( "wordWrap", false );
			__updateTextValue( "multiline", false );
			__updateTextValue( "maxChars", _nMaxChars );
			__updateTextValue( "restrict", _sRestrict );
			
			_textField.setSelection(_nSelectBegin, _nSelectEnd);
			addChild( _textField );
		}
		
		override protected function arrange(): void 
		{
			super.arrange();
			
			_textField.width = width - paddingLeft - paddingRight;
			_textField.height = height - paddingTop - paddingBottom;
			_textField.x = paddingLeft;
			_textField.y = paddingTop;
		}
		
		/**
		 * GETTER / SETTER
		 */
		
		public function set text( value:String ): void 
		{
			_sText = value;
			_bIsHtmlText = false;
			
			__updateTextValue( "text", _sText );
		}
		
		public function get text(): String
		{
			return _sText;
		}
		
		public function set htmlText( value:String ): void 
		{
			_bIsHtmlText = true;
			_sText = value;
			__updateTextValue( "htmlText", _sText );
		}
		
		public function get htmlText(): String
		{
			return _sText;
		}
		
		public function set editable( value:Boolean ): void 
		{
			_bEditable = value;
			__updateTextValue( "type", value ? TextFieldType.INPUT : TextFieldType.DYNAMIC );
		}
		
		public function get editable(): Boolean
		{
			return _bEditable;
		}
		
		public function set displayAsPassword( value:Boolean ): void 
		{
			_bUsePassword = value;
			__updateTextValue( "displayAsPassword", _bUsePassword );
		}
		
		public function get displayAsPassword(): Boolean
		{
			return _bUsePassword;
		}
		
		public function get length(): Number
		{
			if ( !_sText ) return 0;
			return _sText.length;
		}
		
		public function set maxChars( value:uint ): void 
		{
			_nMaxChars = value;
			__updateTextValue( "maxChars", _nMaxChars );
		}
		
		public function get maxChars(): uint
		{
			return _nMaxChars;
		}
		
		public function set selectionBeginIndex( value:int ): void 
		{
			if ( isNaN(value) ) return;
			_nSelectBegin = value;
			if ( _textField ) _textField.setSelection(_nSelectBegin, _nSelectEnd);
		}
		
		public function get selectionBeginIndex(): int
		{
			return _nSelectBegin;
		}
		
		public function set selectionEndIndex( value:int ): void 
		{
			if ( isNaN(value) ) return;
			_nSelectEnd = value;
			if ( _textField ) _textField.setSelection(_nSelectBegin, _nSelectEnd);
		}
		
		public function get selectionEndIndex(): int
		{
			return _nSelectEnd;
		}
		
		public function get textWidth(): Number
		{
			if ( !initialized ) return 0;
			return _textField.textWidth;
		}
		
		public function get textHeight(): Number
		{
			if ( !initialized ) return 0;
			return _textField.textHeight;
		}
		
		public function set restrict( value:String ): void 
		{
			if ( !value ) return;
			_sRestrict = value;
			__updateTextValue( "restrict", _sRestrict );
		}
		
		public function get restrict(): String
		{
			return _sRestrict;
		}
		
		public function get textfield(): TextField
		{
			return _textField;
		}
	}
}