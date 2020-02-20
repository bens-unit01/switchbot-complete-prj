/**
 *  Delegate v2.0.0 - Copyright © 2007 Influxis All rights reserved.
 *	Last Updated    - 11/9/2007 3:35pm PST;
 *  Author          - Joe Lopez
 *  Description     - Use this to delegate calls that require parameters
**/

package org.influxis.as3.utils
{
	public function delegate( p_object:Object, p_func:Function, ...param ): Function
	{
		var aArgs:Array = param as Array;
		var f:Function = function(): *
		{
			var callee:Object = arguments.callee;
			var target:Object = callee.target;
			var func:Function = callee.func;
			return func.apply( target, arguments.concat(arguments.callee.args) );
		};
		f[ "target" ] = p_object;
		f[ "func" ] = p_func;
		f[ "args" ] = aArgs;
		return f;
	}
}