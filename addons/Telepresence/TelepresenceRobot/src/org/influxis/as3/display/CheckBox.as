package org.influxis.as3.display 
{
	//Flash Classes
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	
	//Influxis Classes
	import org.influxis.as3.display.buttonclasses.ButtonBase;
	import org.influxis.as3.skins.StateSkin;
	import org.influxis.as3.utils.SizeUtils;
	import org.influxis.as3.utils.StringUtils;
	import org.influxis.as3.utils.doTimedLater;
	import org.influxis.as3.utils.ScreenScaler;
	
	public class CheckBox extends ButtonBase
	{
		//Skins
		private var _sLabel:String = "";
		
		//Skins
		protected var uiIcon:StateSkin;
		private var tLabel:TextField;
		
		/**
		 * STYLES API
		 */	
		
		override protected function onStyleChanged(style:String = null, styleItem:String = null):void 
		{
			super.onStyleChanged(style, styleItem);
			if ( initialized ) __updateTextFormat();
		}
		
		/**
		 * PRIVATE API
		 */
		
		private function __updateTextFormat(): void
		{
			if ( !initialized ) return;
			tLabel.defaultTextFormat = getTextFormat("label:" + buttonState);
			tLabel.setTextFormat( getTextFormat("label:" + buttonState) );
			tLabel.embedFonts = embeddedFontExists(tLabel.defaultTextFormat.font);
			
			measure();
			arrange();
		}
		
		/**
		 * PROTECTED API
		 */
		
		override protected function setSelected( value:Boolean ): void 
		{
			super.setSelected(value);
			__updateTextFormat();
		}
		 
		override protected function setState(state:String):void 
		{
			super.setState(state);
			__updateTextFormat();
			uiIcon.state = state;
			arrange();
		}
		 
		/**
		 * DISPLAY API
		 */
		
		override protected function measure():void 
		{
			super.measure();
			var textDimensions:Rectangle = StringUtils.measureText(_sLabel?_sLabel:"Dg");
			measuredWidth = paddingLeft + paddingRight + innerPadding + uiIcon.width + textDimensions.width + ScreenScaler.calculateSize(2);
			measuredHeight = paddingBottom + paddingTop + (textDimensions.height > uiIcon.height?textDimensions.height:uiIcon.height);
		}
		 
		override protected function createChildren(): void 
		{
			super.createChildren();
			
			uiIcon = new StateSkin( skinName, "icon", false );
			tLabel = new TextField();
			tLabel.multiline = false;
			tLabel.wordWrap = false;
			tLabel.selectable = false;
			tLabel.type = TextFieldType.DYNAMIC;
			tLabel.text = _sLabel;
			
			addChildren( uiIcon, tLabel );
		}
		
		override protected function childrenCreated():void 
		{
			super.childrenCreated();
			toggle = true;
			doTimedLater( 1, __updateTextFormat );
		}
		
		override protected function arrange(): void 
		{
			super.arrange();
			
			var textDimensions:Rectangle = StringUtils.measureText(tLabel.text, tLabel.defaultTextFormat);
			tLabel.width = textDimensions.width+ScreenScaler.calculateSize(2); tLabel.height = textDimensions.height;
			
			if ( getStyle("labelPosition") == SizeUtils.LEFT )
			{
				tLabel.x = paddingLeft;
				SizeUtils.moveY( tLabel, height, SizeUtils.MIDDLE );
				SizeUtils.hookTarget( uiIcon, tLabel, SizeUtils.RIGHT, innerPadding );
				SizeUtils.moveY( uiIcon, height, SizeUtils.MIDDLE );
			}else{
				uiIcon.x = paddingLeft;
				SizeUtils.moveY( uiIcon, height, SizeUtils.MIDDLE );
				SizeUtils.hookTarget( tLabel, uiIcon, SizeUtils.RIGHT, innerPadding );
				SizeUtils.moveY( tLabel, height, SizeUtils.MIDDLE );
			}
		}
		
		/**
		 * GETTER / SETTER
		 */
		
		override public function set skinName( value:String ):void 
		{
			super.skinName = value;
			if ( uiIcon ) 
			{
				uiIcon.skinName = value;
				__updateTextFormat();
			}
		}
		
		public function set label( value:String ): void
		{
			if ( value == _sLabel || value == null ) return;
			_sLabel = value;
			if ( initialized ) tLabel.text = _sLabel;
			refreshMeasures();
		}
		
		public function get label(): String
		{
			return _sLabel;
		}
	}
}