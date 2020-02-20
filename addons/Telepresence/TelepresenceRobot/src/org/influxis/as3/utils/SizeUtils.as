/**
 * SizeUtils - Copyright © 2010 Influxis All rights reserved.
**/

package org.influxis.as3.utils
{
	//Flash Classes
	import flash.display.DisplayObject;
	
	//Influxis Classes
	import org.influxis.as3.states.AspectStates;
	import org.influxis.as3.states.PositionStates;
	
	public class SizeUtils
	{
		public static const LEFT:String = PositionStates.LEFT;
		public static const RIGHT:String = PositionStates.RIGHT;
		public static const CENTER:String = PositionStates.CENTER;
		public static const TOP:String = PositionStates.TOP;
		public static const BOTTOM:String = PositionStates.BOTTOM;
		public static const MIDDLE:String = PositionStates.MIDDLE;
		
		/**
		 * STATIC API
		 */
		
		public static function getAspectSizing( p_sAspect:String, p_nWidth:Number, p_nHeight:Number, p_nOriginWidth:Number, p_nOriginHeight:Number ): Object
		{
			if ( !p_sAspect ) return null;
			
			var o:Object = new Object();
			switch( p_sAspect )
			{
				case AspectStates.NONE :
					o.width = p_nOriginWidth;
					o.height = p_nOriginHeight;
					break;
					
				case AspectStates.LETTERBOX : 
					var nNewHeight:Number, nNewWidth:Number;
					if( p_nHeight < p_nWidth || p_nHeight == p_nWidth )
					{
						nNewWidth = ( p_nHeight * (p_nOriginWidth / p_nOriginHeight) );
						nNewHeight = p_nHeight;
						if( nNewWidth > p_nWidth )
						{
							nNewHeight = ( p_nWidth * (p_nOriginHeight / p_nOriginWidth) );
							nNewWidth = p_nWidth;
						}
					}else if( p_nWidth < p_nHeight )
					{
						nNewHeight = ( p_nWidth * (p_nOriginHeight / p_nOriginWidth) );
						nNewWidth = p_nWidth;
					}
					o.width = nNewWidth;
					o.height = nNewHeight;
					break;
					
				case AspectStates.ZOOM : 
					o.width = p_nWidth * .2;
					o.height = p_nHeight * .2;
					break;
					
				case AspectStates.STRETCH : 
					o.width = p_nWidth;
					o.height = p_nHeight;
					break;
			}
			return o;
		}
		
		public static function getPositions( p_nOriginWidth:Number, p_nOriginHeight:Number, p_nTotalWidth:Number, p_nTotalHeight:Number, p_sHPosition:String = "left", p_sVPosition:String = "top", inner:Boolean = false, p_nPadding:Number = 0 ): Object
		{
			var o:Object = new Object();
			switch( p_sHPosition )
			{
				case LEFT :
					o.x = inner ? p_nPadding : -(p_nOriginWidth+p_nPadding);
					break;
					
				case RIGHT :
					o.x = inner ? p_nTotalWidth - (p_nOriginWidth+p_nPadding) : (p_nTotalWidth+p_nPadding);
					break;
					
				case CENTER :
					o.x = ((p_nTotalWidth/2)-(p_nOriginWidth/2));
					break;
			}
			
			switch( p_sVPosition )
			{
				case TOP :
					o.y = inner ? p_nPadding : -(p_nOriginHeight+p_nPadding);
					break;
					
				case BOTTOM :
					o.y = inner ? (p_nTotalHeight - (p_nOriginHeight+p_nPadding)) : (p_nTotalHeight+p_nPadding);
					break;
					
				case MIDDLE :
					o.y = ((p_nTotalHeight/2)-(p_nOriginHeight/2));
					break;
			}
			return o;
		}
		
		//Size Target Based on aspect setting
		public static function sizeTarget( p_source:*, p_sAspect:String, p_nWidth:Number, p_nHeight:Number, p_nOriginWidth:Number, p_nOriginHeight:Number ):void 
		{
			if ( !p_sAspect || p_source == undefined ) return;
			
			var o:Object = getAspectSizing( p_sAspect, p_nWidth, p_nHeight, p_nOriginWidth, p_nOriginHeight );
			try
			{
				p_source.setActualSize( o.width, o.height );
			}catch ( e:Error )
			{
				p_source.width = o.width;
				p_source.height = o.height;
			}
		}
		
		public static function movePosition( p_source:*, p_nTotalWidth:Number, p_nTotalHeight:Number, p_sHPosition:String = "left", p_sVPosition:String = "top", p_nPadding:Number = 0 ): void
		{
			if ( p_source == undefined ) return;
			
			var o:Object = getPositions( p_source.width, p_source.height, p_nTotalWidth, p_nTotalHeight, p_sHPosition, p_sVPosition, true, p_nPadding );
			try
			{
				p_source.move( o.x, o.y );
			}catch ( e:Error )
			{
				p_source.x = o.x;
				p_source.y = o.y;
			}
		}
		
		public static function moveX( p_source:*, p_nTotalWidth:Number, p_sHPosition:String = "left", p_nPadding:Number = 0 ): void
		{
			if ( p_source == undefined ) return;
			p_source.x = getPositions( p_source.width, p_source.height, p_nTotalWidth, NaN, p_sHPosition, null, true, p_nPadding ).x;
		}
		
		public static function moveY( p_source:*, p_nTotalHeight:Number, p_sVPosition:String = "top", p_nPadding:Number = 0 ): void
		{
			if ( p_source == undefined ) return;
			p_source.y = getPositions( p_source.width, p_source.height, NaN, p_nTotalHeight, null, p_sVPosition, true, p_nPadding ).y;
		}
		
		public static function moveByTarget( source:*, targetContainer:*, hposition:String = "left", vposition:String = "top", padding:Number = 0 ): void
		{
			if ( targetContainer == undefined || source == undefined ) return;
			
			var o:Object = getPositions( source.width, source.height, targetContainer.width, targetContainer.height, hposition, vposition, true, padding );
			try
			{
				source.move( targetContainer.x+o.x, targetContainer.y+o.y );
			}catch ( e:Error )
			{
				source.x = targetContainer.x+o.x;
				source.y = targetContainer.y+o.y;
			}
		}
		
		public static function moveByTargetX( source:*, targetContainer:*, position:String = "left", padding:Number = 0 ): void
		{
			if ( targetContainer == undefined || source == undefined ) return;
			source.x = targetContainer.x + getPositions( source.width, NaN, targetContainer.width, NaN, position, null, true, padding ).x;
		}
		
		public static function moveByTargetY( source:*, targetContainer:*, position:String = "top", padding:Number = 0 ): void
		{
			if ( targetContainer == undefined || source == undefined ) return;
			source.y = targetContainer.y + getPositions( NaN, source.height, NaN, targetContainer.height, null, position, true, padding ).y;
		}
		
		public static function hookTarget( source:*, targetContainer:*, position:String = "left", padding:Number = 0, inner:Boolean = false ): void
		{
			if ( targetContainer == undefined || source == undefined ) return;
			
			if ( position == LEFT || position == RIGHT || position == CENTER )
			{
				source.x = targetContainer.x + getPositions( source.width, NaN, targetContainer.width, NaN, position, null, inner, padding ).x;
			}else if ( position == TOP || position == BOTTOM || position == MIDDLE )
			{
				source.y = targetContainer.y + getPositions( NaN, source.height, NaN, targetContainer.height, null, position, inner, padding ).y;
			}
		}
		
		//Maintains aspect ratio of target item based on given measurements
		public static function maintainAspectRatio( p_source:*, p_nWidth:Number, p_nHeight:Number, p_nOriginWidth:Number, p_nOriginHeight:Number ): void
		{
			var o:Object = getAspectSizing( AspectStates.LETTERBOX, p_nWidth, p_nHeight, p_nOriginWidth, p_nOriginHeight );
			try
			{
				p_source.setActualSize( o.width, o.height );
			}catch ( e:Error )
			{
				p_source.width = o.width;
				p_source.height = o.height;
			}
		}
		
		public static function getValue( value:Number, maxValue:Number = NaN, minValue:Number = NaN, minZero:Boolean = false ): Number
		{
			if ( isNaN(value) ) return 0;
			
			var newValue:Number = minZero && value < 0 ? 0 : value;
			if ( !isNaN(minValue) ) newValue = newValue > minValue ? minValue : newValue;
			if ( !isNaN(maxValue) ) newValue = newValue < maxValue ? maxValue : newValue;
			return newValue;
		}
	}
}
