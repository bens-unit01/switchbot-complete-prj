/**
 * TextArea - Copyright © 2010 Influxis All rights reserved.
**/

package org.influxis.as3.display 
{
	//Flash Classes
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldType;
	import flash.text.TextLineMetrics;
	import flash.text.TextFieldAutoSize;
	import flash.events.Event;
	import flash.display.DisplayObject;
	
	//Influxis Classes
	import org.influxis.as3.display.StyleCanvas;
	import org.influxis.as3.display.ScrollBar;
	import org.influxis.as3.states.ToggleStates;
	import org.influxis.as3.skins.DefaultTextAreaSkin;
	import org.influxis.as3.managers.SkinsManager;
	import org.influxis.as3.skins.SkinElement;
	import org.influxis.as3.utils.SizeUtils;
	import org.influxis.as3.utils.handler;
	import org.influxis.as3.utils.doTimedLater;
	import org.influxis.as3.utils.StringUtils;
	
	public class TextArea extends StyleCanvas
	{
		
		/**
		 * ToDo - 
		 * 		
		 * 		> 1. Need to add horizontal scroll rules
		 * 		> 2. This class should extend a universal scroll base like flex does
		 * 		> 3. Text should be used from wrapper instead of raw
		 */
		
		private var _sVersion:String = "1.0.0.0";
		public static var STYLE_CONSTRUCTED:Boolean;
		
		private var _sRestrict:String;
		private var _bIsHtmlText:Boolean;
		private var _bUsePassword:Boolean;
		private var _bManualScroll:Boolean;
		private var _nLineCount:uint;
		private var _nMaxChars:uint;
		private var _nSelectBegin:int;
		private var _nSelectEnd:int;
		private var _sText:String = "";
		private var _sVertScrollPolicy:String = ToggleStates.AUTO;
		private var _bEditable:Boolean = true;
		private var _bWordWrap:Boolean = true;
		private var _bAutoScroll:Boolean = true;
		
		private var _textField:TextField;
		private var _scroller:ScrollBar;
		
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
			
			//_padLeft = styleExists("paddingLeft") ? getStyle("paddingLeft") as uint : 2;
			//_padTop = styleExists("paddingTop") ? getStyle("paddingTop") as uint : 2;
			//_padBottom = styleExists("paddingBottom") ? getStyle("paddingBottom") as uint : 2;
			//_padRight = styleExists("paddingRight") ? getStyle("paddingRight") as uint : 2;
			
			if ( initialized ) 
			{
				_textField.defaultTextFormat = getTextFormat("text");
				arrange();
			}
		}
		 
		/**
		 * PRIVATE API
		 */
		
		//Enables disables scroller
		private function __updateScrollerView(): void
		{
			if ( !_scroller ) return;
			_scroller.visible = _sVertScrollPolicy == ToggleStates.OFF || !_scroller.trackVisible ? false : (_scroller.scrollBarEnabled || _sVertScrollPolicy == ToggleStates.ON);
		}
		
		//Set text props
		private function __updateTextValue( prop:String, value:* ): void
		{
			if ( !prop || !_textField ) return;
			_textField[prop] = value;
		}
		
		//Updates scroller props when change in size
		private function __updateScrollBar(): void
		{
			if ( !initialized ) return;
			
			//Page size should be numlines shown plus one
			_scroller.pageSize = _textField.bottomScrollV - _textField.scrollV + 1;
			
			//Enables scroller only if bigger than 0
			_scroller.maxScrollPosition = (_textField.numLines - 1) - _scroller.pageSize;
			__updateScrollerView();
		}  
		
		private function __doScroll(): Boolean
		{
			if ( !_bAutoScroll || !_textField ) return false;
			return (_textField.scrollV == _textField.maxScrollV);
		}
		
		/**
		 * HANDLERS
		 */
		
		private function __onTextChange( event:Event ): void
		{
			if ( event.type == Event.CHANGE )
			{
				if ( _nLineCount != _textField.numLines )
				{
					__updateScrollBar();
					_nLineCount = _textField.numLines;
					_scroller.scrollPosition = _textField.scrollV - 1;
				}
				_sText = _bIsHtmlText ? _textField.htmlText : _textField.text;
			}
		}
		
		private function __onScrollerEvent( event:Event, fromText:Boolean = false ): void 
		{
			if ( event.type == ScrollBar.SCROLL && !fromText ) 
			{
				_bManualScroll = true;
				_textField.scrollV = _scroller.scrollPosition + 1;
			}else if ( event.type == ScrollBar.SCROLL_ENABLED )
			{
				__updateScrollerView();
				arrange();
			}else if ( event.type == Event.SCROLL && !_bManualScroll )
			{
				/*
				 * Note:
				 * 	When you change text size it doesn't register line change right away. 
				 * 	Instead it comes in with a scroll change so we gotta check if the page
				 * 	size changed and if so then tell scroll props to update instead of
				 * 	actually doing a scroll. Textfield frustrations beware :) 
				*/
				
				//If page size is different then update scroller props
				if ( (_textField.bottomScrollV - _textField.scrollV + 1) != _scroller.pageSize )
				{
					__updateScrollBar();
					
					//Only do auto scroll if max and position are the same
					if( _scroller.maxScrollPosition == _scroller.scrollPosition && _bAutoScroll ) _textField.scrollV = _scroller.maxScrollPosition+1;
				}else{
					//Else update scroll position
					_scroller.scrollPosition = _textField.scrollV == _textField.maxScrollV ? _textField.scrollV : (_textField.scrollV - 1);
				}
			}else if ( _bManualScroll )
			{
				_bManualScroll = false;
			}
		}
		
		/**
		 * DISPLAY
		 */
		
		override protected function measure():void 
		{
			super.measure();
			
			//Set default measures if width or height are set to nan
			measuredWidth = _sText ? StringUtils.measureText(_sText, _textField.defaultTextFormat, _bWordWrap, width).width : 100;
			measuredHeight = _sText ? StringUtils.measureText(_sText, _textField.defaultTextFormat, _bWordWrap, width).height : 50;
			
			//_padLeft = styleExists("paddingLeft") ? getStyle("paddingLeft") as uint : 2;
			//_padTop = styleExists("paddingTop") ? getStyle("paddingTop") as uint : 2;
			//_padBottom = styleExists("paddingBottom") ? getStyle("paddingBottom") as uint : 2;
			//_padRight = styleExists("paddingRight") ? getStyle("paddingRight") as uint : 2;
		}
		 
		override protected function createChildren():void 
		{
			super.createChildren();
			
			_textField = new TextField();
			_textField.addEventListener( Event.CHANGE, __onTextChange );
			_textField.addEventListener( Event.SCROLL, handler(__onScrollerEvent, true) );
			_textField.defaultTextFormat = getTextFormat("text");
			
			_scroller = new ScrollBar();
			_scroller.addEventListener( ScrollBar.SCROLL, __onScrollerEvent );
			_scroller.addEventListener( ScrollBar.SCROLL_ENABLED, __onScrollerEvent );
			_scroller.lineScrollSize = 1;
			_scroller.visible = false;
			
			//Update text props
			if( !_bIsHtmlText ) __updateTextValue( "text", _sText );
			if( _bIsHtmlText ) __updateTextValue( "htmlText", _sText );
			__updateTextValue( "type", _bEditable ? TextFieldType.INPUT : TextFieldType.DYNAMIC );
			__updateTextValue( "displayAsPassword", _bUsePassword );
			__updateTextValue( "wordWrap", _bWordWrap );
			__updateTextValue( "maxChars", _nMaxChars );
			__updateTextValue( "restrict", _sRestrict );
			_textField.setSelection(_nSelectBegin, _nSelectEnd);
			
			__updateScrollBar();
			addChildren( _textField, _scroller );
		}
		
		override protected function arrange():void 
		{
			super.arrange();
			
			_textField.width = width - paddingLeft - paddingRight - (_scroller.visible ? _scroller.width : 0);
			_textField.height = height - paddingTop - paddingBottom;
			_textField.x = paddingLeft;
			_textField.y = paddingTop;
			
			//Scroller
			_scroller.width = getStyle( "vScrollWidth" ) as Number;
			if ( _scroller.width == 0 ) _scroller.width = 15;
			_scroller.height = height;
			
			if( _sText.length > 0 ) __updateScrollBar();
			SizeUtils.moveX( _scroller, width, SizeUtils.RIGHT );
		}
		
		/**
		 * GETTER / SETTER
		 */
		
		public function set text( value:String ): void 
		{
			_sText = value;
			_bIsHtmlText = false;
			
			var bDoScroll:Boolean = __doScroll();
			__updateTextValue( "text", _sText );
			__updateScrollBar();
			
			if ( bDoScroll && _bAutoScroll ) _scroller.scrollPosition = _textField.scrollV = _textField.maxScrollV;
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
		
		public function set wordWrap( value:Boolean ): void 
		{
			_bWordWrap = value;
			__updateTextValue( "wordWrap", _bWordWrap );
		}
		
		public function get wordWrap(): Boolean
		{
			return _bWordWrap;
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
		
		public function set verticalScrollPolicy( value:String ): void 
		{
			if ( !value ) return;
			_sVertScrollPolicy = value;
			__updateScrollerView();
		}
		
		public function get verticalScrollPolicy(): String
		{
			return _sVertScrollPolicy;
		}
		
		public function set verticalScrollPosition( value:Number ): void
		{
			if ( !_scroller ) return;
			
			var position:Number = isNaN(value) ? 0 : value > _scroller.maxScrollPosition ? _scroller.maxScrollPosition : value < _scroller.minScrollPosition ? _scroller.minScrollPosition : value;;
			_scroller.scrollPosition = value;
			_textField.scrollV = _scroller.scrollPosition + 1;
		}
		
		public function get verticalScrollPosition(): Number
		{
			var position:Number = 0;
			if ( _scroller ) position = _scroller.scrollPosition;
			return position;
		}
		
		public function get maxScrollPosition(): Number
		{
			var position:Number = 0;
			if ( _scroller ) position = _scroller.maxScrollPosition;
			return position;
		}
		
		public function set autoScroll( value:Boolean ):void 
		{
			_bAutoScroll = value;
		}
		
		public function get autoScroll(): Boolean
		{
			return _bAutoScroll;
		}
		
		public function get textfield(): TextField
		{
			return _textField;
		}
	}
}