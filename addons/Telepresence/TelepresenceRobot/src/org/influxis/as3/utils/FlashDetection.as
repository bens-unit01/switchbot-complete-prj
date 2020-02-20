package org.influxis.as3.utils 
{
	//Flash Classes
	import flash.system.Capabilities;
	import flash.display.DisplayObject;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	import flash.display.Stage;
	import flash.geom.Rectangle;
	
	//Influxis Classes
	import org.influxis.as3.utils.StringUtils;
	
	public class FlashDetection
	{
		public static const FLASH_VERSION:String = Capabilities.version.replace( /^(\w*) /gi, "" ).replace(/,/gi, ".")
		public static const OS:String = Capabilities.version.split(" ")[0];
		public static const CAN_MULTICAST:Boolean = checkRequiredVersion("10.1");
		public static const CAN_STAGE_VIDEO:Boolean = checkRequiredVersion("10.2");
		public static const CAN_ECHO_SUPPRESS:Boolean = checkRequiredVersion("10.3");
		
		public static function get IS_MOBILE(): Boolean
		{
			return OS == "AND";
		}
		
		//Checks FP version to see if the correct one is installed 
		public static function checkRequiredVersion( required:String, targetAlert:DisplayObject = null ): Boolean 
		{
			if ( !required ) return true;
			
			var isCorrect:Boolean = true;
			
			//Get version arrays
			var aCurrentVersion:Array = FLASH_VERSION.split(".");
			var aRequiredVersion:Array = required.split(".");
			
			//Check for version
			for( var i:Number = 0; i < aRequiredVersion.length; i++ )
			{
				if ( i == aCurrentVersion.length || Number(aRequiredVersion[i]) != Number(aCurrentVersion[i]) )
				{
					isCorrect = Number(aRequiredVersion[i]) < Number(aCurrentVersion[i]);
					break;
				}
			}
			
			if ( !isCorrect && targetAlert ) wrongVersionAlert(targetAlert);
			return isCorrect;
		}
		
		//Attached a message to the stage saying the flash version is wrong
		public static function wrongVersionAlert( target:DisplayObject, htmlMessage:String = null, textFormat:TextFormat = null, downloadLink:String = null ): void
		{
			//Text Props
			var textAlert:TextField = new TextField();
				textAlert.wordWrap = true;
				textAlert.selectable = true;
				target.stage.addChild(textAlert);
				textAlert.defaultTextFormat = textFormat != null ? textFormat : new TextFormat( "arial", 12, 0x666666, true, null, null, null, null, "center" );
				textAlert.htmlText = htmlMessage != null ? htmlMessage : "The latest version of Flash Player is required to run this application. " + ( OS == "AND" ? "Please update your version through the Android app store." : "Please <font color='#0000ff'><a href='"+(!downloadLink ? "http://get.adobe.com/flashplayer/" : downloadLink)+"' target='_blank'>download</a></font> it from the Adobe website.");
				textAlert.width = target.stage.stageWidth - 40;
				textAlert.height = StringUtils.measureText( textAlert.text, textAlert.defaultTextFormat, true, textAlert.width ).height;
				textAlert.x = 20;
				textAlert.y = (target.stage.stageHeight / 4) - (textAlert.height / 2);
		}
	}
}