/**
 * StringUtils - Copyright © 2010 Influxis All rights reserved.
**/

package org.influxis.as3.utils
{
	//Flash Classes
	import flash.geom.Rectangle;
	import flash.text.*;
	
	public class StringUtils extends Object
	{
		private var infxClassName:String = "StringUtils";
		private var _sVersion:String = "1.5.0.0";
		
		//Reg used to validate emails
		private static const EMAIL_REGEX : RegExp = /^[A-Z0-9._%+-]+@(?:[A-Z0-9-]+\.)+[A-Z]{2,4}$/i;
		private static var _TEXT_:TextField;
		
		//Escape Characters
		private static const _ESCAPE_SYMBOLS_:Array = 
		[
			{symbol:"%", replace:"%25"},
			{symbol:"+", replace:"%2B"},
			{symbol:" ", replace:"+"},
			{symbol:"$", replace:"%24"},
			{symbol:"-", replace:"%2D"},
			{symbol:"_", replace:"%5F"},
			{symbol:".", replace:"%2E"},
			{symbol:"!", replace:"%21"},
			{symbol:"*", replace:"%2A"},
			{symbol:"\"", replace:"%22"},
			{symbol:"\'", replace:"%27"},
			{symbol:"(", replace:"%28"},
			{symbol:")", replace:"%29"},
			{symbol:";", replace:"%3B"},
			{symbol:"/", replace:"%2F"},
			{symbol:"?", replace:"%3F"},
			{symbol:":", replace:"%3A"},
			{symbol:"@", replace:"%40"},
			{symbol:"=", replace:"%3D"},
			{symbol:"&", replace:"%26"},
			{symbol:"|", replace:"%7C"}
		];
		
		/**
		 * PUBLIC API
		 */
		
		//Get a url escape string
		public static function getURLEscaped( p_sUrl:String ): String
		{
			if( p_sUrl == null ) return null;
			
			var sUrl:String = p_sUrl;
			for each( var o:Object in _ESCAPE_SYMBOLS_ )
			{
				sUrl = String( sUrl ).split( o.symbol ).join( o.replace );
			}
			return sUrl;
		}
		
		public static function measureText( text:String, format:TextFormat = null, useWordWrap:Boolean = false, textWidth:Number = NaN ): Rectangle
		{
			__prepText( format, useWordWrap, textWidth );
			_TEXT_.text = !text ? "Dg" : text;
			return new Rectangle(0, 0, _TEXT_.width, _TEXT_.height);
		}
		
		public static function measureHTMLText( text:String, format:TextFormat = null, useWordWrap:Boolean = false, textWidth:Number = NaN ): Rectangle
		{
			__prepText( format, useWordWrap, textWidth );
			_TEXT_.htmlText = !text ? "Dg" : text;
			return new Rectangle(0, 0, _TEXT_.width, _TEXT_.height);
		}
		
		//Strips Html code from the string
		public static function stripHTML( p_str:String ): String
		{
			var t:TextField = new TextField();
				t.htmlText = p_str;
				
			var sNewMsg:String = t.text;
			return sNewMsg;
		};
		
		public static function formatToHtml( p_s:String, p_fmt:TextFormat ) : String
		{
			var s:String = p_s == null ? "" : p_s;
			var fmt:TextFormat = p_fmt == null ? new TextFormat() : p_fmt;
			
			var boldOpen:String = fmt.bold ? "<b>" : "";
				var boldClose:String = boldOpen == "<b>" ? "</b>" : "";
			var italicOpen:String = fmt.italic ? "<i>" : "";
				var italicClose:String = italicOpen == "<i>" ? "</i>" : "";
			var underOpen:String = fmt.underline ? "<u>" : "";
				var underClose:String = underOpen == "<u>" ? "</u>" : "";
			var fontColor:String = Number( fmt.color ).toString( 16 );
			
			var shtml:String = "<FONT FACE='"+fmt.font+"' SIZE='"+fmt.size+"' COLOR='#"+fontColor+"' LETTERSPACING='"+fmt.letterSpacing+"' KERNING='"+fmt.kerning+"'>"+boldOpen + italicOpen + underOpen 
			+ s +
			underClose + italicClose + boldClose+"</FONT>";
			return shtml;
		};
		
		public static function hiliteURLs( p_sMsg:String ): String
		{
			//+
			//escape all <
			//-
			var sEscaped:String= "";
			var sMsg:String = p_sMsg;
			var nLtPos:Number = p_sMsg.indexOf("<");
			while (nLtPos != -1)
			{
				sEscaped = sMsg.substring(0, nLtPos) + "&lt;" + sMsg.substring(nLtPos + 1, sMsg.length);
				//trace ("escaped: "+escaped);
				sMsg = sEscaped;
				nLtPos = sMsg.indexOf("<");
			}
			
			//+
			//escape all >
			//-
			sEscaped = "";
			nLtPos = sMsg.indexOf(">");
			while (nLtPos != -1)
			{
				sEscaped = sMsg.substring(0, nLtPos) + "&gt;" + sMsg.substring(nLtPos + 1, sMsg.length);
				//trace ("escaped: "+escaped);
				sMsg = sEscaped;
				nLtPos = sMsg.indexOf(">");
			}
			
			//+
			//highlight urls
			//-
			var nUrlBegin:Number = sMsg.indexOf("http:");
			if (nUrlBegin == -1) {
				nUrlBegin = sMsg.indexOf("www.");
			}
			if (nUrlBegin == -1) {
				return sMsg;
			}
			var sHilited:String = sMsg.substring(0, nUrlBegin);
			var nUrlEnd:Number = sMsg.indexOf(" ", nUrlBegin);
			var sUrlstr:String = "";
			if (nUrlEnd == -1) {
				sUrlstr = sMsg.substring(nUrlBegin);
			} else {
				sUrlstr = sMsg.substring(nUrlBegin, nUrlEnd);
			}
			var sUrlref:String = sUrlstr;
			if (sUrlstr.indexOf("www.") == 0) {
				sUrlref = "http://" + sUrlstr;
			}
			var sTrailer:String = "";
			if (nUrlEnd != -1) {
				sTrailer = hiliteURLs(sMsg.substring(nUrlEnd));
			}
			sHilited += "<font color=\"#0000FF\"><u><a href=\"" + sUrlref + "\" target=\"_blank\">" + sUrlstr + "</a></u></font>" + sTrailer;
			return sHilited;
		}
		
		public static function isValidEmail( p_sEmail:String ): Boolean
		{
			if( p_sEmail == null ) return false;
			return Boolean(p_sEmail.match(EMAIL_REGEX));
		}
		
		public static function cutOffText( textField:TextField, message:String, width:Number ): void
		{
			if ( !textField || !message || isNaN(width) ) return;
			var letterWidth:Number = measureText( "a", textField.defaultTextFormat ).width;
				letterWidth = _TEXT_.getLineMetrics(0).width;
				
			textField.text = message.substr( 0, Math.floor(width / letterWidth) - ((width / letterWidth) < 3 ? 0 : 3) ) + "..."; 
		}
		
		/**
		 * PRIVATE API
		 */
		
		private static function __prepText( format:TextFormat = null, useWordWrap:Boolean = false, textWidth:Number = NaN ): void
		{
			if ( !_TEXT_ ) _TEXT_ = new TextField();
			_TEXT_.wordWrap = useWordWrap;
			if ( format ) _TEXT_.defaultTextFormat = format;
			_TEXT_.width = isNaN(textWidth) ? 0 : textWidth;
			_TEXT_.height = 0;
			_TEXT_.autoSize = TextFieldAutoSize.LEFT;
		}
	}
}