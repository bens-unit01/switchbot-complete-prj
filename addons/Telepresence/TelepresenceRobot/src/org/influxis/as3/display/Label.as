package org.influxis.as3.display 
{
	//Flash Classes
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
	//Influxis Classes
	import org.influxis.as3.display.StyleComponent;
	import org.influxis.as3.utils.StringUtils;
	import org.influxis.as3.utils.SizeUtils;
	
	public class Label extends StyleComponent
	{
		private var _customSkinName:String;
		private var _customStyle:String;
		private var _targetLabel:String;
		private var _text:String = "";
		
		private var _textField:TextField;
		private var _background:DisplayObject;
		
		/*
		 * INIT API
		 */
		
		public function Label( skinName:String = null, targetLabel:String = null, targetStyle:String = null ): void
		{
			_customSkinName = skinName;
			_customStyle = targetStyle;
			_targetLabel = targetLabel;
			super();
		}
		
		override protected function init(): void 
		{
			if( _customSkinName ) skinName = _customSkinName;
			super.init();
		}
		
		/*
		 * DISPLAY PAI
		 */
		
		override protected function measure():void 
		{
			var measuredText:Rectangle = StringUtils.measureText( _textField.text == ""?"0000":_textField.text, _textField.defaultTextFormat );
			if ( _customStyle )
			{
				measuredWidth = measuredText.width;
				measuredHeight = measuredText.height;
			}
			
			super.measure();
			if ( !_customStyle )
			{
				measuredWidth = measuredText.width + (paddingLeft + paddingRight);
				measuredHeight = measuredText.height + (paddingTop + paddingBottom);
			}
		}
		 
		override protected function createChildren():void 
		{
			super.createChildren();
			
			if ( !_customStyle && styleExists("background") )
			{
				_background = getStyleGraphic("background");
				addChild(_background);
			}
			
			_textField = getStyleText(!_customStyle?"label":_customStyle);
			addChild(_textField);
		}
		
		override protected function childrenCreated(): void 
		{
			super.childrenCreated();
			_textField.text = _targetLabel ? getLabelAt(_targetLabel) : _text == null ? "" : _text;
		}
		
		override protected function arrange(): void 
		{
			super.arrange();
			
			if ( _customStyle )
			{
				_textField.x = _textField.y = 0;
				_textField.width = width;
				_textField.height = height;
			}else{
				if ( styleExists("align") || styleExists("verticalAlign") )
				{
					var sHortAlign:String = styleExists("align") ? getStyle("align") : SizeUtils.CENTER;
					var sVertAlign:String = styleExists("verticalAlign") ? getStyle("verticalAlign") : SizeUtils.MIDDLE;
					var measuredText:Rectangle = StringUtils.measureText( _textField.text == ""?"0000":_textField.text, _textField.defaultTextFormat );
					
					_textField.width = measuredText.width; _textField.height = measuredText.height;
					SizeUtils.moveX( _textField, width, sHortAlign, (sHortAlign!=SizeUtils.CENTER?sHortAlign==SizeUtils.LEFT?paddingLeft:paddingRight:0) );
					SizeUtils.moveY( _textField, height, sVertAlign, (sVertAlign!=SizeUtils.MIDDLE?sVertAlign==SizeUtils.TOP?paddingTop:paddingBottom:0) );
				}else{
					_textField.x = paddingLeft; _textField.y = paddingTop;
					_textField.width = width - (paddingLeft+paddingRight);
					_textField.height = height - (paddingTop+paddingBottom);
				}
			}
			
			//Only size if it exists
			if ( _background )
			{
				_background.width = width;
				_background.height = height;
			}
		}
		
		/*
		 * GETTER / SETTER
		 */
		
		public function set text( value:String ): void
		{
			if ( value == _text ) return;
			
			if ( initialized )
			{
				_textField.text = value == null ? "" : value;
				if ( !value || !_text || value.length != _text.length ) refreshMeasures();
			}
			_text = value;
			_targetLabel = null;
		}
		 
		public function get text(): String
		{
			return _text;
		}
		
		public function set targetLabel( value:String ): void
		{
			if ( _targetLabel == value ) return;
			_targetLabel = value;
			if ( initialized )
			{
				_textField.text = !_targetLabel ? !_text ? "" : _text : getLabelAt(_targetLabel);
				refreshMeasures();
			}
		}
		
		public function get targetLabel(): String
		{
			return _targetLabel;
		}
	}
}