package org.influxis.flotools.net 
{
	//Flash Classes
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.net.NetConnection;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	
	//Influxis Classes
	import org.influxis.as3.net.ClientSideCallHandler;
	import org.influxis.as3.utils.Interval;
	import org.influxis.as3.utils.doTimedLater;
	
	//Detects BW speed from and to server (not used in this version ignore)
	public class BWDetect extends EventDispatcher
	{
		private var _nc:NetConnection;
		private var _clsh:ClientSideCallHandler;
		
		private var _nCheckCount:int;
		private var _bBWOutStop:Boolean;
		private var _bBWInStop:Boolean;
		private var _nMaxLength:Number = 10;
		private var _nBWInCtr:Number = 0;
		private var _nBWOutCtr:Number = 0;
		private var _nHeadIn:Number = 0;
		private var _nHeadOut:Number = 0;
		private var _nHeadPing:Number = 0;
		private var _nBWInfoTimeout:Number;
		private var _aBWInHistory:Array;
		private var _aBWOutHistory:Array;
		private var _aPingHistory:Array;
		
		private var _bw_out:Number = 0;
		private var _bw_in:Number = 0;
		private var _ping_rtt:Number = 0;
		private var _size:Number = 0;
		private var _time:Number;
		private var _data:String;
		private var _delay:int;
		private var _markerCheck:int;
		private var _timer:Timer;
		private var _started:Boolean;
		
		/*
		 * INIT API
		 */
		
		public function BWDetect( netConnection:NetConnection, delay:int = 15000, markerCheck:int = 45 ): void
		{
			super();
			
			if ( netConnection == null )
			{
				throw new Error("Conn is null!");
				return;
			}
			
			_timer = new Timer(3000, 1);
			_timer.addEventListener( TimerEvent.TIMER, __onTimerEvent );
			
			_data = "";
			
			//Setup data
			for (var i:Number = 0; i < 1000; i++) 
			{
				_data += "C->S";
			}
			
			_nc = netConnection;
			_delay = delay;
			_markerCheck = markerCheck;
			
			_aBWInHistory = new Array(_nMaxLength);
			_aBWOutHistory = new Array(_nMaxLength);
			_aPingHistory = new Array(_nMaxLength);
			
			//Create handlers
			_clsh = ClientSideCallHandler.getInstance();
			_clsh.addPath( "ack", __onAck );
			_clsh.addPath( "onEcho", __onEcho );
			
			//Start test right away
			start();
		}
		
		/*
		 * PUBLIC API
		 */
		
		public function close(): void
		{
			stop();	
			_clsh.removePath( "ack" );
			_clsh.removePath( "onEcho" );
			_clsh = null;
			_nc = null;
		}
		 
		public function start(): void
		{
			if ( _started ) return;
			
			_started = true;
			_timer.start();
		}
		 
		public function stop(): void
		{
			if ( !_started ) return;
			
			_bBWInStop = _bBWOutStop = false;
			_ping_rtt = _bw_out = _bw_in = NaN;
			
			_started = false;
			
			_timer.stop();
			_timer.reset();
			_timer.delay = 3000;
		}
		
		/*
		 * HANDLERS
		 */
		
		private function __onTimerEvent( event:TimerEvent ): void
		{
			if ( _timer.delay ) _timer.delay = _delay;
			
			//Reset timer after launch
			_timer.stop();
			_timer.reset();
			
			//Call server
			__clientToServer();
		}
		 
		/*
		 * PRIVATE API
		 */
		
		private function __onAck( pingVal:Number ): void
		{
			if (!_bBWOutStop)
			{
				_aBWOutHistory[_nHeadOut++ % _nMaxLength] = Math.floor(_size / (getTimer() - _time) * 1000);
				_aPingHistory[_nHeadPing++ % _nMaxLength] = pingVal;
				
				if ( _nCheckCount < _markerCheck )
				{
					_nc.call("recData", null, _data);
					_size += 4000;
					_nBWOutCtr++;
					_nCheckCount++;
				}else {
					_bBWOutStop = true;
					__serverToClient();
				}
			}
		}
		
		private function __onEcho( ...args ): void 
		{
			if ( !_started ) return;
			if (!_bBWInStop)
			{
				_aBWInHistory[_nHeadIn++ % _nMaxLength] = Math.floor(_size / (getTimer() - _time) * 1000);
				if ( _nCheckCount < _markerCheck )
				{
					_nc.call("echoData", null, 0);
					_size += 4000;
					_nBWInCtr++;
					_nCheckCount++;
				}else {
					_bBWInStop = true;
					__onCheckResults();
				}	
			}
		}
		
		private function __onCheckResults(): void
		{
			var newPing:Number = 0;
			var newBWOut:Number = 0;
			var newBWInt:Number = 0;
			
			for (var p:Number = 0; p < _nMaxLength && p < _nBWOutCtr; p++)
			{
				newPing = Math.max(newPing, _aPingHistory[p]);
			}
			
			for (var o:Number = 0; o < _nMaxLength && o < _nBWOutCtr; o++) 
			{
				newBWOut += _aBWOutHistory[o];
			}
			
			newBWOut /= Math.min(_nMaxLength, _nBWOutCtr);
			newBWOut = Math.round((newBWOut / 1024) * 8);
			
			for (var i:Number = 0; i < _nMaxLength && i < _nBWInCtr; i++) 
			{
				newBWInt += _aBWInHistory[i];
			}
			
			newBWInt /= Math.min(_nMaxLength, _nBWInCtr);
			newBWInt = Math.round((newBWInt / 1024) * 8);
			
			if ( !isChanged(_bw_out, newBWOut) && !isChanged(_bw_in, newBWInt) ) 
			{
				_bBWInStop = _bBWOutStop = false;
				_timer.start()
				return;
			}
			
			_ping_rtt = newPing;
			_bw_out = newBWOut;
			_bw_in = newBWInt;
			
			var sStatus:String = "";
				sStatus += "bandwidth\n";
				sStatus += "   upstream: " + newBWOut + " kbps\n";
				sStatus += "   downstream: " + newBWInt + " kbps\n";
				sStatus += "   latency: " + newPing + " ms\n";
				
			//Dispatch a change and set timer for recycle check
			dispatchEvent(new Event(Event.CHANGE));
			_bBWInStop = _bBWOutStop = false;
			_timer.start()
		}
		
		private function isChanged( value1:Number, value2:Number ): Boolean
		{
			return value1 - value2 >= 10 || value1 - value2 <= -10;
		}
		
		private function __clientToServer(): void
		{
			_time = getTimer();
			_size = 0;
			_nCheckCount = 0;
			
			_nc.call("recData", null, _data);
			_nc.call("recData", null, _data);
		};
		
		private function __serverToClient(): void 
		{
			_time = getTimer();
			_size = 0;
			_nCheckCount = 0;
			
			_nc.call("echoData", null, 0);
			_nc.call("echoData", null, 0);
		}
		
		/*
		 * GETTER / SETTER - API
		 */
		
		public function get bw_in(): Number
		{
			return _bw_in;
		}
		
		public function get bw_out(): Number
		{
			return _bw_out;
		}
		
		public function get ping(): Number
		{
			return _ping_rtt;
		}
		
		public function started(): Boolean
		{
			return _started;
		}
	}
}
