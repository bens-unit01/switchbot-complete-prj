/**
 * P2PGroup - Copyright © 2011 Influxis All rights reserved.
**/

package org.influxis.p2p.net 
{
	//Flash Classes
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;
	import flash.net.NetGroup;
	import flash.net.GroupSpecifier;
	
	//Influxis Classes
	import org.influxis.as3.core.infx_internal;
	import org.influxis.as3.net.ClientSideCallHandler;
	import org.influxis.p2p.net.P2PConnection;
	
	public class P2PGroup extends NetGroup
	{
		//Setup namespace
		use namespace infx_internal;
		
		private static const _CALL_PREFIX_:String = "GroupFailOverManager:static";
		private static const _HAVE_PREFIX_:String = "__haveObject";
		private static const _WANT_PREFIX_:String = "__wantObject";
		private static var _ID_COUNTER_:uint;
		
		private var _callHandler:ClientSideCallHandler = ClientSideCallHandler.getInstance();
		private var _oServerHandler:Object;
		
		protected var netConnection:NetConnection;
		protected var netGroup:NetGroup;
		protected var groupSpec:String;
		
		private var _sServerID:String;
		private var _sLocalID:String;
		private var _sNearID:String;
		private var _sServerAddress:String;
		private var _nRTMPPeerCount:Number = 0;
		private var _peers:Vector.<String>;
		private var _oReplicationInfo:Object = new Object();
		
		/**
		 * INIT API
		 */
		
		public function P2PGroup( connection:NetConnection, groupSpec:String ) 
		{
			//Assign a local id to this group instance
			_sLocalID = "P2PGroup" + _ID_COUNTER_;
			_ID_COUNTER_++;
			
			//Set default Props
			this.netConnection = connection;
			this.groupSpec = groupSpec;
			
			//New list to keep track of peers
			_peers = new Vector.<String>();
			
			//Keeps the compiler from throwing an error
			var i:Number = 20;
			if ( i == 0 ) super( netConnection, groupSpec );
			initialize();
		}
		
		//Register group based on connect type
		protected function initialize(): void
		{
			if ( netConnection.protocol == "rtmfp" )
			{
				createLocalGroup();
			}else{
				_oServerHandler = new Object()
				_oServerHandler.__onServerEvent = __onServerEvent;
				
				_callHandler.addPath( "GroupFailOverManager", _oServerHandler );
				netConnection.call( _CALL_PREFIX_+".connectP2PClient?clientInfo", null, groupSpec, _sLocalID );
			}
		}
		
		//Creates group for netgroup
		protected function createLocalGroup(): void
		{
			if ( !groupSpec || !netConnection ) return;
			if ( netConnection.protocol != "rtmfp" ) return;
			
			if ( netGroup )
			{
				netGroup.removeEventListener( NetStatusEvent.NET_STATUS, __groupStatusEvent );
				netGroup.close();
				netGroup = null;
			}
			
			netGroup = new NetGroup( netConnection, groupSpec );
			netGroup.addEventListener( NetStatusEvent.NET_STATUS, __groupStatusEvent );
		}
		
		/**
		 * PUBLIC API
		 */
		
		override public function addHaveObjects(startIndex:Number, endIndex:Number):void 
		{
			if ( netGroup )
			{
				netGroup.addHaveObjects(startIndex, endIndex);
			}else {
				_oReplicationInfo[_HAVE_PREFIX_] = {start:startIndex, end:endIndex};
				netConnection.call( _CALL_PREFIX_+".runGroupCommand?clientInfo", null, groupSpec, _sLocalID, "addHaveObjects", startIndex, endIndex );
			}
		}
		
		override public function addMemberHint(peerID:String):Boolean 
		{
			var b:Boolean = true;
			if ( netGroup )
			{
				b = netGroup.addMemberHint(peerID);
			}else {
				netConnection.call( _CALL_PREFIX_+".runGroupCommand?clientInfo", null, groupSpec, _sLocalID, "addMemberHint", peerID );
			}
			return b;
		}
		
		override public function addNeighbor(peerID:String):Boolean 
		{
			var b:Boolean = true;
			if ( netGroup )
			{
				b = netGroup.addNeighbor(peerID);
			}else {
				netConnection.call( _CALL_PREFIX_+".runGroupCommand?clientInfo", null, groupSpec, _sLocalID, "addNeighbor", peerID );
			}
			return b;
		}
		
		override public function addWantObjects(startIndex:Number, endIndex:Number):void 
		{
			if ( netGroup )
			{
				netGroup.addWantObjects(startIndex, endIndex);
			}else {
				_oReplicationInfo[_WANT_PREFIX_] = {start:startIndex, end:endIndex};
				netConnection.call( _CALL_PREFIX_+".runGroupCommand?clientInfo", null, groupSpec, _sLocalID, "addWantObjects", startIndex, endIndex );
			}
		}
		
		override public function close(): void 
		{
			if ( netGroup )
			{
				netGroup.removeEventListener( NetStatusEvent.NET_STATUS, __groupStatusEvent );
				netGroup.close();
				netGroup = null;
			}else{
				//Unregister the user from server
				netConnection.call( _CALL_PREFIX_ +".closeP2PClient?clientInfo", null, groupSpec, _sLocalID );
				
				//Destroy replication info
				if( _oReplicationInfo[_HAVE_PREFIX_] != undefined ) delete _oReplicationInfo[_HAVE_PREFIX_];
				if( _oReplicationInfo[_WANT_PREFIX_] != undefined ) delete _oReplicationInfo[_WANT_PREFIX_];
				
				//Clear out objects
				_callHandler.removePathAt( "GroupFailOverManager", _oServerHandler );
				delete _oServerHandler.__onServerEvent;
				_oServerHandler = null;	
			}
			
			netConnection = null;
			groupSpec = null;
		}
		
		override public function denyRequestedObject(requestID:int):void 
		{
			if ( netGroup )
			{
				netGroup.denyRequestedObject(requestID);
			}else {
				netConnection.call( _CALL_PREFIX_+".runGroupCommand?clientInfo", null, groupSpec, _sLocalID, "denyRequestedObject", requestID );
			}
		}
		
		override public function post(message:Object):String 
		{
			//in rtmp mode this does not return anything
			var sId:String = "";
			if ( netGroup )
			{
				sId = netGroup.post(message);
			}else {
				netConnection.call( _CALL_PREFIX_+".runGroupCommand?clientInfo", null, groupSpec, _sLocalID, "post", message );
			}
			return sId;
		}
		
		override public function removeHaveObjects(startIndex:Number, endIndex:Number):void 
		{
			if ( netGroup )
			{
				netGroup.removeHaveObjects(startIndex, endIndex);
			}else {
				if( _oReplicationInfo[_HAVE_PREFIX_] != undefined ) delete _oReplicationInfo[_HAVE_PREFIX_];
				netConnection.call( _CALL_PREFIX_+".runGroupCommand?clientInfo", null, groupSpec, _sLocalID, "removeHaveObjects", startIndex, endIndex );
			}
		}
		
		override public function removeWantObjects(startIndex:Number, endIndex:Number):void 
		{
			if ( netGroup )
			{
				netGroup.removeWantObjects(startIndex, endIndex);
			}else {
				if( _oReplicationInfo[_WANT_PREFIX_] != undefined ) delete _oReplicationInfo[_WANT_PREFIX_];
				netConnection.call( _CALL_PREFIX_+".runGroupCommand?clientInfo", null, groupSpec, _sLocalID, "removeWantObjects", startIndex, endIndex );
			}
		} 
		
		override public function sendToAllNeighbors(message:Object):String 
		{
			//in rtmp mode this does not return anything
			var sId:String = "";
			if ( netGroup )
			{
				sId = netGroup.sendToAllNeighbors(message);
			}else {
				netConnection.call( _CALL_PREFIX_+".runGroupCommand?clientInfo", null, groupSpec, _sLocalID, "sendToAllNeighbors", message );
			}
			return sId;
		}
		
		override public function sendToNearest(message:Object, groupAddress:String):String 
		{
			//in rtmp mode this does not return anything
			var sId:String = "";
			if ( netGroup )
			{
				if ( groupAddress.indexOf("rtmp") != -1 )
				{
					sId = netGroup.sendToNearest( {message:message, targetPeer:groupAddress}, _sServerAddress);
				}else {
					sId = netGroup.sendToNearest( message, groupAddress);
				}
			}else {
				netConnection.call( _CALL_PREFIX_+".runGroupCommand?clientInfo", null, groupSpec, _sLocalID, "sendToNearest", message, groupAddress );
			}
			return sId;
		}
		
		override public function sendToNeighbor(message:Object, sendMode:String):String 
		{
			//in rtmp mode this does not return anything
			var sId:String = "";
			if ( netGroup )
			{
				sId = netGroup.sendToNeighbor(message, sendMode);
			}else {
				netConnection.call( _CALL_PREFIX_+".runGroupCommand?clientInfo", null, groupSpec, _sLocalID, "sendToNeighbor", message, sendMode );
			}
			return sId;
		}
		
		override public function writeRequestedObject(requestID:int, object:Object):void 
		{
			if ( netGroup )
			{
				netGroup.writeRequestedObject(requestID, object);
			}else {
				netConnection.call( _CALL_PREFIX_+".runGroupCommand?clientInfo", null, groupSpec, _sLocalID, "writeRequestedObject", requestID, object );
			}
		}
		
		override public function convertPeerIDToGroupAddress(peerID:String):String 
		{
			//If an rtmp peerid or the client is rtmp then it should be sent back as the id and not a peer address
			return (peerID.indexOf("rtmp") != -1 || !netGroup ? peerID : netGroup.convertPeerIDToGroupAddress(peerID));
		}
		
		/**
		 * HANDLERS
		 */
		
		//Handles calls coming from the server
		private function __onServerEvent( event:Object ): void
		{
			if ( event.type == "ServerP2PEvent" )
			{
				var outEvent:NetStatusEvent = new NetStatusEvent( NetStatusEvent.NET_STATUS, false, false, event.info );
				if ( event.info.code == "NetGroup.Connect.Success" )
				{
					_nRTMPPeerCount = event.info.peerCount;
					_sNearID = event.info.nearId;
					
					var infxConnection:P2PConnection = netConnection as P2PConnection;
					if ( infxConnection ) infxConnection.nearID2 = _sNearID;
					netConnection.dispatchEvent(outEvent);
					return;
					
				}else if ( event.info.code == "NetGroup.Neighbor.Connect" || event.info.code == "NetGroup.Neighbor.Disconnect" )
				{
					//Update user count as rtmfp members sign in and out
					_nRTMPPeerCount = _nRTMPPeerCount + (event.info.code == "NetGroup.Neighbor.Connect" ? 1 : -1 );
				}
				__groupStatusEvent(outEvent);
			}
		}
		
		//Handles calls from the netgroup
		private function __groupStatusEvent( event:NetStatusEvent ): void
		{
			var code:String = event.info.code;
			
			//Check if the server sent a custom event and if so then process
			if ( code == "NetGroup.Posting.Notify" || code == "NetGroup.SendTo.Notify" )
			{
				if ( event.info.message != undefined )
				{
					if ( event.info.message.type == "ServerP2PEvent" )
					{
						if ( event.info.message.info.code == "NetGroup.Neighbor.Connect" || event.info.message.info.code == "NetGroup.Neighbor.Disconnect" )
						{
							//Update user count as rtmp members sign in and out
							_nRTMPPeerCount = _nRTMPPeerCount + (event.info.code == "NetGroup.Neighbor.Connect" ? 1 : -1 );
							
							//Update connected peers
							__updatePeerCount( event.info.message.info.code == "NetGroup.Neighbor.Connect", event.info.message.info.peerID );
						}
						if ( netConnection ) netConnection.dispatchEvent(new NetStatusEvent(NetStatusEvent.NET_STATUS, false, false, event.info.message.info));
						dispatchEvent( new NetStatusEvent(NetStatusEvent.NET_STATUS, false, false, event.info.message.info) );
						return;
					}else if ( event.info.message.type == "ServerP2PInfo" )
					{
						//Server info
						_sServerID = event.info.message.peerID;
						_sServerAddress = event.info.message.address;
						_nRTMPPeerCount = event.info.message.peerCount;
						
						//Remove server from peer list if it was added
						__updatePeerCount( false, _sServerID );
						
						return;
					}
				}
			}else if ( code == "NetGroup.Neighbor.Connect" || code == "NetGroup.Neighbor.Disconnect" )
			{
				//Update connected peers
				__updatePeerCount( code == "NetGroup.Neighbor.Connect", event.info.peerID );
			}
			//if ( netConnection ) netConnection.dispatchEvent(event);
			dispatchEvent( event );
		}
		
		/**
		 * PRIVATE API
		**/
		
		//Updates our peer list
		private function __updatePeerCount( addPeer:Boolean, peerID:String ): void
		{
			if ( addPeer )
			{
				_peers.push(peerID);
			}else{
				var nLen:Number = _peers.length;
				for ( var i:Number = 0; i < nLen; i++ )
				{
					if ( _peers[i] == peerID )
					{
						_peers.splice(i, 1);
						break;
					}
				}
			}
		}
		
		/**
		 * GETTER / SETTER
		 */
		
		//Extended api which lets you know what peers are connected to the group
		public function get availablePeers(): Vector.<String>
		{
			return _peers;
		}
		
		//Extended api which let's you get the nearID
		public function get nearID(): String
		{
			return !netGroup ? _sNearID : netConnection.nearID;
		}
		
		override public function get estimatedMemberCount():Number 
		{
			return (!netGroup ? 0 : netGroup.estimatedMemberCount)+_nRTMPPeerCount;
		}
		
		//Not compatible in rtmp mode
		override public function get localCoverageFrom():String 
		{
			return !netGroup ? null : netGroup.localCoverageFrom; 
		}
		
		//Not compatible in rtmp mode
		override public function get localCoverageTo():String 
		{ 
			return !netGroup ? null : netGroup.localCoverageTo; 
		}
		
		override public function get neighborCount():Number 
		{ 
			return (!netGroup ? 0 : netGroup.neighborCount)+_nRTMPPeerCount; 
		}
		
		/**
		 * Note: Both receiveMode and replicationStrategy are shared so setting the following affects all RTMP users 
		 */
		
		//Receive mode can't be overriden so I created another version which allows this
		public function get receiveMode2():String 
		{ 
			return !netGroup ? null : netGroup.receiveMode; 
		}
		
		public function set receiveMode2(value:String):void 
		{
			if ( !netGroup ) return;
			netGroup.receiveMode = value;
		}
		
		override public function get replicationStrategy():String 
		{ 
			return !netGroup ? null : netGroup.replicationStrategy; 
		}
		
		override public function set replicationStrategy(value:String):void 
		{
			if ( !netGroup ) return;
			netGroup.replicationStrategy = value;
		}
	}
}