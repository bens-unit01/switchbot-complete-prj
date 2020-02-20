/**
 *  doLater v1.0.0 - Copyright © 2010 Influxis All rights reserved.
**/

package org.influxis.as3.utils
{
	import flash.utils.setTimeout;
	public function doLater( p_sFunc:Function, ...param ): void
	{
		setTimeout.apply( null, new Array( p_sFunc, 800 ).concat( param as Array ) );
	}
}