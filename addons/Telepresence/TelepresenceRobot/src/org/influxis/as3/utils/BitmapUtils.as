/**
 * BitmapUtils - Influxis Copyright @2007 - All Rights Reserved
**/

package org.influxis.as3.utils
{
	//Flash Classes
	import flash.display.DisplayObject;
	import flash.display.IBitmapDrawable;
	import flash.utils.ByteArray
	import flash.geom.Rectangle;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.geom.Matrix;
	
	//Influxis Classes
	import org.influxis.as3.codecs.JPEGEncoder;
	import org.influxis.as3.utils.ByteUtils;
	
	public class BitmapUtils extends Object
	{
		/**
		 * PUBLIC API
		**/
		
		public static function isEmpty( p_bitmClip:BitmapData, checkColor:uint = 0 ) : Boolean
		{
			if( p_bitmClip == null ) return true;
			
			var ba:ByteArray = p_bitmClip.getPixels(p_bitmClip.rect);
			var _reOriColorBoundsRect:Rectangle = p_bitmClip.getColorBoundsRect( 0xffffff, checkColor, true );
			if( _reOriColorBoundsRect.width == p_bitmClip.rect.width || _reOriColorBoundsRect.height == p_bitmClip.rect.height ) return true;
			
			return false;
		}
		
		public static function displayToBitmap( p_mcClip:DisplayObject, p_bTransparent:Boolean = false, p_nFillColor:Number = 0xFFFFFFFF ) : BitmapData
		{
			if( p_mcClip == null ) return null;
			
			//Draw display
			var bitmapData:BitmapData = new BitmapData( p_mcClip.width, p_mcClip.height, p_bTransparent, p_nFillColor );
			
			try
			{
				bitmapData.draw(p_mcClip);
			}catch( e:Error )
			{
				trace(e);
				return null;
			}
			
			return bitmapData;
		}
		
		public static function scaleImageSource( source:IBitmapDrawable, originWidth:Number, originHeight:Number, targetWidth:Number, targetHeight:Number ): BitmapData 
		{
			var mat:Matrix = new Matrix();
				mat.scale(targetWidth/originWidth, targetHeight/originHeight);
				
			var bitmapData:BitmapData = new BitmapData(targetWidth, targetHeight, false);
				bitmapData.draw(source, mat, null, null, null, true);
				
			return bitmapData;
		}
		
		public static function bitmapToString( p_bm:BitmapData, p_sEncoding:String = "bitmap", p_nEncodeQuality:Number = 50 ): String
		{
			if( p_bm == null || p_sEncoding == null ) return null;
			
			//trace( "bitmapToString: " + p_bm.width + " : " + p_bm.height );
			
			var bytes:ByteArray;
			if( p_sEncoding == "jpg" )
			{
				var jpgEncoder:JPEGEncoder = new JPEGEncoder( p_nEncodeQuality );
				bytes = jpgEncoder.encode(p_bm);
			}else{
				bytes = p_bm.getPixels(p_bm.rect);
			}
			
			bytes.compress();
			return ByteUtils.bytesToArray(bytes).join(",");
		}
		
		public static function bytesToBitmap( p_bytes:ByteArray, p_nWidth:Number, p_nHeight:Number, p_bTransparent:Boolean = false, p_nFillColor:Number = 0xFFFFFFFF ): BitmapData
		{
			if( p_bytes == null ) return null;
			var bm:BitmapData = new BitmapData( p_nWidth, p_nHeight, p_bTransparent, p_nFillColor );
				
			try
			{
				bm.setPixels( bm.rect, p_bytes );
			}catch( e:Error )
			{
				//trace( e );
			}
				
			return bm;
		}
		
		public static function stringToBitmap( p_sBitmap:String, p_nWidth:Number, p_nHeight:Number, p_bTransparent:Boolean = false, p_nFillColor:Number = 0xFFFFFFFF  ): BitmapData
		{
			if( p_sBitmap == null || isNaN(p_nWidth) || isNaN(p_nHeight) ) return null;
			
			var bytes:ByteArray = ByteUtils.arrayToBytes( p_sBitmap.split(",") );
				bytes.uncompress();
			
			var bm:BitmapData = new BitmapData( p_nWidth, p_nHeight, p_bTransparent, p_nFillColor );
			try
			{
				bm.setPixels( bm.rect, bytes );
			}catch( e:Error )
			{
				//trace( e );
			}
			return bm;
		}
	}
}