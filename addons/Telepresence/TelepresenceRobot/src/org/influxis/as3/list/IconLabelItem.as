package org.influxis.as3.list 
{
	//Flash Classes
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	
	//Influxis Classes
	import org.influxis.as3.display.listclasses.ListItem;
	import org.influxis.as3.utils.SizeUtils;
	import org.influxis.as3.utils.StringUtils;
	
	public class IconLabelItem extends ListItem
	{
		private var _iconStates:Object;
		private var _iconSavedIndex:Number;
		private var _iconLeftAlign:Boolean;
		private var _sLabel:String;
		
		protected var leftAlign:Array;
		protected var rightAlign:Array;
		protected var label:TextField;
		protected var icon:DisplayObject;
		
		/*
		 * INIT API
		 */
		
		public function IconLabelItem(skinName:String): void
		{
			super(skinName);
		}
		 
		/**
		 * PROTECTED
		 */
		
		protected function updateTextFormat(): void
		{
			if ( !initialized ) return;
			
			label.defaultTextFormat = getTextFormat("label:" + state);
			label.setTextFormat( getTextFormat("label:" + state) );
			label.embedFonts = embeddedFontExists(label.defaultTextFormat.font);
			invalidateDisplayList();
		}
		
		protected function refreshDisplay(): void
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
			
			updateLabel( data is String ? String(data) : data.label != undefined ? data.label : data.labelFunction is Function ? (data.labelFunction as Function).apply( null, [data, index] ) : null );
			invalidateDisplayList();
		}
		
		//Generate icon styles
		protected final function refreshIconStates(): void
		{	
			_iconStates = new Object();
			_iconStates["up"] = getStyleGraphic( "icon:up" );
			_iconStates["down"] = getStyleGraphic( "icon:down" );
			_iconStates["over"] = getStyleGraphic( "icon:over" );
			_iconStates["selectedUp"] = getStyleGraphic( "icon:selectedUp" );
			_iconStates["selectedDown"] = getStyleGraphic( "icon:selectedDown" );
			_iconStates["selectedOver"] = getStyleGraphic( "icon:selectedOver" );
			_iconStates["disabled"] = getStyleGraphic( "icon:disabled" );
		}
		
		override protected function stateChanged():void 
		{
			super.stateChanged();
			
			//Get new icon skin
			icon = (_iconStates[state] == undefined ? _iconStates["up"] : _iconStates[state]) as DisplayObject;
			
			//Have to redo saved reference in align arrays. Not ideal solution so will have to think of something better when times comes to solve this :/
			(_iconLeftAlign ? leftAlign : rightAlign)[_iconSavedIndex] = icon;
			
			addChildren( label, icon );
			
			//Format text skin
			updateTextFormat();
		}
		
		protected function updateLabel( value:String ): void
		{
			if ( _sLabel == value || value == null ) return;
			_sLabel = value;
		}
		
		/**
		 * DISPLAY API
		 */
		
		override protected function measure():void 
		{
			super.measure();
			measuredHeight = StringUtils.measureText( "Dummy Text", label.defaultTextFormat ).height + paddingBottom + paddingTop;
		}
		 
		override protected function createChildren(): void 
		{
			super.createChildren();
			
			//Create and format label 1
			label = new TextField();
			label.multiline = false;
			label.wordWrap = false;
			label.selectable = false;
			label.type = TextFieldType.DYNAMIC;
			
			//Create icon states
			refreshIconStates();
			
			//Set current icon state and add children
			icon = (_iconStates[state] == undefined ? _iconStates["up"] : _iconStates[state]) as DisplayObject;
			addChildren( label, icon );
		}
		
		override protected function childrenCreated():void 
		{
			super.childrenCreated();
			updateTextFormat();
			
			leftAlign = new Array();
			rightAlign = new Array();
			
			//Submit to align array which handles the arranging
			if ( !styleExists("alignIcon") || getStyle("alignIcon") == SizeUtils.LEFT ) 
			{
				_iconSavedIndex = leftAlign.length;
				_iconLeftAlign = true;
				leftAlign.push(icon);
			}else{
				_iconSavedIndex = rightAlign.length;
				rightAlign.push(icon);
			}
			if ( !styleExists("alignLabel") || getStyle("alignLabel") == SizeUtils.LEFT ) 
			{
				leftAlign.push(label);
			}else{
				rightAlign.push(label);
			}
			
			refreshDisplay();
		}
		
		override protected function arrange(): void 
		{
			super.arrange();
			
			formatTextLabel();
			var nLen:Number; var i:Number;
			if ( leftAlign )
			{
				nLen = leftAlign.length;
				for ( i = 0; i < nLen; i++ )
				{
					if ( i == 0 )
					{
						SizeUtils.moveX( leftAlign[i], width, SizeUtils.LEFT, paddingLeft );
					}else{
						SizeUtils.hookTarget( leftAlign[i], leftAlign[i-1], SizeUtils.RIGHT, innerPadding );
					}
				}
			}
			
			if ( rightAlign )
			{
				nLen = rightAlign.length;
				for ( i = 0; i < nLen; i++ )
				{
					if ( i == 0 )
					{
						SizeUtils.moveX( rightAlign[i], width, SizeUtils.RIGHT, paddingRight );
					}else{
						SizeUtils.hookTarget( rightAlign[i], rightAlign[i-1], SizeUtils.LEFT, innerPadding );
					}
				}
			}
			
			SizeUtils.moveY( label, height, SizeUtils.MIDDLE );
			SizeUtils.moveY( icon, height, SizeUtils.MIDDLE );
		}
		
		protected function formatTextLabel(): void
		{
			if ( _sLabel )
			{
				//Measure and cut off label text if not enough space to display
				var availableWidth:Number = width - (paddingLeft + paddingRight + icon.width + innerPadding);
				var measuredText:Rectangle = StringUtils.measureText( _sLabel, label.defaultTextFormat );
				if ( measuredText.width > availableWidth )
				{
					StringUtils.cutOffText( label, _sLabel, availableWidth );
					label.width = StringUtils.measureText( label.text, label.defaultTextFormat ).width;
				}else{
					label.width = measuredText.width;
					label.text = _sLabel;
				}
				label.height = measuredText.height;
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