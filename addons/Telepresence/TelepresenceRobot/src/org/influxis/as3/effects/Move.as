/**
 * Move - Copyright © 2010 Influxis All rights reserved.
**/

package org.influxis.as3.effects 
{
	//Flash Classes
	import flash.display.DisplayObject;
	import flash.utils.Dictionary;
	
	//Influxis Classes
	import org.influxis.as3.effects.Effect;
	
	public class Move extends Effect
	{
		private static const ID_PREFIX:String = "move";
		private static var ID:uint = 0;
		
		private var _displayListX:Dictionary = new Dictionary();
		private var _displayListY:Dictionary = new Dictionary();
		private var _displayListZ:Dictionary = new Dictionary();
		
		/**
		 * PUBLIC API
		 */
		
		public function moveDisplay( target:DisplayObject, duration:Number = 1000, xposition:Number = NaN, yposition:Number = NaN, zposition:Number = NaN ): void
		{
			if ( !target ) return;
			
			var sEffectName:String = ID_PREFIX + String(ID);
			if ( !isNaN(xposition) )
			{
				if ( _displayListX[target] ) effectComplete(_displayListX[target]);
				sEffectName = ID_PREFIX + String(ID);
				++ID;
				
				setEffectItem( sEffectName, duration, target.x, xposition );
				effects[sEffectName].display = target;
				effects[sEffectName].isXPos = true;
				_displayListX[target] = sEffectName;
			}
			
			if ( !isNaN(yposition) )
			{
				if ( _displayListY[target] ) effectComplete(_displayListY[target]);
				sEffectName = ID_PREFIX + String(ID);
				++ID;
				
				setEffectItem( sEffectName, duration, target.y, yposition );
				effects[sEffectName].display = target;
				effects[sEffectName].isYPos = true;
				_displayListY[target] = sEffectName;
			}
			
			if ( !isNaN(zposition) )
			{
				if ( _displayListZ[target] ) effectComplete(_displayListZ[target]);
				sEffectName = ID_PREFIX + String(ID);
				++ID;
				
				setEffectItem( sEffectName, duration, target.z, zposition );
				effects[sEffectName].display = target;
				effects[sEffectName].isZPos = true;
				_displayListZ[target] = sEffectName;
			}
		}
		 
		/**
		 * PROTECTED API
		 */
		
		override protected function effectUpdated(effect:String):void 
		{
			if ( !effect ) return;
			
			var target:DisplayObject = effects[effect].display;
			if ( effects[effect].isXPos == true )
			{
				target.x = effects[effect].value;
			}else if ( effects[effect].isYPos == true )
			{
				target.y = effects[effect].value;
			}else if ( effects[effect].isZPos == true )
			{
				target.z = effects[effect].value;
			}
			super.effectUpdated(effect);
		}
		
		override protected function effectComplete(effect:String):void 
		{
			if ( effects[effect].isXPos == true )
			{
				delete _displayListX[effects[effect].display];
			}else if ( effects[effect].isYPos == true )
			{
				delete _displayListY[effects[effect].display];
			}else if ( effects[effect].isZPos == true )
			{
				delete _displayListZ[effects[effect].display];
			}
			super.effectComplete(effect);
		}	
	}

}