package com.wowwee.drivepath;

import java.io.IOException;
import java.util.LinkedList;

import com.google.gson.Gson;
import com.wowwee.switchbot.SBRealDevice;
import com.wowwee.switchbot.SBRealDeviceFactory;
import com.wowwee.switchbot.SBRobot;
import com.wowwee.switchbot.SBRobot.RobotEvent;
import com.wowwee.switchbot.SBRobot.RobotListener;
import com.wowwee.telepresence.PushServer;
import com.wowwee.util.AdbUtils;
import com.wowwee.util.SBProtocol;
import com.wowwee.util.Utils;
import com.wowwee.websocket_server.CommHandler;
import com.wowwee.websocket_server.EventSocket;

import android.content.Context;
import android.util.Log;


public class SBCommHandler implements CommHandler{

	SBRealDevice mNordicsBoard;
	PushServer mLsClient;
	Context context;
	private Sequencer mSequencer;
	private String FILENAME;
	private DPMap map;
	
	
  	
	private SBCommHandler(SBRealDevice mNordicsBoard) {
		super();
		this.mNordicsBoard = mNordicsBoard;
		this.mNordicsBoard.addRobotListener(new SBUsbListener());
	 
	}
	public SBCommHandler(PushServer mLsClient, Context context){
	       this.mLsClient = mLsClient;
       this.context = context;
       //mSequencer = new Sequencer(mSwitchBotMcu);
       mSequencer = new Sequencer(context);
         
       // initialisation of the map for the DrivePath 
    	FILENAME = "/data/data/" + this.context.getPackageName() + "/json_data";
	   Utils utils = new Utils();
       String jsonMap = utils.readData(FILENAME);
   	   Gson gson = new Gson();
       DPMap result = gson.fromJson(jsonMap, DPMap.class);
   	   
       if (null != result){
    	   log("SBCommHandler map: " + result);
		    map = result;
    	} else {
    		map =  new DPMap();
    	}	
	}
	
	

	public SBCommHandler(SBRealDevice mSwitchBotMcu, PushServer mLsClient, Context context) {
       this(mSwitchBotMcu);

	}


    public void setRobotListener(){
      	
		SBRealDeviceFactory.getInstance().addRobotListener(new SBUsbListener());
    }


	@Override
	public void handle(String str) {
	  try{
		  log(" #handle str: " + str);
		  jettyHandler(str);	
	  }catch(NumberFormatException e)	{
		 e.printStackTrace(); 
	  }catch(ArrayIndexOutOfBoundsException e){
		 e.printStackTrace(); 
	  }
	   
	}
	
	
	public class SBUsbListener implements RobotListener {

		@Override
		public void onNotify(RobotEvent e) {
			
				
			 log("SBUsbListener#onNotify data: " + Utils.bytesToHex2(e.getData()));
			 try{
			 nordicHandler(e.getData());
			 }catch(ArrayIndexOutOfBoundsException ex){
				ex.printStackTrace(); 
			 }
			 
		}
		
	}
	
