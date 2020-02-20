package org.influxis.as3.utils 
{
	//Flash Classes
	import flash.system.Capabilities;
	
	//Checks FP version to see if the correct one is installed 
	public function checkFlashVersion( required:String ): Boolean 
	{
		if ( !required ) return true;
		
		var isCorrect:Boolean = true;
		
		//Get version arrays
		var aCurrentVersion = Capabilities.version.replace( /^(\w*) /gi, "" ).split(",");
		var aRequiredVersion:Array = required.split(".");
		
		//Check for version
		for( var i:Number = 0; i < aRequiredVersion.length; i++ )
		{
			if ( i == aCurrentVersion.length || Number(aRequiredVersion[i]) > Number(aCurrentVersion[i]) )
			{
				isCorrect = false;
				break;
			}
		}
		return isCorrect;
	}
}