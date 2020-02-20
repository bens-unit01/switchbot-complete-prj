package  
{
	/**
	 * ...
	 * @author bens
	 */
    import com.lightstreamer.as_client.item_renderers.HighlightCellItemRenderer;
    import com.lightstreamer.as_client.events.NonVisualItemUpdateEvent;
    import com.lightstreamer.as_client.events.UnsubscriptionEvent;
    import com.lightstreamer.as_client.events.LostUpdatesEvent;
    import com.lightstreamer.as_client.events.EndOfSnapshotEvent;
    import com.lightstreamer.as_client.events.ServerErrorEvent;
    import com.lightstreamer.as_client.events.SubscriptionErrorEvent;
    import com.lightstreamer.as_client.events.SendMessageErrorEvent;
    import com.lightstreamer.as_client.events.ConnectionDropEvent;
    import com.lightstreamer.as_client.events.ControlConnectionErrorEvent;
    import com.lightstreamer.as_client.events.StatusChangeEvent;
    import com.lightstreamer.as_client.LSClient;
    import com.lightstreamer.as_client.ConnectionInfo;
    import com.lightstreamer.as_client.ConnectionPolicy;
	import com.lightstreamer.as_client.Message;
    import com.lightstreamer.as_client.VisualTable;
    import com.lightstreamer.as_client.NonVisualTable;
	import flash.events.Event;
	import flash.events.EventDispatcher;
      
    import com.lightstreamer.as_client.logger.Logger;
    import com.lightstreamer.as_client.logger.RemoteAppender;

    import mx.events.CollectionEventKind;
    import mx.events.PropertyChangeEvent;
    import mx.events.CollectionEvent;

	
	public class MegamipLSClient extends EventDispatcher
	{
		
		   // Address of Lightstreamer Server
    public const HOST:String = "ec2-107-22-46-148.compute-1.amazonaws.com"; 
    public const PORT:uint = 8080;
    public const PROTOCOL:String = "http";
	public const ADAPTER_SET:String = "TP02";
	public static var CONNECTED:String = 'modelWasUpdated';
	public static var UPDATE:String = 'MessageReceived'; 
	public static var FAILED:String = 'ConnectionFailed'; 
	public static var NB_ATTEMPTS:int =   3;

	
    
  
    
    //update of this table will be reported to the TextArea with custom code
    public var nonVisualTable:NonVisualTable;
    
    //the LSClient object connects to Lightstreamer Server
    private var client:LSClient;
    private var columns:Array;
    private var items:Array = new Array("chat_room");
    private var fields:Array = new Array("timestamp", "IP", "nick", "message");
	private var lines:uint = 0;
	private var message:String;
	private var attemptsCounter:int = NB_ATTEMPTS;
		
		public function MegamipLSClient() 
		{
			
		init();	
			
		}
		
	  public function init():void {
      client = new LSClient();
	  
      //client.setMaxBandwidth(5);
      
      //add the event listeners for LSClient events. The listener set on this demo
      //are empty functions
      client.addEventListener(StatusChangeEvent.STATUS_CHANGE,onStatusChange);
      client.addEventListener(ServerErrorEvent.SERVER_ERROR,onServerError);
      client.addEventListener(ConnectionDropEvent.CONNECTION_DROP,onConnectionDrop);
      client.addEventListener(ControlConnectionErrorEvent.CONTROL_CONNECTION_ERROR,onControlConnectionError);
      client.addEventListener(SendMessageErrorEvent.SEND_MESSAGE_ERROR,onSendMessageError);
      
      //the ConnectionInfo object represents the information needed to connect 
      //to Lightstreamer Server
      var cInfo:ConnectionInfo = new ConnectionInfo();
      cInfo.server = HOST;
      cInfo.adapterSet = ADAPTER_SET;
      cInfo.controlPort = PORT;
      cInfo.port = PORT;
      cInfo.controlProtocol = PROTOCOL;
      cInfo.protocol = PROTOCOL;
      cInfo.user = Constants.LS_USER;
      //cInfo.password = "";
      
      //the ConnectionInfo object represents the policy in use to interact with 
      //Lightstreamer Server              
      var cPolicy:ConnectionPolicy = new ConnectionPolicy();
	  
      //cPolicy.idleTimeout = 30000;
      //cPolicy.keepaliveInterval = 0;
      //cPolicy.pollingInterval = 500;
      //cPolicy.timeoutForStalled = 2000;
      //cPolicy.timeoutForReconnect = 15000;
      
      //Connect to Lightstreamer Server
      try {
       // client.openConnection(cInfo,cPolicy);
        client.openConnection(cInfo, cPolicy);
	//	clientSend.openConnection(cInfo,cPolicy);
      } catch(e:Error) {
       trace("MegamipLSClient#init - block catch - message: "+e.message);
      }
      
    //  var remoteListener:RemoteAppender = new RemoteAppender(Logger.WARN,client);
    //  Logger.getLogger("com.lightstreamer.as_client.LSClient.timeouts").addLoggerListener(remoteListener);
      
      tableSubscriptions();   
    
    }
    
   
    
    public function tableSubscriptions():void {
    
      
      nonVisualTable = new NonVisualTable(items,fields,"DISTINCT");
      nonVisualTable.dataAdapter = "TELEPRESENCE02";
      nonVisualTable.snapshotRequired = true;
      //nonVisualTable.setItemRange(2,3);
      //nonVisualTable.requestedBufferSize = 1;
      //nonVisualTable.requestedMaxFrequency = 0.5;
      //nonVisualTable.selector = "ipse...";
      nonVisualTable.addEventListener(SubscriptionErrorEvent.SUBSCRIPTION_ERROR,onSubscriptionError);
      nonVisualTable.addEventListener(EndOfSnapshotEvent.END_OF_SNAPSHOT,onEOS);
      nonVisualTable.addEventListener(LostUpdatesEvent.LOST_UPDATES,onLost);
      nonVisualTable.addEventListener(UnsubscriptionEvent.UNSUBSCRIPTION,onUnsub);
      nonVisualTable.addEventListener(NonVisualItemUpdateEvent.NON_VISUAL_ITEM_UPDATE,onChange);
      //subscribe the table
      client.subscribeTable(nonVisualTable);
    
    }
    
	private function logDebug(output:String):void {
	 Main.logDebug(output);
	}
  
    ////////////////////LSClient event handlers
    public function onStatusChange(e:StatusChangeEvent):void {
      if (e.status == LSClient.DISCONNECTED) {
        logDebug("Disconnected from Push Server attemps: " + attemptsCounter);
		attemptsCounter--;
		if ( attemptsCounter == 0 ) {
		// notify that the connection failed
		  attemptsCounter = NB_ATTEMPTS;
		  dispatchEvent(new Event(MegamipLSClient.FAILED));
		}
      } else if (e.status == LSClient.CONNECTING) {
        logDebug("Trying to connect to Push Server...");
      } else if (e.status == LSClient.POLLING) {
         logDebug( "Connected to Push Server (Smart polling)");
      } else if (e.status == LSClient.STREAMING) {
		  dispatchEvent(new Event(MegamipLSClient.CONNECTED));
         logDebug("Connected to Push Server (Streaming)");
      } else if (e.status == LSClient.STALLED) {
        logDebug("Connection to Push Server stalled");
      }
	   logDebug("onStatusChange status: " + e.status);
		
    }
    
    public function onControlConnectionError(evt:ControlConnectionErrorEvent):void {
		logDebug("onControlConnectionError");
    }
    
    public function onConnectionDrop(evt:ConnectionDropEvent):void {
		logDebug("onConnectionDrop");
    }
    
    public function onServerError(evt:ServerErrorEvent):void {
			logDebug("onServerError");
    }
    
    ///////////////////Table event handlers (common)
    
    public function onSubscriptionError(evt:SubscriptionErrorEvent):void {
		logDebug("onSubscriptionError");
    }
    
    public function onEOS(evt:EndOfSnapshotEvent):void {
		logDebug("onEOS ");
    }
    
    public function onLost(evt:LostUpdatesEvent):void {
		logDebug("onLost");
    }
    
    public function onUnsub(evt:UnsubscriptionEvent):void {
		logDebug("onUnsub");
    }
    
    public function onSendMessageError(evt:SendMessageErrorEvent):void {
			logDebug("onSendMessageError");
	}
    
    
    ///////////////////VisualTable event handlers
    
    //calculates the custom field (last+spread 5%)
    public function onCollChange(evt:CollectionEvent):void {
    /*  var i:*;
      if (evt.kind == CollectionEventKind.UPDATE) { 
        for (i in evt.items) { 
          var pcevt:PropertyChangeEvent = evt.items[i] as PropertyChangeEvent;
          if (pcevt.property == "last_price") {
            pcevt.source["custom"] =  calculateSpread(pcevt.source["last_price"]);
          }
        }
    
      } else if (evt.kind == CollectionEventKind.ADD) { 
        for (i in evt.items) {
          evt.items[i]["custom"] =  calculateSpread(evt.items[i]["last_price"]);
        } 
      }*/
	  
	  logDebug("onCollChange");
    }
    //----
   
   
    
    
    ///////////////////NonVisualTable event handlers
    
 
    
    //puts the update infos in the TextArea widget
    public function onChange(evt:NonVisualItemUpdateEvent):void {
        var input:String = evt.getFieldValue("message")
		
		this.message = input;
		logDebug("onCollChange message: " + input);
		dispatchEvent(new Event(MegamipLSClient.UPDATE));
    }       
    
    //helper function
    public function extractFieldUpdate(evt:NonVisualItemUpdateEvent,field:*):String {
     /* if (evt.isFieldChanged(field)) {
        return "| field " + field + " changed: " + evt.getFieldValue(field);
      } else {
        return "";
      }*/
	  return "";
    }   
    
	public function sendMessage( msg:String):void {
		
	
		var message:String = msg;
		var sequence01:String = "sequ01";
		var objMessage:Message = new Message(message, sequence01, 1000);
		//client.sendMessage("CHAT|"+message);
		client.sendMessage(objMessage);
		
		 logDebug("sendMessage() - msg:"+msg);
		}
		
		
		
			public function getMessage():String {
		
			return this.message;
		}
		
	}
	
	
	
	
	//- observer desing pattern 
/*	
	public interface MegamipLSClientListener {
		
	 public function onNotify(evt:LsServerEvent);
		
	}
	
	public class LsServerEvent extends Event {
		
	}*/

}