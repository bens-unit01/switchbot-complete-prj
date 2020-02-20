/**
 * Effect - Copyright © 2010 Influxis All rights reserved.
**/

package org.influxis.as3.effects 
{
	//Flash Classes
	import flash.events.EventDispatcher;
	
	//Influxis Classes
	import org.influxis.as3.events.SimpleEvent;
	import org.influxis.as3.effects.tweenerbase.Tween;
	import org.influxis.as3.interfaces.effects.ITweener;
	
	[Event(name = "effectStarted", type = "org.influxis.as3.events.SimpleEvent")]
	[Event(name = "effectUpdated", type = "org.influxis.as3.events.SimpleEvent")]
	[Event(name = "effectCompleted", type = "org.influxis.as3.events.SimpleEvent")]
	public class Effect extends EventDispatcher implements ITweener
	{
		public static const STARTED:String = "effectStarted";
		public static const UPDATED:String = "effectUpdated";
		public static const COMPLETED:String = "effectCompleted";
		
		private var _bCompleted:Boolean = true;
		private var _effects:Object = new Object();
		
		/**
		 * INIT API
		 */
		 
		public function Effect( effect:String = null, duration:uint = 0, startValue:Number = NaN, endValue:Number = NaN ): void
		{
			setEffectItem( effect, duration, startValue, endValue );
		}
		
		/**
		 * PUBLIC API
		 */
		 
		/**
		 * PROTECTED API
		 */
		
		protected function setEffectItem( effect:String, duration:uint, startValue:Number, endValue:Number ): void
		{
			if ( !effect ) return;
			
			var o:Object = new Object();
				o["name"] = effect;
				o["duration"] = duration;
				o["currentTime"] = 0;
				o["start"] = startValue;
				o["end"] = endValue;
				o["value"] = startValue;
				
			_effects[effect] = o;
			if( completed ) Tween.addTweenItem(this);
		}
		 
		protected function effectStarted( effect:String ): void
		{
			dispatchEvent( new SimpleEvent(STARTED, null, {effect:effect}) );
		}
		
		protected function effectUpdated( effect:String ): void
		{
			dispatchEvent( new SimpleEvent(UPDATED, null, {effect:effect, value:_effects[effect].value, currentTime:_effects[effect].currentTime}) );
		}
		
		protected function effectComplete( effect:String ): void
		{
			if ( !effect ) return;
			
			_effects[effect] = null;
			delete _effects[effect];
			
			dispatchEvent( new SimpleEvent(COMPLETED, null, {effect:effect}) );
		}
		
		protected function calculateValue( currentTime:Number, duration:Number, startValue:Number, endValue:Number ): Number
		{
			return ((endValue-startValue) / 2 * (Math.sin(Math.PI * (currentTime / duration - 0.5)) + 1) + startValue);//(currentTime * ((endValue - startValue) / duration));
		}
		
		protected function get effects(): Object
		{
			return _effects;
		}
		
		/**
		 * PRIVATE API
		 */
		
		private function __checkComplete(): void
		{
			var bComplete:Boolean = true;
			for( var i:String in _effects )
			{
				bComplete = false;
				break;
			}
			_bCompleted = bComplete;
		}
		 
		private function __updateFunction(): void
		{
			for each( var o:Object in _effects )
			{
				if ( o.start == o.value ) effectStarted( o.name );
				
				o.currentTime = o.currentTime + Tween.CYCLE_RATE;
				o.value = calculateValue( o.currentTime, o.duration, o.start, o.end );
				//trace( "__updateFunction: " + o.name, o.currentTime, o.duration, o.start, o.end, o.value );
				
				effectUpdated( o.name );
				
				if ( o.end > o.start )
				{
					if( o.value >= o.end ) effectComplete( o.name );
				}else{
					if ( o.value <= o.end ) effectComplete( o.name );
				}
			}
			__checkComplete();
		}
		
		/**
		 * GETTER / SETTER
		 */
		
		public function get completed(): Boolean
		{
			return _bCompleted;
		}
		
		public function get updateFunction(): Function
		{
			return __updateFunction;
		}
	}
}