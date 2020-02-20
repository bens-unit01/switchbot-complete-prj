package org.influxis.as3.utils 
{
	//Flash Classes
	import flash.system.Capabilities;
	import flash.display.DisplayObject;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.display.Stage;
	
	//Influxis Classes
	import org.influxis.as3.utils.StringUtils;
	
	//Attached a message to the stage saying the flash version is wrong
	public function flashRequiredVersionAlert( target:DisplayObject, htmlMessage:String = null, textFormat:TextFormat = null, downloadLink:String = null ): void
	{
		//Text Props
		var textAlert:TextField = new TextField();
			textAlert.wordWrap = true;
			textAlert.selectable = true;
			target.stage.addChild(textAlert);
			textAlert.defaultTextFormat = textFormat != null ? textFormat : new TextFormat( "arial", 12, 0x666666, true, null, null, null, null, "center" );
			textAlert.htmlText = htmlMessage != null ? htmlMessage : "The latest version of Flash Player is required to run this application. " + ( Capabilities.version.indexOf("AND") != -1 ? "Please update your version through the Android app store." : "Please <font color='#0000ff'><a href='"+(!downloadLink ? "http://get.adobe.com/flashplayer/" : downloadLink)+"' target='_blank'>download</a></font> it from the Adobe website.");
			textAlert.width = target.stage.stageWidth - 40;
			textAlert.height = StringUtils.measureText( textAlert.text, textAlert.defaultTextFormat, true, textAlert.width ).height;
			textAlert.x = 20;
			textAlert.y = (target.stage.stageHeight / 4) - (textAlert.height / 2);
	}	
}