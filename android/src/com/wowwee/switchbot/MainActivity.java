package com.wowwee.switchbot;

import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.lang.reflect.Method;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.ArrayList;
import java.util.Random;
import java.util.Timer;
import java.util.TimerTask;

import com.wowwee.drivepath.SBCommHandler;

import org.jivesoftware.smack.util.StringUtils;
import org.json.JSONArray;
import org.json.JSONObject;

import com.nucleus.library.NucleusAPI;
import com.nucleus.library.NucleusAPI.RunnableListener;
import com.wowwee.drivepath.DPNode;
import com.wowwee.switchbot.SBRobot.DeviceType;
import com.wowwee.switchbot.SBRobot.RobotEvent;
import com.wowwee.switchbot.SBRobot.RobotListener;
import com.wowwee.telepresence.PushServer;
import com.wowwee.telepresence.PushServerListener;
import com.wowwee.util.AdbUtils;
import com.wowwee.util.SBProtocol;
import com.wowwee.util.Utils;
import com.wowwee.websocket_server.CommServer;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.hardware.usb.UsbManager;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.media.MediaPlayer.OnPreparedListener;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.wifi.WifiManager;
import android.os.Bundle;
import android.os.CountDownTimer;
import android.os.Handler;
import android.preference.PreferenceManager;
import android.speech.RecognizerIntent;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

public class MainActivity extends Activity implements RunnableListener{

	// final String TAG = getClass().getSimpleName();
	final String TAG = "KUDO";
	private SBRobot mSwitchBotMcu, mXyzMcu;
	private PushServer mLsClient = null;
	// private final boolean IS_REAL_DEVICE = false; // set this flag to false
	// to use the virtual device
	private NucleusAPI mNucleusAPI = null;
	private Context context;
	private CommServer mCommServer;
	private SBCommHandler mCommHandler = null;
	public static final int SB_VIRTUAL_DEVICE = 0;
	public static final int SB_REAL_DEVICE = 1;
	public static final int SB_REAL_DEVICE_MINI = 2;
	public static final int SB_Q410_BOARD = 3;
  
   
//	 public static final int SELECTED_DEVICE = SB_VIRTUAL_DEVICE;   // android board only 
//	 public static final int SELECTED_DEVICE = SB_REAL_DEVICE_MINI; // android + arduino 
//	 public static final int SELECTED_DEVICE = SB_REAL_DEVICE;      // android (ODROD-C1) + motors board ( bobi board)
	public static final int SELECTED_DEVICE = SB_Q410_BOARD;        // android (qualcomm Q410) + motors board ( Andrew Kohlsmith board) 

	private int destID = -1;
	
    private String message, info, msg, SSID, password, userID, userPWD;
	private final int MAX_VALUE = 0x10;
	private final int MAX_VALUE_LR = 0x07;
	
