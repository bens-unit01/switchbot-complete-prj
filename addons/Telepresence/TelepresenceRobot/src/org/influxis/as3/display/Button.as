package org.influxis.as3.display 
{
	//Flash Classes
	import flash.display.InteractiveObject;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldType;
	
	//Influxis Classes
	import org.influxis.as3.display.buttonclasses.ButtonBase;
	import org.influxis.as3.managers.SkinsManager;
	import org.influxis.as3.skins.SkinElement;
	import org.influxis.as3.skins.DefaultButtonSkin;
	import org.influxis.as3.utils.SizeUtils;
	import org.influxis.as3.states.MouseStates;
	import org.influxis.as3.utils.StringUtils;
	import org.influxis.as3.utils.doTimedLater;
	import org.influxis.as3.utils.ScreenScaler;
	
	public class Button extends ButtonBase
	{
		private var _sVersion:String = "1.0.0.0";
		private var _sLabel:String = "";
		
		//Skins
		private var uiIcon:InteractiveObject;
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
			refreshMeasures();
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
		}
		
		/**
		 * HANDLERS
		 */
		
		 
		/**
		 * DISPLAY API
		 */
		
		override protected function measure():void 
		{
			super.measure();
			
			if ( _sLabel == "" || !_sLabel )
			{
				measuredWidth = background.measuredWidth;
				measuredHeight = background.measuredHeight;
			}else{
				measuredWidth = paddingLeft + paddingRight + StringUtils.measureText(_sLabel?_sLabel:"Dg", tLabel.defaultTextFormat).width + ScreenScaler.calculateSize(2);
				measuredHeight = paddingBottom + paddingTop + StringUtils.measureText(_sLabel?_sLabel:"Dg", tLabel.defaultTextFormat).height;
			}
		}
		 
		override protected function createChildren(): void 
		{
			super.createChildren();
			
			tLabel = new TextField();
			tLabel.multiline = false;
			tLabel.wordWrap = false;
			tLabel.selectable = false;
			tLabel.type = TextFieldType.DYNAMIC;
			
			addChild(tLabel);
		}
		
		override protected function childrenCreated():void 
		{
			super.childrenCreated();
			tLabel.text = _sLabel;
			__updateTextFormat();
		}
		
		override protected function arrange(): void 
		{
			super.arrange();
			
			var textHeight:Number = StringUtils.measureText( "Dummy", tLabel.defaultTextFormat ).height;//tLabel.text
			tLabel.width = width - (paddingLeft + paddingRight);
			tLabel.height = textHeight;//(textHeight + (paddingBottom + paddingTop)) > height ? height : textHeight;
			tLabel.x = paddingLeft;
			SizeUtils.moveY( tLabel, height, SizeUtils.MIDDLE );
		}
		
		/**
		 * GETTER / SETTER
		 */
		
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