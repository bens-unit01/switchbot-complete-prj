package org.influxis.flotools.managers 
{
	
	//Flash Classes
	import flash.display.DisplayObject;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.SharedObject;
	import flash.net.Responder;
	import flash.utils.ByteArray;
	
	//Influxis Classes
	import org.influxis.as3.data.HashTable;
	import org.influxis.as3.states.DataStates;
	import org.influxis.as3.net.ClientSideCallHandler;
	import org.influxis.as3.codecs.JPEGAsyncEncoder;
	import org.influxis.as3.utils.BitmapUtils;
	import org.influxis.as3.utils.ByteUtils;
	//import org.influxis.as3.utils.FileUtils;
	import org.influxis.as3.utils.handler;
	
	//Manages and saves thumb data to server
	public class VideoThumbCacher extends EventDispatcher
	{
		private static var __instances:Object = new Object();
		
		private var _callPrefix:String;
		private var _netConnection:NetConnection;
		private var _ls:SharedObject;
		private var _clsh:ClientSideCallHandler;
		private var _instanceName:String;
		private var _loadAllImages:Boolean;
		private var _data:HashTable;
		private var _encodingJPG:Object = new Object();
		private var _encodeQueue:Vector.<String>;
		private var _encodeSavedRef:Object;
		private var _encoderRunning:Boolean = true;
		
		/*
		 * INIT API
		 */
		
		public function VideoThumbCacher( target:String, loadAllImages:Boolean = true ): void
		{
			_instanceName = target;
			_loadAllImages = loadAllImages;
			_data = new HashTable();
			
			if ( !_instanceName ) throw new Error( "Target folder must be non-null!" );
			
			_clsh = ClientSideCallHandler.getInstance();
			_clsh.addPath( "VideoFrames." + target, { __onServerEvent:__onServerEvent } );
			_callPrefix = "VideoFrames:" + target;
			
			_ls = SharedObject.getLocal( "VideoThumbCacher." + target, "/" );
			//__runSavedJobs();
		}
		
		/*
		 * SINGLETON API
		 */
		
		public static function getInstance( instanceName:String = "_DEFAULT_", loadAllImages:Boolean = true ): VideoThumbCacher
		{
			if ( !instanceName ) return null;
			if ( __instances[instanceName] == undefined ) __instances[instanceName] = new VideoThumbCacher(instanceName);
			return (__instances[instanceName] as VideoThumbCacher);
		}
		 
		public function destroy( instanceName:String = "_DEFAULT_" ): void
		{
			if ( !instanceName || __instances[instanceName] == undefined ) return;
			
			__instances[instanceName].close();
			__instances[instanceName] = null;
			delete __instances[instanceName];
		}
		
		/*
		 * CONNECT API
		 */
		
		public function connect( netConnection:NetConnection ): Boolean 
		{
			if ( !netConnection || !netConnection.connected ) return false;
			_netConnection = netConnection;
			_netConnection.call( _callPrefix + ".connect?clientInfo", null, _loadAllImages );
			return false;
		}
		
		public function close(): void 
		{
			if ( !_netConnection ) return;
			_netConnection = null;
		}
		
		/*
		 * PUBLIC API
		 */
		
		public function stopEncodingJobs(): void
		{
			if ( !_encoderRunning ) return;
			
			_encoderRunning = false;
			for each( var i:String in _encodeQueue )
			{
				JPEGAsyncEncoder(_encodingJPG[i].encoderEngine).stop();
			}
		}
		
		public function startEncodingJobs(): void
		{
			if ( _encoderRunning ) return;
			_encoderRunning = true;
			if( _encodeQueue && _encodeQueue.length > 0 ) JPEGAsyncEncoder(_encodingJPG[_encodeQueue[0]].encoderEngine).start();
		}
		 
		public function saveDisplayImage( slot:String, display:DisplayObject, imageQuality:Number = 50, targetWidth:Number = NaN, targetHeight:Number = NaN, encodePixelsPerIteration:uint = 4, encodeWaitTime:uint = 100 ): JPEGAsyncEncoder
		{
			if ( !slot || !display ) return null;
			
			var bitmapData:BitmapData;
			if ( isNaN(targetWidth) && isNaN(targetHeight) )
			{
				bitmapData = new BitmapData( display.width, display.height );
				bitmapData.draw(display);
			}else{
				bitmapData = BitmapUtils.scaleImageSource(display, display.width, display.height, targetWidth, targetHeight);
			}
			
			return saveEncodeBitmapData( slot, bitmapData, imageQuality, encodePixelsPerIteration, encodeWaitTime );
		}
		
		public function saveCameraImage( slot:String, camera:Camera, imageQuality:Number = 50, targetWidth:Number = NaN, targetHeight:Number = NaN, encodePixelsPerIteration:uint = 4, encodeWaitTime:uint = 100 ): JPEGAsyncEncoder
		{
			if ( !slot || !camera ) return null;
			
			//Create new bitmap and save camera info to it
			var bitmapData:BitmapData = new BitmapData( camera.width, camera.height );
			camera.drawToBitmapData(bitmapData);
			
			//Scale image if required and send to encode and save
			if ( !isNaN(targetWidth) || !isNaN(targetHeight) ) bitmapData = BitmapUtils.scaleImageSource(bitmapData, bitmapData.width, bitmapData.height, targetWidth, targetHeight);
			return saveEncodeBitmapData( slot, bitmapData, imageQuality, encodePixelsPerIteration, encodeWaitTime );
		}
			
		public function saveEncodeBitmapData( slot:String, bitmapData:BitmapData, imageQuality:Number = 50, encodePixelsPerIteration:uint = 4, encodeWaitTime:uint = 100 ): JPEGAsyncEncoder
		{
			if ( !bitmapData || _encodingJPG[slot] != undefined ) return null;
			
			var encoder:JPEGAsyncEncoder = new JPEGAsyncEncoder(imageQuality);
				encoder.addEventListener( Event.COMPLETE, handler(__onEncoderEvent, slot) );
				encoder.pixelsPerIteration = encodePixelsPerIteration == 0 ? 4 : encodePixelsPerIteration;
				encoder.waitTime = encodeWaitTime == 0 ? 1 : encodeWaitTime;
			
			_encodingJPG[slot] = 
			{
				encoderEngine: encoder,
				width:bitmapData.width,
				height:bitmapData.height,
				encoder:"jpg"
			}
			
			/*_encodeSavedRef[slot] = 
			{
				width:bitmapData.width,
				height:bitmapData.height,
				imageQuality: imageQuality,
				slot:slot 
			}*/
			
			//Saved to ref and local disk
			//_ls.setProperty( "savedRef", _encodeSavedRef );
			//FileUtils.saveToLocalDisk( bitmapData.getPixels(new Rectangle(0, 0, bitmapData.width, bitmapData.height)), slot + ".flbmp"); 
			if ( !_encodeQueue ) _encodeQueue = new Vector.<String>();
			
			encoder.encode(bitmapData, (_encodeQueue.length == 0 && _encoderRunning));
			_encodeQueue.push(slot);
			return encoder;
		}
		
		public function getImageAt( slot:String, pixelSnapping:String = "auto", smoothing:Boolean = false ): DisplayObject
		{
			if( !slot ) return null;
			return new Bitmap( getBitmapDataAt(slot), pixelSnapping, smoothing );
		}
		
		public function requestImageDataAt( slot:String, resultFunc:Function ): void
		{
			_netConnection.call( _callPrefix + ".getVideoFrameDataAt", new Responder(handler(__onServerDataResult,resultFunc)), slot );
		}
		
		public function getBitmapDataAt( slot:String ): BitmapData
		{
			if( !slot || !_data ) return null;
			
			var o:Object = _data.getItemAt(slot);
			if( !o || o.encoding != "bitmap" ) return null;
			
			return BitmapUtils.stringToBitmap( o.bitmap, o.width, o.height );
		}
		
		public function getEncoderAt( slot:String ): JPEGAsyncEncoder
		{
			return !slot || !_encodingJPG || _encodingJPG[slot] == undefined ? null : JPEGAsyncEncoder(_encodingJPG[slot].encoderEngine);
		}
		
		public function removeImageAt( slot:String ) : void
		{
			if ( !slot ) return;
			_netConnection.call( _callPrefix + ".removeImageDataAt", null, slot );
		}
		
		public function clearAllImages() : void
		{
			//if ( !connected ) return;
			_netConnection.call( _callPrefix + ".clearAllImages", null );
		}
		
		public function exist( slot:String ) : Boolean
		{
			if( !slot ) return false;
			
			var bExists:Boolean;
			if ( _data ) bExists = _data.exists(slot);
			return bExists;
		}
		 
		/*
		 * HANDLERS
		 */
		
		private function __onServerEvent( event:Object ): void 
		{
			if ( event.instanceName != _instanceName || event.data == undefined ) return;
			
			switch( String(event.type) )
			{
				case DataStates.ADD :
					_data.addItemAt(event.slot, event.data);
					break;
				case DataStates.REMOVE :
					_data.removeItemAt(event.slot);
					break;
				case DataStates.UPDATE :
					_data.updateItemAt(event.slot, event.data);
					break;
				case DataStates.CHANGE :
					_data.source = event.data == undefined ? {} : event.data;
					break;
				case DataStates.CLEAR :
					_data.clear();
					break;
			}
		}
		
		private function __onEncoderEvent( event:Event, slot:String ): void
		{
			if ( event.type == Event.COMPLETE )
			{
				//Remove listener
				_encodingJPG[slot].encoderEngine.removeEventListener( Event.COMPLETE, handler(__onEncoderEvent, slot) );
				
				//Grab and compress bytes
				var bytes:ByteArray = ByteArray(_encodingJPG[slot].encoderEngine.imageData);
					bytes.compress();
					
				//Save to server
				_netConnection.call( _callPrefix + ".addImageDataAt", null, slot, { bitmap:ByteUtils.bytesToArray(bytes).join(","),
																					width:_encodingJPG[slot].width,
																					height:_encodingJPG[slot].height,
																					encoder:_encodingJPG[slot].encoder } );
																					
				
				//Delete Ref
				//_encodeSavedRef[slot] = null;
				//delete _encodeSavedRef[slot];
				
				//Save ref and remove file
				//_ls.setProperty( "savedRef", _encodeSavedRef );
				//FileUtils.deleteFromDisk( slot + ".flbmp");
				
				//Delete encoding job
				_encodingJPG[slot] = null;
				delete _encodingJPG[slot];
				
				_encodeQueue.splice( _encodeQueue.indexOf(slot), 1 );
				if ( _encodeQueue.length == 0 ) 
				{
					_encodeQueue = null;
				}else{
					JPEGAsyncEncoder(_encodingJPG[_encodeQueue[0]].encoderEngine).start();
				}	
			}
		}
		
		/*
		 * PRIVATE API
		 */
		
		private function __onServerDataResult( imageData:Object, resultFunc:Function ): void
		{
			var newImageData:Object;
			if ( imageData ) 
			{
				if ( imageData.encoding == "bitmap" )
				{
					newImageData = new Bitmap(BitmapUtils.stringToBitmap(imageData.bitmap, imageData.width, imageData.height))
				}else{
					var bytes:ByteArray = ByteUtils.arrayToBytes( String(imageData.bitmap).split(",") );
					try
					{
						//Uncompress and convert to image
						bytes.uncompress();
					}catch(e:Error)
					{
						return;
					}
					
					newImageData = 
					{
						bitmap: bytes,
						width: imageData.width,
						height: imageData.height,
						encoder: imageData.encoder
					}
				}
			}
			resultFunc.apply( null, [newImageData] );
		}
		
		/*private function __runSavedJobs(): void
		{
			if ( _encodeSavedRef ) return;
			
			_encodeSavedRef = _ls.data.savedRef == undefined ? new Object() : _ls.data.savedRef;
			var encoder:JPEGAsyncEncoder; var bitmapData:BitmapData; var bytes:ByteArray;
			for ( var i:String in _encodeSavedRef )
			{
				//Load saved bitmap data
				bitmapData = new BitmapData(_encodeSavedRef[i].width, _encodeSavedRef[i].height);
				
				bytes = FileUtils.loadFromLocalDisk(i + ".flbmp")
				bitmapData.setPixels( new Rectangle(0, 0, _encodeSavedRef[i].width, _encodeSavedRef[i].height), bytes );
				
				//Create encoder
				encoder = new JPEGAsyncEncoder(_encodeSavedRef[i].imageQuality);
				encoder.addEventListener( Event.COMPLETE, handler(__onEncoderEvent, i), false, Number.MAX_VALUE );
				encoder.pixelsPerIteration = 4;
				encoder.waitTime = 100;
				
				//Create references
				if ( !_encodingJPG ) _encodingJPG = new Object();
				if ( !_encodeQueue ) _encodeQueue = new Vector.<String>();
				
				//Save encoder
				_encodingJPG[i] = 
				{
					encoderEngine: encoder,
					width:_encodeSavedRef[i].width,
					height:_encodeSavedRef[i].height,
					encoder:"jpg"
				}
				
				//Push to queue and encode
				_encodeQueue.push(i);
				encoder.encode(bitmapData, false);
			}
			
			if ( _encodeQueue ) JPEGAsyncEncoder(_encodingJPG[_encodeQueue[0]].encoderEngine).start();
		}*/
		
		/*
		 * GETTER / SETTER
		 */
		
		public function get dataProvider(): HashTable
		{
			return _data;
		}
	}
}