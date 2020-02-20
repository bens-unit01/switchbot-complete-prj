/**
 * ArrayUtils v1.0.2 - Influxis Copyright @2007 - All Rights Reserved
**/

package org.influxis.as3.utils
{
	public class ArrayUtils extends Object
	{
		public static var symbolName:String = "ArrayUtils";
		public static var symbolOwner:Object = org.influxis.as3.utils.ArrayUtils;
		private var infxClassName:String = "ArrayUtils";
		private var _sVersion:String = "1.0.0.0";
		
		public static var DEBUG:Boolean = false;
			
		/**
		 * INIT API
		**/
		
		public function ArrayUtils(){}
		
		/**
		 * VERSION
		**/
		
		public function toString(): String
		{
			return ("[ "+ infxClassName + " " + _sVersion +" ]");
		}
		
		public function get version(): String
		{
			return _sVersion;
		}
		
		/**
		 * PUBLIC API
		**/
		
		public static function shuffle( value:*, isVector:Boolean = false ): *
		{
			var newValue:* = isVector ? new Vector.<Object>() : new Array();
			while (value.length > 0)
			{
				newValue.push(value.splice(Math.round(Math.random() * (value.length - 1)), 1)[0]);
			}
			return newValue;
		}
		
		public static function duplicateArray( p_a:Array ): Array
		{
			if( p_a == null ) return null;
			var ra:Array = new Array();
			
			var nLen:Number = p_a.length;
			for( var i:Number = 0; i < nLen; i++ )
			{
				ra[ i ] = p_a[ i ];
			}
			
			return ra;
		}
		
		public static function duplicateVector( p_a:Object ): Object
		{
			if( p_a == null ) return null;
			var ra:Vector.<Object> = new Vector.<Object>();
			for each( var o:Object in p_a )
			{
				ra.push(o);
			}
			return ra;
		}
		
		public static function toVector( p_a:Array ): Vector.<Object>
		{
			if( p_a == null ) return null;
			var ra:Vector.<Object> = new Vector.<Object>();
			
			var nLen:Number = p_a.length;
			for( var i:Number = 0; i < nLen; i++ )
			{
				ra[i] = p_a[i];
			}
			return ra;
		}
		
		public static function moveElement( p_nElement1:Number, p_nElement2:Number, p_aArray:Array ) : Array
		{
			if( p_nElement1 == p_nElement2 || p_aArray == null || isNaN(p_nElement1) || isNaN(p_nElement2) ) return p_aArray;
			
			var nElement1:Number = p_nElement1;
			var nElement2:Number = p_nElement2;
			
			var aData:Array;
			var bdat:Array
			var cdat:Array;
			var ddat:Array;
			
			if( nElement1 > nElement2 )
			{
				bdat = p_aArray.slice( 0, nElement2 );
				bdat.push( p_aArray[ nElement1 ] );
				
				cdat = p_aArray.slice( nElement2, nElement1 );
				ddat = p_aArray.slice( nElement1 + 1 );
			}else{
				bdat = p_aArray.slice( 0, nElement1 );
				cdat = p_aArray.slice( nElement1 + 1, nElement2 + 1 );
				
				cdat.push( p_aArray[ nElement1 ] );
				ddat = p_aArray.slice( nElement2 + 1 );
			}
			aData = bdat.concat( cdat, ddat );
			return aData;
		}
		
		public static function splitArray( p_nItemsPerElement:Number, p_aDataArray:Array ) : Array
		{
			if( p_aDataArray == null || isNaN(p_nItemsPerElement) ) return null;
			
			var aMainData:Array = new Array();
			var nItemCount:Number = 0;
			
			var aData:Array = p_aDataArray;
			var nLen:Number = aData.length / p_nItemsPerElement;
			for( var i:Number = 0; i < nLen; i++ )
			{
				var nIndex:Number = i + 1;
				var aItemSegment:Array = aData.slice( nItemCount, (nIndex * p_nItemsPerElement) );
				aMainData.push( aItemSegment );
				nItemCount = (nIndex * p_nItemsPerElement);
			}
			
			return aMainData;
		}
		
		/**
		* DEBUGGER
		**/
		
		protected function tracer( p_msg:* ) : void
		{
			if( DEBUG == true ) trace("#" + infxClassName +"#  "+p_msg);
		}
	}
}