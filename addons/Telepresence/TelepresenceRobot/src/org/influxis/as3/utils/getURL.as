/**
 *  getURL - Copyright © 2010 Influxis All rights reserved.
**/

package org.influxis.as3.utils 
{
	//Flash Classes
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	
	public function getURL( url:String, target:String = "_blank" ): void
	{
		navigateToURL(new URLRequest(url), target);
	}
}