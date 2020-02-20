/*
 * TelepresenceMegamip
 * Flex_projects\develop\11\TelepresenceMegamip
 * */
package  {
	import com.bit101.components.CheckBox;
	import com.bit101.components.Panel;
	import com.bit101.components.PushButton;
	import com.bit101.components.Text;
	import com.soma.ui.vo.*;
	import com.soma.ui.*;
	import com.soma.ui.layouts.*;
	import flash.text.TextFormat;
	import flash.net.*;
	import flash.events.*;
	import flash.geom.Matrix;
	import flash.utils.Timer;
    
	import org.osmf.media.MediaElement;
	import org.osmf.net.StreamingURLResource;
	import org.osmf.net.StreamType;
	import org.osmf.containers.MediaContainer;
	import org.osmf.elements.VideoElement;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.URLResource;
	import org.osmf.media.MediaPlayerSprite;
   
	import flash.net.NetConnection;
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.media.H264VideoStreamSettings;
	import flash.media.H264Profile;
	import flash.media.H264Level;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.net.NetConnection;
	import flash.net.NetStream;
    import flash.media.Video;
    import flash.media.Microphone;
    import flash.media.Camera;
	import flash.media.CameraPosition;
	import flash.display.StageDisplayState;
	import flash.geom.Rectangle; 
	import com.bit101.components.ProgressBar;
	
	
	public class Main extends Sprite {

	// consts 
	private const SERVER_ADRESS:String = "rtmfp://p2p.rtmfp.net";
	private const DEVELOPER_KEY:String = "ab4cf6a661db0fc2f51f582d-6aeff8c9e9ef";
	private const platform:String = "tablet";
		
		
	// members 
	    private var txtMessage:TextField;
		private var txtLog:TextField;
	    private var btnConnect:PushButton;
		private var btnPublish:PushButton;
		private var btnRead:PushButton;
		private var nc:NetConnection;
		private var nsRead:NetStream;
		private var nsPublish:NetStream;
        private var videoPublish:Video;
		private var videoRead:Video;
        private var camera:Camera;
        private var mic:Microphone;
		private var videoElementPublish:VideoElement;
		private var videoElementRead:VideoElement;
		private var farPeerID:String;
		private var myPeerID:String;
		
	//	private var megamipLSClient:MegamipLSClient;
		public static var externalArgs:String = "";
		private var videoRotation:String = "0";
		private var progressBar:ProgressBar;
		private var progressBarTimer:Timer = new  Timer(150);
		private var progress:int = 0;
		private var startupMessage:TextField;
		
	
		
		public function Main() {
		 
			NativeApplication.nativeApplication.addEventListener(
			InvokeEvent.INVOKE, onInvoke);
			
			
		
		//	onInvoke2(null);
		

		}
		
		
		private function initHandler(evt:Event):void {
			
			NativeApplication.nativeApplication.addEventListener(
					InvokeEvent.INVOKE, onInvoke);
		}
		
		private function onInvoke(event:InvokeEvent):void
		{
		  
       	    var uri:String = event.arguments[0];
		    var args:Array = uri.split("//");
			farPeerID = args[1]; 
			 
			if ( farPeerID == Constants.CMD_CLOSE) deactivate(null);
			// farPeerID = "3f44ee297187ec9470047f12156441441aae5036c68a6e3c2caea31c8becf958";
			//initProgressBar();  
			initGui();
			initConnection(null);
			
		//	 megamipLSClient = new MegamipLSClient();
		//	 megamipLSClient.addEventListener(MegamipLSClient.UPDATE, lsReceiveData);
		 trace("onInvoke ... uri: " + uri );
			 
			 
			 
		}
		
	    private function asyncErrorHandlerPublish(event:AsyncErrorEvent):void {
		 logDebug("async error nsPublish");
		  
		}
		 private function asyncErrorHandlerRead(event:AsyncErrorEvent):void {
		  logDebug("async error nsRead");
		}
		private function initSendStream(event:MouseEvent):void{
		
			
		logDebug("initSendStream");

		nsPublish = new NetStream(nc, NetStream.DIRECT_CONNECTIONS);
		nsPublish.addEventListener(NetStatusEvent.NET_STATUS, netStatusReadHandler);
		nsPublish.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandlerPublish);
		//nsPublish.publish("media");



     // tricky !! 

		var sendStreamClient:Object = new Object();
			sendStreamClient.onPeerConnect = function(callerns:NetStream):Boolean{
		  
				farPeerID= callerns.farID;

				logDebug(" farPeerID: " + farPeerID);
				 var client:Object=new Object();
                  client.stopTransmit=function($p1:*,$p2:*):void{
                   logDebug("SB stopTransmit called " + $p1 + " " + $p2);
                   }
                  client.startTransmit=function():void{
                  logDebug("SB startTransmit called");
                }
            callerns.client = client;
				return true;
			}
		 
		  nsPublish.client = sendStreamClient;
		  publishLiveStream();

		}

		private function initRecvStream(event:MouseEvent):void{

			nsRead = new NetStream(nc, farPeerID);
		//	nsRead.bufferTime = 3;
			nsRead.addEventListener(NetStatusEvent.NET_STATUS, netStatusReadHandler);
			nsRead.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandlerRead);
			//nsRead.play("media");
			nsRead.client = this;
			readLiveStream();
		}


		public function receiveSomeData(str:String):void{

		   // we use str !!

		}

		private function sendSomeData():void{

			nsPublish.send("receiveSomeData", "texte a envoyer");
		}



		private function netStatusReadHandler(event:NetStatusEvent):void{
			
			logDebug(event.info.code);
		}
		
		/*
		 * 
		 * */
		 private function ncStatusHandler(event:NetStatusEvent):void{
			logDebug("ncStatusHandler# " + event.info.code);
			myPeerID = nc.nearID;

			txtMessage.text = myPeerID;
		}
		
		
		//------------------------------------------------------------------------------------------------------

		/*
		 * 
		 * Connecting to Cirrus
		 * */
		
		 private function initConnection(event:MouseEvent):void{


			// recuperation du fingerPrint 
	//		var txtFP:String = txtFingerPrint.text;
		//	farPeerID = txtFP;
			nc = new NetConnection();
			nc.addEventListener(NetStatusEvent.NET_STATUS, netStatusReadhHandler);
			nc.connect(SERVER_ADRESS,DEVELOPER_KEY);

		}
		
	
		
	
		
		/*
		 * 
		 * 
		 * */
        private function netStatusPublishHandler(event:NetStatusEvent):void
        {
            logDebug("netStatusPublishHandler#connected is: " + nc.connected );
			logDebug("netStatusPublishHandler#event.info.level: " + event.info.level);
			logDebug("netStatusPublishHandler#event.info.code: " + event.info.code);
			
            switch (event.info.code)
            {
                case "NetConnection.Connect.Success":
	                trace("Congratulations! you're connected");
	                publishLiveStream();
					
	                break;
                case "NetConnection.Connect.Rejected":
	                trace ("Oops! the connection was rejected");
	                break;
	            case "NetStream.Play.Stop":
	                trace("The stream has finished playing");
	                break;
	            case "NetStream.Play.StreamNotFound":
	                trace("The server could not find the stream you specified"); 
	                break;
	            case "NetStream.Publish.Start":
				
	                trace("Adding metadata to the stream");
	                // when publishing starts, add the metadata to the stream
                	var metaData:Object = new Object();
                	metaData.title = "myStream";
               // 	metaData.width = 400;
                //	metaData.height = 200;
                	nsPublish.send("@setDataFrame", "onMetaData", metaData);
	                break;
					
	            case "NetStream.Publish.BadName":
	                trace("The stream name is already used");
	                break;
	        }
        }
        
		 /*
		 * 
		 * 
		 * */
		
		    private function netStatusReadhHandler(event:NetStatusEvent):void
        {
            logDebug("netStatusReadhHandler#connected is: " + nc.connected );
			logDebug("netStatusReadhHandler#event.info.level: " + event.info.level);
			logDebug("netStatusReadhHandler#event.info.code: " + event.info.code);
			
            switch (event.info.code)
            {
                case "NetConnection.Connect.Success":
	                trace("Congratulations! you're connected");
					 initRecvStream(null);
				   //readLiveStream();
	                break;
                case "NetConnection.Connect.Rejected":
	                trace ("Oops! the connection was rejected");
	                break;
	            case "NetStream.Play.Stop":
	                trace("The stream has finished playing");
	                break;
	            case "NetStream.Play.StreamNotFound":
	                trace("The server could not find the stream you specified"); 
	                break;
	            case "NetStream.Play.Start":
				
	                trace("netStatusReadhHandler#reading stream ...");
	               
	                break;
					
	            case "NetStream.Publish.BadName":
	                trace("The stream name is already used");
	                break;
				
				case "NetStream.Connect.Closed":
					deactivate(null);
					break;
	        }
        }
		
		/*
		 * 
		 * 
		 * */
		
		
		
       	private function activityHandler(event:ActivityEvent):void {
		    logDebug("activityHandler#: " + event);
		 //   trace("activating: " + event.activating);
	    } 
        
		/*
		 *  Create a live stream, attach the camera and microphone, and
		 *  publish it to the local server
		 */
        private function publishLiveStream():void {
		  
		
		    camera = getCamera();
		
		    mic = Microphone.getMicrophone();
		    
			
			
/*	  edge:   { width:128, height:96, fps:10, bandwidth:32000, quality:90, bwDetect:0.15, encodeQual
      low:    { width:256, height:192, fps:10, bandwidth:32000, quality:90, bwDetect:0.15, encodeQua
      small:  { width:384, height:288, fps:12, bandwidth:32000, quality:90, bwDetect:0.15, encodeQua
      medium: { width:512, height:384, fps:15, bandwidth:56000, quality:90, bwDetect:0.12, encodeQua
      high:   { width:640, height:480, fps:18, bandwidth:96000, quality:90, bwDetect:0.95, encodeQua
	  
	  
	  12-29 22:25:51.666: D/CameraHal(112): Support Preview sizes:
		  640x480,1280x720,960x544,800x448,640x360,800x600,416x240,352x288,176x144,320x240,160x120   

	  */
	  
	  
		    if (camera != null){

			/*	var h264Settings:H264VideoStreamSettings = new H264VideoStreamSettings();
				h264Settings.setProfileLevel( H264Profile.BASELINE, H264Level.LEVEL_3_1 )*/
			camera.setMode(640, 480, camera.fps, true);
			//camera.setMode( 320, 240, 30, true );
			camera.setMotionLevel(50, 300);
			logDebug("fps: " + camera.fps);
		
			//camera.setQuality(camera.bandwidth, 50);
			//camera.setQuality( 90000, 90 );
			camera.setQuality(120000, 90);
		    camera.setKeyFrameInterval(18);
			camera.addEventListener(ActivityEvent.ACTIVITY, activityHandler);
			    
	
		//			nsPublish.videoStreamSettings  = h264Settings;
				videoPublish.attachCamera(camera);
				
				nsPublish.attachCamera(camera);
			//	nsPublish.bufferTime = 3;
		
				
			// timer used to launch stats 	
			   var t:Timer = new Timer(100);
               t.addEventListener(TimerEvent.TIMER, timerHandler);		
               t.start();
			
			}
			
			if (mic != null) {
				mic.addEventListener(ActivityEvent.ACTIVITY, activityHandler);
								
			    nsPublish.attachAudio(mic);
			}
			
			if (camera != null || mic != null){
				// start publishing
			    // triggers NetStream.Publish.Start
			    nsPublish.publish("media", "live");
				
				 var metaData:Object = new Object();

            metaData.fps = camera.fps;
            metaData.bandwith = camera.bandwidth;
            metaData.height = camera.height;
            metaData.width = camera.width;
            metaData.keyFrameInterval = camera.keyFrameInterval;
            metaData.copyright = "WowWee Canada - Megamip";
            nsPublish.send("@setDataFrame", "onMetaData", metaData);
			logDebug("publishLiveStream# publishing cam.width: " + camera.width + " camera.height: " + camera.height + "\n "
		 +"	bandwidth: " + camera.bandwidth );
			
		    } else {
			    logDebug("Please check your camera and microphone");
		    }
	    }  
				
		/*
		 * 
		 * */
		
		private function readLiveStream():void {
			
			
			
		
		videoRead.attachNetStream(nsRead);
		nsRead.play("media");
		
		//---------------------------
		
	
       
		// we start publishing ... 	
		  initSendStream(null); 
		 }
			
		 
		 /*
	 * 
	 * 
	 * */	
		private function deactivate(e:Event):void 
		{
			// make sure the app behaves well (or exits) when in background
			logDebug("deactivate ...");
			if (nsPublish != null) {
				nsPublish.removeEventListener(NetStatusEvent.NET_STATUS, netStatusPublishHandler);
				videoPublish.attachCamera(null);
				nsPublish.attachCamera(null);
				nsPublish.close();
			}
			if (nsRead != null) {
				nsRead.removeEventListener(NetStatusEvent.NET_STATUS, netStatusReadHandler);
				nsRead.close();
			} 
			if ( nc != null ) {
				nc.removeEventListener(NetStatusEvent.NET_STATUS, ncStatusHandler);
				nc.close();
			}
			
			NativeApplication.nativeApplication.exit();
		}
	
			
		/*
		 * 
		 * */	
		private function getCamera():Camera {
			
		   return Camera.getCamera();
		}
		

		
		
		
		
		private function initGui():void {
		    this.stage.align = StageAlign.TOP_LEFT;
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE; 
			this.stage.color =  0x202020;
			
		//-- progress bar 
		
		
			
			
		 //-------------- videos display 
		 
		  
		
	    // videoRead 
	    videoRead = new Video();
		videoRead.smoothing = true;
		videoPublish = new Video();
		videoPublish.smoothing = true;
		

		videoRead.scaleX = 3;
		videoRead.scaleY = 3;
		videoPublish.scaleX = 0.4;
		videoPublish.scaleY = 0.4;
		var gap:int = (stage.fullScreenWidth - videoRead.width) / 2;
		
		//trace("initGui rotation: " + videoRotation);
		
   
		videoRead.x = gap ;
		videoRead.y = 0;
		var gap2:int = gap + videoRead.width;
		videoPublish.x = (videoPublish.width)/2  ;
		videoPublish.y = stage.fullScreenHeight - ( videoPublish.height + 30 );
		
		// log panel  cam params 
		
		 var txtFormat:TextFormat = new TextFormat();
		 txtMessage = new TextField();
		 txtFormat.leftMargin = 5;
			
		//	txtMessage.type = TextFieldType.INPUT;
		   
		 txtMessage.width = 300;
		 txtMessage.height = 200;
		 txtMessage.multiline = true;
		 txtMessage.background = true;
			
		//	txtFormat.font = "Verdana";
            txtMessage.defaultTextFormat = txtFormat;
			txtMessage.backgroundColor = 0x99D9EA;

			var baseUI:BaseUI = new BaseUI(stage);
			var ctnTxtMessage:ElementUI = baseUI.add(txtMessage);
			ctnTxtMessage.bottom = 20;
			ctnTxtMessage.left = 220;
			ctnTxtMessage.refresh();
			
			
			
		// log panel app --------------------------------------
		
		 var txtFormat2:TextFormat = new TextFormat();
		 txtLog = new TextField();
		 txtFormat2.leftMargin = 5;
			
		//	txtMessage.type = TextFieldType.INPUT;
		   
		 txtLog.width = 500;
		 txtLog.height = 500;
		 txtLog.multiline = true;
		 txtLog.background = true;
			
		//	txtFormat.font = "Verdana";
            txtLog.defaultTextFormat = txtFormat;
			txtLog.backgroundColor = 0x99D9EA;

			
			var ctnTxtLog:ElementUI = baseUI.add(txtLog);
			 ctnTxtLog.bottom = 20;
			 ctnTxtLog.left = 620;
			 ctnTxtLog.refresh();
		
	    //------------------
		
		addChild(txtMessage);
		addChild(txtLog);
		addChild(videoPublish);
        addChild(videoRead); 
		
		}
		
		//------------------------ LightStreamer communication methods ( remote control)
	
		public function lsReceiveData(event:Event):void{
        
		//	var message:String = megamipLSClient.getMessage();
		//	 trace("lsReceiveData event:" + event);
		//	 trace("lsReceiveData message:" +message);
		//	 sendMegamipCMD(message);
		    

		}
		private function sendMegamipCMD(str:String):void {
	/*	trace("sendMegamipCMD ... str: " + str);	
		var url:String = "http://localhost:8080/"+str;
		var request:URLRequest = new URLRequest(url);
		request.method = URLRequestMethod.GET;

		var variables:URLVariables = new URLVariables();
		variables.name = "cmd_params";
		request.data = variables;

		var loader:URLLoader = new URLLoader();
		loader.addEventListener(Event.COMPLETE, onSendMegamipCallback);
		loader.dataFormat = URLLoaderDataFormat.TEXT;
		loader.load(request);
*/
			
		}
		
		private function onSendMegamipCallback (event:Event):void {
		logDebug( "onSendMegamipCallback " + event.target.data);
		}


		private function logDebug(message:String):void {
		   trace(message);
			log(message);
     	}
		
		private function log(message:String):void {
		  txtLog.appendText(message + "\n");
		/*	if (megamipLSClient != null) {
				megamipLSClient.sendMessage(message);
			}*/
	
		}
		
		
		private function timerHandler(event:TimerEvent):void
      {		
	    txtMessage.text = "";
	    txtMessage.appendText("activityLevel : " + camera.activityLevel + "\n");
	    txtMessage.appendText("bandwidth : " + camera.bandwidth + "\n");
	    txtMessage.appendText("currentFPS : " + camera.currentFPS + "\n");
	    txtMessage.appendText("fps : " + camera.fps + "\n");
	    txtMessage.appendText("keyFrameInterval : " + camera.keyFrameInterval + "\n");
	    txtMessage.appendText("loopback : " + camera.loopback + "\n");
    	txtMessage.appendText("motionLevel : " + camera.motionLevel + "\n");
    	txtMessage.appendText("motionTimeout : " + camera.motionTimeout + "\n");
     	txtMessage.appendText("quality : " + camera.quality + "\n");
		txtMessage.appendText("width : " + camera.width + "\n");
		txtMessage.appendText("height : " + camera.height + "\n");
     }
		
	}
	


}


		class CustomClient {
		public function onMetaData(info:Object):void {
			trace("width: " + info.width);
			trace("height: " + info.height);
		}
		
	}
