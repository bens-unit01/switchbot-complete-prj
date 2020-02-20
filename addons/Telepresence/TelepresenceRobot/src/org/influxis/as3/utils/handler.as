/**
 *  handler v1.0.0 - Copyright © 2010 Influxis All rights reserved.
**/

package org.influxis.as3.utils
{
	public function handler( p_func:Function, ...param ): Function
	{
		var aArgs:Array = param as Array;
		var f:Function = function(): *
		{
			var callee:Object = arguments.callee;
			var func:Function = callee.func;
			return func.apply( null, arguments.concat(arguments.callee.args) );
		};
		f[ "func" ] = p_func;
		f[ "args" ] = aArgs;
		return f;
	}
}