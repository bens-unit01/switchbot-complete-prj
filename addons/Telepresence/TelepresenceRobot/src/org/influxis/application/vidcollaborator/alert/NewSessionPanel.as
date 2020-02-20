package org.influxis.application.vidcollaborator.alert 
{
	//Flash Classes
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.FocusEvent;
	import flash.utils.Dictionary;
	
	//Influxis Classes
	import org.influxis.as3.display.StyleCanvas;
	import org.influxis.as3.display.Label;
	import org.influxis.as3.display.TextInput;
	import org.influxis.as3.display.CheckBox;
	import org.influxis.as3.display.Button;
	import org.influxis.as3.events.DataEvent;
	import org.influxis.as3.interfaces.display.IAlert;
	import org.influxis.as3.utils.SizeUtils;
	import org.influxis.as3.utils.ScreenScaler;
	
	public class NewSessionPanel extends StyleCanvas implements IAlert
	{
		public static const CREATED:String = "sessionCreated";
		
		private var _sessionID:String;
		private var _defaultTextRef:Dictionary;
		private var _includeCancel:Boolean;
		
		private var _lTitle:Label;
		private var _lPass:Label;
		private var _lUserLimit:Label;
		
		private var _tTitle:TextInput;
		private var _tPass:TextInput;
		private var _tUserLimit:TextInput;
		private var _cxPrivate:CheckBox;
		
		private var _cbCreate:Button;
		private var _cbCancel:Button;
		
		/*
		 * INIT API
		 */
		
		override protected function preInitialize():void 
		{
			_sessionID = "session" + new Date().getTime();
			super.preInitialize();
		}
		
		/*
		 * HANDLERS
		 */
		
		private function __onButtonEvent( event:MouseEvent ): void
		{
			if ( event.currentTarget == _cbCreate )
			{
				//Create new session
				dispatchEvent(new DataEvent(CREATED, 
				{
					id: _sessionID,
					title: _tTitle.text == "" ? null : String(_tTitle.text),
					privateSession: _cxPrivate.selected,
					password: _tPass.text == "" || _tPass.text == getLabelAt("noPassword") ? null : String(_tPass.text),
					limit: _tUserLimit.text == "" ? 0 : Number(_tUserLimit.text)
				} ));
			}
			
			dispatchEvent(new Event(Event.CLOSE));
		}
		
		private function __onFocusEvent( event:FocusEvent ): void
		{
			var input:TextInput = event.currentTarget as TextInput;
			if ( !input ) return;
			
			switch( event.type )
			{
				case FocusEvent.FOCUS_IN : 
					if ( input.text == _defaultTextRef[input] ) input.text = "";
					break;
				case FocusEvent.FOCUS_OUT :
					if ( input.text == "" ) input.text = _defaultTextRef[input];
					break;
			}
		}
		
		/*
		 * DISPLAY API
		 */
		
		override protected function measure():void 
		{
			super.measure();
			
			measuredWidth = ScreenScaler.calculateSize(200) + paddingLeft + paddingRight;
			measuredHeight = _lTitle.height + _lPass.height + _tTitle.height + _tPass.height + 
							 _cxPrivate.height + _cbCreate.height + (innerPadding * 3) + paddingTop + paddingBottom;
		}
		
		override protected function createChildren(): void 
		{
			super.createChildren();
			
			_lTitle = new Label( skinName, "sessionTitle", "label" );
			_lPass = new Label( skinName, "sessionPassword", "label" );
			_lUserLimit = new Label( skinName, "sessionLimit", "label" );
			
			_tTitle = new TextInput();
			_tTitle.skinName = "newSessionInput";
			_tPass = new TextInput();
			_tPass.skinName = "newSessionInput";
			_tUserLimit = new TextInput();
			_tUserLimit.skinName = "newSessionInput";
			
			_cxPrivate = new CheckBox();
			_cxPrivate.skinName = "newSessionCheckBox";
			
			_cbCreate = new Button();
			_cbCreate.skinName = "greenBtn";
			
			_cbCancel = new Button();
			_cbCancel.skinName = "redBtn";
			_cbCancel.visible = _includeCancel;
			
			addChildren( _lTitle, _lPass, _lUserLimit, 
						 _tTitle, _tPass, _tUserLimit, 
						 _cxPrivate, _cbCreate, _cbCancel );
		}
		
		override protected function childrenCreated():void 
		{
			super.childrenCreated();
			
			_defaultTextRef = new Dictionary();
			_defaultTextRef[_tUserLimit] = "0";
			_defaultTextRef[_tTitle] = _sessionID;
			_defaultTextRef[_tPass] = getLabelAt("noPassword");
			
			_tUserLimit.addEventListener( FocusEvent.FOCUS_IN, __onFocusEvent );
			_tUserLimit.addEventListener( FocusEvent.FOCUS_OUT, __onFocusEvent );
			_tTitle.addEventListener( FocusEvent.FOCUS_IN, __onFocusEvent );
			_tTitle.addEventListener( FocusEvent.FOCUS_OUT, __onFocusEvent );
			_tPass.addEventListener( FocusEvent.FOCUS_IN, __onFocusEvent );
			_tPass.addEventListener( FocusEvent.FOCUS_OUT, __onFocusEvent );
			
			_tUserLimit.maxChars = 5;
			_tUserLimit.restrict = "0-9";
			_tUserLimit.text = "0";
			
			_tTitle.text = _sessionID;
			_tPass.text = _defaultTextRef[_tPass];
			
			_cxPrivate.label = getLabelAt("privateSession");
			_cbCreate.label = getLabelAt("createSession");
			_cbCancel.label = getLabelAt("cancelBtn");
			_cbCreate.addEventListener( MouseEvent.CLICK, __onButtonEvent );
			_cbCancel.addEventListener( MouseEvent.CLICK, __onButtonEvent );
		}
		
		override protected function arrange():void 
		{
			super.arrange();
			
			//Title
			_lTitle.move( paddingLeft, paddingTop );
			_tTitle.width = width - (paddingLeft + paddingRight);
			_tTitle.x = paddingLeft;
			SizeUtils.hookTarget( _tTitle, _lTitle, SizeUtils.BOTTOM );
			
			//Password
			_lPass.x = paddingLeft;
			SizeUtils.hookTarget( _lPass, _tTitle, SizeUtils.BOTTOM, innerPadding );
			_tPass.width = (width - (paddingLeft + paddingRight)) - (ScreenScaler.calculateSize(60) + innerPadding);
			_tPass.x = paddingLeft;
			SizeUtils.hookTarget( _tPass, _lPass, SizeUtils.BOTTOM );
			
			//User Limit
			_tUserLimit.width = ScreenScaler.calculateSize(60);
			_tUserLimit.y = _tPass.y;
			SizeUtils.hookTarget( _tUserLimit, _tPass, SizeUtils.RIGHT, innerPadding );
			_lUserLimit.x = _tUserLimit.x;
			SizeUtils.hookTarget( _lUserLimit, _tUserLimit, SizeUtils.TOP );
			
			//Private Checkbox
			_cxPrivate.x = paddingLeft;
			SizeUtils.hookTarget( _cxPrivate, _tUserLimit, SizeUtils.BOTTOM, innerPadding );
			
			//Buttons
			if ( _includeCancel )
			{
				_cbCreate.x = (width / 2) - ((_cbCreate.width + _cbCancel.width + innerPadding) / 2);
				SizeUtils.hookTarget( _cbCancel, _cbCreate, SizeUtils.RIGHT, innerPadding );
				SizeUtils.hookTarget( _cbCancel, _cxPrivate, SizeUtils.BOTTOM, innerPadding );
			}else{
				SizeUtils.moveX( _cbCreate, width, SizeUtils.CENTER );
				
			}
			
			SizeUtils.hookTarget( _cbCreate, _cxPrivate, SizeUtils.BOTTOM, innerPadding );
		}
		
		/*
		 * GETTER / SETTER
		 */
		
		public function set includeCancel( value:Boolean ): void
		{
			if ( _includeCancel == value ) return;
			
			_includeCancel = value;
			if ( initialized )
			{
				_cbCancel.visible = _includeCancel;
				invalidateDisplayList();
			}
		}
		
		public function get includeCancel(): Boolean
		{
			return _includeCancel;
		}
	}
}