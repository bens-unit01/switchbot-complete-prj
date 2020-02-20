/**
 *  SimpleEventConst v1.0 - Copyright © 2010 Influxis All rights reserved.
**/

package org.influxis.as3.events
{
	public class SimpleEventConst
	{
		//States
		public static const INITIALIZED:String = "infxInitialized";
		public static const RESIZE:String = "infxResize";
		public static const RESIZE_WIDTH:String = "infxResizeWidth";
		public static const RESIZE_HEIGHT:String = "infxResizeHeight";
		public static const MOVE:String = "infxMove";
		public static const MOVE_X:String = "infxMoveX";
		public static const MOVE_Y:String = "infxMoveY";
		public static const STATE:String = "state";
		public static const TIME:String = "time";
		public static const DURATION:String = "duration";
		
		//Simple Play Events
		public static const PLAY:String = "play";
		public static const PAUSE:String = "pause";
		public static const MUTE:String = "mute";
		public static const UNMUTE:String = "unmute";
		public static const SEEKING:String = "seeking";
		public static const SEEK:String = "seek";
		public static const FULLSCREEN:String = "fullscreen";
		public static const FULLSCREEN_OFF:String = "fullscreenOff";
		public static const VOLUME:String = "volume";
		public static const REWIND:String = "rewind";
		public static const STOP:String = "stop";
	}
}