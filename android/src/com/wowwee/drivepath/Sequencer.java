package com.wowwee.drivepath;

import java.util.ArrayList;
import java.util.LinkedList;

import com.wowwee.switchbot.SBRealDevice;
import com.wowwee.switchbot.SBRealDeviceFactory;
import com.wowwee.util.SBProtocol;

import android.content.Context;
import android.util.Log;

public class Sequencer {
	
	
	
    final static String TAG = "Sequencer";	
	private ArrayList<DPNode> path1To3;
	private ArrayList<DPNode> path3To1;
    private int pathIndex;	
    private ArrayList<DPNode> currentPath;
    private SBRealDevice mNordicBoard;
    
    private DPNode mNextBeacon;
    
    private int targetBeacon;
	private int startBeacon;
	private DPAlgorithmBFS algo;
	private LinkedList<Integer> path;
	private Context context;
	
	
	public void setTargetBeacon(int targetBeacon) {
		this.targetBeacon = targetBeacon;
	}

	public void setStartBeacon(int startBeacon) {
		this.startBeacon = startBeacon;
	}

	public Sequencer(SBRealDevice nordicBoard){
	    this();
		mNordicBoard = nordicBoard; 
		

	}
	
	public boolean isStartEqualTarget(){
		return targetBeacon == startBeacon;
	}
	
	public Sequencer(){
		path = new LinkedList<Integer>();
		pathIndex = 0;
	}
	public Sequencer(Context context){
		this();
		this.context = context;
	}
 
	public void setCurrentPath(int id){
		pathIndex = 0;
		if( id == 0){
			currentPath = path1To3;
		}else {
		   currentPath = path3To1; 	
		}
		
		// we clear eStop 
		byte data[] = {SBProtocol.CLEAR_ESTOP, 0, 0};
		 SBRealDeviceFactory.getInstance().writeRaw(data);
		
	}
	public void goToNextBeacon2() {
	    if(currentPath == null) return;// if we call this method before calling setCurrentPath()	
		if(pathIndex >= currentPath.size()){
			log("target reached ...");
			// we set eStop 
  		 try {
			Thread.sleep(200);
		   } catch (InterruptedException e) {
			e.printStackTrace();
	       }
			byte data[] = {SBProtocol.ESTOP, 0, 0};
			 SBRealDeviceFactory.getInstance().writeRaw(data);
			
			return;
		}
		
		mNextBeacon = currentPath.get(pathIndex);
		log( "go to beacon " + mNextBeacon );
	    goToBeacon(mNextBeacon);
		pathIndex++;
	}

	private void goToBeacon(DPNode nextBeacon) {
		byte data[] = {SBProtocol.DP_STOP, 0, 0};
		 SBRealDeviceFactory.getInstance().writeRaw(data);
		 
		 try {
			Thread.sleep(2000);
		} catch (InterruptedException e) {
			e.printStackTrace();
		} 
		 data[0] = SBProtocol.DP_GOTO_BEACON;
		 data[1] = (byte) nextBeacon.id;
		 data[2] = 0;
		 SBRealDeviceFactory.getInstance().writeRaw(data);	
		
	}
   public void goToNextBeacon(){
	   
	   try{
		if(pathIndex >= path.size()){
			log("target reached ...");
			// we set eStop 
			byte data[] = {SBProtocol.NOTF_DP_TARGET_REACHED, 0, 0};
			try {
				
			 SBRealDeviceFactory.getInstance().writeRaw(data);
			 data[0] = SBProtocol.ESTOP;
				Thread.sleep(20);
		/*	 SBRealDevice.getInstance(context).writeRaw(data);
			    Thread.sleep(1000);
			 SBRealDevice.getInstance(context).writeRaw(data);
			    Thread.sleep(1000);*/
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
			
		//	 SBRealDevice.getInstance(context).writeRaw(data);
			return;
		}
		
	   }catch(NullPointerException ex){
		   ex.printStackTrace();
	   } 
		
	    
		try {
			byte data[] = { SBProtocol.DP_STOP, 0, 0 };
			//SBRealDevice.getInstance(context).writeRaw(data);
//			Thread.sleep(2000);
			data[0] = SBProtocol.DP_GOTO_BEACON;
			data[1] = (byte) ((int)path.get(pathIndex));
			data[2] = 0;
			SBRealDeviceFactory.getInstance().writeRaw(data);
        		log( "Sequencer#goToNextBeacon index: " + pathIndex + " beacon id: " + data[1]);
			pathIndex++;
		} catch (NullPointerException e) {
			e.printStackTrace();
		}
	   
   }
	public void start(final DPMap map) {
		
	//	new Thread(new Runnable() {
			
	//		@Override
	//		public void run() {
				

		DPNode start = new DPNode(0, 0, startBeacon);
		DPNode target = new DPNode(0, 0, targetBeacon);

		algo = new DPAlgorithmBFS();
	  	path = algo.getPath(start, target, map);  // call to the DrivePath algo 
	    
	  	if(null == path){
	  	log( "Sequencer#start  no results ...");
	  	return;
	  	}
	  	
	  	pathIndex = 0;
	  	if(path.size() > 0){
	  		
   		 try {
     	
   	     byte data[] = {SBProtocol.CLEAR_ESTOP, 0, 0};
 		 Thread.sleep(20);
//   		 SBRealDevice.getInstance(context).writeRaw(data);
// 		 Thread.sleep(200);
//   		 SBRealDevice.getInstance(context).writeRaw(data);
// 		 Thread.sleep(200);
//   		 SBRealDevice.getInstance(context).writeRaw(data);
// 		 Thread.sleep(200);
   		
   		 // we clear eStop  
 	/*	 data[0] = SBProtocol.DP_STOP;
 		 data[1] = 0; 
 		 data[2] = 0;
 		 SBRealDevice.getInstance(context).writeRaw(data);		  				 
 		 Thread.sleep(800);
 		*/ 
 		 // we go to the first beacon 		 
 		 data[0] = SBProtocol.DP_GOTO_BEACON;
   		 data[1] = (byte) ((int) path.get(pathIndex));
   		 data[2] = 0;
   		 SBRealDeviceFactory.getInstance().writeRaw(data);	
   		 log( " Sequencer#start : we drive to " + pathIndex); 
   		 pathIndex++;
   		 
   		} catch (InterruptedException e) {
   			e.printStackTrace();
   		} 
   		
     		
	  	}else{
	  		log( "Sequencer#start path.size == 0");
	  	}
	//		}
	//	}).start();
	
	}

	private void log(String string) {
		  Log.d("DP", "[Sequencer]: " +string);	
		}

}
