/**
 * SimpleChat - Copyright © 2010 Influxis All rights reserved.
**/

package org.influxis.flotools.components 
{
	//Flash Classes
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	
	//Influxis Classes
	import flash.net.NetConnection;
	import org.influxis.flotools.core.InfluxisComponent;
	import org.influxis.as3.display.TextArea;
	import org.influxis.as3.display.Button;
	import org.influxis.as3.utils.SizeUtils;
	import org.influxis.as3.utils.doTimedLater;
	import org.influxis.as3.utils.StringUtils;
	import org.influxis.as3.events.SimpleEvent;
	import org.influxis.as3.interfaces.net.IFMS;
	import org.influxis.as3.managers.LayoutManager;
	import org.influxis.as3.containers.Divider;
	import org.influxis.as3.states.RotateState;
	
	//Flotools Classes
	import org.influxis.flotools.data.FlowChatManager;
	import org.influxis.flotools.states.MessageType;
	
	public class SimpleChat extends InfluxisComponent implements IFMS
	{
		private var _sVersion:String = "1.0.0.0";
		
		//Because of a bug from either flash or flex i lose line breaks when trying to recover text so use key below instead to format in history 
		private static var _DEFAULT_LINE_BREAK_:String = "{br}";
		
		private var _flm:FlowChatManager;
		private var _layout:LayoutManager;
		
		private var _oLastMsg:Object;
		private var _oUserData:Object;
		private var _sUsername:String;
		
		private var _nOuterGap:uint = 0;
		private var _nInnerGap:uint = 5;
		private var _nInputHeight:uint = 40;
		private var _nButtonWidth:uint = 50;
		
		private var _div:Divider;
		private var _history:TextArea;
		private var _input:TextArea;
		private var _send:Button;
		
		/**
		 * STYLES API
		 */
		
		override protected function onStyleChanged(style:String = null, styleItem:String = null):void 
		{
			super.onStyleChanged(style, styleItem);
			
			if ( styleExists("innerGap") ) _nInnerGap = getStyle( "innerGap" );
			if ( styleExists("outerGap") ) _nOuterGap = getStyle( "outerGap" );
			if ( styleExists("inputHeight") ) _nInputHeight = getStyle( "inputHeight" );
			if ( initialized ) arrange();
		}
		
		/**
		 * PROTECTED API
		 */
		
		override public function connect(p_nc:NetConnection):Boolean 
		{
			if ( !super.connect(p_nc) ) return false;
			
			if ( initialized )
			{
				_send.visible = _input.visible = _input.editable = true;
				arrange();
			}
			return true;
		}
		
		override public function close():void 
		{
			super.close();
			
			if ( _input )
			{
				_send.visible = _input.visible = _input.editable = false;
				_input.text = "";
				arrange();
			}	
		}
		
		override protected function instanceChange(): void 
		{
			super.instanceChange();
			if ( !connected ) return;
			
			_flm = FlowChatManager.getInstance( instance );
			_flm.addEventListener( SimpleEvent.ADDED, __handleFlowEvent );
			_flm.addEventListener( SimpleEvent.REMOVED, __handleFlowEvent );
			_flm.addEventListener( SimpleEvent.UPDATED, __handleFlowEvent );
			_flm.addEventListener( SimpleEvent.CHANGED, __handleFlowEvent );
			_flm.username = _sUsername;
			_flm.connect( _nc );
		}
		
		override protected function instanceClose():void 
		{
			super.instanceClose();
			
			if ( _flm )
			{
				_flm.removeEventListener( SimpleEvent.ADDED, __handleFlowEvent );
				_flm.removeEventListener( SimpleEvent.REMOVED, __handleFlowEvent );
				_flm.removeEventListener( SimpleEvent.UPDATED, __handleFlowEvent );
				_flm.removeEventListener( SimpleEvent.CHANGED, __handleFlowEvent );
				
				_flm.close();
				_flm = null
				
				_history.text = "";
			}
		}
		
		/**
		 * PUBLIC API
		**/
		
		public function sendMessage( p_sMsg:String, p_txFormat:TextFormat = null ): void
		{
			//trace( "sendMessage: " + p_sMsg );
			if( !p_sMsg || p_sMsg == "" ) return;
			_flm.sendMessage( StringUtils.stripHTML(p_sMsg), MessageType.TEXT, {format:__formatTextFormat(p_txFormat), flowUserData:_oUserData} );
		}
		
		/**
		 * PROTECTED API
		 */
		
		protected function composeMessage( msg:Object ): void
		{
			if ( !msg ) return;
			
			if ( _oLastMsg )
			{
				if ( msg.name == _oLastMsg.name )
				{
					_history.text += "  - " + parseText(msg.data) + "\r";
				}else{
					_history.text += msg.name + ": \r  - " + parseText(msg.data) + "\r";
				}
			}else{
				_history.text += msg.name + ": \r  - " + parseText(msg.data) + "\r";
			}
			_oLastMsg = msg;
		}
		
		protected function parseText( msg:String ): String
		{
			if ( !msg ) return "";
			return (msg.split(_DEFAULT_LINE_BREAK_).join("\r"));
		}
		 
		/**
		 * PRIVATE API
		 */
		
		private function __formatTextFormat( p_txFormat:TextFormat ): Object
		{
			if( !p_txFormat ) return null;
			return {bold:p_txFormat.bold, color:p_txFormat.color, font:p_txFormat.font, italic:p_txFormat.italic, size:p_txFormat.size, underline:p_txFormat.underline};
		}
		
		private function __clearMessageText(): void
		{
			_input.text = "";
		}
		
		private function __newLine(): void
		{
			_input.text += "\r";
			_input.textfield.setSelection( _input.length, _input.length );
		}
		
		/**
		 * HANDLERS
		 */
		
		private function __handleFlowEvent( event:SimpleEvent ): void
		{
			//trace( "__handleFlowEvent: " + event.type );
			if ( event.type == SimpleEvent.ADDED )
			{
				composeMessage( event.data );
			}else if ( event.type == SimpleEvent.REMOVED || event.type == SimpleEvent.UPDATED || event.type == SimpleEvent.CHANGED )
			{
				_history.text = "";
				
				//We're not loading history in this version
				/*for each( var o:Object in _flm.dataProvider.source )
				{
					composeMessage(o);
				}*/
			}
		}
		
		private function __handleKeyEvent( p_e:KeyboardEvent ): void
		{
			if( p_e.type == KeyboardEvent.KEY_DOWN )
			{
				if( p_e.keyCode == Keyboard.ENTER && !p_e.ctrlKey )
				{
					//trace( "__handleKeyEvent: " + _input.text );
					sendMessage( _input.text.split("\r").join(_DEFAULT_LINE_BREAK_), _input.textfield.getTextFormat() );
					doTimedLater( 100, __clearMessageText );
				}else if( p_e.keyCode == Keyboard.ENTER && p_e.ctrlKey )
				{
					doTimedLater( 100, __newLine );
				}
			}
		}
		
		private function __handleSendPress( event:MouseEvent ): void
		{
			if ( event.type == MouseEvent.CLICK )
			{
				sendMessage( _input.text.split("\r").join(_DEFAULT_LINE_BREAK_), _input.textfield.getTextFormat() );
				doTimedLater( 100, __clearMessageText );
			}
		}
		
		private function __onDividerMoved( event:Event ): void
		{
			arrange();
		}
		
		/**
		 * DISPLAY API
		**/
		
		override protected function measure():void 
		{
			super.measure();
			
			measuredWidth = 200;
			measuredHeight = 150;
		}
		
		override protected function createChildren(): void 
		{
			super.createChildren();
			
			_history = new TextArea();
			_input = new TextArea();
			_send = new Button();
			_div = new Divider();
			
			addChildren( _history, _input, _send, _div );
		}
		
		override protected function childrenCreated():void 
		{
			super.childrenCreated();
			
			_history.editable = false;
			_send.visible = _input.visible = _input.editable = connected;
			_input.text = "";
			_send.label = getLabelAt("chatSend");
			_input.percentWidth = _input.percentHeight = _send.percentHeight = 100;
			_history.minHeight = 30;
			
			_layout = new LayoutManager();
			_layout.minHeight = 30;
			_layout.maxHeight = 150;
			_layout.height = _nInputHeight;
			_layout.setArray( [_input, _send], false );
			
			_div.increaseType = RotateState.REVERSE;
			_div.direction = RotateState.VERTICAL;
			_div.targetDisplay = _layout;
			_div.brotherDisplay = _history;
			
			_div.addEventListener( Divider.DIVIDER_MOVED, __onDividerMoved );
			_input.addEventListener( KeyboardEvent.KEY_DOWN, __handleKeyEvent );
			_send.addEventListener( MouseEvent.CLICK, __handleSendPress );
		}
		
		override protected function arrange():void 
		{
			super.arrange();
			
			//_input.height = _send.height = _nInputHeight;
			//_layout.width = width - (_send.width + (outerPadding*2));//innerPadding + 
			//_input.width = width - (_send.width + innerPadding + (outerPadding*2));
			_div.width = _layout.width = width - (outerPadding * 2);
			_div.height = _layout.gap = innerPadding;
			
			_div.x = paddingLeft;
			SizeUtils.movePosition( _layout, width, height, SizeUtils.LEFT, SizeUtils.BOTTOM, outerPadding );
			SizeUtils.moveByTargetY( _div, _layout,SizeUtils.TOP );
			//SizeUtils.movePosition( _send, width, height, SizeUtils.RIGHT, SizeUtils.BOTTOM, outerPadding );
			
			_history.width = width - (outerPadding*2);
			_history.height = (_input.visible ? (_div.y - (innerPadding+outerPadding)):(height-(outerPadding*2)));
			_history.x = _history.y = outerPadding;
		}
		
		/**
		 * GETTER / SETTER
		 */
		
		public function set username( value:String ): void 
		{
			if ( _sUsername == value ) return;
			_sUsername = value;
			if ( _flm ) _flm.username = value;
		}
		
		public function get username(): String
		{
			return _sUsername;
		}
	}
}