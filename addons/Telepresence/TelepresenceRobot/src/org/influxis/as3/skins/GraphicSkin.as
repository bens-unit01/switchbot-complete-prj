package org.influxis.as3.skins 
{
	//Import Classes
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.filters.BlurFilter; 
	
	//Influxis Classes
	import org.influxis.as3.display.SimpleSprite;
	import org.influxis.as3.utils.ScreenScaler;
	
	public class GraphicSkin extends SimpleSprite
	{
		private var _skinData:Object;
		private var _originSkin:Object;
		
		/**
		 * INIT API
		 */
		
		public function GraphicSkin( skinData:Object, originSkin:Object = null ) 
		{
			super();
			
			_originSkin = !originSkin ? new Object() : originSkin;
			parseData(skinData, _originSkin);
		}
		
		/**
		 * STATIC API
		 */
		
		public static function drawGraphic( skinData:Object, graphics:Graphics, width:Number = 0, height:Number = 0 ): void
		{
			if ( !skinData || !graphics ) return;
			
			width = isNaN(width) ? 0 : width;
			height = isNaN(height) ? 0 : height;
			
			//Clear old
			graphics.clear();
			if ( width <= 0 || height <= 0 ) return;
			
			var bLeft:Boolean, bRight:Boolean, bTop:Boolean, bBottom:Boolean;
			if( skinData.borderSides != "" )
			{
				bTop = skinData.borderSides.indexOf("top") != -1;
				bRight = skinData.borderSides.indexOf("right") != -1;
				bBottom = skinData.borderSides.indexOf("bottom") != -1;
				bLeft = skinData.borderSides.indexOf("left") != -1;
			}
			
			var matrix:Matrix = new Matrix();
				matrix.createGradientBox((width*(skinData.gradiantWidth/100)), (height*(skinData.gradiantHeight/100)), skinData.angle * Math.PI / 180);
			
			//Setup graphics
			graphics.lineStyle( skinData.borderThickness, 0, 0, true );
			graphics.moveTo( skinData.cornerRadius[0], 0 );
			graphics.lineGradientStyle( skinData.gradientType, skinData.borderColor, skinData.borderAlpha, skinData.borderRatios, matrix, "pad", "rgb", skinData.focalPointRatio);
			graphics.beginGradientFill(skinData.gradientType, skinData.backgroundColor, skinData.backgroundAlpha, skinData.backgroundRatios, matrix, "pad", "rgb", skinData.focalPointRatio);
			
			//First line
			if( !bTop ) graphics.lineGradientStyle(skinData.gradientType, skinData.backgroundColor, skinData.backgroundAlpha, skinData.backgroundRatios, matrix, "pad", "rgb", skinData.focalPointRatio);
			graphics.lineTo((width - skinData.cornerRadius[1]), 0);
			if ( skinData.cornerRadius[1] > 0 ) graphics.curveTo( width, 0, width, skinData.cornerRadius[1] );
			if( !bTop ) graphics.lineGradientStyle( skinData.gradientType, skinData.borderColor, skinData.borderAlpha, skinData.borderRatios, matrix, "pad", "rgb", skinData.focalPointRatio);
			
			//Second line
			if( !bRight ) graphics.lineGradientStyle(skinData.gradientType, skinData.backgroundColor, skinData.backgroundAlpha, skinData.backgroundRatios, matrix, "pad", "rgb", skinData.focalPointRatio);
			graphics.lineTo(width, height - skinData.cornerRadius[2]);
			if ( skinData.cornerRadius[2] > 0 ) graphics.curveTo( width, height, (width - skinData.cornerRadius[2]), height );
			if( !bRight ) graphics.lineGradientStyle( skinData.gradientType, skinData.borderColor, skinData.borderAlpha, skinData.borderRatios, matrix, "pad", "rgb", skinData.focalPointRatio);
			
			//Third line
			if( !bBottom ) graphics.lineGradientStyle(skinData.gradientType, skinData.backgroundColor, skinData.backgroundAlpha, skinData.backgroundRatios, matrix, "pad", "rgb", skinData.focalPointRatio);
			graphics.lineTo(skinData.cornerRadius[3], height);
			if ( skinData.cornerRadius[3] > 0 ) graphics.curveTo( 0, height, 0, (height - skinData.cornerRadius[3]) );
			if( !bBottom ) graphics.lineGradientStyle( skinData.gradientType, skinData.borderColor, skinData.borderAlpha, skinData.borderRatios, matrix, "pad", "rgb", skinData.focalPointRatio);
			
			//Last line
			if( !bLeft ) graphics.lineGradientStyle(skinData.gradientType, skinData.backgroundColor, skinData.backgroundAlpha, skinData.backgroundRatios, matrix, "pad", "rgb", skinData.focalPointRatio);
			graphics.lineTo(0, skinData.cornerRadius[0]);
			if ( skinData.cornerRadius[0] > 0 ) graphics.curveTo( 0, 0, skinData.cornerRadius[0], 0 );	
			if ( !bLeft ) graphics.lineGradientStyle( skinData.gradientType, skinData.borderColor, skinData.borderAlpha, skinData.borderRatios, matrix, "pad", "rgb", skinData.focalPointRatio);
			
			graphics.endFill();
		}
		 
		/**
		 * PUBLIC API
		 */
		
		public function clear(): void
		{
			_skinData = null;
			graphics.clear();
		}
		
		public function redraw(): void
		{
			drawGraphic( _skinData, graphics, width, height );
		}
		
		/**
		 * PROTECTED API
		 */
		
		protected function parseData( skinData:Object, originSkin:Object, draw:Boolean = true ): void
		{
			if ( !skinData ) return;
			
			var o:Object = new Object();
				o.borderSides = skinData.borderSides == undefined ? originSkin.borderSides == undefined ? "left right bottom top" : originSkin.borderSides : skinData.borderSides;
				o.gradiantWidth = skinData.gradiantWidth == undefined ? originSkin.gradiantWidth == undefined ? 100 : originSkin.gradiantWidth : skinData.gradiantWidth;
				o.gradiantHeight = skinData.gradiantHeight == undefined ? originSkin.gradiantHeight == undefined ? 100 : originSkin.gradiantHeight : skinData.gradiantHeight;
				o.gradientType = skinData.gradientType == undefined ? originSkin.gradientType == undefined ? "linear" : originSkin.gradientType : skinData.gradientType;
				o.focalPointRatio = skinData.focalPointRatio == undefined ? originSkin.focalPointRatio == undefined ? 100 : originSkin.focalPointRatio : skinData.focalPointRatio;
				o.angle = skinData.angle == undefined ? originSkin.angle == undefined ? 90 : originSkin.angle : skinData.angle;
				o.borderThickness = ScreenScaler.calculateSize(skinData.borderThickness == undefined ? originSkin.borderThickness == undefined ? 1 : originSkin.borderThickness : skinData.borderThickness);
				
				
			//Default measures in case size is not given
			if( !isNaN(skinData.measuredWidth) ) measuredWidth = ScreenScaler.calculateSize(Number(skinData.measuredWidth));
			if( !isNaN(skinData.measuredHeight) ) measuredHeight = ScreenScaler.calculateSize(Number(skinData.measuredHeight));
			
			o.cornerRadius = skinData.cornerRadius == undefined ? originSkin.cornerRadius == undefined ? [0, 0, 0, 0] : originSkin.cornerRadius : skinData.cornerRadius;
			o.cornerRadius = o.cornerRadius is Array ? o.cornerRadius : [o.cornerRadius];
			if ( o.cornerRadius.length < 4 )
			{
				if ( o.cornerRadius[0] == undefined ) o.cornerRadius[0] = 1;
				for ( var r:int = o.cornerRadius.length; r < 4; r++ )
				{
					o.cornerRadius.push( o.cornerRadius[0] );
				}
			}
			
			//Border Color
			o.borderColor = skinData.borderColor == undefined ? originSkin.borderColor == undefined ? [0xffffff] : originSkin.borderColor : skinData.borderColor;
			o.borderColor = o.borderColor is Array ? o.borderColor : [o.borderColor];
			o.borderColor = o.borderColor.length == 1 ? [o.borderColor[0],o.borderColor[0]] : o.borderColor;
			
			//Border Alpha
			o.borderAlpha = skinData.borderAlpha == undefined ? originSkin.borderAlpha == undefined ? [1] : originSkin.borderAlpha : skinData.borderAlpha;
			o.borderAlpha = o.borderAlpha is Array ? o.borderAlpha : [o.borderAlpha];
			
			//Border Ratio
			o.borderRatios = skinData.borderRatios == undefined ? originSkin.borderRatios == undefined ? [] : originSkin.borderRatios : skinData.borderRatios;
			
			var bIncludeRatio:Boolean = o.borderColor.length != o.borderRatios.length;
			var bIncludeAlphas:Boolean = o.borderColor.length != o.borderAlpha.length;
			
			if ( bIncludeRatio || bIncludeAlphas )
			{
				var nRatioCounter:uint = Math.floor(255/(o.borderColor.length-1));
				for ( var b:int = 0; b < o.borderColor.length; b++ )
				{
					if ( o.borderRatios[b] == undefined )
					{
						o.borderRatios[b] = (b * nRatioCounter);
						o.borderRatios[b] = o.borderRatios[b] > 255 ? 255 : o.borderRatios[b];
					}
					if ( o.borderAlpha[b] == undefined ) o.borderAlpha[b] = o.borderAlpha[0];
				}
			}
			
			//Border Color
			o.backgroundColor = skinData.backgroundColor == undefined ? originSkin.backgroundColor == undefined ? [0xffffff] : originSkin.backgroundColor : skinData.backgroundColor;
			o.backgroundColor = o.backgroundColor is Array ? o.backgroundColor : [o.backgroundColor];
			o.backgroundColor = o.backgroundColor.length == 1 ? [o.backgroundColor[0],o.backgroundColor[0]] : o.backgroundColor;
			
			//Border Alpha
			o.backgroundAlpha = skinData.backgroundAlpha == undefined ? originSkin.backgroundAlpha == undefined ? [(skinData.backgroundColor == undefined && originSkin.backgroundColor == undefined ? 0 : 1)] : originSkin.backgroundAlpha : skinData.backgroundAlpha;
			o.backgroundAlpha = o.backgroundAlpha is Array ? o.backgroundAlpha : [o.backgroundAlpha];
			
			//Border Ratio
			o.backgroundRatios = skinData.backgroundRatios == undefined ? originSkin.backgroundRatios == undefined ? [] : originSkin.backgroundRatios : skinData.backgroundRatios;
			
			bIncludeRatio = o.backgroundColor.length != o.backgroundRatios.length;
			bIncludeAlphas = o.backgroundColor.length != o.backgroundAlpha.length;
			
			if ( bIncludeRatio || bIncludeAlphas )
			{
				var nRatioCounter2:uint = Math.floor(255/(o.backgroundColor.length-1));
				for ( var g:int = 0; g < o.backgroundColor.length; g++ )
				{
					if ( o.backgroundRatios[g] == undefined ) 
					{
						o.backgroundRatios[g] = (g * nRatioCounter2);
						o.backgroundRatios[g] = o.backgroundRatios[g] > 255 ? 255 : o.backgroundRatios[g];
					}
					if ( o.backgroundAlpha[g] == undefined ) o.backgroundAlpha[g] = o.backgroundAlpha[0];
				}
			}
			
			var aFilters:Array = new Array();
			if ( skinData.dropShadowEnabled == true || originSkin.dropShadowEnabled == true )
			{
				var shadow:DropShadowFilter = new DropShadowFilter();
				shadow.alpha = skinData.shadowAlpha == undefined ? originSkin.shadowAlpha == undefined ? 1 : originSkin.shadowAlpha : skinData.shadowAlpha;
				shadow.angle = skinData.shadowAngle == undefined ? originSkin.shadowAngle == undefined ? 45 : originSkin.shadowAngle : skinData.shadowAngle;
				shadow.blurX = skinData.shadowBlurX == undefined ? originSkin.shadowBlurX == undefined ? 4 : originSkin.shadowBlurX : skinData.shadowBlurX;
				shadow.blurY = skinData.shadowBlurY == undefined ? originSkin.shadowBlurY == undefined ? 4 : originSkin.shadowBlurY : skinData.shadowBlurY;
				shadow.color = skinData.shadowColor == undefined ? originSkin.shadowColor == undefined ? 0 : originSkin.shadowColor : skinData.shadowColor;
				shadow.distance = skinData.shadowDistance == undefined ? originSkin.shadowDistance == undefined ? 4 : originSkin.shadowDistance : skinData.shadowDistance;
				shadow.hideObject = skinData.shadowHideObject == undefined ? originSkin.shadowHideObject == undefined ? false : originSkin.shadowHideObject : skinData.shadowHideObject;
				shadow.inner = skinData.shadowInner == undefined ? originSkin.shadowInner == undefined ? false : originSkin.shadowInner : skinData.shadowInner;
				shadow.knockout = skinData.shadowKnockout == undefined ? originSkin.shadowKnockout == undefined ? false : originSkin.shadowKnockout : skinData.shadowKnockout;
				shadow.quality = skinData.shadowQuality == undefined ? originSkin.shadowQuality == undefined ? 1 : originSkin.shadowQuality : skinData.shadowQuality;
				shadow.strength = skinData.shadowStrength == undefined ? originSkin.shadowStrength == undefined ? 1 : originSkin.shadowStrength : skinData.shadowStrength;
				aFilters.push( shadow );
			}
			
			//Check for glow
			if ( skinData.glowEnabled == true || originSkin.glowEnabled == true )
			{
				var glow:GlowFilter = new GlowFilter();
				glow.alpha = skinData.glowAlpha == undefined ? originSkin.glowAlpha == undefined ? 1 : originSkin.glowAlpha : skinData.glowAlpha;
				glow.blurX = skinData.glowBlurX == undefined ? originSkin.glowBlurX == undefined ? 6 : originSkin.glowBlurX : skinData.glowBlurX;
				glow.blurY = skinData.glowBlurY == undefined ? originSkin.glowBlurY == undefined ? 6 : originSkin.glowBlurY : skinData.glowBlurY;
				glow.color = skinData.glowColor == undefined ? originSkin.glowColor == undefined ? 0 : originSkin.glowColor : skinData.glowColor;
				glow.inner = skinData.glowInner == undefined ? originSkin.glowInner == undefined ? false : originSkin.glowInner : skinData.glowInner;
				glow.knockout = skinData.glowKnockout == undefined ? originSkin.glowKnockout == undefined ? false : originSkin.glowKnockout : skinData.glowKnockout;
				glow.quality = skinData.glowQuality == undefined ? originSkin.glowQuality == undefined ? 1 : originSkin.glowQuality : skinData.glowQuality;
				glow.strength = skinData.glowStrength == undefined ? originSkin.glowStrength == undefined ? 2 : originSkin.glowStrength : skinData.glowStrength;
				aFilters.push( glow );
			}
			
			//Check for glow
			if ( skinData.blurEnabled == true || originSkin.blurEnabled == true )
			{
				var blur:BlurFilter = new BlurFilter();
				blur.blurX = skinData.blurBlurX == undefined ? originSkin.blurBlurX == undefined ? 6 : originSkin.blurBlurX : skinData.blurBlurX;
				blur.blurY = skinData.blurBlurY == undefined ? originSkin.blurBlurY == undefined ? 6 : originSkin.blurBlurY : skinData.blurBlurY;
				blur.quality = skinData.blurQuality == undefined ? originSkin.blurQuality == undefined ? 1 : originSkin.blurQuality : skinData.blurQuality;
				aFilters.push( blur );
			}
			
			filters = aFilters;
			_skinData = o;
			
			if( draw ) redraw();
		}
		
		/**
		 * DISPLAY API
		 */
		
		override protected function arrange(): void
		{
			super.arrange();
			redraw();
		}
		 
		/**
		 * GETTER / SETTER
		 */
		
		public function set skinData( skinData:Object ): void
		{
			_skinData = skinData;
		}
		
		public function get skinData(): Object
		{
			return _skinData;
		}
	}
}