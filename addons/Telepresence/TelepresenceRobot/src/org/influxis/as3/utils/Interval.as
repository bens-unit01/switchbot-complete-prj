/**
 *  Interval v1.5.0 - Copyright © 2007 Influxis All rights reserved.
 *	Last Updated    - 11/13/2007 12:26pm PST;
 *  Author          - Joe Lopez
 *  Description     - Use this to fire intervals.
**/

/**
 * NOTE: You could use the Timer class in as3.0 but the timing is off on it and you can only control one at a time without making new instances.
 *       Interval class allows you to make multiple intervals and should still allow you to keep the accuracy in only one Interval instance. 
 *
 * 		 CAUTION: This class by default does throw an error warning when used.
**/

package org.influxis.as3.utils
{
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	public class Interval extends Object
	{
		//class name
		public static const CLASS_NAME:String = "Interval";
			
		public static var DEBUG:Boolean = false;
		private static var INT_PREFIX:String = "int";
		
		private var _oINT:Object = new Object();
		private var _nIntCount:Number = 0;
		private var _oParent:Object;
		private var _oINTCount:Object;
		
		public function Interval( p_oParent:Object = null )
		{
			//Grabs the param parent
			_oParent = p_oParent;
		};
		
		//Start the interval
		public function startInterval( p_sMethodName:*, p_nTime:Number, p_nStopCount:Number = 0, ...p_aArgs ): uint
		{
			//if( p_sMethodName == undefined || p_sMethodName == "" || isNaN( p_nTime ) == true ) return;
			var sIntID:String = String( INT_PREFIX + _nIntCount );
			if( _oINT[sIntID] != undefined )
			{
				//Clear the interval and delete the property
				clearInterval( _oINT[sIntID] );
				
				_oINT[sIntID] = null;
				delete _oINT[sIntID];
				if( _oINTCount )
				{
					if( _oINTCount[sIntID] != undefined ) 
					{
						_oINTCount[sIntID] = null
						delete _oINTCount[sIntID];	
					}
				}
			}
			
			if( isNaN(p_nStopCount) != true && p_nStopCount != 0 )
			{
				if( _oINTCount == null ) _oINTCount = new Object();
				_oINTCount[sIntID] = p_nStopCount;
			}
			
			_oINT[ sIntID ] = setInterval( receiveIntervalCall, p_nTime, sIntID, p_sMethodName, (p_aArgs as Array) );
			++_nIntCount;
			
			tracer( "startInterval: " + sIntID );
			return _oINT[sIntID];
		}	
		
		public function stopInterval( p_nINT:uint, p_sIntervalID:String = null ) : void
		{
			//Clear out object slots to prevent a memory leak
			if( p_sIntervalID )
			{
				_oINT[p_sIntervalID] = null;
				delete _oINT[p_sIntervalID];
				
				if( _oINTCount[p_sIntervalID] != undefined ) 
				{
					_oINTCount[p_sIntervalID] = null
					delete _oINTCount[p_sIntervalID];	
				}
			}else{
				var nValue:uint;
				for( var i:String in _oINT )
				{
					nValue = _oINT[i];
					if( nValue == p_nINT )
					{
						_oINT[i] = null;
						delete _oINT[i];
						
						if( _oINTCount )
						{
							if( _oINTCount[i] != undefined ) 
							{
								_oINTCount[i] = null
								delete _oINTCount[i];	
							}
						}
					}
				}
			}
			
			//Stop interval
			clearInterval( p_nINT );
			p_nINT = 0;
		}
		
		/**
		 * PRIVATE API
		**/
		
		//receives the interval call and handles call count and cancellation
		private function receiveIntervalCall( p_sIntID:String, p_sMethodName:*, p_aArgs:Array ): void
		{
			if( p_sMethodName is Function )
			{
				//If method just call it directly
				p_sMethodName.apply( null, p_aArgs );
			}else{
				//Call the method initialized by the parent
				_oParent[p_sMethodName].apply( _oParent, p_aArgs );
			}
			
			tracer( "receiveIntervalCall: " + p_sIntID + " : " + p_sMethodName );
			//Use try exceptions to make sure null properties are not used
			try
			{
				if( _oINTCount[ p_sIntID ] != null )
				{
					if( _oINTCount[ p_sIntID ] == 1 )
					{
						stopInterval( _oINT[p_sIntID], p_sIntID );
					}else if( _oINTCount[ p_sIntID ] > 0 )
					{
						_oINTCount[p_sIntID]--;
					}
				}
			} catch( e:Error )
			{
				tracer( "Stop Count does not exist for this interval" );
			}
		}
		
		/**
		* DEBUGGER METHODS
		**/
		
		private function tracer( p_msg:* ) : void
		{
			if( DEBUG )
			{
				trace( "#" + CLASS_NAME + "# " + p_msg );
			}
		}
	}
}

