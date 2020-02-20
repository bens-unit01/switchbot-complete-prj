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
package com.wowwee.touchpad;

import java.io.UnsupportedEncodingException;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.concurrent.Executor;
import java.util.concurrent.Executors;

import com.wowwee.touchpad.Robot.RobotListener;
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
	private Button btnConnect, btnActivateADB;
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
		//btnGetStatus = (Button) findViewById(R.id.btnGetStatus);
		btnActivateADB = (Button) findViewById(R.id.btnActivateADB);
//		ledBluetooth = (ImageButton) findViewById(R.id.btnLedBluetooth);
		ledUsb = (ImageButton) findViewById(R.id.btnLedUsb);
		ledWifi = (ImageButton) findViewById(R.id.btnLedWifi);
		ledTelep = (ImageButton) findViewById(R.id.btnLedTelep);
		
		
		Log.d(TAG, "selected SB: " + MainActivity.SELECTED_SWITCHBOT);
		
		Robot.getInstance().setRobotListener(new RobotListener() {

			@Override
			public void onNotify(String action, String data) {
				if (action.equals(Robot.ACTION_DATA_AVAILABLE)) {
					log("msg: " + data);
					String cmd[] = data.split(SBProtocol.JETTY_SPLIT_CHAR);
					if (cmd[0].equals(SBProtocol.JETTY_SET_STATUS)
							&& (cmd.length >= 2)) {
						displayStatus(Byte.parseByte(cmd[1]));
					}
				}
				if (action.equals(Robot.ACTION_ROBOT_CONNECTED)) {
					log("connected");
					runOnUiThread(new Runnable() {
						public void run() {
							btnConnect.setText("Disconnect");
							ledWifi.setPressed(true);
						}
					});
					
					executor.execute(new Thread(new Runnable() {
						
						@Override
						public void run() {
						// wait 1 sec before we start sending data 	
						try {
							Thread.sleep(1000);
						} catch (InterruptedException e1) {
							e1.printStackTrace();
						}
					     while(isWsConnected()){
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
				if (action.equals(Robot.ACTION_ROBOT_DISCONNECTED)) {

					runOnUiThread(new Runnable() {
						public void run() {
							btnConnect.setText("Connect");
							ledWifi.setPressed(false);

						}
					});
					displayStatus((byte) 0x00);
					log("disconnected");
				}
			}
		});

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
				if (btnConnect.getText().equals("Connect")) {
                        isDisconnectRequested = false;
                        Robot.getInstance().connect(); 
					} else {
						// Disconnect button pressed
						isDisconnectRequested = true;
						Robot.getInstance().disconnect(); 
	    			}

			}
		});
/*
    btnGetStatus.setOnClickListener(new OnClickListener() {
		
		@Override
		public void onClick(View v) {
		   if(isWsConnected()){
			getStatus();   
		   }	
		}
	});

 */
		
		btnActivateADB.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
			log("Request sent --> activate ADB ...");
			send(SBProtocol.JETTY_ACTIVATE_ADB + SBProtocol.JETTY_SPLIT_CHAR);
			
			}
		});
		
		log("app started");

	}

	private void getStatus() {
		new Thread(new Runnable() {

			@Override
			public void run() {
				if (isWsConnected()) {
   //					byte[] value = { SBProtocol.NOTF_GET_STATUS, 0x00, 0x00 };
	               String output = SBProtocol.JETTY_GET_STATUS + SBProtocol.JETTY_SPLIT_CHAR; 
					// we send a request to get the system status
					Robot.getInstance().send(output); 
//					try {
//						// we deduct that usb is disconnected
//						// if we don't have a response after 2 seconds
//						isUsbDisconnected = true;
//						Thread.sleep(USB_TIMEOUT);
//						 if(isUsbDisconnected) displayStatus((byte) 0x00);
//					} catch (InterruptedException e) {
//						log("catch bloc e: " + e.getMessage());
//						e.printStackTrace();
//					}
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
	
	
	private void send(final String cmd){
		new Thread(new Runnable() {
			public void run() {
			Robot.getInstance().send(cmd);	
			}
		}).start();
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
		ledWifi.setPressed(false);
		if(isWsConnected()) {
			ledWifi.setPressed(true);
		}

	}
    private boolean isWsConnected(){
    	return Robot.getInstance().isConnected();
    }

	

	@Override
	public void onDestroy() {
		super.onDestroy();
		isDisconnectRequested = true;
		//mBtClient.onDestroy();
		Robot.getInstance().disconnect();

	}
		@Override
	public void onBackPressed() {
	    isDisconnectRequested = true;
	    Robot.getInstance().disconnect();
		btnConnect.setText("Connect");
		this.finish();
	}

}
