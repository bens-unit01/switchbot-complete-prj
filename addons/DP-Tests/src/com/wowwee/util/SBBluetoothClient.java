package com.wowwee.util;

import java.text.DateFormat;
import java.util.ArrayList;
import java.util.Date;

import com.wowwee.util.UartService.LocalBinder;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.ServiceConnection;
import android.os.IBinder;
import android.support.v4.content.LocalBroadcastManager;
import android.util.Log;

public class SBBluetoothClient {

	public static final int REQUEST_SELECT_DEVICE = 1;
	public static final int REQUEST_ENABLE_BT = 2;
    public static final int UART_PROFILE_READY = 10;
    public static final int UART_PROFILE_CONNECTED = 20;
    public static final int UART_PROFILE_DISCONNECTED = 21;
    public static final int STATE_OFF = 10;
    private int mState = UART_PROFILE_DISCONNECTED;
    private BluetoothDevice mDevice = null;
	private UartService mService = null;
    private boolean isUsbDisconnected = false;
    private Context context = null;
    private ArrayList<SBBluetoothListener> listeners;
	private ServiceConnection mServiceConnection = new ServiceConnection() {
		public void onServiceConnected(ComponentName className,
				IBinder rawBinder) {
			mService = ((UartService.LocalBinder) rawBinder).getService();
			//Log.d(TAG, "onServiceConnected mService= " + mService);
			if (!mService.initialize()) {
				log( "Unable to initialize Bluetooth");
			//	finish();
			}

		}

		public void onServiceDisconnected(ComponentName classname) {
			// // mService.disconnect(mDevice);
			mService = null;
		}
	};
	
	 private final BroadcastReceiver UARTStatusChangeReceiver = new BroadcastReceiver() {

	        public void onReceive(Context context, Intent intent) {
	            String action = intent.getAction();

	            final Intent mIntent = intent;
	            byte[] data = null;
	            

	            
	            if (action.equals(UartService.ACTION_GATT_CONNECTED)) {

	                             mState = UART_PROFILE_CONNECTED;
	   
	            }
	           
	            if (action.equals(UartService.ACTION_GATT_DISCONNECTED)) {

	                             mState = UART_PROFILE_DISCONNECTED;
	                             mService.close();
	            }
	            
	          
	            if (action.equals(UartService.ACTION_GATT_SERVICES_DISCOVERED ) &&  mService != null)  {
	             	 mService.enableTXNotification();
	            }
	            
	            if (action.equals(UartService.ACTION_DATA_AVAILABLE)) {
	                data = intent.getByteArrayExtra(UartService.EXTRA_DATA);
	           
	             }
	           //*********************//
	            if (action.equals(UartService.DEVICE_DOES_NOT_SUPPORT_UART)){
	            	log("Device doesn't support UART. Disconnecting");
	            	mService.disconnect();
	            }
	            
	            for(SBBluetoothListener l: listeners){
	            	l.onNotify(action, data);
	            }
	            
	            
	        }






	    };
	// constructors  ----------------------------------------- 
	public SBBluetoothClient() {
		super();
	}
	public SBBluetoothClient(Context context) {
      super();
       this.context = context;
       listeners = new ArrayList<SBBluetoothListener>();
	   service_init();
	}	
	
    private void service_init() {
        Intent bindIntent = new Intent(context, UartService.class);
        context.bindService(bindIntent, mServiceConnection, Context.BIND_AUTO_CREATE);
  
        LocalBroadcastManager.getInstance(context).registerReceiver(UARTStatusChangeReceiver, makeGattUpdateIntentFilter());
    	
      }
    private static IntentFilter makeGattUpdateIntentFilter() {
        final IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction(UartService.ACTION_GATT_CONNECTED);
        intentFilter.addAction(UartService.ACTION_GATT_DISCONNECTED);
        intentFilter.addAction(UartService.ACTION_GATT_SERVICES_DISCOVERED);
        intentFilter.addAction(UartService.ACTION_DATA_AVAILABLE);
        intentFilter.addAction(UartService.DEVICE_DOES_NOT_SUPPORT_UART);
        return intentFilter;
    }
	private void log(String string) {
	   Log.d("SBBluetoothClient", string);	
	}
	

	
      public void connect(String deviceAddress){
    		mService.connect(deviceAddress);
      }	
      
      public void disconnect() {
    	 mService.disconnect(); 
      }
	    public void onBackPressed() {
	    	mService.disconnect();
	    	//btnConnect.setText("Connect");
	    	//finish();
	    }
	    
	    public int getState() {
			return mState;
		}

		public void writeRX(byte[] value){
	    	
	    	mService.writeRXCharacteristic(value);
	    }
	    
	    public void onResume() {
	        log("onResume");

	    }
	    
	    
	    public void onDestroy() {
	        log("onDestroy()");
	        
	        try {
	        	LocalBroadcastManager.getInstance(context).unregisterReceiver(UARTStatusChangeReceiver);
	        } catch (Exception ignore) {
	            log( ignore.toString());
	        } 
	        context.unbindService(mServiceConnection);
	        mService.stopSelf();
	        mService= null;
	       
	    }
	    
	    public interface SBBluetoothListener {
	    	public void onNotify(String action, byte[] data);
	    }
	    
	    public void addSBBluetoothListener(SBBluetoothListener listener) {
	       listeners.add(listener);	
	    }
}