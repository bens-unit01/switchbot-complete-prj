package org.influxis.as3.list 
{
	//Flash Classes
	import flash.display.DisplayObjectContainer;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	
	//Influxis Classes
	import org.influxis.as3.utils.SizeUtils;
	import org.influxis.as3.utils.StringUtils;
	import org.influxis.as3.list.IconLabelItem;
	
	public class TwoLabelItem extends IconLabelItem
	{
		protected var label2:TextField;
		private var _sLabel2:String;
		
		/*
		 * INIT API
		 */
		
		public function TwoLabelItem(skinName:String): void
		{
			super(skinName);
		}
		
		/**
		 * PRIVATE API
		 */
		
		override protected function updateTextFormat():void 
		{
			label2.defaultTextFormat = getTextFormat("label2:" + state);
			label2.setTextFormat( getTextFormat("label2:" + state) );
			label2.embedFonts = embeddedFontExists(label2.defaultTextFormat.font);
			super.updateTextFormat();
		}
		
		override protected function refreshDisplay():void 
		{
			if ( !initialized ) return;
			
			//Retrieve index through the parent
			var index:Number;
			try
			{
				index = (parent as DisplayObjectContainer).getChildIndex(this);
			}catch ( e:Error )
			{
				
			}
			
			try
			{
				updateLabel2( data is String ? String(data) : data.label2 != undefined ? data.label2 : data.labelFunction2 is Function ? (data.labelFunction2 as Function).apply( null, [data, index] ) : null );
			}catch ( e:Error )
			{
				
			}
			
			super.refreshDisplay();
		}
		
		/**
		 * PROTECTED
		 */
		
		override protected function stateChanged():void 
		{
			super.stateChanged();
			addChild( label2 );
		}
		
		override protected function updateLabel(value:String):void 
		{
			super.updateLabel(value);
			label.text = value;
		}
		
		protected function updateLabel2( value:String ): void
		{
			if ( _sLabel2 == value || value == null ) return;
			_sLabel2 = value;
		}
		
		/**
		 * DISPLAY API
		 */
		
		override protected function measure():void 
		{
			super.measure();
			var newMeasuredHeight:Number = StringUtils.measureText( "Dummy Text", label2.defaultTextFormat ).height + paddingBottom + paddingTop;
			if ( newMeasuredHeight > measuredHeight ) measuredHeight = newMeasuredHeight;
		}
		 
		override protected function createChildren():void 
		{
			super.createChildren();
			
			//Create and format label 2
			label2 = new TextField();
			label2.multiline = false;
			label2.wordWrap = false;
			label2.selectable = false;
			label2.type = TextFieldType.DYNAMIC;
			
			addChild(label2);
		}
		
		override protected function childrenCreated():void 
		{
			super.childrenCreated();
			
			label2.height = StringUtils.measureText( "DymmyText", label2.defaultTextFormat ).height;
			if ( !styleExists("alignLabel2") || getStyle("alignLabel2") == SizeUtils.RIGHT ) 
			{
				rightAlign.push(label2);
			}else{
				leftAlign.push(label2);
			}
		}
		
		override protected function arrange(): void 
		{
			//Measure and size label
			var measuredText:Rectangle = StringUtils.measureText( label.text, label.defaultTextFormat );
			label.width = measuredText.width;
			label.height = measuredText.height;
			super.arrange();
			SizeUtils.moveY( label2, height, SizeUtils.MIDDLE );
		}
		
		override protected function formatTextLabel():void 
		{
			if ( _sLabel2 )
			{
				//Measure and cut off label 2 text if not enough space to display
				var availableWidth:Number = width - (paddingLeft + paddingRight + icon.width + label.width + (innerPadding * 2));
				var measuredWidth:Number = StringUtils.measureText( _sLabel2, label2.defaultTextFormat ).width;
				if ( measuredWidth > availableWidth )
				{
					StringUtils.cutOffText( label2, _sLabel2, availableWidth );
					label2.width = StringUtils.measureText( label2.text, label2.defaultTextFormat ).width;
				}else{
					label2.width = measuredWidth;
					label2.text = _sLabel2;
				}
			}
		}
		
		/**
		 * GETTER / SETTER
		 */
		
		override public function set data(value:Object):void 
		{
			super.data = value;
			refreshDisplay();
		}
	}
}