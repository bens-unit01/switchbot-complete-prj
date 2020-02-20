package org.influxis.flotools.states 
{
	//Flash Classes
	import flash.display.DisplayObject;
	
	//Influxis Classes
	import org.influxis.as3.states.AspectStates;
	import org.influxis.as3.utils.SizeUtils;
	import org.influxis.as3.display.SimpleSprite;
	
	public class DisplayPositionStates 
	{
		public static const PICTURE_IN_PICTURE:String = "picInPic";
		public static const SIDE_BY_SIDE:String = "sideBySide";
		public static const SIDE_BY_SIDE_ALT:String = "sideBySideAlt";
		public static const ONE_BY_MANY_VERTICAL:String = "oneByManyVert";
		public static const ONE_BY_MANY_HORIZONTAL:String = "oneByManyHor";
		
		private static const _MODE_MAPPER_:Object = 
		{
			picInPic:organizePicInPic,
			sideBySide:organizeSideBySide,
			sideBySideAlt:organizeSideBySide,
			//sideBySideAlt:organizeSideBySideAlt,
			oneByManyVert:organizeOneByManyVert,
			oneByManyHor:organizeOneByManyHor
		}
		
		/*
		 * PUBLIC API
		 */
		
		public static function organizeWindows( positionState:String, videoDisplays:Vector.<DisplayObject>, totalWidth:Number, totalHeight:Number, padding:uint = 0, targetContainer:DisplayObject = null ): void
		{
			if ( !positionState || !videoDisplays || isNaN(totalWidth) || isNaN(totalHeight) || videoDisplays.length == 0 ) return;
			
			var displayFunction:Function = videoDisplays.length == 1 ? organizePicInPic : _MODE_MAPPER_[positionState] as Function;
			if ( displayFunction != null ) displayFunction( videoDisplays, totalWidth, totalHeight, padding, targetContainer );
		}
		
		/*
		 * PRIVATE API
		 */
		
		private static function organizePicInPic( videoDisplays:Vector.<DisplayObject>, totalWidth:Number, totalHeight:Number, padding:uint = 0, targetContainer:DisplayObject = null ): void 
		{
			var measuredDisplay:Object = SizeUtils.getAspectSizing( AspectStates.LETTERBOX, totalWidth * 0.2, totalHeight, 640, 360 );
			videoDisplays[0].width = totalWidth;
			videoDisplays[0].height = totalHeight;
			//trace("organizePicInPic: " + totalWidth, totalHeight );
			videoDisplays[0].x = 0; videoDisplays[0].y = 0;
			
			if ( videoDisplays.length == 1 ) return;
			
			var vertPos:String; var hortPos:String;
			var nLen:Number = videoDisplays.length;
			for ( var i:Number = 1; i < nLen; i++ )
			{
				videoDisplays[i].width = Number(measuredDisplay.width);
				videoDisplays[i].height = Number(measuredDisplay.height);
				
				if ( i == 1 || i == 2 ) 
				{
					hortPos = i == 1 ? SizeUtils.LEFT : SizeUtils.RIGHT;
					vertPos = SizeUtils.BOTTOM; 
				}
				if ( i == 3 || i == 4 ) 
				{
					hortPos = i == 4 ? SizeUtils.LEFT : SizeUtils.RIGHT;
					vertPos = SizeUtils.TOP;
				}
				
				if ( targetContainer )
				{
					SizeUtils.hookTarget( videoDisplays[i], targetContainer, hortPos, padding, true );
					SizeUtils.hookTarget( videoDisplays[i], targetContainer, vertPos, padding, true );
				}else {
					SizeUtils.hookTarget( videoDisplays[i], videoDisplays[0], hortPos, padding, true );
					SizeUtils.hookTarget( videoDisplays[i], videoDisplays[0], vertPos, padding, true );
				}
			}
		}
		
		private static function organizeSideBySide( videoDisplays:Vector.<DisplayObject>, totalWidth:Number, totalHeight:Number, padding:uint = 0, targetContainer:DisplayObject = null ): void 
		{
			var nLen:Number = videoDisplays.length;
			var windowWidth:Number = ((totalWidth - (padding * ((nLen - 1) + 2))) / nLen);// - (padding * (nLen - 1));
			var windowHeight:Number = totalHeight - (padding * 2);
			
			for ( var i:Number = 0; i < nLen; i++ )
			{
				videoDisplays[i].width = windowWidth;
				videoDisplays[i].height = windowHeight;
				if ( i > 0 ) 
				{
					SizeUtils.hookTarget( videoDisplays[i], videoDisplays[i - 1], SizeUtils.RIGHT, padding );
				}else{
					videoDisplays[i].x = padding;
				}
				videoDisplays[i].y = padding;
			}
		}
		
		private static function organizeSideBySideAlt( videoDisplays:Vector.<DisplayObject>, totalWidth:Number, totalHeight:Number, padding:uint = 0, targetContainer:DisplayObject = null ): void 
		{
			//Gotta think about this one hehe
		}
		
		private static function organizeOneByManyVert( videoDisplays:Vector.<DisplayObject>, totalWidth:Number, totalHeight:Number, padding:uint = 0, targetContainer:DisplayObject = null ): void 
		{
			if ( !videoDisplays || videoDisplays.length == 0 ) return;
			
			//First we need to get the original window length and then the count of individual sub windows
			var nLen:Number = videoDisplays.length;
			var windowLen:Number = nLen - 1;
			
			//Get initial measure for main window
			var mainWindowWidth:Number = ((totalWidth / 3) * 2) - (padding * 2);
			var mainWindowHeight:Number = totalHeight - (padding * 2);
			
			//Measure the sub windows
			var measuredDisplay:Object = SizeUtils.getAspectSizing( AspectStates.LETTERBOX, (totalWidth-(mainWindowWidth+padding)), ((mainWindowHeight / windowLen) - (padding * (windowLen - 1))), 640, 360 );
			
			//Size and position main window first
			videoDisplays[0].width = totalWidth - (measuredDisplay.width+(padding*3));
			videoDisplays[0].height = mainWindowHeight;
			videoDisplays[0].x = padding; videoDisplays[0].y = padding;
			
			//Handle the sub windows here
			for ( var i:Number = 1; i < nLen; i++ )
			{
				videoDisplays[i].width = measuredDisplay.width;
				videoDisplays[i].height = measuredDisplay.height;
				SizeUtils.hookTarget( videoDisplays[i], videoDisplays[0], SizeUtils.RIGHT, padding );
				if ( i > 1 ) 
				{
					SizeUtils.hookTarget( videoDisplays[i], videoDisplays[i - 1], SizeUtils.BOTTOM, padding );
				}else{
					videoDisplays[i].y = (totalHeight / 2) - (((measuredDisplay.height * windowLen) + (padding * (windowLen - 1))) / 2);
				}
			}
		}
		
		private static function organizeOneByManyHor( videoDisplays:Vector.<DisplayObject>, totalWidth:Number, totalHeight:Number, padding:uint = 0, targetContainer:DisplayObject = null ): void 
		{
			if ( !videoDisplays || videoDisplays.length == 0 ) return;
			
			//First we need to get the original window length and then the count of individual sub windows
			var nLen:Number = videoDisplays.length;
			var windowLen:Number = nLen - 1;
			
			//Get initial measure for main window
			var mainWindowWidth:Number = totalWidth - (padding * 2);
			var mainWindowHeight:Number = ((totalHeight / 3) * 2) - (padding * 2);
			
			//Measure the sub windows
			var measuredDisplay:Object = SizeUtils.getAspectSizing( AspectStates.LETTERBOX, ((mainWindowWidth / windowLen) - (padding * (windowLen - 1))), (totalHeight-(mainWindowHeight+padding)), 640, 360 );
			
			//Size and position main window first
			videoDisplays[0].width = mainWindowWidth;
			videoDisplays[0].height = totalHeight - (measuredDisplay.height+(padding*3));
			videoDisplays[0].x = padding; videoDisplays[0].y = padding;
			
			//Handle the sub windows here
			for ( var i:Number = 1; i < nLen; i++ )
			{
				videoDisplays[i].width = measuredDisplay.width;
				videoDisplays[i].height = measuredDisplay.height;
				SizeUtils.hookTarget( videoDisplays[i], videoDisplays[0], SizeUtils.BOTTOM, padding );
				if ( i > 1 ) 
				{
					SizeUtils.hookTarget( videoDisplays[i], videoDisplays[i - 1], SizeUtils.RIGHT, padding );
				}else{
					videoDisplays[i].x = (totalWidth / 2) - (((measuredDisplay.width * windowLen) + (padding * (windowLen - 1))) / 2);
				}
			}
		}
	}
}