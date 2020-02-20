/**
 * FlowChatManager - Copyright © 2010 Influxis All rights reserved.
**/

package org.influxis.flotools.data
{
	//Flash Classes
	import flash.net.NetConnection;
	import flash.events.EventDispatcher;
	
	//Influxis Classes
	import org.influxis.as3.data.Singleton;
	import org.influxis.as3.net.ClientSideCallHandler;
	import org.influxis.as3.net.CallModel;
	import org.influxis.as3.data.DataProvider;
	import org.influxis.as3.utils.StringUtils;
	import org.influxis.as3.events.SimpleEvent;
	
	//Flotools Classes
	import org.influxis.flotools.states.MessageType;
	
	public class FlowChatManager extends EventDispatcher
	{
		private var infxClassName:String = "FlowChatManager";
		
		public static var DEBUG:Boolean = false;
		private static var __st:Singleton = new Singleton();
		
		public static const DEFAULT_INSTANCE:String = "_DEFAULT_";
		
		public static var DEFAULT_IMAGE_MESSAGE_LABEL:String = "*** Images are not saved in history ***";
		public static var DEFAULT_IMAGE_MESSAGE_COLOR:uint = 0x666666;
		public static var DEFAULT_IMAGE_MESSAGE_SIZE:uint = 10;
		public static var CHAT_MANAGER_UNKNOWN_USER:String = "Unknown";	
		
		public static const PROPERTY_CHANGE:String = "propertiesChange";
		public static const TIME_STAMP:String = "timeStamp";
		
		//Class Variables
		//private var _fcFloodCheck:FloodCheck;
		private var _sName:String;
		private var _cloChat:CallModel;
		private var _nc:NetConnection;
		private var _sUsername:String;
		private var _clsh:ClientSideCallHandler;
		private var _aChatHistory:DataProvider = new DataProvider();
		private var _oChatProps:Object;
		//private var _bFloodCheck:Boolean = true;
		private var _nChatOffset:Number;
		private var _nChatTimeStamp:Number;
		
		/**
		* INIT METHODS
		**/
		
		public function FlowChatManager( p_sName:String )
		{
			init( p_sName );
		}
		
		private function init( p_sName:String ): void
		{
			
			/*
			_fcFloodCheck = new FloodCheck();
			_fcFloodCheck.addEventListener( FloodCheck.FLOODED_EVENT, __handleFloodEvent );
			_fcFloodCheck.addEventListener( FloodCheck.CLEAR_EVENT, __handleFloodEvent );
			*/
			
			_sName = ( p_sName == null ? "_DEFAULT_" : p_sName );			
		};
		
		/**
		 * SINGLETON API
		**/
		
		public static function getInstance( p_sName:String = "_DEFAULT_" ) : FlowChatManager
		{
			if ( !p_sName ) return null;
			
			var flow:FlowChatManager = __st.getInstance( p_sName ) as FlowChatManager;
			if ( !flow )
			{
				flow = new FlowChatManager( p_sName );
				__st.addInstance( p_sName, flow );
			}
			return flow;
		}
		
		//Destroys given instance
		public static function destroy( p_sName:String = "_DEFAULT_" ): Boolean
		{
			if( !__st.getInstance(p_sName) ) return false;
			
			(__st.getInstance( p_sName ) as FlowChatManager).close();
			__st.destroy( p_sName );
			return true;
		}
		
		/**
		 * CONNECT API
		**/
		
		public function connect( p_nc:NetConnection ): void
		{
			if( !p_nc.connected || _nc != null ) return;
			
			_nc = p_nc;
			
			//Initiate server handlers
			_cloChat = CallModel.getInstance( infxClassName + "." + _sName, _nc );
			_cloChat.addRemoteMethod( "__serverHandler", __handleServerEvent );
			_cloChat.call( "connect", null, {localTime:new Date()} );
			
			//If name is not null then set at server
			if( _sUsername != null ) _cloChat.call( "changeName", null, _sUsername);
		}
		
		public function close(): void
		{
			_cloChat.call( "close", null );
			CallModel.destroy( infxClassName + "." + _sName );
			_cloChat = null;
			
			_aChatHistory = null;
			_aChatHistory = new DataProvider();
			
			_sUsername = null;
			_nc = null;
		}
		
		/**
		 * PUBLIC API
		**/
		
		public function clearHistory(): void
		{
			_cloChat.call( "clearHistory", null );
		}
		
		public function sendMessage( message:*, p_sMsgType:String = "textMessage", p_oAddParams:Object = null ): void
		{
			if( message == undefined ) return;
			
			//Check if flooded
			/*if( _bFloodCheck ) 
			{
				if( __checkFlood() ) return;
			}*/
			
			var sName:String = ( _sUsername == null ? CHAT_MANAGER_UNKNOWN_USER : _sUsername );
			var msg:* = message;
			
			if( p_sMsgType == MessageType.TEXT )
			{
				var sNewMesg:String = message as String;
				if( sNewMesg.length == 0 ) return;
				
				//In the future we're going to add filters for here but for now its just this
				msg = StringUtils.stripHTML( sNewMesg );
			}/*else if( p_sMsgType == MessageType.IMAGE )
			{
				var btm:BitmapData = message as BitmapData;
				var oImage:Object = new Object();
					oImage["image"] = BitmapUtils.bitmapToString( btm );
					oImage["imageWidth"] = btm.width;
					oImage["imageHeight"] = btm.height;
				
				msg = oImage;
			}*/
			_cloChat.call( "sendMessage", null, sName, msg, p_sMsgType, p_oAddParams );
		}
		
		public function sendRawMessage( p_oMsg:Object ): void
		{
			if( !p_oMsg ) return;
			
			//Check if flooded
			/*if( _bFloodCheck ) 
			{
				if( __checkFlood() ) return;
			}*/
			
			_cloChat.call( "sendRawMessage", null, p_oMsg );
		};
		
		public function updateChatProperties( p_oChatProps:Object ): void
		{
			if( !p_oChatProps ) return;
			_cloChat.call( "updateChatProperties", null, p_oChatProps );
		}
		
		public function setUsername( p_sUsername:String ): void
		{
			if( p_sUsername == "" || p_sUsername == null ) return;
			_sUsername = p_sUsername;
		}
		
		/**
		 * PRIVATE API
		**/
		
		/*private function __checkFlood(): Boolean
		{
			var bFlooded:Boolean = _fcFloodCheck.flooded;
			if( !bFlooded ) 
			{
				_fcFloodCheck.check();
			}else{
				dispatchEvent( new SimpleEvent( FloodCheck.FLOODED_EVENT, "FloodCheck.Flooded" ) );
			}
			return bFlooded;
		}*/
		
		private function __formatImageMessage( p_oMsg:Object ): Object
		{
			if( !p_oMsg ) return null;
			if( p_oMsg.data == undefined ) return null;
			
			//var oMsg:Object = p_oMsg;
			//trace( "__formatImageMessage: " + oMsg.data );
			if( p_oMsg.data == undefined )
			{
				p_oMsg[ "type" ] = MessageType.TEXT;
				p_oMsg[ "data" ] = DEFAULT_IMAGE_MESSAGE_LABEL;
				p_oMsg[ "format" ] = {size:DEFAULT_IMAGE_MESSAGE_SIZE, color:DEFAULT_IMAGE_MESSAGE_COLOR, italic:true};
			}
			return p_oMsg;
		}
		
		private function __formatChathistory( p_aChatHistory:Array ): Array
		{
			if( !p_aChatHistory ) return null;
			
			var aChatHistory:Array = new Array();
			var oFormatted:Object;
			for each( var o:Object in p_aChatHistory )
			{
				oFormatted = __formatImageMessage(o);
				if( oFormatted ) aChatHistory.push( oFormatted );
			}
			return aChatHistory;
		}
		
		/**
		 * HANDLERS
		**/
		
		/*private function __handleFloodEvent( p_e:SimpleEvent ): void
		{
			if( !p_e ) return;	
			dispatchEvent( p_e );
		}*/
		
		private var _bInitDataReceived:Boolean;
		private function __handleServerEvent( p_oEvent:Object ): void
		{
			if( !p_oEvent ) return;
			
			var se:SimpleEvent;
			var oFormatItem:Object;
			//trace( "__handleServerEvent: " + p_oEvent.type );
			if( p_oEvent.type == "added" )
			{
				oFormatItem = p_oEvent.data.type == MessageType.IMAGE ? __formatImageMessage(p_oEvent.data) : p_oEvent.data;
				if( oFormatItem )
				{
					_aChatHistory.addItem( oFormatItem );
					se = new SimpleEvent( SimpleEvent.ADDED, null, oFormatItem );
				}
			}else if( p_oEvent.type == "removed" )
			{
				_aChatHistory.removeItemAt( p_oEvent.index );
				se = new SimpleEvent( SimpleEvent.REMOVED, null, {index:p_oEvent.index} );
			}else if( p_oEvent.type == "updated" )
			{
				oFormatItem = p_oEvent.data.type == MessageType.IMAGE ? __formatImageMessage(p_oEvent.data) : p_oEvent.data
				if(oFormatItem)
				{
					_aChatHistory.addItemAt( p_oEvent.index, oFormatItem );
					se = new SimpleEvent( SimpleEvent.UPDATED, null, {index:p_oEvent.index, data:oFormatItem} );
				}
			}else if( p_oEvent.type == "change" )
			{
				_aChatHistory.setArray( __formatChathistory(p_oEvent.data as Array), false );
				se = new SimpleEvent( SimpleEvent.CHANGED, null, _aChatHistory );
				_bInitDataReceived = true;
			}else if( p_oEvent.type == "relay" && _bInitDataReceived )
			{
				if( p_oEvent.data != undefined ) se = new SimpleEvent( MessageType.RELAY, null, p_oEvent.data );
			}else if( p_oEvent.type == PROPERTY_CHANGE )
			{
				_oChatProps = p_oEvent.data;
				se = new SimpleEvent( p_oEvent.type, null, _oChatProps );
			}else if( p_oEvent.type == TIME_STAMP )
			{
				_nChatOffset = p_oEvent.timeDifference;
				_nChatTimeStamp = p_oEvent.timeStamp;
				se = new SimpleEvent( p_oEvent.type, null, {timeOffSet:p_oEvent.timeOffSet, timeStamp:p_oEvent.timeStamp} );
			}
			if( se ) dispatchEvent( se );
		}
		
		/*private function __handleBitmapEvent( p_e:SimpleEvent ): void
		{
			//Not sure if needed yet
		}
		
		private function __floodEvent( p_se:SimpleEvent ): void
		{
			dispatchEvent( p_se );
		}*/
		
		/**
		 * GETTER / SETTER
		**/
		
		public function get dataProvider(): DataProvider
		{
			return _aChatHistory;
		}
		
		public function get chatProperties(): Object
		{
			return _oChatProps;
		}
		
		public function get chatOffSet(): Number
		{
			return _nChatOffset;
		}
		
		public function get chatTimeStamp(): Number
		{
			return _nChatTimeStamp;
		}
		
		public function set username( p_sUsername:String ): void
		{
			if( p_sUsername == "" || p_sUsername == null ) return;
			
			_sUsername = p_sUsername;
			
			if( !connected ) return;
			_cloChat.call( "changeName", null, _sUsername );
		}
		
		public function get username(): String
		{
			return _sUsername;
		}
		
		/*public function set floodCheck( p_bFloodCheck:Boolean ): void
		{
			_bFloodCheck = p_bFloodCheck;
		}
		
		public function get floodCheck(): Boolean
		{
			return _bFloodCheck;
		}
		
		public function get flooded(): Boolean
		{
			return _fcFloodCheck.flooded;
		}*/
		
		public function get connected(): Boolean
		{
			return (_nc == null ? false : (_nc.connected == true));
		}
	}
}
	
	