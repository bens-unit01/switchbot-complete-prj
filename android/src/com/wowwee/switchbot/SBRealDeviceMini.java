package com.wowwee.switchbot;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import com.hoho.android.usbserial.driver.UsbSerialDriver;
import com.hoho.android.usbserial.driver.UsbSerialProber;
import com.hoho.android.usbserial.util.SerialInputOutputManager;
import com.wowwee.drivepath.DPNode;
import com.wowwee.drivepath.SBCommHandler;
import com.wowwee.util.SBProtocol;
import com.wowwee.util.Utils;

import android.content.Context;
import android.hardware.usb.UsbDevice;
import android.hardware.usb.UsbManager;
import android.util.Log;

public class SBRealDeviceMini implements SBRobot {

	// final String TAG = getClass().getSimpleName();
	static final String TAG = "SwitchBot";
//    <usb-device vendor-id="9025" />
	public static final int ARDUINO_PRODUCT_ID = 24577; // 0x6001
	private final ExecutorService mExecutor = Executors
			.newSingleThreadExecutor();
	private Context mContext;
	private UsbManager mUsbManager;
	private UsbSerialDriver mUsbDriver;
	private SerialInputOutputManager mSerialIoManager;
	private static ArrayList<RobotListener> mListeListeners = new ArrayList<RobotListener>();
	private static SBRealDeviceMini mUsbDevice;
	public static final int MIN_SIZE = 3;
	private boolean eStopFlag = true;
	private boolean isListening = false;	
	
	private final SerialInputOutputManager.Listener mListener = new SerialInputOutputManager.Listener() {

		@Override
		public void onRunError(Exception e) {
			Log.d(TAG, "UsbDevice onRunError " + e.getMessage());
		}

		@Override
		public void onNewData(final byte[] data) {
			
			
          Log.d(TAG, " SBRealDeviceMini#onNewData data: " + Utils.bytesToHex2(data));

          if(data[0] == 0x50){
          if(isListening) return;  
        	synchronized (this) {
			isListening = true;
		   }
          }
		   
		   
	   //   byte[] out = {SBProtocol.START_BYTE, data[0], SBProtocol.END_BYTE};	
			for (RobotListener b : mListeListeners) {
				b.onNotify(new RobotEvent(this, data));
			}
			
          if(data[0] == 0x50){
			new Thread(new Runnable() {

				@Override
				public void run() {
					try {
						Thread.sleep(2000);
					} catch (InterruptedException e) {
						e.printStackTrace();
					}
					synchronized (this) {
						isListening = false;
					}

				}
			}).start();
			
          }		

		}

	};
	
	/**
	 * This method is used to get an instance of the SBRealDevice according
	 * to the singleton design pattern. This instance represent the FTDI board 
	 * connected to the nordic board pca10001
	 * @param context : the calling activity context
	 * @return
	 */

	public static SBRealDeviceMini getInstance(Context context) {

		if (mUsbDevice != null) {
			return mUsbDevice;
		} else {

			mUsbDevice = new SBRealDeviceMini(context);
			return mUsbDevice;
		}

	}
	
	
    /**
     * private constructor 
     * @param context : the activity context
     */
	private SBRealDeviceMini(Context context ) {
		super();
		mContext = context;
		mUsbManager = (UsbManager) context
				.getSystemService(Context.USB_SERVICE);

		HashMap<String, UsbDevice> deviceList = mUsbManager.getDeviceList();
		UsbDevice usbDevice = null;
		for (UsbDevice element : deviceList.values()) {

			if (ARDUINO_PRODUCT_ID == element.getProductId()) {

						usbDevice = element;
					
			}
		}

		try {
			mUsbDriver = UsbSerialProber.acquire(mUsbManager, usbDevice);
			mUsbDriver.open();
			int baudrate = 115200;
			mUsbDriver.setParameters(baudrate, UsbSerialDriver.DATABITS_8,
					UsbSerialDriver.STOPBITS_1, UsbSerialDriver.PARITY_NONE);
			mUsbDriver.setDTR(true);

		} catch (IOException e) {

			try {
				mUsbDriver.close();
			} catch (IOException e1) {

				e1.printStackTrace();
			}
			e.printStackTrace();
			Log.e(TAG,
					"MipUsbDevice - constructor - bloc catch ex = "
							+ e.getMessage());
		} catch (NullPointerException e) {

			e.printStackTrace();
			Log.e(TAG,
					"MipUsbDevice - constructor - bloc catch ex = "
							+ e.getMessage());
		}

		stopIoManager();
		startIoManager();
	}

