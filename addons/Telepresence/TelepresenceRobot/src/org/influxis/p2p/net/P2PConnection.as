/**
 * P2PConnection - Copyright © 2011 Influxis All rights reserved.
**/

package org.influxis.p2p.net 
{
	//Flash Classes
	import flash.events.NetStatusEvent;
	
	//Influxis Classes
	import org.influxis.as3.core.infx_internal;
	import org.influxis.as3.states.ConnectStates;
	import org.influxis.as3.net.InfluxisConnection;
	import org.influxis.as3.utils.doTimedLater;
	
	public class P2PConnection extends InfluxisConnection
	{
		//Setup namespace
		use namespace infx_internal;
		private var _sNearID:String;
		
		/**
		 * PRIVATE API
		 */
		
		private function __reconnect(): void
		{
			onStateChanged(ConnectStates.INITIALIZED);
			tryRTMPPort();
		}
		 
		/**
		 * HANDLERS
		 */
		
		override protected function onConnect(event:NetStatusEvent):void 
		{
			super.onConnect(event);
			var code:String = event.info.code;
			
			//If the request for P2P is rejected by the user then default back to RTMP
			if ( (code == ConnectStates.INFO_NETSTREAM_REJECTED || code == ConnectStates.INFO_NETGROUP_REJECTED) && connected )
			{
				//If this is an rtmfp connection then force back to initialize and try RTMP
				if ( path.indexOf("rtmfp") != -1 ) 
				{
					close();
					doTimedLater( 100, __reconnect );
				}
			}
		}
		
		/**
		 * GETTER / SETTERS
		 */
		
		//Override to send a custom id used for failover api
		override public function get nearID():String 
		{ 
			return !_sNearID ? super.nearID : _sNearID; 
		}
		
		//Set a new nearID here
		infx_internal function set nearID2( value:String ): void
		{
			if ( !value ) return;
			_sNearID = value;
		}
	}
}