/**
 * Tween - Copyright © 2010 Influxis All rights reserved.
**/

package org.influxis.as3.effects.tweenerbase 
{
	//Flash Classes
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	//Influxis Classes
	import org.influxis.as3.data.DataProvider;
	import org.influxis.as3.interfaces.effects.ITweener;
	
	public class Tween
	{
		public static const CYCLE_RATE:uint = 10;
		
		private static var _tweens:DataProvider = new DataProvider();
		private static var _timer:Timer;
		
		/**
		 * PUBLIC API
		 */
		
		public static function addTweenItem( tweenItem:ITweener ): void
		{
			if ( !tweenItem ) return;
			
			_tweens.addItem( tweenItem );
			if ( !_timer )
			{
				_timer = new Timer(CYCLE_RATE);
				_timer.addEventListener( TimerEvent.TIMER, __onTimerEvent );
				_timer.start();
			}
		}
		
		/**
		 * PRIVATE API
		 */
		
		private static function __onTimerEvent( event:Event ): void
		{
			//trace( "__onTimerEvent: " + _tweens.length );
			//If called but no tweens then check if timer exists then kill it
			if ( _tweens.length == 0 ) 
			{
				if ( _timer ) __removeTimer();
				return;
			}
			
			var tweener:ITweener;
			var nLen:int = _tweens.length-1;
			for ( var i:int = nLen; i > -1; i-- )
			{
				tweener = _tweens.getItemAt(i) as ITweener;
				if ( tweener )
				{
					tweener.updateFunction();
					if ( tweener.completed ) _tweens.removeItemAt(i);
				}
			}
			//If no tween items longer exist then kill off timer
			if ( _tweens.length == 0 ) __removeTimer();
		}
		
		private static function __removeTimer(): void
		{
			if ( _timer )
			{
				_timer.stop();
				_timer.reset();
				_timer.removeEventListener(TimerEvent.TIMER, __onTimerEvent );
				_timer = null;
			}
		}
	}
}