package com.wowwee.switchbot;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.security.InvalidParameterException;
import java.util.ArrayList;

import com.hoho.android.usbserial.util.SerialInputOutputManager;
import com.q410.uart.SerialPort;
import com.wowwee.drivepath.DPNode;
import com.wowwee.drivepath.SBCommHandler;
import com.wowwee.util.SBProtocol;

import android.content.Context;
import android.util.Log;

public class SBQ410Device extends SBRealDeviceCommon {

	// final String TAG = getClass().getSimpleName();
	final static String TAG = "SwitchBot";
	final static int WRITE_DELAY = 25;  
	
	protected SerialPort mSerialPort;
	protected OutputStream mOutputStream;
	private InputStream mInputStream;
//	private ReadThread mReadThread;
	
//	private SBCommHandler mCommHandler;
	private static ArrayList<RobotListener> mListeListeners = new ArrayList<RobotListener>();

	static final int BAUD_RATE = 115200;
//	static final int BAUD_RATE = 9600;
	static final int BUFFER_SIZE = 10; 
	static final String PATH =  "/dev/ttyHSL1";
	

	private static SBQ410Device mUsbDevice = null;
	

	public static SBQ410Device  getInstance(Context context) {

		if (mUsbDevice != null) {
			return mUsbDevice;
		} else {

			mUsbDevice = new SBQ410Device(context);
			return mUsbDevice;
		}

	}
	/**
	 * This method is used to get an instance of the SBRealDevice according
	 * to the singleton design pattern. This instance represent the FTDI board 
	 * connected to the nordic board pca10001
	 * @param context : the calling activity context
	 * @return
	 */

	
	
    /**
     * private constructor 
     * @param context : the activity context
     */
	private SBQ410Device(Context context ) {
		super(context);
		
		try {
			mSerialPort = getSerialPort();
			mOutputStream = mSerialPort.getOutputStream();
			mInputStream = mSerialPort.getInputStream();

//			mReadThread = new ReadThread();
//			mReadThread.start();
			
			new Thread(new Runnable() {
				
				@Override
				public void run() {
					// TODO Auto-generated method stub
					Log.d(TAG, "SBQ410Device#ReadThread start "); 
//					while(!isInterrupted()) {
					while(true) {
						int size;
						try {
							byte[] buffer = new byte[BUFFER_SIZE];
							if (mInputStream == null) {
							Log.d(TAG, "SBQ410Device#ReadThread mInputStream == null "); 
								return;
							}
							size = mInputStream.read(buffer);
							Log.d(TAG, "SBQ410Device#ReadThread size: " + size); 
							if (size >= 3) {
						     byte[] data = {buffer[0], buffer[1], buffer[2] }; 	
							for (RobotListener b : mListeListeners) {
		         				b.onNotify(new RobotEvent(this, data)); 
				        	}  
			
							}else{
								
		                       Log.d(TAG, "SBQ410#ReadThread --> size < 3"); 
							}
						} catch (IOException e) {
							e.printStackTrace();
							return;
						} 
					}
					
				}
			}).start();
			
			
		} catch (SecurityException e) {
           Log.d(TAG, "bloc catch " + e.getMessage()); 
			e.printStackTrace();
		} catch (InvalidParameterException e) {
           Log.d(TAG, "bloc catch " + e.getMessage()); 
			e.printStackTrace();
		} catch (IOException e) {
           Log.d(TAG, "bloc catch " + e.getMessage()); 
			e.printStackTrace();
		}

	}
	
	public SerialPort getSerialPort() throws SecurityException, IOException, InvalidParameterException {
		if (mSerialPort == null) {

			Log.d(TAG, " device: " + PATH + " baudrate: " + BAUD_RATE); 
			mSerialPort = new SerialPort(new File(PATH), BAUD_RATE, 0);
			
		}
		return mSerialPort;
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
					try {
						
						mSerialPort = getSerialPort();
						mOutputStream = mSerialPort.getOutputStream();
						mInputStream = mSerialPort.getInputStream();
						
						mOutputStream.write(data);
						Thread.sleep(WRITE_DELAY); 
					} catch (IOException e) {
						e.printStackTrace();
					} catch (InterruptedException e) {
						e.printStackTrace();
					}
	}
   
	/**
	 * this method is not used since we have only one board 
	 */
	@Override
	public boolean isAllUsbConnected(Context context) {
		// TODO Auto-generated method stub
        Log.d(TAG, "SBQ410#isAllUsbConnected ... "); 
		return false;
	}
	
	/**
	 * this method sends data to the nordic board
	 */
	@Override
	public void writeRaw(byte[] data) {
					try {
						mOutputStream.write(data);
						Thread.sleep(WRITE_DELAY); 
					} catch (IOException e) {
						e.printStackTrace();
					} catch (InterruptedException e) {
						e.printStackTrace();
					}
	}



   
	/**
	 * Method to check of the usb device is connected 
	 * @param context : the calling activity context 
	 * @return  true if the device is connected, false if not 
	 */
	public static boolean isConnected(Context context ) {
        Log.d(TAG, "SBQ410#isConnected ... "); 
		return false;
	}

	/**
	 * this method is not used since we have only one device 
	 */
	@Override
	public boolean isDeviceConnected(Context context, DeviceType deviceType) {
		// TODO Auto-generated method stub
        Log.d(TAG, "SBQ410#isDeviceConnected ... "); 
		return false;
	}


	@Override
	public void removeListeners() {
        Log.d(TAG, "SBQ410#removeListeners ... "); 
	}


	@Override
	public void disconnect(DeviceType deviceType) {
        Log.d(TAG, "SBQ410#disconnect ... "); 
//		if (mReadThread != null)
//			mReadThread.interrupt();
		closeSerialPort();
		mSerialPort = null;
		
	}
	
	public void closeSerialPort() {
        Log.d(TAG, "SBQ410#closeSerialPort ... "); 
		if (mSerialPort != null) {
			mSerialPort.close();
			mSerialPort = null;
		}
	}


}
