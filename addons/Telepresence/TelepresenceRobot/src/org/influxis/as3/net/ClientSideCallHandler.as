/**
 *  ClientSideCallHandler - Copyright © 2011 Influxis All rights reserved.
**/

package org.influxis.as3.net
{
	//Flash Classes
	import flash.events.*;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	
	public dynamic class ClientSideCallHandler extends Proxy
	{
		public var className:String = "ClientSideCallHandler";
		public var version:String = "2.0";
		
		public static var DEBUG:Boolean = false;
		private static var _csc:ClientSideCallHandler;
		public var _oClient:Object;
		private var _originClient:Object;
		
		/**
		 * INIT API
		**/
		
		public function ClientSideCallHandler()
		{
			_oClient = new Object();
			tracer("ClientSideCallHandler");
		};
		
		/**
		 * SINGLETON API
		**/
		
		public static function getInstance() : ClientSideCallHandler
		{
			if( _csc == null ) _csc = new ClientSideCallHandler();
			return _csc;
		}
		
		/**
		 * PUBLIC API
		**/
		
		//Add new paths for new components
		public function addPath( p_sPath:String, p_val:* ) : void
		{
			var oClassPath:Object = _oClient;
			var aPath:Array = p_sPath.split(".");
			
			var nLen:Number = aPath.length;
			for( var i:Number = 0; i < nLen; i++ ) 
			{
				var sNameSpace:String = aPath[i];
				if ( (i+1) == nLen && oClassPath[sNameSpace] != undefined )
				{
					oClassPath[sNameSpace].handlers.push( p_val );
				}else if( oClassPath[sNameSpace] == undefined ) 
				{
					oClassPath[sNameSpace] = new Object();
					if( (i+1) == nLen ) oClassPath[sNameSpace].handlers = [p_val];
				}
				oClassPath = oClassPath[ sNameSpace ];
			}
		}
		
		//Removes an handler from a namespace that was made
		public function removePathAt( p_sPath:String, p_val:* ) : Boolean
		{
			var oClassPath:Object = _oClient;
			var aPath:Array = p_sPath.split(".");
			
			var nLen:Number = aPath.length;
			for( var i:Number = 0; i < nLen; i++ ) 
			{
				var sNameSpace:String = aPath[ i ];
				if( oClassPath[sNameSpace] == undefined ) return false;
				
				if ( (i+1) == nLen ) 
				{
					oClassPath[sNameSpace];
					var aHandlers:Array = oClassPath[sNameSpace].handlers;
					if ( aHandlers )
					{
						var nLenHan:Number = aHandlers.length-1;
						for ( var z:Number = nLenHan; z > -1; z-- )
						{
							if ( p_val == aHandlers[z] )
							{
								oClassPath[sNameSpace].handlers.splice( z, 1 );
								if ( oClassPath[sNameSpace].handlers.length == 0 ) delete oClassPath[sNameSpace];
								break;
							}
						}
					}
				}else{
					oClassPath = oClassPath[ sNameSpace ];
				}
			}
			return true;
		}
		
		//Removes an item from a namespace that was made
		public function removePath( p_sPath:String ) : Boolean
		{
			var oClassPath:Object = _oClient;
			var aPath:Array = p_sPath.split(".");
			
			var nLen:Number = aPath.length;
			for( var i:Number = 0; i < nLen; i++ ) 
			{
				var sNameSpace:String = aPath[i];
				if( oClassPath[sNameSpace] == undefined ) return false;
				
				if ( (i + 1) == nLen ) 
				{
					delete oClassPath[sNameSpace];
					
				}else{
					oClassPath = oClassPath[sNameSpace];
				}
			}
			return true;
		}
		
		//Invoked when a server side method fails
		public function failCall( ... args ) : void
		{
			var aArgs:Array = args as Array;
			trace("Error, Serverside code could not find method. ( arguments: "+aArgs+" )");
		};
		
		/**
		 * FLASH PROXY API
		**/
		
		override flash_proxy function callProperty( p_sMethod:*, ... args ) : *
		{
			tracer( "PROXY callProperty  method "+p_sMethod+",  args "+args );
			if( p_sMethod == "toString" ) return this;
		}
		
		override flash_proxy function setProperty( name:*, p_val:* ) : void
		{
			_oClient[name] = p_val;
		}
		
		override flash_proxy function getProperty( p_name:* ) : *
		{
			tracer( "PROXY getProperty name " + p_name );
			var sPath:String = p_name;
			var nLastDotPos:Number = sPath.lastIndexOf(".");
			
			//put a default fail function when serverside calls that will look for and call a fail method on class.
			var f:* = failCall;
			var oClassPath:Object = _oClient;
			var sMethod:String;
			if( nLastDotPos == -1 )
			{
				//If the origin client has this prop then override to them
				if ( oClassPath[sPath] == undefined )
				{
					return _originClient[sPath];
				}else {
					oClassPath = oClassPath[sPath];
				}
			} else {
				//Get namespace info
				var sNameSpace:String = sPath.substring( 0, nLastDotPos );
				sMethod = sPath.substr( nLastDotPos + 1 );
				var aNameSpace:Array = sNameSpace.split( "." );
				
				var nLen:Number = aNameSpace.length;
				for( var i:Number = 0; i < nLen; i++ ) 
				{
					var sNameSpaceItem:String = aNameSpace[i];
					//tracer( "classPath: " + oClassPath[ sNameSpaceItem ] + " : " + sNameSpaceItem );
					if( oClassPath[sNameSpaceItem] == undefined || oClassPath[sNameSpaceItem] == null ) 
					{
						break;
					} else {
						oClassPath = oClassPath[ sNameSpaceItem ];
						//tracer("item: " + sNameSpaceItem);
					}
				}
			}
			
			if( oClassPath != null ) 
			{
				//tracer("path: "+oClassPath[ sMethod ] + " : " + sMethod);
				// if method does not exist in path, look for fail method named serverCallFail
				// otherwise default to a local trace method.
				
				f = function( ...args ):*
				{
					var aArgs:Array = args as Array;
					var returnValue:*;
					if ( oClassPath.handlers != undefined )
					{
						for each( var i:* in oClassPath.handlers )
						{
							if ( i != undefined )
							{
								if ( i is Function )
								{
									i.apply( i, aArgs );
								}else {
									try {
										if( i[sMethod] == undefined || i[sMethod] == null ) 
										{
											if ( i["serverCallFail"] == undefined )
											{
												returnValue = failCall.apply( null, aArgs );
											}else{
												returnValue = i["serverCallFail"].apply( i, aArgs );
											}
										}else{
											returnValue = i[sMethod].apply( i, aArgs );
										}
									}catch ( e:Error )
									{
										//Error
									}
								}
							}
						}
					}
					return returnValue;
				}
			}
			return f;
		}
		
		/**
		 * GETTERS / SETTERS
		 */
		
		public function set client( value:Object ): void
		{
			_originClient = value;
		}
		 
		public function get client(): Object
		{
			return _originClient;
		}
		
		/**
		 * DEBUG
		**/
		
		private function tracer( p_msg:* ) : void
		{
			if ( DEBUG ) 
			{
				trace("#"+className+"#  "+p_msg);
			}
		}
	}
}
