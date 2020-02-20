/**
 * IFMS - Copyright © 2010 Influxis All rights reserved.
**/

package org.influxis.as3.interfaces.net
{
	import flash.net.NetConnection;
	
	public interface IFMS
	{
		//General Methods
		function connect( p_nc:NetConnection ): Boolean;
		function close(): void;
		
		//Getter / Setters
		function get connected(): Boolean;
		function set instance( p_sInstanceName:String ): void;
		function get instance(): String;
	}
}