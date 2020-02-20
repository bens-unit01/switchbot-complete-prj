/**
 * MediaItem - Copyright Â© 2010 Influxis All rights reserved.
**/

package org.influxis.as3.data 
{
	//Flash Classes
	import flash.events.EventDispatcher;
	
	//Influxis Classes
	import org.influxis.as3.data.Singleton;
	import org.influxis.as3.events.SimpleEvent;
	import org.influxis.as3.utils.StreamUtils;
	import org.influxis.as3.core.infx_internal;
	
	//Events
	[Event(name="updated",type="org.influxis.as3.events.SimpleEvent")]
	[Event(name="removed",type="org.influxis.as3.events.SimpleEvent")]
	
	public class MediaItem extends EventDispatcher
	{
		public static var symbolName:String = "MediaItem";
		public static var symbolOwner:Object = org.influxis.as3.data.MediaItem;
		private var infxClassName:String = "MediaItem";
		private var _sVersion:String = "1.0.0.0";
		
		private static var __st:Singleton = new Singleton();
		
		public static var DEBUG:Boolean = false;
		use namespace infx_internal;
		
		public static const VIDEO:String = "video";
		public static const MUSIC:String = "music";
		public static const YOUTUBE:String = "youtube";
		public static const IMAGE:String = "image";
		public static const LIVE:String = "live";
		public static const COMMERCIAL:String = "commercial";
		
		public static const PROGRESSIVE:String = "progressive";
		public static const STREAM:String = "stream";
		public static const HTTPSTREAM:String = "httpStream";
		
		private var _mediaData:Object;
		private var _sPlayName:String;
		private var _sTitle:String;
		private var _sFilename:String;
		private var _sType:String;
		private var _sFiletype:String;
		private var _nTime:Number = 0;
		
		/**
		 * SINGLETON API
		**/
		
		public static function getInstance( p_sName:String = "_DEFAULT_" ) : MediaItem
		{
			if ( !p_sName ) return null;
			
			var mdi:MediaItem = __st.getInstance( p_sName ) as MediaItem;
			if ( !mdi )
			{
				mdi = new MediaItem();
				__st.addInstance( p_sName, mdi );
			}
			return mdi;
		}
		
		//Destroys given instance
		public static function destroy( p_sName:String = "_DEFAULT_" ): Boolean
		{
			if( !__st.getInstance(p_sName) ) return false;
			__st.destroy( p_sName );
			return true;
		}
		
		/**
		 * STATIC API
		 */
		
		public static function getInstanceName( mediaData:Object ): String 
		{
			if ( !mediaData ) return null;
			return (mediaData["folder"] + "_" + mediaData["filename"] + "_" + mediaData["type"]);
		}
		 
		/**
		 * INFX API
		 */
		
		infx_internal function update( p_oMediaData:Object ): void
		{
			_mediaData = p_oMediaData;
			parseData();
			dispatchEvent( new SimpleEvent(SimpleEvent.UPDATED) );
		}
		
		infx_internal function remove(): void
		{
			_mediaData = null;
			clearData();
			dispatchEvent( new SimpleEvent(SimpleEvent.REMOVED) );
		}
		
		/**
		 * PROTECTED API
		 */
		
		protected function clearData(): void
		{
			_sPlayName = _sFiletype = _sType = _sFilename = _sTitle = "";
			_nTime = 0;
		}
		 
		protected function parseData(): void
		{
			if ( !_mediaData ) return;
			
			_sTitle = _mediaData["name"];
			_nTime = _mediaData["time"];
			_sFilename = _mediaData["filename"];
			_sType = _mediaData["type"];
			_sFiletype = _mediaData["filetype"];
			_sPlayName = _mediaData["playName"] != undefined ? _mediaData["playName"] : StreamUtils.getPlayName( _mediaData.filename, _mediaData.type, _mediaData.folder, _mediaData.virtualPath );
		}
		
		/**
		 * GETTER / SETTER
		 */
		
		public function get title(): String
		{
			return _sTitle;
		}
		
		public function get length(): Number
		{
			return _nTime;
		}
		
		public function get filename(): String
		{
			return _sFilename;
		}
		
		public function get type(): String
		{
			return _sType;
		}
		
		public function get filetype(): String
		{
			return _sFiletype;
		}
		
		public function get playName(): String
		{
			return _sPlayName;
		}
		
		/** 
		 * DEBUGGER 
		**/
		
		private function tracer( p_msg:* ) : void
		{
			if( DEBUG ) trace("##" + infxClassName + "##  "+p_msg);
		}
	}
}