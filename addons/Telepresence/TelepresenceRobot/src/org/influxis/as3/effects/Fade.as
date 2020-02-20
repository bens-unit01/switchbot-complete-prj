/**
 * Fade - Copyright © 2010 Influxis All rights reserved.
**/

package org.influxis.as3.effects 
{
	//Flash Classes
	import flash.display.DisplayObject;
	import flash.utils.Dictionary;
	
	//Influxis Class
	import org.influxis.as3.effects.Effect;
	
	public class Fade extends Effect
	{
		private static const ID_PREFIX:String = "fade";
		private static var ID:uint = 0;
		
		private var _displayList:Dictionary = new Dictionary();
		
		/**
		 * PUBLIC API
		 */
		
		public function fadeDisplay( target:DisplayObject, duration:Number, targetFade:Number ): void
		{
			if ( !target ) return;
			
			var sEffectName:String = ID_PREFIX + String(ID);
			ID++;
			
			if ( _displayList[target] ) effectComplete(_displayList[target]);
			
			setEffectItem( sEffectName, duration, target.alpha, targetFade );
			effects[sEffectName].display = target;
			_displayList[target] = sEffectName;
		}
		 
		/**
		 * PROTECTED API
		 */
		
		override protected function effectUpdated(effect:String):void 
		{
			if ( !effect ) return;
			
			var target:DisplayObject = effects[effect].display;
				target.alpha = effects[effect].value;
				
			if ( !target.visible ) target.visible = true;
			super.effectUpdated(effect);
		}
		
		override protected function effectComplete(effect:String):void 
		{
			var target:DisplayObject = effects[effect].display;
			if ( target.alpha <= 0 ) target.visible = false;
			
			delete _displayList[effects[effect].display];
			super.effectComplete(effect);
		}
	}
}