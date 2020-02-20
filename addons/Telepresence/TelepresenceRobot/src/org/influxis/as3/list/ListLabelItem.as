/**
 * ListLabelItem - Copyright © 2011 Influxis All rights reserved.
**/

package org.influxis.as3.list 
{
	//Flash Classes
	import flash.display.DisplayObjectContainer;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	
	//Influxis Classes
	import org.influxis.as3.display.listclasses.ListItem;
	import org.influxis.as3.utils.SizeUtils;
	import org.influxis.as3.utils.StringUtils;
	
	public class ListLabelItem extends ListItem
	{
		private var _tLabel:TextField;
		private var _sLabel:String = "";
		
		/**
		 * INIT API
		 */
		
		public function ListLabelItem( skinName:String = "List" ): void 
		{
			super(skinName);
		}
		
		/**
		 * PRIVATE API
		 */
		
		private function __updateTextFormat(): void
		{
			if ( !initialized ) return;
			
			_tLabel.defaultTextFormat = getTextFormat("label:" + state);
			_tLabel.setTextFormat( getTextFormat("label:" + state) );
			_tLabel.embedFonts = embeddedFontExists(_tLabel.defaultTextFormat.font);
			arrange();
		}
		
		private function __parseData(): void
		{
			if ( !initialized || !data ) return;
			
			//Retrieve index through the parent
			var index:Number;
			try
			{
				index = (parent as DisplayObjectContainer).getChildIndex(this);
			}catch ( e:Error )
			{
				
			}
			
			_tLabel.text = data is String ? String(data) : data.label != undefined ? data.label : data.labelFunction is Function ? (data.labelFunction as Function).apply( null, [data, index] ) : null;
			//arrange();
		}
		
		/**
		 * PROTECTED
		 */
		
		override protected function stateChanged():void 
		{
			super.stateChanged();
			addChild(_tLabel);
			__updateTextFormat();
		}
		
		/**
		 * DISPLAY API
		 */
		
		override protected function measure():void 
		{
			super.measure();
			var measuredText:Rectangle = StringUtils.measureText( _tLabel.text, _tLabel.defaultTextFormat );
			measuredHeight = measuredText.height + paddingBottom + paddingTop;
			//measuredWidth = measuredText.width + paddingLeft + paddingRight;
		}
		 
		override protected function createChildren():void 
		{
			super.createChildren();
			
			_tLabel = new TextField();
			_tLabel.multiline = false;
			_tLabel.wordWrap = false;
			_tLabel.selectable = false;
			_tLabel.type = TextFieldType.DYNAMIC;
			_tLabel.text = _sLabel;
			addChild(_tLabel);
		}
		
		override protected function childrenCreated():void 
		{
			super.childrenCreated();
			__updateTextFormat();
			__parseData();
			refreshMeasures();
		}
		
		override protected function arrange(): void 
		{
			super.arrange();
			
			var textHeight:Number = StringUtils.measureText( _tLabel.text, _tLabel.defaultTextFormat ).height;
			_tLabel.width = width - (paddingLeft + paddingRight);
			_tLabel.height = (textHeight + (paddingBottom + paddingTop)) > height ? height : textHeight;
			_tLabel.x = paddingLeft;
			SizeUtils.moveY( _tLabel, height, SizeUtils.MIDDLE );
		}
		
		/**
		 * GETTER / SETTER
		 */
		
		override public function set data(value:Object):void 
		{
			super.data = value;
			__parseData();
		}
	}
}