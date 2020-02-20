package  {
	
	import com.bit101.components.CheckBox;
	import com.bit101.components.Panel;
	import com.bit101.components.PushButton;
	import com.soma.ui.vo.*;
	import com.soma.ui.*;
	import com.soma.ui.layouts.*;
	import flash.net.*;
	import flash.events.*;
	import flash.utils.Timer;

	import org.osmf.media.MediaElement;
	import org.osmf.net.StreamingURLResource;
	import org.osmf.net.StreamType;
	import org.osmf.containers.MediaContainer;
	import org.osmf.elements.VideoElement;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.URLResource;
	import org.osmf.media.MediaPlayerSprite;

	import flash.events.TouchEvent;
	import flash.events.MouseEvent;
	import flash.net.NetConnection;
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.display.Sprite;
	import flash.display.StageOrientation;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.media.H264VideoStreamSettings;
	import flash.media.H264Profile;
	import flash.media.H264Level;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldType;
	import flash.net.NetConnection;
    import flash.events.NetStatusEvent;
    import flash.events.ActivityEvent;
	import flash.events.MouseEvent;
	import flash.net.NetStream;
    import flash.media.Video;
    import flash.media.Microphone;
    import flash.media.Camera;
	import flash.media.CameraPosition;
	import flash.geom.Matrix;


	public class Main extends Sprite {

	// consts 
	private const SERVER_ADRESS:String = "rtmfp://p2p.rtmfp.net";
	private const DEVELOPER_KEY:String = "ab4cf6a661db0fc2f51f582d-6aeff8c9e9ef";
	
	public static const NONE:int = 0;
	public static const CONNECTING:int = 1;
	public static const CONNECTED:int = 2;
	
		
		// members 
	    private static var txtMessage:TextField;
		private var btnStart:PushButton;
		private var btnForward:CustomButton;
	    private var btnBack:CustomButton;
		private var btnLeft:CustomButton;
		private var btnRight:CustomButton;
		private var btnConnect:CustomButton;
		private var btnExit:CustomButton;

        private var ctnDPadBackground:CustomButton;
		private var btnRead:PushButton;
		
		private var ncRead:NetConnection;
		private var ncPublish:NetConnection;
		private var nc:NetConnection;
		private var nsRead:NetStream;
		private var nsPublish:NetStream;
        private var videoPublish:Video;
		private var videoRead:Video;
        private var mic:Microphone;
		private var videoElementPublish:VideoElement;
		private var videoElementRead:VideoElement;
		private var farPeerID:String;
		private var myPeerID:String;
		private var sbUserLSClient:MegamipLSClient;
		private var blinkTimer:Timer = new Timer(200);
		private var timerFlag:Boolean = true;
		
		private var urlRequestMF:URLRequest;
		private var urlRequestMB:URLRequest;
		private var urlRequestML:URLRequest;
		private var urlRequestMR:URLRequest;
		private var urlLoader:URLLoader;
		private var host:String;
		private var speed:String;
		private var counter:int = 0; 
		private var REFRESH_RATE_FORWARD:int = 250;
		private var REFRESH_RATE_TURN:int = 100;
		private var currentCommand:URLRequest;
		
		private var mState:int = NONE;
		
	
		
		public function Main() {
			
			NativeApplication.nativeApplication.addEventListener(
			InvokeEvent.INVOKE, onInvoke);
			
			initGui();
		    initListeners();
		
			
		}
		
		private function onInvoke(event:InvokeEvent):void
		{
			  
			  log("onInvoke ...");
		//  megamipLSClient = new MegamipLSClient();
		  
	   }
	   
	   public static function logDebug(output:String):void {
		 // log(output);
	    }
		
		private static function log(output:String):void {
		    trace(output);
		    txtMessage.appendText(output + "\n");
			txtMessage.scrollV++;
	    }
		//---------------------------------------     P2P ---------------------------------------------------------
	    private function asyncErrorHandlerPublish(event:AsyncErrorEvent):void {
		 logDebug("async error nsPublish");
		  
		}
		 private function asyncErrorHandlerRead(event:AsyncErrorEvent):void {
		  logDebug("async error nsRead");
		}

		private function initSendStream(event:MouseEvent):void{
			
		trace("initSendStream");
		//txtFingerPrint.appendText("\n Connected !!\n Publishing ...");

		nsPublish = new NetStream(nc, NetStream.DIRECT_CONNECTIONS);
		nsPublish.addEventListener(NetStatusEvent.NET_STATUS, netStatusPublishHandler);
		nsPublish.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandlerPublish);
		nsPublish.publish("media");
        logDebug("initSendStream farID: " + nsPublish.farID);


     // tricky !! 

			var sendStreamClient:Object = new Object();

			sendStreamClient.onPeerConnect = function(callerns:NetStream):Boolean{
		  
				farPeerID= callerns.farID;

				logDebug("onPeerConnect farPeerID: " + farPeerID);
				
				 var client:Object=new Object();
                  client.stopTransmit=function($p1:*,$p2:*):void{
                    logDebug("user stopTransmit called" + $p1 + " " +$p2);
                   }
                  client.startTransmit=function():void{
                  logDebug("user startTransmit called");
                }
				
				callerns.client = client;
				return true;
			}
		 
		  nsPublish.client = sendStreamClient;
          publishLiveStream();
		}

		private function initRecvStream(event:MouseEvent):void{

			nsRead = new NetStream(nc, farPeerID);
			nsRead.addEventListener(NetStatusEvent.NET_STATUS, netStatusReadHandler);
			nsRead.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandlerRead);
			//nsRead.play("media");
			nsRead.client = this;
			
			//  +------------------### log ###-------------------+
			logDebug("connected to stream nc farID: " + nc.farID + " nearID: " + nc.nearID);
			logDebug("nsRead  farID: " + nsRead.farID);
			logDebug("connected to stream \n far ID: " + nc.farID +" near ID: " + nc.nearID );
			//txtFingerPrint.appendText("\n Reading stream from Megamip ...");
		   readLiveStream();
		}


		public function receiveData(str:String):void{

		   // we use str !!

		}

		private function sendData():void{

			nsPublish.send("receiveSomeData", "texte a envoyer");
		}



		private function netStatusReadHandler(event:NetStatusEvent):void{
			
			logDebug("netStatusReadHandler event: " + event.info.code);
			/*if (event.info.code == "NetStream.Play.PublishNotify") {
				readLiveStream();
			}*/
	       switch (event.info.code)
            {
               case "NetConnection.Connect.Success":
                    trace("Congratulations! you're connected");
                  // readLiveStream();
                   break;
                case "NetConnection.Connect.Rejected":
                trace ("Oops! the connection was r");
                break;
                 case "NetStream.Play.Stop":
                trace("The stream has finished pla");
                break;
                 case "NetStream.Play.StreamNotFound":
                trace("The server could not find t");
                break;
                 case "NetStream.Play.Start":
					 blinkTimer.stop();
			         btnConnect.setBackground(CustomButton.ButtonConnected);
		          //	btnExit.addEventListener(MouseEvent.CLICK, deactivate);	
			        log( "Connected !");
                trace("reading stream ...");
                break;
                 case "NetStream.Publish.BadName":
                  trace("The stream name is already used");
				 break;
            }
         
	}
		
		//----------------------------------   P2P  --------------------------------------------------------------
		
		/*
		 * 
		 * Connecting to Cirrus
		 * */
		
		 private function initConnection(event:MouseEvent):void{


			// recuperation du fingerPrint 
		    /*var txtFP:String = txtFingerPrint.text;
			farPeerID = txtFP;
			*/
			
			//             +----------### log ###----------+ 
			//txtFingerPrint.appendText( "--------------\n Connecting ...");
			
			mState = CONNECTING;
			logDebug("initConnection() ...");
			btnConnect.removeEventListener(MouseEvent.CLICK, initConnection);
			btnConnect.setBackground(CustomButton.ButtonConnecting1); 
			
			log("connecting ... please wait" );
			blinkTimer.start();
			blinkTimer.addEventListener(TimerEvent.TIMER, onTick);
			nc = new NetConnection();
			nc.addEventListener(NetStatusEvent.NET_STATUS, ncStatusHandler);
			nc.connect(SERVER_ADRESS, DEVELOPER_KEY);
			
	    }
		
		private function onTick(evt:TimerEvent):void {
		  (timerFlag)? btnConnect.setBackground(CustomButton.ButtonConnecting2) : btnConnect.setBackground(CustomButton.ButtonConnecting1);
		  timerFlag = !timerFlag;
		}
		
		
		/*
		 * 
		 * */
		
		 private function ncStatusHandler(event:NetStatusEvent):void{
			logDebug("ncStatusHandler# - "+event.info.code);
			

			//txtFingerPrint.text = myPeerID;
			// connecting to LightStreamer server and sending the p2p fingerprint
			if (event.info.code == "NetConnection.Connect.Success") {
				log("ncStatusHandler NetConnection --> success");
		
				myPeerID = nc.nearID;
				sbUserLSClient = new MegamipLSClient();
				sbUserLSClient.addEventListener(MegamipLSClient.FAILED, function():void {
					log("push server down ...");
					if ( mState == CONNECTING ) {
					  blinkTimer.stop();
					  connectionFailed("connection failed : push server down ");
					  disconnect();
					  mState = NONE;
					}
				   } );	  
			
				    sbUserLSClient.addEventListener(MegamipLSClient.CONNECTED, sendPeerID);
				
				//megamipLSClient.sendMessage("LAUNCH:"+myPeerID);
			}
			
			if (event.info.code == "NetConnection.Connect.Failed") {
					blinkTimer.stop();
					connectionFailed("Connection failed ... check your wifi connection ");
					mState = NONE;	
			}
			if (event.info.code == "NetStream.Connect.Closed") {
                    connectionFailed("Disconnected ...");
					mState = NONE;
			}
		}
		
		private function connectionFailed(message:String):void {
		  log(message);
		  btnConnect.setBackground(CustomButton.ButtonConnect);
	      btnConnect.addEventListener(MouseEvent.CLICK, initConnection);
		}
	
		public function lsReceiveData(event:Event):void{
        
			var message:String = sbUserLSClient.getMessage();
			logDebug(message);
		}
		
		private function sendPeerID(e:Event):void {
		 
			 sbUserLSClient.removeEventListener(MegamipLSClient.CONNECTED, sendPeerID);
			// we start publishing 
			initSendStream(null);
			sbUserLSClient.sendMessage(Constants.CMD_LAUNCH + ":"+ myPeerID);
		    sbUserLSClient.addEventListener(MegamipLSClient.UPDATE, lsReceiveData);
		}
		/*
		 * 
		 * 
		 * */
        private function netStatusPublishHandler(event:NetStatusEvent):void
        {
            logDebug("netStatusPublishHandler# connected is: " + nc.connected );
			logDebug("netStatusPublishHandler# event.info.level: " + event.info.level);
			logDebug("netStatusPusblishHandler# event.info.code: " + event.info.code);
			
            switch (event.info.code)
            {
                case "NetConnection.Connect.Success":
	                trace("Congratulations! you're connected");
	                
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
                	//metaData.width = 400;
                	//metaData.height = 200;
                	//nsPublish.send("@setDataFrame", "onMetaData", metaData);
				//	publishLiveStream();
	                break;
					
	            case "NetStream.Publish.BadName":
	                trace("The stream name is already used");
	                break;
				case "NetStream.Play.Start":	
					 trace("netStatusPublishHandler - we start reading ");
					 initRecvStream(null);
	                 break;
	        }
        }
        

		
		/*
		 * 
		 * 
		 * */
		
		
		
       	private function activityHandler(event:ActivityEvent):void {
		    trace("activityHandler: " + event);
		    trace("activating: " + event.activating);
	    } 
        
		/*
		 *  Create a live stream, attach the camera and microphone, and
		 *  publish it to the local server
		 */
        private function publishLiveStream():void {
 
			var metaData:Object = new Object();
            metaData.copyright = "WowWee Canada - SwitchBot";
            nsPublish.send("@setDataFrame", "onMetaData", metaData);

	    }  
				
		/*
		 * 
		 * */
		
		private function readLiveStream():void {
			
			
			
		//	var mediaPlayerSprite:MediaPlayerSprite = new MediaPlayerSprite();
		//	var videoElement:VideoElement = new VideoElement();

		//	videoElementRead.resource = new StreamingURLResource("rtmp://dL6fny.cloud.influxis.com/Telepresence1/_definst_/megamip01", StreamType.LIVE);
		
		/*	mediaPlayerSprite.media = videoElement;
			mediaPlayerSprite.width = 640; 
            mediaPlayerSprite.height = 360; 
			addChild(mediaPlayerSprite);
			*/
			
		   videoRead.attachNetStream(nsRead);
		    nsRead.play("media");
			
			mState = CONNECTED;
			
			//removeChild(txtMessage);
			//addChild(videoRead);
		 }
			
		 
		 /*
	 * 
	 * 
	 * */	

	
			
		/*
		 * 
		 * */	
		private function getCamera():Camera {
			
			
			var returnValue:Camera;
		
			
			 for (var i:int = 0; i < 2; i++ ) {
				var cam:Camera = Camera.getCamera(String(i));
				if (cam.position == CameraPosition.FRONT) {
					returnValue = cam;	
				}
			}	
			
		
	//	returnValue = Camera.getCamera();	
		return returnValue;
		}
		
		private function initListeners():void {
			
			
		   btnConnect.addEventListener(MouseEvent.CLICK, initConnection);
	      // btnRead.addEventListener(MouseEvent.CLICK, initRecvStream);
		  
		   btnExit.addEventListener(MouseEvent.CLICK, deactivate);	
		   
		   btnForward.addEventListener(MouseEvent.CLICK, moveForward);
		   btnForward.addEventListener(MouseEvent.MOUSE_DOWN, function():void {
			   btnForward.setBackground(CustomButton.ButtonForwardSel);
			
			   } );
		   btnForward.addEventListener(MouseEvent.MOUSE_UP, function():void {
			   btnForward.setBackground(CustomButton.ButtonForward);
			
			   } );
		   btnForward.addEventListener(MouseEvent.MOUSE_OUT, function():void {
			   btnForward.setBackground(CustomButton.ButtonForward);
			
			   } );
			   
		 
		    btnBack.addEventListener(MouseEvent.CLICK, moveBackward);
		    btnBack.addEventListener(MouseEvent.MOUSE_DOWN, function():void {
			   btnBack.setBackground(CustomButton.ButtonBackwardSel);
		
			   } );
		    btnBack.addEventListener(MouseEvent.MOUSE_UP, function():void {
			   btnBack.setBackground(CustomButton.ButtonBackward);
			 
			   } );
		    btnBack.addEventListener(MouseEvent.MOUSE_OUT, function():void {
			   btnBack.setBackground(CustomButton.ButtonBackward);
		
			   } );
			   
		    btnLeft.addEventListener(MouseEvent.CLICK, moveLeft);
		    btnLeft.addEventListener(MouseEvent.MOUSE_DOWN, function():void {
			   btnLeft.setBackground(CustomButton.ButtonLeftSel);
		
			   } );
		    btnLeft.addEventListener(MouseEvent.MOUSE_UP, function():void {
			   btnLeft.setBackground(CustomButton.ButtonLeft);
			 
			   } );
		    btnLeft.addEventListener(MouseEvent.MOUSE_OUT, function():void {
			   btnLeft.setBackground(CustomButton.ButtonLeft);
			
			   } );
		   
		   
		   btnRight.addEventListener(MouseEvent.CLICK, moveRight);
		   btnRight.addEventListener(MouseEvent.MOUSE_DOWN, function():void {
			   btnRight.setBackground(CustomButton.ButtonRightSel);
		
			   } );
		    btnRight.addEventListener(MouseEvent.MOUSE_UP, function():void {
			   btnRight.setBackground(CustomButton.ButtonRight);
			
			   } );
		    btnRight.addEventListener(MouseEvent.MOUSE_OUT, function():void {
			   btnRight.setBackground(CustomButton.ButtonRight);
		
			   } );
			   
			
		}
		//--------------- GUI initialisation 
		private function resizeListener (e:Event):void {
		
	/*	videoRead.width = stage.stageWidth;
		videoRead.height = stage.stageHeight;
		*/
		var newWidth:int = stage.stageWidth;
		var newHeight:int = stage.stageHeight;
        videoRead.width = newWidth;
		videoRead.height = newHeight;
	//	videoRead.height = newHeight;
	//	videoRead.scaleX = videoRead.scaleY;
		videoRead.x = 0; // videoRead.width;
		videoRead.y = videoRead.height;
	
        log("resize ... screen w: " + stage.stageWidth + " h: " + stage.stageHeight
   	    + " video w: " + videoRead.width + " h: " + videoRead.height);

		}
		private function initGui():void {
		
			this.stage.align = StageAlign.TOP_LEFT;
		//	stage.setOrientation( StageOrientation.ROTATED_LEFT);
		//	this.stage.setOrientation(StageOrientation.ROTATED_LEFT);    // stage rotation to portrait 
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			var baseUI:BaseUI = new BaseUI(stage);

		//	stage.addEventListener(Event.RESIZE, resizeListener);
			 txtMessage = new TextField();
			
	    //-------------- videos display 
		   
		   var container1:MediaContainer = new MediaContainer();
		 //  var container2:MediaContainer = new MediaContainer();
		   var player1:MediaPlayer = new MediaPlayer();
		   var player2:MediaPlayerSprite = new MediaPlayerSprite();

		 
		    videoElementPublish = new VideoElement();
			videoElementRead = new VideoElement();
	
	
		/*	videoPublish = new Video();
			videoPublish.scaleX = 0.5;
			videoPublish.scaleY = 0.5;
	      */
	
			videoRead = new Video();
		
		//	videoRead.smoothing = true;
	
		
		// video rotation 
		var mat:Matrix = new Matrix();
	

		mat.rotate(Math.PI );
		mat.rotate(Math.PI / 2 );
		mat.concat(videoRead.transform.matrix);
		videoRead.transform.matrix = mat;
           
			
	    // calculating ratio 
		var stageWidth:Number = stage.stageWidth;
		var stageHeight:Number = stage.stageHeight;
		
    //    videoRead.scaleX = 7.84;
	 //   videoRead.scaleY = 6.6;
	    videoRead.scaleX = stageHeight / videoRead.height;
		videoRead.scaleY = stageWidth / videoRead.width;
		videoRead.x = 0;
		videoRead.y = videoRead.height;
			
	   
		log("video  w/h " + videoRead.width + " " + videoRead.height);
		log("screen w/h " + stage.stageWidth + " " + stage.stageHeight);
		//	videoRead.x =  videoRead.width + 35;
		//	videoRead.y = 20;
	//	 videoRead.x =  0;
		// videoRead.y = videoRead.height;
			
		/*  var element3:ElementUI = baseUI.add(videoPublish); // positioning of the small screen 
		    element3.top = 30;
		    element3.right = 10;
		   */
		 //----------- displaying the DPad background
		   
		   ctnDPadBackground = new CustomButton(CustomButton.DPadBackground);
		   var dPadBkgDisplay:ElementUI = baseUI.add(ctnDPadBackground); // positioning of the small screen 
		   dPadBkgDisplay.bottom = 30;
		   dPadBkgDisplay.right = 10;
		   dPadBkgDisplay.refresh();
		
         //----------------------- displaying RC  buttons  
           
	
		 btnForward = new CustomButton(CustomButton.ButtonForward);
         btnBack = new CustomButton(CustomButton.ButtonBackward);
		 btnLeft = new CustomButton(CustomButton.ButtonLeft);
		 btnRight = new CustomButton(CustomButton.ButtonRight);

		 var ctnLeftRight:HBoxUI = new HBoxUI(this, 180, 56);
		 ctnLeftRight.backgroundColor = 0x251010;
		 ctnLeftRight.backgroundAlpha = 0;
		 ctnLeftRight.addChild(btnLeft);
		 ctnLeftRight.addChild(btnRight);
		 ctnLeftRight.childrenGap = new GapUI(40, 0);
		 
		 var ctnForward:VBoxUI = new VBoxUI(this, 180, 56);
		 ctnForward.backgroundColor = 0x251010;
		 ctnForward.backgroundAlpha = 0;
		 ctnForward.addChild(btnForward);
		 ctnForward.childrenAlign = VBoxUI.ALIGN_TOP_CENTER;
		
         var ctnPrincipalRC:VBoxUI = new VBoxUI(this, 190, 300);
         ctnPrincipalRC.backgroundColor = 0xFF0000;
         ctnPrincipalRC.backgroundAlpha = 0;
		 ctnPrincipalRC.childrenPadding = new PaddingUI(18, 2, 2, 2);
		 ctnPrincipalRC.childrenAlign = VBoxUI.ALIGN_BOTTOM_CENTER;
		 ctnPrincipalRC.addChild(btnBack);
		 ctnPrincipalRC.addChild(ctnLeftRight);
		 ctnPrincipalRC.addChild(ctnForward);
		 var vboxContainerRight:ElementUI = baseUI.add(ctnPrincipalRC);
		 vboxContainerRight.bottom = 37;
		 vboxContainerRight.right = 15;
		 vboxContainerRight.refresh();
		 
		 //----------- Displaying the connect button 
		 
		 btnConnect = new CustomButton(CustomButton.ButtonConnect);
	     var ctnBtnConnect:ElementUI = baseUI.add(btnConnect); 
	     ctnBtnConnect.bottom = 30;
	     ctnBtnConnect.left = 10;
	     ctnBtnConnect.refresh();
		 
	     btnExit = new CustomButton(CustomButton.ButtonExit);
	     var ctnBtnExit:ElementUI = baseUI.add(btnExit); 
	     ctnBtnExit.bottom = 30;
	     ctnBtnExit.left = 75;
	     ctnBtnExit.refresh();
         
		 var txtFormat:TextFormat = new TextFormat();
		
		 txtFormat.leftMargin = 5;
			
		//	txtMessage.type = TextFieldType.INPUT;
		   
		 txtMessage.width = 300;
		 txtMessage.height = 100;
		 txtMessage.multiline = true;
		 txtMessage.background = true;
			
		//	txtFormat.font = "Verdana";
            txtMessage.defaultTextFormat = txtFormat;
			txtMessage.backgroundColor = 0x99D9EA;

			var ctnTxtMessage:ElementUI = baseUI.add(txtMessage);
			ctnTxtMessage.bottom = 100;
			ctnTxtMessage.left = 20;
			ctnTxtMessage.refresh();

		 //--------------------------------------------------------------
		 	
		  	
          addChild(txtMessage);
		  addChild(videoRead); 
	      addChild(container1);
       //   addChild(container2);
		  addChild(ctnDPadBackground);
		  addChild(ctnPrincipalRC);
		  addChild(btnConnect);
		  addChild(btnExit);

	
		}
		

		
		//------------------------ LightStreamer communication methods ( remote control )
	
		public function p2pReceiveData(str:String):void{

		   // we use str !!

		}

		private function lsSendData(str:String):void{
			
			 sbUserLSClient.sendMessage(str);
		}
		
		
		
		//-------------  RC commands 
		private function moveForward(evt:MouseEvent):void {
			
			 logDebug("move forward");
		    lsSendData(Constants.CMD_DRIVE_FORWARD + ":/");
		
		}
	
		private function moveBackward(evt:MouseEvent):void {
			
		    logDebug("move backward");
	    //    trace(urlRequestMB.url + " " + counter);
		   	lsSendData(Constants.CMD_DRIVE_BACKWARD + ":/"+ speed + "/5");
			  
		}
		private function moveLeft(evt:MouseEvent):void {
		
	        logDebug("turn left");
		   	lsSendData(Constants.CMD_TURN_LEFT + ":/" + speed + "/5");
		}
		private function moveRight(evt:MouseEvent):void {

		  logDebug("turn right");
		  lsSendData(Constants.CMD_TURN_RIGHT + ":/" + speed + "/5");
		}
		
		
		private function deactivate(e:Event):void 
		{
			// make sure the app behaves well (or exits) when in background
			logDebug("deactivate() -- exiting TelepresenceUser...");

			disconnect();

		//	NativeApplication.nativeApplication.exit();
		}
		
		private function disconnect():void 
		{
		
				// notify TelepresenceMegamip instance that we're quitting 
			if (sbUserLSClient != null) {
					lsSendData(Constants.CMD_CLOSE);
				}
			var t1:Timer = new Timer(600);
			t1.addEventListener(TimerEvent.TIMER, function():void {
				
			if (nsPublish != null) {
				nsPublish.removeEventListener(NetStatusEvent.NET_STATUS, netStatusPublishHandler);
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
			
			} );
			t1.start();	
			
		

		
			
			
		
		}
	}
	
	
	
}


class CustomClient {
		public function onMetaData(info:Object):void {
			trace("width: " + info.width);
			trace("height: " + info.height);
		}
		public function startTransmit($p1:*,$p2:*):void{
           trace("startTransmit TelepresenceUser...");
        }

       public function stopTransmit():void{
          trace("stopTransmit TelepresenceUser...");
      }
		
}