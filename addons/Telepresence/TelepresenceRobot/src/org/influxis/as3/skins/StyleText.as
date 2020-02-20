package org.influxis.as3.skins 
{
	//Flash Classes
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	//Influxis Classes
	import org.influxis.as3.skins.SkinElement;
	import org.influxis.as3.events.SimpleEvent;
	import org.influxis.as3.managers.SkinsManager;
	
	public class StyleText extends TextField
	{
		private var _skinStyle:String;
		private var _originClass:String;
		private var _skinElement:SkinElement;
		private var _classSkinElement:SkinElement;
		private var _skinsManager:SkinsManager;
		
		/**
		 * INIT API
		 */
		
		public function StyleText( skinElement:SkinElement, skinStyle:String, originClass:String ): void
		{
			super();
			
			//Manager for fonts
			_skinsManager = SkinsManager.getInstance();
			
			//If custom skin does not exist then we need to create class back fall
			_originClass = originClass;
			_classSkinElement = SkinElement.getInstance( _originClass );
			if ( _classSkinElement ) _classSkinElement.addEventListener( SimpleEvent.CHANGED, __onClassSkinChanged );
			
			changeStyle( skinStyle );
			changeSkinElement( skinElement );
		}
		
		/**
		 * PUBLIC API
		 */
		
		public function changeStyle( skinStyle:String ): void
		{
			_skinStyle = skinStyle;
			
			//Update skins
			if ( _skinElement && _skinStyle )
			{
				if ( _skinElement.getStyle(_skinStyle) != undefined ) updateGraphic();
			}
		}
		 
		public function changeSkinElement( skinElement:SkinElement ): void
		{
			if ( _skinElement )
			{
				_skinElement.removeEventListener( SimpleEvent.CHANGED, __onSkinChanged );
				_skinElement = null;
			}
			
			_skinElement = skinElement;
			if ( !_skinElement ) return;
			
			if ( getTextFormat() != null ) updateGraphic();
			if ( _skinElement.skinName != _originClass ) _skinElement.addEventListener( SimpleEvent.CHANGED, __onSkinChanged );
		}
		
		/**
		 * PROTECTED API
		 */
		
		protected function getSkinTextFormat(): TextFormat
		{
			var format:TextFormat = _skinElement.getTextFormat( _skinStyle );
			if ( _skinElement.skinName != _originClass && !format ) format = _classSkinElement.getTextFormat( _skinStyle );
			return format;
		}
		
		protected function updateGraphic(): void 
		{
			var format:TextFormat = getSkinTextFormat();
			if ( !format ) format = new TextFormat();
			
			defaultTextFormat = !format ? new TextFormat() : format;
			__applyFilters( _skinElement.getStyle( _skinStyle ), _classSkinElement.getStyle( _skinStyle ) );
		}
		
		protected function onStyleChanged( styleName:String = null, styleItem:String = null ):void 
		{
			if ( (styleName && styleName == _skinStyle) || !styleName ) updateGraphic();
		}
		
		private function __applyFilters( skinData:Object, originSkin:Object ): void
		{
			skinData = !skinData || (skinData is String) ? new Object() : skinData;
			originSkin = !originSkin || (originSkin is String) ? new Object() : originSkin;
			
			antiAliasType = skinData.antiAliasType == undefined ? originSkin.antiAliasType == undefined ? "advanced" : originSkin.antiAliasType : skinData.antiAliasType;
			sharpness = skinData.sharpness == undefined ? originSkin.sharpness == undefined ? 0 : originSkin.sharpness : skinData.sharpness;
			thickness = skinData.thickness == undefined ? originSkin.thickness == undefined ? 0 : originSkin.thickness : skinData.thickness;
			selectable = skinData.selectable == undefined ? originSkin.selectable == undefined ? true : originSkin.selectable : skinData.selectable;
			embedFonts = _skinsManager.embeddedFontExists( defaultTextFormat.font );
			
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
		}
		
		/**
		 * HANDLERS
		 */
		 
		private function __onSkinChanged( event:SimpleEvent ):void 
		{
			if ( event.data )
			{
				onStyleChanged( event.data.styleName, event.data.styleItem );
			}else{
				onStyleChanged();
			}
		}
		
		private function __onClassSkinChanged( event:SimpleEvent ):void 
		{
			if ( event.data )
			{
				onStyleChanged( event.data.styleName, event.data.styleItem );
			}else{
				onStyleChanged();
			}
		}
	}
}