	TextView textViewUserID;

   
	@SuppressWarnings("unused")
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);
		
		Log.d(TAG, "onCreate ...");
		context = this;
		textViewUserID = (TextView) findViewById(R.id.textUserID);
		
        SharedPreferences sharedPref = PreferenceManager.getDefaultSharedPreferences(context);
        SSID = sharedPref.getString("KudoSSID", "");
        userID = sharedPref.getString("KudoUserEmail", "");
        userPWD = sharedPref.getString("KudoUserPwd", "");
		
		mNucleusAPI = new NucleusAPI(this, "nuance") {
			@Override
			public void loginAuth(boolean isValid) {
				if (isValid) {
					Log.d(TAG, "loginAuth..................."+isValid);
					
					mNucleusAPI.registerServices();
			        mNucleusAPI.StartNucleusCommand("kudo");
			        userID = mNucleusAPI.getUserID();
			        userPWD = mNucleusAPI.getUserPWD();
			        
			        SharedPreferences sharedPref = PreferenceManager.getDefaultSharedPreferences(context);
			        SharedPreferences.Editor editor = sharedPref.edit();
			        editor.putString("KudoUserEmail", userID);
			        editor.putString("KudoUserPwd", userPWD);
			        editor.commit();
			        
			        runOnUiThread(new Runnable() {
			            @Override
			            public void run() {

			            	textViewUserID.setText("Connected: " + userID);

			           }
			       });
					
			        
					ArrayList<DPNode> beacons = mSwitchBotMcu
							.getBeaconsLabels();
					try {
						JSONArray locs = new JSONArray();
						for (int i = 0; i < beacons.size(); ++i) {
						
							JSONObject loc = new JSONObject();
							loc.put("label", beacons.get(i).label);
							loc.put("id", beacons.get(i).id);

							locs.put(loc);
							
							Log.d(TAG, "Data..................."+beacons.get(i).label);
						}
						setLocations(locs);
						setLED(SBProtocol.RGB_SOLID_BLUE);
					} catch (Exception e) {
						e.printStackTrace();
					}
				}
			}

			@Override
			public void listeningStart() {
				Log.d(TAG, "listeningStart ...");
				setLED(SBProtocol.RGB_SOLID_AMBER);
				super.listeningStart();
			}

			@Override
			public void listeningStop() {
				Log.d(TAG, "listeningStop ...");
				resetLED();
				super.listeningStop();
			}

			@Override
			public void thinkingStart() {
				Log.d(TAG, "thinkingStart ...");
				setLED(SBProtocol.RGB_FLASH_GREEN_SLOW);
				super.thinkingStart();
			}

			@Override
			public void thinkingStop() {
				Log.d(TAG, "thinkingStop ...");
				resetLED();
				super.thinkingStop();
			}

			@Override
			public void speakingStart() {
				Log.d(TAG, "speakinStart ...");
				setLED(SBProtocol.RGB_FLASH_GREEN_QUICK);
				super.speakingStart();
			}

			@Override
			public void speakingStop() {
				Log.d(TAG, "speakinStop ...");
				resetLED();
				super.speakingStop();
			}
			
			private int getAngle(int angle, int minValue) {
				//return angle * 0x1f / 90 + minValue;  
				return angle * MAX_VALUE_LR/ 90 + minValue;  
			}

			@Override
			public void SHEneticsListener(JSONObject data) {
				byte[] usbData = new byte[2];
				Log.d(TAG, "data" + data.toString());
				try {
					if (data.getString("type") == "location") {
						// Bedroom, Den, Dining Room, Entryway, Kitchen, Front
						// Door, Back Door, Side Door, Patio, Family Room,
						// Hallway, Living Room, Master Bedroom, Kids Bedroom,
						// Guest Room, Office, Upstairs, Downstairs, Basement
						destID = data.getInt("id");
						new Thread(new Runnable() {
							@Override
							public void run() {
								mSwitchBotMcu.driveTo(destID);
							}
						}).start();
					} else if (data.getString("type") == "joystick") {
						int angle = data.getInt("angle");
						int power = data.getInt("power");
						String deviceID = data.getString("deviceID");
						
						String cmd = "";
						int fwd_bwd = 0, left_right = 0;
				        
						if( angle <= 90 && angle >= -90){
				        	 fwd_bwd = power * 0x20 / 100;
							   fwd_bwd = power * MAX_VALUE / 100;
				        	if(angle >= 0 ){
				        	    left_right  = getAngle(angle, 0x41);	
				        		Log.d(TAG, "forward right " + fwd_bwd + " " + left_right);
				        	}else {
				        	    left_right  = getAngle(-angle, 0x61);	
				        		Log.d(TAG, "forward left "+ fwd_bwd + " " + left_right);
				        	}
				        }else{
				        	fwd_bwd = (power * 0x20 /100) + 0x21;
				        	fwd_bwd = (power * MAX_VALUE/100) + 0x21;
				        	if(angle <= -90){
				        	    left_right  = getAngle(180 + angle, 0x61);	
				        	    Log.d(TAG, "backward left "+ fwd_bwd + " " + left_right);
				        	}else {
				        	    left_right  = getAngle(180 - angle, 0x41);	
				        	    Log.d(TAG, "backward right "+ fwd_bwd + " " + left_right);
				        	}
				        }

						cmd = SBProtocol.JETTY_DRIVE + SBProtocol.JETTY_SPLIT_CHAR;
						cmd +=  fwd_bwd + SBProtocol.JETTY_SPLIT_CHAR;
						cmd +=  left_right + SBProtocol.JETTY_SPLIT_CHAR;
						
//							usbData[0] = SBProtocol.TURN_LEFT;
//							usbData[1] = 2;
//							mSwitchBotMcu.write(usbData);
						return;
					} else if (data.getString("type") == "control") {
						if (data.getString("mode").contentEquals(
								"MOTION_TURN_LEFT")) {
							usbData[0] = SBProtocol.TURN_LEFT;
							usbData[1] = 2;
							mSwitchBotMcu.write(usbData);
							speak("left");
							return;
						}

						if (data.getString("mode").contentEquals(
								"MOTION_TURN_RIGHT")) {
							usbData[0] = SBProtocol.TURN_RIGHT;
							usbData[1] = 2;
							mSwitchBotMcu.write(usbData);
							speak("right");
							return;
						}

						if (data.getString("mode").contentEquals(
								"MOTION_MOVE_FORWARD")) {
							usbData[0] = SBProtocol.MOVE_FORWARD;
							usbData[1] = 2;
							mSwitchBotMcu.write(usbData);
							speak("forward");
							return;
						}

						if (data.getString("mode").contentEquals(
								"MOTION_MOVE_BACKWARD")) {
							usbData[0] = SBProtocol.MOVE_BACKWARD;
							usbData[1] = 2;
							mSwitchBotMcu.write(usbData);
							speak("backward");
							return;
						}

						if (data.getString("mode").contentEquals(
								"MOTION_LEAN_FORWARD")) {
							usbData[0] = SBProtocol.LEAN_FORWARD;
							usbData[1] = 2;
							mSwitchBotMcu.write(usbData);
							speak("leaning foward");
							return;
						}

						if (data.getString("mode").contentEquals(
								"MOTION_LEAN_BACKWARD")) {
							usbData[0] = SBProtocol.LEAN_BACKWARD;
							usbData[1] = 2;
							mSwitchBotMcu.write(usbData);
							speak("leaning backward");
							return;
						}

						if (data.getString("mode").contentEquals("MODE_STAND")) {
							usbData[0] = SBProtocol.STAND_UP;
							usbData[1] = 2;
							mSwitchBotMcu.write(usbData);
							speak("standing up");
							return;
						}

						if (data.getString("mode").contentEquals("MODE_DANCE")) {
							usbData[0] = SBProtocol.DANCE;
							usbData[1] = 2;
							mSwitchBotMcu.write(usbData);
							speak("dancing");
							return;
						}

						if (data.getString("mode").contentEquals("MODE_KNEEL")) {
							usbData[0] = SBProtocol.KNEEL;
							usbData[1] = 2;
							mSwitchBotMcu.write(usbData);
							speak("kneeling");
							return;
						}
					}
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		};

		switch (SELECTED_DEVICE) {
			case SB_VIRTUAL_DEVICE:
				// -------------- virtual device initialization ------------------
				Button btnSpeak = (Button) findViewById(R.id.btnStart);
				mSwitchBotMcu = new SBVirtualDevice(btnSpeak);
				Button btnPairingMode = (Button) findViewById(R.id.btnPairingMode);
				btnPairingMode.setOnClickListener(new View.OnClickListener() {
					@Override
					public void onClick(View v) {
						devicePairingMode();
					}
				});
				// ---------------------------------------------------------------
				break;
			case SB_REAL_DEVICE_MINI:
				// --------------static SwitchBot initialization ------------------
				if (!SBRealDeviceMini.isConnected(this)) {
					Log.d(TAG, "switchbot mcu not connected, exiting program ...");
					this.finish();
					return;
				}
				mSwitchBotMcu = SBRealDeviceMini.getInstance(this);
				// ---------------------------------------------------------------
				break;
			case SB_REAL_DEVICE:
			case SB_Q410_BOARD:
				// -------------- complete version of SwitchBot initialization ----
				if (SELECTED_DEVICE == SB_REAL_DEVICE) {
					SBRealDeviceFactory.setSelectedDevice(SB_REAL_DEVICE, context);
					if (!SBRealDevice.isConnected(this)) {
						Log.d(TAG,
								"switchbot mcu not connected, exiting program ...");
						this.finish();
						return;  
					}
				} else {
	
					SBRealDeviceFactory.setSelectedDevice(SB_Q410_BOARD, context);
				}
				mSwitchBotMcu = SBRealDeviceFactory.getInstance();
				mLsClient = new PushServer();
				mLsClient.addLSClientListener(new PushServerListener(this, mLsClient));
				mCommHandler = new SBCommHandler(mLsClient, context);
				mCommHandler.setRobotListener();
				mCommServer = new CommServer(mCommHandler);
				mSwitchBotMcu.setCommHandler(mCommHandler);
	
				// --------------------------
				ArrayList<DPNode> nodes = mSwitchBotMcu.getBeaconsLabels();
				Log.d(TAG, " beacons " + nodes);
				break;
		}
		
		ConnectivityManager connManager = (ConnectivityManager) getSystemService(Context.CONNECTIVITY_SERVICE);
        NetworkInfo mWifi = connManager.getNetworkInfo(ConnectivityManager.TYPE_WIFI);
        Boolean isConnected = mWifi.isConnected();
        if (!isConnected || userID.equals("") || userPWD.equals("")) {
        	Log.d(TAG, "Going into device pairing mode " + userID + ", " + userPWD);
        	Log.d(TAG, "wifi state " + isConnected);
        	devicePairingMode();
        } else {
        	int wifiRetry = 0;
        	Boolean connected = false;
        	Log.d(TAG, "Wifi connection loop");
        	while (wifiRetry < 60 && !connected) {
        		try {
					Thread.sleep(1000);
					Log.d(TAG, "Wifi timer");
					if (++wifiRetry > 60) {
						Log.d(TAG, "Wifi connection timeout");
						devicePairingMode();
						break;
					}
					if (mNucleusAPI.isConnectedToInternet()) {
                        Log.d(TAG, "Wifi connected " + userID);
                        mNucleusAPI.loadEarcons(R.raw.sk_start, R.raw.sk_stop, R.raw.sk_error);
                		mNucleusAPI.login(userID, userPWD, true, "");
                        setLED(SBProtocol.RGB_SOLID_BLUE);
                        connected = true;
					}
				} catch (Exception e) {
				}
        	}
        }
        
        setDisconnectListener();
        mSwitchBotMcu.addRobotListener(new SBUsbListener());
	}
	
	private final static char[] idchars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".toCharArray();
	private static String createId(int len) {
	    char[] id = new char[len];
	    Random r = new Random(System.currentTimeMillis());
	    for (int i = 0;  i < len;  i++) {
	        id[i] = idchars[r.nextInt(idchars.length)];

	    }
	    return new String(id);
	}	

	private void setDisconnectListener() {
		BroadcastReceiver mUsbReceiver = new BroadcastReceiver() {

			@Override
			public void onReceive(Context context, Intent intent) {
				Log.d(TAG, "onReceive ...");
				checkDevice();
			}

		};

		IntentFilter filter = new IntentFilter();
		filter.addAction(UsbManager.ACTION_USB_DEVICE_DETACHED);
		registerReceiver(mUsbReceiver, filter);
	}

	protected void onDestroy() {
		super.onDestroy();
		Log.d(TAG, "onDestroy ...");
		if (mNucleusAPI != null) {
			mNucleusAPI.release();
		}
		 
		
	}
  
	@Override
	protected void onResume() {
		super.onResume();

		Log.d(TAG, "onResume ...");
		if (mLsClient != null) {
			mLsClient.onResume();
		}

	}
	
	private void devicePairingMode() {
    	Log.v(TAG, "Disconnected");

		setLED(SBProtocol.RGB_SOLID_AMBER);
		
		SSID = "KUDO-" + createId(8);
		Log.d(TAG, "Generating Kudo SSID for P2P wifi setup: " + SSID);
        SharedPreferences sharedPref = PreferenceManager.getDefaultSharedPreferences(this);
        SharedPreferences.Editor editor = sharedPref.edit();
        editor.putString("KudoSSID", SSID);
        editor.commit();
    	
//		TextView textViewUserID = (TextView) findViewById(R.id.textUserID);
		textViewUserID.setText("Pairing Mode: " + SSID);
		
        mNucleusAPI.devicePairingMode(SSID, "9ag82kfjA!Vb7");
        Log.v(TAG, "isConnectedToInternet BEFORE START....");
        boolean isConnectedToInternet = mNucleusAPI.StartThread(this);
        Log.v(TAG, "isConnectedToInternet AFTER...." + isConnectedToInternet);
	}

	private void setLED(int color) {
		if (mSwitchBotMcu == null)
			return;

		byte[] usbData = new byte[3];
		usbData[0] = SBProtocol.RGB_CTRL_COMMAND;
		usbData[1] = (byte) color;
		usbData[2] = 0;
		if(usbData != null && mSwitchBotMcu != null)
			mSwitchBotMcu.write(usbData);
	}

	private void resetLED() { 
		setLED(SBProtocol.RGB_SOLID_BLUE);
	}

	private class SBUsbListener implements RobotListener {
		

		@Override
		public void onNotify(RobotEvent e) {

			// Log.d(TAG, " " + Utils.bytesToHex2(e.getData()));
			byte cmd = e.getData()[0];

			Log.d(TAG, "-- input: " + Utils.bytesToHex2(e.getData()));
			switch (cmd) {
			case SBProtocol.NOTF_VOICE_RECORD: // intended to SHE

			
					MainActivity.this.runOnUiThread(new Runnable() {

						@Override
						public void run() {

							// ------------------ start of voice recording
							// ---------------------------

							if (mNucleusAPI != null) {
								resetLED();
								mNucleusAPI.asrStart(context);
								Log.d(TAG, "btnStart ... ");
							}

						}
					});

				

				break;

			case SBProtocol.NOTF_DP_TARGET_REACHED: // intended to SHE
				if (mNucleusAPI != null) {
					ArrayList<DPNode> beacons = mSwitchBotMcu
							.getBeaconsLabels();
					for (int i = 0; i < beacons.size(); ++i) {
						if (beacons.get(i).id == destID) {
							mNucleusAPI.speak("I've reached the "
									+ beacons.get(i).label);
						}
					}
				}
 
				destID = -1;
				break;

			case SBProtocol.NOTF_MCU_UP: // intended to SHE
				resetLED();
				break;

			// ------------------------------------------------------------------

			case SBProtocol.NOTF_GET_STATUS:
				Log.d(TAG, "Notif get status ");
				handleGetStatus();
				break;

			case SBProtocol.NOTF_ACTIVATE_ADB:
				Log.d(TAG, "Notif activate ADB through wifi  ");
				try {
					Log.d(TAG, "activating adb through wifi, have root: ");
					AdbUtils.set(5555);
				} catch (IOException e1) {
					e1.printStackTrace();
				} catch (InterruptedException e1) {
					e1.printStackTrace();
				}

				break;

			default:
				break;
			}
		}

	}

	@Override
	protected void onNewIntent(Intent intent) {
		super.onNewIntent(intent);
		Log.d(TAG, " onNewIntent ...");
		switch (SELECTED_DEVICE) {
		case SB_REAL_DEVICE:
			mSwitchBotMcu = SBRealDevice.getInstance(this);
			break;
		case SB_REAL_DEVICE_MINI:
			mSwitchBotMcu = SBRealDeviceMini.getInstance(this);
			break;
		default:
			break;
		}
		checkDevice();
		mSwitchBotMcu.removeListeners();
		mSwitchBotMcu.addRobotListener(new SBUsbListener());
		if (mCommHandler != null) {
			mCommHandler.setRobotListener();
		}

	}

	private void checkDevice() {

		switch (SELECTED_DEVICE) {
		case SB_REAL_DEVICE:
			if (SBRealDevice.isConnected(context)) {
				Log.d(TAG, "MCU connected ...");

			} else {  
				mSwitchBotMcu.disconnect(DeviceType.NUTINY);
				Log.d(TAG, "MCU disconnected ...");
			}
			break;
		case SB_REAL_DEVICE_MINI:
			if (SBRealDeviceMini.isConnected(context)) {
				Log.d(TAG, "MCU connected ..."); 
 
			} else {
				mSwitchBotMcu.disconnect(DeviceType.NUTINY);
				Log.d(TAG, "MCU disconnected ...");
			}
			break;
		default:
			break;
		}
	}

	private void handleGetStatus() {
		if (!SBRealDevice.isConnected(this))
			return;
		byte status = 0x01; // usb connected
		if (Utils.isWifiConnected())
			status = (byte) (status | 0x02); // wifi connected
		if (mLsClient.isConnected())
			status = (byte) (status | 0x04); // telepresence connected

		// send status notification to mcu
		mSwitchBotMcu.writeRaw(new byte[] { SBProtocol.NOTF_SET_STATUS, status,
				0x00 });  
  
	}

	@Override
	public void onResult(boolean result, final String userid, final String password) {
		Log.v(TAG, "ISConnected..." + result);
		if(result){
			Log.v(TAG, "Start..." + result);
			while(!mNucleusAPI.isConnectedToInternet()) {
				try {
					Thread.sleep(1000);
				} catch (InterruptedException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}
			
			runOnUiThread(new Runnable() {
                @Override
                public void run() {
                	Log.v(TAG, "isConnectedToInternet()..." + mNucleusAPI.isConnectedToInternet());
                  	mNucleusAPI.login(userid, password, true, "");
                }
            });
		}
	}
}
