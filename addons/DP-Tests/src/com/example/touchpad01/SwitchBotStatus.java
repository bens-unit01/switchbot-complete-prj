/*
 * Copyright (C) 2013 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.example.touchpad01;

import java.io.UnsupportedEncodingException;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.concurrent.Executor;
import java.util.concurrent.Executors;





import com.wowwee.util.SBProtocol;
import com.wowwee.util.Utils;

import android.app.Activity;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.ServiceConnection;
import android.os.Bundle;
import android.os.IBinder;
import android.support.v4.content.LocalBroadcastManager;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;

public class SwitchBotStatus extends Activity {
	private final String TAG = this.getClass().getSimpleName();
	private TextView txtLog;
	private ScrollView scrLog;
	private Button btnConnect, btnActivateAdb;
	private ImageButton ledBluetooth, ledUsb, ledWifi, ledTelep;
	private static final int REQUEST_SELECT_DEVICE = 1;
	private static final int REQUEST_ENABLE_BT = 2;
	private static final int UART_PROFILE_READY = 10;
	private static final int UART_PROFILE_CONNECTED = 20;
	private static final int UART_PROFILE_DISCONNECTED = 21;
	private static final int STATE_OFF = 10;
	private int mState = UART_PROFILE_DISCONNECTED;
//	private BluetoothDevice mDevice = null;
//	private BluetoothAdapter mBtAdapter = null;
	private boolean isUsbDisconnected = false;
	//private SBBluetoothClient mBtClient = null;
	private final int REFRESH_TIME = 4000, USB_TIMEOUT = 2000;
	private final DateFormat formater = new SimpleDateFormat("hh.mm.ss a");
	private Executor executor = Executors.newSingleThreadScheduledExecutor();
	private String mDeviceAdress = null; 
	private boolean isDisconnectRequested = false;
	private byte mPreviousStatus = 0x00;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_switch_bot_logs);
		txtLog = (TextView) findViewById(R.id.txtLog);
		scrLog = (ScrollView) findViewById(R.id.scrLog);
		btnConnect = (Button) findViewById(R.id.btnConnect);
		//btnActivateAdb = (Button) findViewById(R.id.btnActivateADB);
		ledBluetooth = (ImageButton) findViewById(R.id.btnLedBluetooth);
		ledUsb = (ImageButton) findViewById(R.id.btnLedUsb);
		ledWifi = (ImageButton) findViewById(R.id.btnLedWifi);
		ledTelep = (ImageButton) findViewById(R.id.btnLedTelep);

	//	mBtAdapter = BluetoothAdapter.getDefaultAdapter();
/*
		mBtClient = new SBBluetoothClient(this);
		mBtClient.addSBBluetoothListener(new SBBluetoothListener() {

			@Override
			public void onNotify(String action, byte[] data) {
				if (action.equals(UartService.ACTION_DATA_AVAILABLE)) {
					if(data.length < 2) return;  // we need at least 2 bytes  
					Log.d(TAG, "data: " + Utils.bytesToHex2(data));
					displayStatus(data[1]);

				}

				if (action.equals(UartService.ACTION_GATT_CONNECTED)) {
					log(mDevice.getName() + " - ready");
					btnConnect.setText("Disconnect");
					ledBluetooth.setPressed(true);
					// we check the status every 10 seconds
					executor.execute(new Thread(new Runnable() {
						
						@Override
						public void run() {
						// wait 1 sec before we start sending data 	
						try {
							Thread.sleep(1000);
						} catch (InterruptedException e1) {
							e1.printStackTrace();
						}
					     while(isBtConnected()){
							getStatus();
							try {
								Thread.sleep(REFRESH_TIME);
							} catch (InterruptedException e) {
								e.printStackTrace();
							}
					     }
						}
					}));
					

				}

				if (action.equals(UartService.ACTION_GATT_DISCONNECTED)) {
					log(" Disconnected from: " + mDevice.getName());
					btnConnect.setText("Connect");
					ledBluetooth.setPressed(false);
					displayStatus((byte) 0x00);
					reconnect();
				}
				
				Log.i(TAG, "onNotify action: " + action  + " mState: " + mBtClient.getState());

			}

			private void reconnect() {
				if(!isDisconnectRequested)
				mBtClient.connect(mDeviceAdress);
			}
		});
		
		
		*/
		btnConnect.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
/*
				if (!mBtAdapter.isEnabled()) {
					Log.i(TAG, "onClick - BT not enabled yet");
					Intent enableIntent = new Intent(
							BluetoothAdapter.ACTION_REQUEST_ENABLE);
					startActivityForResult(enableIntent, REQUEST_ENABLE_BT);
				} else {
					if (btnConnect.getText().equals("Connect")) {

						// Connect button pressed, open DeviceListActivity
						// class, with popup windows that scan for devices
                        isDisconnectRequested = false;
			//			Intent newIntent = new Intent(SwitchBotStatus.this,
			//					DeviceListActivity.class);
			//			startActivityForResult(newIntent, REQUEST_SELECT_DEVICE);
					} else {
						// Disconnect button pressed
						isDisconnectRequested = true;
						if (mDevice != null) {
				//			mBtClient.disconnect();
						}
					}
				}
*/
			}
		});
