/**
 * InfluxisComponent - Copyright © 2010 Influxis All rights reserved.
**/

package org.influxis.flotools.core 
{
	//Flash Classes
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.net.NetConnection;
	import flash.net.Responder;
	import flash.events.NetStatusEvent;
	
	//Influxis Classes
	import org.influxis.as3.interfaces.net.IFMS;
	import org.influxis.as3.display.StyleCanvas;
	import org.influxis.as3.display.SimpleComponent;
	import org.influxis.as3.events.SimpleEventConst;
	import org.influxis.as3.net.InfluxisConnection;
	import org.influxis.as3.states.ConnectStates;
	
	public class InfluxisComponent extends StyleCanvas implements IFMS
	{
		public static var DEBUG:Boolean = true;
		private var _sInstance:String;
		
		protected var _bConnected:Boolean;
		protected var _nc:NetConnection;
		protected var connectChildren:Boolean = true;
		protected var syncInstances:Boolean = true;
		protected var reconnecting:Boolean;
		
		/**
		 * PUBLIC API
		 */
		
		public function connect( p_nc:NetConnection ): Boolean
		{
			if ( !p_nc || _nc ) return false;
			if ( !p_nc.connected ) return false;
			
			_nc = p_nc;
			_nc.addEventListener( SimpleEventConst.STATE, onConnectionStateChanged );
			
			_bConnected = true;
			if ( instance ) instanceChange();
			connectAllChildren();
			return true;
		}
		
		public function close(): void
		{
			closeAllChildren();
			if( instance ) instanceClose();
			
			if ( _nc )
			{
				_nc.removeEventListener( SimpleEventConst.STATE, onConnectionStateChanged );
			    _nc = null;
			}
			
			_bConnected = false;
		}
		
		protected function onReconnectMode( reconnecting:Boolean ): void
		{
			if ( this.reconnecting == reconnecting ) return;
			this.reconnecting = reconnecting;
		}
		
		/**
		 * INTERNAL
		 */
		 
		protected function instanceClose(): void
		{
			if ( !_sInstance || !_bConnected ) return;
			
		}
		 
		protected function instanceChange(): void
		{
			if ( !_bConnected || !_sInstance ) return;
			
		}
		
		protected function call( method:String, callbackMethod:Function = null, ...args ): void
		{
			//if ( !connected ) return;
			var aArgs:Array = new Array( method, (callbackMethod!=null?new Responder(callbackMethod):null) );
			_nc.call.apply( _nc, aArgs.concat( (args as Array) == null ? new Array() : (args as Array) ) );
		}
		
		/**
		 * PRIVATE API
		 */
		
		private function __onInstanceChange( value:String ): void
		{
			if ( value == _sInstance ) return;
			//trace("__onInstanceChange: " + instance, value, this );
			if ( _sInstance && _bConnected ) instanceClose();
			
			_sInstance = value;
			__updateChildInstances();
			if( _sInstance && _bConnected ) instanceChange();
		}
		
		/*
		 * HANDLERS
		 */
		
		private function onConnectionStateChanged( event:Event ): void
		{
			var infxConnect:InfluxisConnection = _nc as InfluxisConnection;
			if ( infxConnect )
			{
				if ( infxConnect.state == ConnectStates.CONNECTED )
				{
					if ( infxConnect.reconnected ) onReconnectMode(false);
				}else if ( infxConnect.state == ConnectStates.RECONNECTING )
				{
					onReconnectMode(true);
				}
			}
		}
		 
		/**
		 * DISPLAY API
		 */
		
		protected function connectAllChildren(): void
		{
			if ( !connected || !connectChildren ) return;
			
			var compChild:SimpleComponent;
			var child:IFMS;
			for ( var i:uint = 0; i < numChildren; i++ )
			{
				child = getChildAt(i) as IFMS;
				if ( child ) 
				{
					compChild = getChildAt(i) as SimpleComponent;
					if( !compChild || compChild.initialized ) __connectChild(child);
				}
			}
		}
		
		protected function closeAllChildren(): void
		{
			if ( !connected || !connectChildren ) return;
			for ( var i:uint = 0; i < numChildren; i++ )
			{
				var child:IFMS = getChildAt( i ) as IFMS;
				if( child ) __closeChild(child);
			}
		}
		
		private function __updateChildInstances(): void
		{
			if ( !connected || !syncInstances ) return;
			for ( var i:uint = 0; i < numChildren; i++ )
			{
				var child:IFMS = getChildAt( i ) as IFMS;
				if( child ) child.instance = instance;
			}
		}
		
		private function __connectChild( p_fmsChild:IFMS ): void
		{
			if ( !connected || !connectChildren ) return;
			p_fmsChild.connect(_nc);
			if( syncInstances ) p_fmsChild.instance = instance;
		}
		
		private function __closeChild( p_fmsChild:IFMS ): void
		{
			if ( !connected || !connectChildren ) return;
			p_fmsChild.close();
			if( syncInstances ) p_fmsChild.instance = null;
		} 
		
		private function __handleChildAdd( p_e:Event ): void
		{
			var child:* = p_e.currentTarget;
			child.removeEventListener( p_e.type, __handleChildAdd );
			
			var compChild:SimpleComponent = child as SimpleComponent;
			if ( compChild && !compChild.initialized && p_e.type != SimpleEventConst.INITIALIZED )
			{
				child.addEventListener( SimpleEventConst.INITIALIZED, __handleChildAdd );
				return;
			}
			if ( child is IFMS ) __connectChild( child );
		}
		
		private function __handleChildRemove( p_e:Event ): void
		{
			var child:* = p_e.currentTarget;
			child.removeEventListener( Event.REMOVED_FROM_STAGE, __handleChildRemove );
			if ( child is IFMS ) __closeChild( child );
		}
		
		override public function addChild(child:DisplayObject): DisplayObject 
		{
			if ( !child ) return null;
			child.addEventListener( Event.ADDED_TO_STAGE, __handleChildAdd );
			//child.addEventListener( SimpleEventConst.INITIALIZED, __handleChildAdd );
			return super.addChild(child);
		}
		
		override public function addChildAt( child:DisplayObject, index:int ): DisplayObject
		{
			child.addEventListener( Event.ADDED_TO_STAGE, __handleChildAdd );
			return super.addChildAt( child, index );
		}
		
		override public function removeChild( child:DisplayObject ): DisplayObject
		{
			child.addEventListener( Event.REMOVED_FROM_STAGE, __handleChildRemove );
			return super.removeChild(child);
		}
		
		override public function removeChildAt( index:int ): DisplayObject
		{
			getChildAt(index).addEventListener( Event.REMOVED_FROM_STAGE, __handleChildRemove );
			return super.removeChildAt(index);
		}
		
		/**
		 * GETTER / SETTER
		 */
		
		public function set instance( value:String ): void 
		{
			__onInstanceChange(value);
		}
		
		public function get instance(): String 
		{
			return _sInstance;
		}
		
		public function get connected(): Boolean
		{
			return _bConnected;
		}
	}
}