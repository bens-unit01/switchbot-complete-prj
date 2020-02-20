/**
 * ObjectUtils v1.0.0.0 - Copyright © 2008 Influxis All rights reserved.
**/

package org.influxis.as3.utils
{
	//Flash Classes
	import flash.utils.ByteArray;
	
	public class ObjectUtils extends Object
	{
		//Copies objects - Left here for backwards compatibility
		public static function duplicateObject( p_oOld:Object ) : Object
		{
			return applyObject(p_oOld);
			/*if ( !p_oOld == null ) return null;
			
			var dupObj:Object = new Object();
			for (var i:String in p_oOld ) 
			{
				dupObj[i] = p_oOld[i];
			}
			return dupObj;*/
		}
		
		public static function applyObject( props:Object, target:Object = null, omit:String = null ): Object
		{
			if ( !props ) return null;
			
			target = !target ? new Object() : target;
			var sOmitFlags:String = omit == null ? "" : omit.split(",").join("|");
			for (var i:String in props ) 
			{
				if( new RegExp(sOmitFlags, "gi").test(i) != true || sOmitFlags == "" ) target[i] = props[i];
			}
			return target;
		}
		
		//This method copies objects at a deep level and is more efficient than duplicateObject
		//
		// Note: If you are cloning a class make sure you register it with the registerAlias method for it to work.
		//       This will not work for bitmapdata objects.
		//
		//	ex - use [RemoteClass] metadata <--- Place this at the top of your class
		//		 use registerClassAlias()
		//	     
		//  ex2 - registerClassAlias( "com.tests.TestClass", TestClass ); <--- Before you clone if you do not have [RemoteClass] metadata tag
		//        var testCopy:TestClass = TestClass( ObjectUtils.cloneObject(test) );
		//
		public static function cloneObject( p_o:Object ): *
		{
			if( p_o == null ) return null;
			
			var baBuffer:ByteArray = new ByteArray();
				baBuffer.writeObject(p_o);
				baBuffer.position = 0;
			
			var o:Object = baBuffer.readObject();
			return o;
		}
	}
}