	/**
	 * method used to add a listener to handle the received data from the nordic board board
	 */
	@Override
	public void addRobotListener(RobotListener usbListener) {
		mListeListeners.add(usbListener);
	}

	/**
	 * method used to send data to the nuveton board through the nordic board  
	 * the data is processed according to the SwitchBot protocol, see SBProtocol.java
	 */
	@Override
	public void write(byte[] data) {
			if (mUsbDriver == null) return;
			Log.d(TAG, "SBRealDeviceMini#write data:" + Utils.bytesToHex2(data));
			try {
				mUsbDriver.write(data, 1000);
			} catch (IOException e) {
				e.printStackTrace();
			}
		
	}
   
	/**
	 * this method is not used since we have only one board 
	 */
	@Override
	public boolean isAllUsbConnected(Context context) {
		// TODO Auto-generated method stub
		return false;
	}
	
	/**
	 * this method sends data to the nordic board
	 */
	@Override
	public void writeRaw(byte[] data) {
	
			Log.d(TAG, "SBRealDeviceMini#writeRaw data:" + Utils.bytesToHex2(data));
	}

	private void stopIoManager() {
		if (mSerialIoManager != null) {
			Log.i(TAG, "Stopping io manager ..");
			mSerialIoManager.stop();
			mSerialIoManager = null;
		}
	}

	private void startIoManager() {
		if (mUsbDriver != null) {
			Log.i(TAG, "Starting io manager ..");
			mSerialIoManager = new SerialInputOutputManager(mUsbDriver,
					mListener);
			mExecutor.submit(mSerialIoManager);
			Log.d(TAG, "UsbDevice 6");
		}
	}
	
	
    /**
     * Method to disconnect the USB device 
     */
	@Override
	public void disconnect(DeviceType deviceType) {

			mUsbDevice = null;
			stopIoManager();
	}
   
	/**
	 * Method to check of the usb device is connected 
	 * @param context : the calling activity context 
	 * @return  true if the device is connected, false if not 
	 */
	public static boolean isConnected(Context context ) {
		UsbManager usbManager = (UsbManager) context
				.getSystemService(Context.USB_SERVICE);

		HashMap<String, UsbDevice> deviceList = usbManager.getDeviceList();

		try {
			for (UsbDevice element : deviceList.values()) {
				Log.d(TAG, "product id: " + element.getProductId());
				if (ARDUINO_PRODUCT_ID == element.getProductId()) {
	
						return true;
				}

			}
		} catch (NullPointerException ex) {
			ex.printStackTrace();
		}

		return false;
	}

	/**
	 * this method is not used since we have only one device 
	 */
	@Override
	public boolean isDeviceConnected(Context context, DeviceType deviceType) {
		// TODO Auto-generated method stub
		return false;
	}


	@Override
	public ArrayList<DPNode> getBeaconsLabels() {
		// TODO Auto-generated method stub
		return null;
	}


	@Override
	public void driveTo(int beaconId) {
		// TODO Auto-generated method stub
		
	}


	@Override
	public void removeListeners() {
	   mListeListeners.clear();
	}


	@Override
	public void setCommHandler(SBCommHandler mCommHandler) {
		// TODO Auto-generated method stub
		
	}

}
