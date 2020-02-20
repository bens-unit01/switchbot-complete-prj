package com.wowwee.switchbot;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.security.InvalidParameterException;
import java.util.ArrayList;

import com.q410.uart.SerialPort;
import android.content.Context;
import android.util.Log;

public class SBQ410Device extends SBRealDeviceCommon {

	// final String TAG = getClass().getSimpleName();
	final static String TAG = "SwitchBot";
	
	protected SerialPort mSerialPort;
	protected OutputStream mOutputStream;
	private InputStream mInputStream;
	private ReadThread mReadThread;
	
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
	
	private class ReadThread extends Thread {

		@Override
		public void run() {
			super.run();
			while(!isInterrupted()) {
				int size;
				try {
					byte[] buffer = new byte[BUFFER_SIZE];
					if (mInputStream == null) return;
					size = mInputStream.read(buffer);
					if (size >= 3) {
				     byte[] data = {buffer[0], buffer[1], buffer[2] }; 	
					for (RobotListener b : mListeListeners) {
         				b.onNotify(new RobotEvent(this, data));
		        	}
	
					}
				} catch (IOException e) {
					e.printStackTrace();
					return;
				}
			}
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

			mReadThread = new ReadThread();
			mReadThread.start();
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
						mOutputStream.write(data);
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
					try {
						mOutputStream.write(data);
					} catch (IOException e) {
						e.printStackTrace();
					}
	}



   
	/**
	 * Method to check of the usb device is connected 
	 * @param context : the calling activity context 
	 * @return  true if the device is connected, false if not 
	 */
	public static boolean isConnected(Context context ) {

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
	public void removeListeners() {
	}


	@Override
	public void disconnect(DeviceType deviceType) {
		if (mReadThread != null)
			mReadThread.interrupt();
		closeSerialPort();
		mSerialPort = null;
		
	}
	
	public void closeSerialPort() {
		if (mSerialPort != null) {
			mSerialPort.close();
			mSerialPort = null;
		}
	}


}
