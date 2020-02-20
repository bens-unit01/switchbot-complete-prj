package com.wowwee.switchbot;

import android.content.Context;

public class SBRealDeviceFactory {
	
	
	static int SELECTED_DEVICE = 0; 

	
	public static final int SB_REAL_DEVICE        = 2;
	public static final int SB_Q410_BOARD         = 3;
 
	private static Context mContext; 
	
	public static void setSelectedDevice(int selectedDevice, Context context){
         	SELECTED_DEVICE = selectedDevice;
         	mContext = context; 
         	
	}
	
	public static SBRobot getInstance(){
		SBRobot selectedDevice = null; 
		
		if(SELECTED_DEVICE == SB_REAL_DEVICE ){
		  selectedDevice = SBRealDevice.getInstance(mContext); 	
		}
		
		if(SELECTED_DEVICE == SB_Q410_BOARD ){
			  selectedDevice = SBQ410Device.getInstance(mContext); 	
		}
				
		return selectedDevice; 
	}

}
