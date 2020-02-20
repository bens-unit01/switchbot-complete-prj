package org.influxis.as3.states 
{
	public class ConnectStates
	{
		public static const CONNECTED:String = "connected";
		public static const CLOSED:String = "closed";
		public static const FAILED:String = "failed";
		public static const REJECTED:String = "rejected";
		public static const INITIALIZED:String = "initialized";
		public static const RECONNECTING:String = "reconnecting";
		public static const RECONNECT_FAILED:String = "reconnectFailed";
		
		public static const INFO_CONNECTED:String = "NetConnection.Connect.Success";
		public static const INFO_REJECTED:String = "NetConnection.Connect.Rejected";
		public static const INFO_FAILED:String = "NetConnection.Connect.Failed";
		public static const INFO_CLOSED:String = "NetConnection.Connect.Closed";
		public static const INFO_NETSTREAM_REJECTED:String = "NetStream.Connect.Rejected";
		public static const INFO_NETGROUP_REJECTED:String = "NetGroup.Connect.Rejected";
	}
}