/*
    btnActivateAdb.setOnClickListener(new OnClickListener() {
		
		@Override
		public void onClick(View v) {
		   if(isBtConnected()){
			   		byte[] value = { SBProtocol.NOTF_ACTIVATE_ADB, 0x00, 0x00 };
        			String currentTime = "[" + formater.format(new Date()) + "] : ";
			   		log(currentTime + "activating ADB...");
					// we send a request to activate adb through wifi 
				//	mBtClient.writeRX(value);
		   }	
		}
	});
*/
		log("app started");

	}

	private void getStatus() {
		new Thread(new Runnable() {

			@Override
			public void run() {
				if (isBtConnected()) {
					byte[] value = { SBProtocol.NOTF_GET_STATUS, 0x00, 0x00 };
					// we send a request to get the system status
			//		mBtClient.writeRX(value);
					try {
						// we deduct that usb is disconnected
						// if we don't have a response after 2 seconds
						isUsbDisconnected = true;
						Thread.sleep(USB_TIMEOUT);
						 if(isUsbDisconnected) displayStatus((byte) 0x00);
					} catch (InterruptedException e) {
						log("catch bloc e: " + e.getMessage());
						e.printStackTrace();
					}
				}
			}
		}).start();
	}

	public void log(final String str) {
		runOnUiThread(new Runnable() {

			@Override
			public void run() {
				txtLog.append(str + "\n");
				scrLog.smoothScrollTo(0, txtLog.getBottom());
				Log.d(TAG, " log " + str);
			}
		});
	}

	private void displayStatus(final byte b) {
		// b0 --> usb, b1 --> wifi, b2 --> telep.

		runOnUiThread(new Runnable() {

			@Override
			public void run() {
				byte[] output  = {b};
                Log.d(TAG, "status: " + Utils.bytesToHex2(output)); 
				String currentTime = "[" + formater.format(new Date()) + "] : ";
				if ((byte) (b & 0x01) == 0x01) {
					synchronized (this) {
						isUsbDisconnected = false;
					}
					ledUsb.setPressed(true);
					if ((byte) (mPreviousStatus & 0x01) == 0x00)
						log(currentTime + "usb connected");
				} else {
					ledUsb.setPressed(false);
					if ((byte) (mPreviousStatus & 0x01) == 0x01)
						log(currentTime + "usb disconnected");
					
				}
				if ((byte) (b & 0x02) == 0x02) {
					ledWifi.setPressed(true);
					if ((byte) (mPreviousStatus & 0x02) == 0x00)
					 log(currentTime + "wifi connected");
					
				} else {
					ledWifi.setPressed(false);
					if ((byte) (mPreviousStatus & 0x02) == 0x02)
					log(currentTime + "wifi disconnected");
				
				}

				if ((byte) (b & 0x04) == 0x04) {
					ledTelep.setPressed(true);
					if ((byte) (mPreviousStatus & 0x04) == 0x00)
				    log(currentTime + "telep. connected");
					
				} else {
					ledTelep.setPressed(false);
					if ((byte) (mPreviousStatus & 0x04) == 0x04)
					log(currentTime + "telep. disconnected");
					
				}

				mPreviousStatus = b;

			}
		});

	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {

		switch (requestCode) {

		case REQUEST_SELECT_DEVICE:
			// When the DeviceListActivity return, with the selected device
			// address
			if (resultCode == Activity.RESULT_OK && data != null) {
				String deviceAddress = data
						.getStringExtra(BluetoothDevice.EXTRA_DEVICE);
		//		mDeviceAdress = deviceAddress;
		//		mDevice = BluetoothAdapter.getDefaultAdapter().getRemoteDevice(
		//				deviceAddress);

				// log("... onActivityResultdevice.address==" + mDevice);
		//		log(mDevice.getName() + "- connecting ...");

		//		mBtClient.connect(deviceAddress);
			}
			break;
		case REQUEST_ENABLE_BT:
			// When the request to enable Bluetooth returns
			if (resultCode == Activity.RESULT_OK) {
				Toast.makeText(this, "Bluetooth has turned on ",
						Toast.LENGTH_SHORT).show();

			} else {
				// User did not enable Bluetooth or an error occurred
				log("BT not enabled");
				Toast.makeText(this, "Problem in BT Turning ON ",
						Toast.LENGTH_SHORT).show();
				finish();
			}
			break;
		default:
			log("wrong request code");
			break;
		}

	}

	@Override
	public void onBackPressed() {;
	    isDisconnectRequested = true;
	//	mBtClient.disconnect();
		btnConnect.setText("Connect");
		this.finish();
	}

	@Override
	public void onResume() {
		super.onResume();
		Log.d(TAG, "onResume");
		/*
		if (!mBtAdapter.isEnabled()) {
			Log.i(TAG, "onResume - BT not enabled yet");
			Intent enableIntent = new Intent(
					BluetoothAdapter.ACTION_REQUEST_ENABLE);
			startActivityForResult(enableIntent, REQUEST_ENABLE_BT);
		}
		*/
		ledBluetooth.setPressed(false);
		if(isBtConnected()) {
			ledBluetooth.setPressed(true);
		}

	}
    private boolean isBtConnected(){
    	//return mBtClient.getState() == UART_PROFILE_CONNECTED;
    	return false;
    }
	@Override
	public void onDestroy() {
		super.onDestroy();
		isDisconnectRequested = true;
		//mBtClient.onDestroy();

	}

}
