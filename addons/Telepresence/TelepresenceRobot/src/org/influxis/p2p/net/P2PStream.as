/**
 * P2PStream - Copyright © 2011 Influxis All rights reserved.
**/

package org.influxis.p2p.net 
{
	//Flash Classes
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	public class P2PStream extends NetStream
	{
		/**
		 * NOTE: Nothing here yet but expansion is planned :) 
		 */
		
		/**
		 * INIT API
		 */
		
		public function P2PStream( connection:NetConnection, peerID:String = "connectToFMS" ): void
		{
			super( connection, peerID );
		}
	}
}