package com.wowwee.switchbot;

import java.util.ArrayList;

import android.content.Context;
import android.util.Log;

import com.google.gson.Gson;
import com.wowwee.drivepath.DPLine;
import com.wowwee.drivepath.DPMap;
import com.wowwee.drivepath.DPNode;
import com.wowwee.drivepath.SBCommHandler;
import com.wowwee.util.SBProtocol;
import com.wowwee.util.Utils;

public class SBRealDeviceCommon implements SBRobot {
	
	protected Context mContext; 
	protected SBCommHandler mCommHandler;
	
	
	protected SBRealDeviceCommon(Context mContext) {
		super();
		this.mContext = mContext;
	}

	@Override
	public void addRobotListener(RobotListener robotListener) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void removeListeners() {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void write(byte[] data) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void writeRaw(byte[] data) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void disconnect(DeviceType deviceType) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public boolean isDeviceConnected(Context context, DeviceType deviceType) {
		// TODO Auto-generated method stub
		return false;
	}

	@Override
	public boolean isAllUsbConnected(Context context) {
		// TODO Auto-generated method stub
		return false;
	}

	@Override
	public ArrayList<DPNode> getBeaconsLabels() {
			
		String FILENAME = "/data/data/" + mContext.getPackageName()
				+ "/json_data";
		   Utils utils = new Utils();
	       String jsonMap = utils.readData(FILENAME);
	   	   Gson gson = new Gson();
	       DPMap map = gson.fromJson(jsonMap, DPMap.class);
	   	   ArrayList<DPNode> nodesList = new ArrayList<DPNode>();
	       if (null != map){
	    	  // log("SBCommHandler map: " + result);
	           ArrayList<DPLine> lines = map.getLines(); 
	           for(DPLine line: lines){
	        	   if(line.startPoint.label != null){
	        		  if(!line.startPoint.label.equals("")){
	        			  if(!nodesList.contains(new DPNode(0, 0, line.startPoint.id))){
	        				 DPNode node = new DPNode(0, 0, line.startPoint.id);
                             node.label = line.startPoint.label;
		                     nodesList.add(node);
	        			  }
	        		  } 
	        	   }
	        	   
	        	   if(line.endPoint.label != null){
		        		  if(!line.endPoint.label.equals("")){
		        			  if(!nodesList.contains(new DPNode(0, 0, line.endPoint.id))){
		        				 DPNode node = new DPNode(0, 0, line.endPoint.id);
                                 node.label = line.endPoint.label;
			                     nodesList.add(node);
		        			  }
		        		  } 
		        	   }
	           }
	           
	           return nodesList;
	       
	       } else {
	    		//map =  new DPMap();
	    		return null;
	    	}		

	}



	@Override
	public void driveTo(int beaconId) {
		
 	   Log.d("DP", "SBQ410Device#driveTo beaconId: " + beaconId);
	   String cmd = SBProtocol.JETTY_DRIVETO_BEACON + SBProtocol.JETTY_SPLIT_CHAR + beaconId;
	   mCommHandler.handle(cmd);

	}

	@Override
	public void setCommHandler(SBCommHandler mCommHandler) {
		this.mCommHandler = mCommHandler;
		
	}

}
