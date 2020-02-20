package com.wowwee.switchbot;

import java.util.ArrayList;
import java.util.Iterator;

import com.wowwee.drivepath.DPNode;
import com.wowwee.drivepath.SBCommHandler;
import com.wowwee.util.SBProtocol;
import com.wowwee.util.Utils;

import android.content.Context;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;

public class SBVirtualDevice implements SBRobot {

	private ArrayList<RobotListener> mListeListeners = new ArrayList<RobotListener>();
	private final String TAG = "SwitchBot";
	private ArrayList<DPNode> labels;
	
	
	
    
	public SBVirtualDevice(Button button) {
		super();

		labels = new ArrayList<DPNode>();
		DPNode node1 = new DPNode(0, 0, 1);
		node1.label ="kitchen";
		DPNode node2 = new DPNode(0, 0, 2);
		node2.label = "Office";
	    DPNode node3 = new DPNode(0, 0, 3);
	    node3.label = "Front Door";

/*		labels = new ArrayList<Node>();
		Node node1 = new Node(1, 0);
		node1.setLabel("Kitchen");
		Node node2 = new Node(2, 0);
		node2.setLabel("Office");
	    Node node3 = new Node(3, 0);
	    node3.setLabel("Front Door");
	    */
	    
	    labels.add(node1);
	    labels.add(node2);
	    labels.add(node3);
	    
		button.setOnClickListener(new OnClickListener() {
		//byte[] dataIn = {SBProtocol.START_BYTE, SBProtocol.NOTF_VOICE_RECORD, SBProtocol.END_BYTE};	
		byte[] dataIn = { SBProtocol.NOTF_VOICE_RECORD, SBProtocol.END_BYTE};	
			@Override
			public void onClick(View v) {
				for ( RobotListener iterable : mListeListeners) {
					iterable.onNotify(new RobotEvent(this, dataIn));
				}
				
			}
		});
		
	}

	@Override
	public void addRobotListener(RobotListener usbListener) {
		mListeListeners.add(usbListener);
	}
/**
 * This method is used to send a data packet to the SwitchBot microcontroller 
 */
	@Override
	public void write(byte[] data) {

	
			Log.d(TAG, "SBVirtualDevice#write data:" + Utils.bytesToHex2(data));
		
	}
	
	@Override
	public void writeRaw(byte[] data) {
			Log.d(TAG, Utils.bytesToHex2(data)); 
	}
	
	//--------------------------------------------------------------------
	// the following methods  are not used for now in SwitchBot project 
	//---------------------------------------------------------------------
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
		
		return labels;
	}

	@Override
	public void driveTo(final int beaconId) {
		new Thread(new Runnable() {
			
			@Override
			public void run() {
			   try {
				Log.d(TAG, "driving to : " + beaconId);  
				Thread.sleep(3000);
				//byte[] dataIn = {SBProtocol.START_BYTE, SBProtocol.NOTF_DP_TARGET_REACHED, SBProtocol.END_BYTE};	
				byte[] dataIn = {SBProtocol.NOTF_DP_TARGET_REACHED, SBProtocol.END_BYTE};	
				
				for ( RobotListener iterable : mListeListeners) {
					iterable.onNotify(new RobotEvent(this, dataIn));
				}
			} catch (InterruptedException e) {
				e.printStackTrace();
			}	
				
			}
		}).start();
		
	}

	@Override
	public void removeListeners() {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void setCommHandler(SBCommHandler mCommHandler) {
		// TODO Auto-generated method stub
		
	}

}
