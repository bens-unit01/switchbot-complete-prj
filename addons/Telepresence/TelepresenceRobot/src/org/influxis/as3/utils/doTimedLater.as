/**
 *  doTimedLater v1.0.1 - Copyright © 2010 Influxis All rights reserved.
**/

package org.influxis.as3.utils
{
	//Flash Classes
	import flash.utils.setTimeout;
	
	public function doTimedLater( p_nTime:Number, p_sFunc:Function, ...param ): void
	{
		setTimeout.apply( null, new Array( p_sFunc, p_nTime ).concat( param as Array ) );
	}
}