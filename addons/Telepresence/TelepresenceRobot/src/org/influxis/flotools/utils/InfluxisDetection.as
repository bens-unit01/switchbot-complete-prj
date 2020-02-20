package org.influxis.flotools.utils 
{
	//Flash Classes
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.display.DisplayObject;
	
	//Influxis Classes
	import org.influxis.as3.utils.StringUtils;
	
	public class InfluxisDetection 
	{
		//Attached a message to the stage saying the flash version is wrong
		public static function wrongVersionAlert( target:DisplayObject, htmlMessage:String = null, textFormat:TextFormat = null ): void
		{
			//Text Props
			var textAlert:TextField = new TextField();
				textAlert.wordWrap = true;
				textAlert.selectable = true;
				target.stage.addChild(textAlert);
				textAlert.defaultTextFormat = textFormat != null ? textFormat : new TextFormat( "arial", 12, 0x666666, true, null, null, null, null, "center" );
				textAlert.htmlText = htmlMessage != null ? htmlMessage : "This application can only be used with an Influxis account. Please make sure to sign up at the main Influxis <font color='#0000ff'><a href='www.influxis.com' target='_blank'>website</a></font>.";
				textAlert.width = target.stage.stageWidth - 40;
				textAlert.height = StringUtils.measureText( textAlert.text, textAlert.defaultTextFormat, true, textAlert.width ).height;
				textAlert.x = 20;
				textAlert.y = (target.stage.stageHeight / 4) - (textAlert.height / 2);
		}
	}
}