	protected void nordicHandler(final byte[] bs) {
		

		switch (bs[0]) {
		case SBProtocol.NOTF_GET_NEXT_BEACON:
	        log("SBCommHandler#nordicHandler - get to next ... " );
	        new Thread(new Runnable() {
				
				@Override
				public void run() {
					// we confirm the reception
//				  try {
//					Thread.sleep(30);
				  byte data[] = {SBProtocol.ACK_BYTE, 0x00, 0x00};
			   	  SBRealDeviceFactory.getInstance().writeRaw(data);
//					Thread.sleep(30);

//				} catch (InterruptedException e) {
//					e.printStackTrace();
//				} 
	                  
			   	  
			   	  mSequencer.goToNextBeacon(); 
					
				}
			}).start();
			break;
		case SBProtocol.NOTF_NORDIC_MB_TEST:
//	        log("Test Nordic --> Mediabox OK " );
	        log("log from nordic: " + bs[1]);
			break;

		case SBProtocol.NOTF_DP_CLOSEST_BEACON:

			try{  
				// we confirm the reception
                  byte data[] = {SBProtocol.ACK_BYTE, 0x00, 0x00};
			   	  SBRealDeviceFactory.getInstance().writeRaw(data);
				
			 log("SBCommHandler#nordicHandler closest beacon id: " + bs[1]);
			 mSequencer.setStartBeacon(bs[1]);
			 if(mSequencer.isStartEqualTarget()){ // target and closeset are the same 
				 data[0] = SBProtocol.DRIVE; 
				 data[1] = bs[1]; 
			   	  SBRealDeviceFactory.getInstance().writeRaw(data);
			 }else {  // normal case 
				  mSequencer.start(map);
			 }
			
			 
			}catch(ArrayIndexOutOfBoundsException ex){
				ex.printStackTrace();
			    log("SBCommHandler#nordicHandler requesting the closest beacon again ... " );
			    byte data[] = {SBProtocol.DP_GET_CLOSEST_BEACON, 0, 0}; // we ask again for the closest beacon
			    SBRealDeviceFactory.getInstance().writeRaw(data);
			}

			
			break;
		default:
			break;
		}
	}
	
	

private void jettyHandler(String params)
		throws ArrayIndexOutOfBoundsException, NumberFormatException {

	String[] input = params.split(SBProtocol.JETTY_SPLIT_CHAR);
    String cmd = input[0];

	// int turnTime = MipReceiver.TIME / 2;
	//mipUsbDeviceUno = MipUsbDevice.getInstance(context, DeviceType.UNO);

	// Log.d(TAG, "jettHandler cmd: " + input[1]);
	
	// --------- drive path handling 
   	
	if(cmd.equals(SBProtocol.JETTY_CHANGE_RANGE)){
	 	
	 int range = Integer.parseInt(input[1]) ;
	 log("change range  : " + range );
	 byte data[] = {SBProtocol.DP_CHANGE_RANGE, (byte)range, 0};
	 SBRealDeviceFactory.getInstance().writeRaw(data);
	}
	
	
	if(cmd.equals(SBProtocol.JETTY_GET_STATUS)){
		log("get status request ...");
		//byte status = 0x07;
		//send(SBProtocol.JETTY_SET_STATUS + SBProtocol.JETTY_SPLIT_CHAR + status);
		handleGetStatus();
	}
	if(cmd.equals(SBProtocol.JETTY_GOTO_BEACON)){
	 int beaconId  = Integer.parseInt(input[1]) ;
	 log("drivepath go : " + beaconId );
	 byte data[] = {SBProtocol.DP_GOTO_BEACON, (byte)beaconId, 0};
	 SBRealDeviceFactory.getInstance().writeRaw(data);
	}
	
	if(cmd.equals(SBProtocol.JETTY_DISCONNECT_BEACON)){
	  log("drivepath disconnect "); 	
	 byte data[] = {SBProtocol.DP_STOP, 0, 0};
	 SBRealDeviceFactory.getInstance().writeRaw(data);
	}
	
	if(cmd.equals(SBProtocol.JETTY_CLR_ESTOP)){
		 log("clear eStop ");
		 byte data[] = {SBProtocol.CLEAR_ESTOP, 0, 0};
		 SBRealDeviceFactory.getInstance().writeRaw(data);
	}
	
	if(cmd.equals(SBProtocol.JETTY_SET_ESTOP)){
		 log("set eStop ");
		 byte data[] = {SBProtocol.ESTOP, 0, 0};  
		 SBRealDeviceFactory.getInstance().writeRaw(data);
	  }
	
	if(cmd.equals(SBProtocol.JETTY_DRIVEPATH_INIT)){
	 log("\ndrivepath init config: " + input[1]);
	 // data decoding
	 log("\ndecoding:");
	// Gson gson = new Gson();
	 //DPMap l = gson.fromJson(input[2], DPMap.class); 
	 //LinkedList<Node> nodes = l.getNodes();
	 
	// log("current: " + l.getCurrent());
	 //for(Node element: nodes){
	  //  log(" id: " + element.getId() + " weight: " + element.getWeight()); 
	// }
	}
	
	
	if(cmd.equals(SBProtocol.JETTY_DRIVETO_BEACON)){
        int targetBeaconId  = Integer.parseInt(input[1]);
        mSequencer.setTargetBeacon(targetBeaconId);
        new Thread(new Runnable() {
			
			@Override
			public void run() {
			byte data[] = {SBProtocol.CLEAR_ESTOP, 0, 0}; // request to get the closest beacon id 
		    try {
			SBRealDeviceFactory.getInstance().writeRaw(data);
		    Thread.sleep(200);
			SBRealDeviceFactory.getInstance().writeRaw(data);
		    Thread.sleep(200);
			} catch (InterruptedException e) {
				e.printStackTrace();
			}	
		    data[0] =  SBProtocol.DP_GET_CLOSEST_BEACON; 
		    data[1] = 0;
		    data[2] = 0;
			SBRealDeviceFactory.getInstance().writeRaw(data);
			}
		}).start();

		
	}
	if(cmd.equals(SBProtocol.JETTY_ACTIVATE_ADB)){
       log("activating adb ...");	
       try {
		AdbUtils.set(5555);
	} catch (IOException e) {
       log("catch: " + e.getMessage());	
		e.printStackTrace();
	} catch (InterruptedException e) {
       log("catch: " + e.getMessage());	
		e.printStackTrace();
	}
	}
	
	
	if(cmd.equals(SBProtocol.JETTY_NORDIC_MEDIABOX_TEST)){
		 log("request test : Nordic --> Mediabox  ");
		 byte data[] = {SBProtocol.DP_NORDIC_MB_TEST, 0, 0};
		 SBRealDeviceFactory.getInstance().writeRaw(data);	
	}
	
	
	if(cmd.equals(SBProtocol.JETTY_DRIVE)){
		 log("request drive  ");
		 if(input.length < 3) return;
		 byte fwd_bwd = Byte.parseByte(input[1]);
		 byte lft_rgt = Byte.parseByte(input[2]);
		 byte data[] = {SBProtocol.DRIVE, fwd_bwd, lft_rgt};
		 log("drive cmd: " + Utils.bytesToHex2(data)); 
		 SBRealDeviceFactory.getInstance().writeRaw(data);	
	}
	if(cmd.equals(SBProtocol.JETTY_KNEEL)){
		 log("request kneel");
		 byte data[] = {SBProtocol.KNEEL, 0, 0};
		 //mNordicsBoard.writeRaw(data);	
	}
	if(cmd.equals(SBProtocol.JETTY_STAND_UP)){
		 log("request standup");
		 byte data[] = {SBProtocol.STAND_UP, 0, 0}; 
		 //mNordicsBoard.writeRaw(data);	

	}
	if(cmd.equals(SBProtocol.JETTY_LEAN_FORWARD)){
		 log("request lean forward ");
		 byte data[] = {SBProtocol.LEAN_FORWARD, 0, 0};
	}
	if(cmd.equals(SBProtocol.JETTY_LEAN_BACKWARD)){
		 log("request lean backward ");
		 byte data[] = {SBProtocol.LEAN_BACKWARD, 0, 0};
	}
	
	
	if(cmd.equals(SBProtocol.JETTY_SAVE_DATA)){
		log("save data " + input[1]);
		String jsonString = input[1];
		saveData(jsonString);
	 	
		// updating the DrivePath map
		Gson gson = new Gson();
	    DPMap result = gson.fromJson(jsonString, DPMap.class);
	   	 if (null != result){
	    	   log("SBCommHandler map: " + result);
			    map = result;
	    	} else {
	    		map =  new DPMap();
	      }
		
	}
}

private void saveData(final String data){
	new Thread(new Runnable() {
		
		@Override
		public void run() {
		        log("saving map : " + data);
		        Utils utils = new Utils();
		        utils.saveData(FILENAME, data);
		}
	}).start();
	
}
private void log(String string) {
  Log.d("DP", "[SBCommHandler]: " +string);	
}


	private void send(String str) {
		try {
			EventSocket.getCurrentSession().getRemote().sendString(str);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	private void handleGetStatus() {
		byte status = 0x00; //everything disconnected  
		if (SBRealDevice.isConnected(context)) {
			status = 0x01;  // usb connected 
		}
		if (Utils.isWifiConnected()) {
			status = (byte) (status | 0x02); // wifi connected
			// if the wifi is disconnected, the companion app will not receive any response
		}
		if (mLsClient.isConnected()) {
			status = (byte) (status | 0x04); // telepresence connected
		}

		send(SBProtocol.JETTY_SET_STATUS + SBProtocol.JETTY_SPLIT_CHAR + status);
	}

}
