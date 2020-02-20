package org.influxis.application.vidcollaborator.alert 
{
	//Flash Classes
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;
	
	//Influxis Classes
	import org.influxis.as3.display.StyleCanvas;
	import org.influxis.as3.interfaces.display.IAlert;
	import org.influxis.as3.display.Label;
	import org.influxis.as3.display.Button;
	import org.influxis.as3.display.TextInput;
	import org.influxis.as3.utils.SizeUtils;
	import org.influxis.as3.utils.ScreenScaler;
	
	public class PasswordPanel extends StyleCanvas implements IAlert
	{
		public static const AUTHORIZED:String = "passAuthorized";
		private var _source:Object;
		
		private var _passLabel:Label;
		private var _submitBtn:Button;
		private var _cancelBtn:Button;
		private var _passText:TextInput;
		
		/*
		 * PROTECTED API
		 */
		
		protected function resetPassword(): void
		{
			_passText.text = "";
			_passText.displayAsPassword = true;
		}
		
		/*
		 * HANDLERS
		 */
		
		private function __onButtonEvent( event:MouseEvent ): void
		{
			if ( event.currentTarget == _submitBtn )
			{
				if ( _passText.text == _source.password )
				{
					dispatchEvent(new Event(AUTHORIZED));
				}else{
					_passText.text = getLabelAt("incorrectPass");
					_passText.displayAsPassword = false;
					setTimeout(resetPassword, 1000 );
					return;
				}
			}
			dispatchEvent(new Event(Event.CLOSE));
		}
		 
		/*
		 * DISPLAY API
		 */
		
		override protected function measure():void 
		{
			super.measure();
			
			measuredWidth = paddingLeft + paddingRight + ScreenScaler.calculateSize(250);
			measuredHeight = paddingTop + paddingBottom + _passLabel.height + _passText.height + _submitBtn.height + innerPadding;
			
		}
		 
		override protected function createChildren():void 
		{
			super.createChildren();
			
			_passLabel = new Label( skinName, "enterPassLabel", "label" );
			
			_passText = new TextInput();
			_passText.skinName = "newSessionInput";
			
			_submitBtn = new Button();
			_submitBtn.skinName = "greenBtn";
			
			_cancelBtn = new Button();
			_cancelBtn.skinName = "redBtn";
			
			addChildren( _passLabel, _passText, _submitBtn, _cancelBtn );
		}
		 
		override protected function childrenCreated():void 
		{
			super.childrenCreated();
			
			_submitBtn.label = getLabelAt("submitBtn");
			_cancelBtn.label = getLabelAt("cancelBtn");
			
			_submitBtn.addEventListener( MouseEvent.CLICK, __onButtonEvent );
			_cancelBtn.addEventListener( MouseEvent.CLICK, __onButtonEvent );
			
			_passText.displayAsPassword = true;
		}
		
		override protected function arrange():void 
		{
			super.arrange();
			
			_passLabel.move( paddingLeft, paddingTop );
			
			_passText.x = paddingLeft;
			_passText.width = width - (paddingLeft + paddingRight);
			SizeUtils.hookTarget( _passText, _passLabel, SizeUtils.BOTTOM );
			
			_submitBtn.x = (width / 2) - ((_submitBtn.width + _cancelBtn.width + innerPadding) / 2);
			SizeUtils.hookTarget( _cancelBtn, _submitBtn, SizeUtils.RIGHT, innerPadding );
			SizeUtils.hookTarget( _submitBtn, _passText, SizeUtils.BOTTOM, innerPadding );
			SizeUtils.hookTarget( _cancelBtn, _passText, SizeUtils.BOTTOM, innerPadding );
			
		}
		
		/*
		 * GETTER / SETTER
		 */
		 
		public function set source( value:Object ): void
		{
			if ( _source == value ) return;
			_source = value;
		}
		
		public function get source(): Object
		{
			return _source;
		}
		
	}
}