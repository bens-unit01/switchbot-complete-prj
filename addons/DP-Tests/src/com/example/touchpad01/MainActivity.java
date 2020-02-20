package com.example.touchpad01;

import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.ProtocolException;
import java.net.SocketException;
import java.net.URISyntaxException;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;

import org.eclipse.jetty.websocket.api.Session;

import com.example.touchpad01.Robot.RobotListener;
import com.wowwee.util.SBProtocol;
import com.wowwee.ws_client.ClientListener;
import com.wowwee.ws_client.EventClient;

import android.os.Bundle;
import android.preference.PreferenceManager;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnLongClickListener;
import android.view.View.OnTouchListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemSelectedListener;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.SeekBar;
import android.widget.SeekBar.OnSeekBarChangeListener;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

public class MainActivity extends Activity {

	private String mHost = null, mIp;
	private Button btnConnect, btnDisconnect, btnNordicMediaboxTest, btnStatus, btnGoto, btnRC, btnBleDisconnect,
			btnPos3, btnADB, btnClrEStop,btnSetEStop, btnChangeRange, btnBeaconsList, btnGotoBeacon3;
	private ImageButton ledWifi;
	private EditText txtBeaconId, txtRange;
	public final String TAG7 = "MainActivity";
	public final int REFRESH_RATE_FORWARD = 250, REFRESH_RATE_TURN = 100,
			MAXIMUM_STEPS = 150;
	private Thread threadForward, threadBackward, threadLeft, threadRight,
			threadMoveProjectorTo, threadStop;
	private boolean flagForward = false, flagBackward = false,
			flagLeft = false, flagRight = false;

	private static final int RESULT_SETTINGS = 1;
	private Spinner spinner;
	private String location = "montreal";
	private SeekBar mSeekBar;
	private TextView mTxtSeekBar;
	private int mSpeed;
	private static Context CONTEXT;
	//private EventClient mWSClient;
    	
    public static String ROBOT_IP = "10.10.250.173";	

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);
        CONTEXT = this; 
		txtBeaconId = (EditText) findViewById(R.id.txtBeaconId);
//		txtRange = (EditText) findViewById(R.id.txtRange);

	//	btnPos2 = (Button) findViewById(R.id.btnPos2);
	//	btnPos3 = (Button) findViewById(R.id.btnPos3);
     	btnADB = (Button) findViewById(R.id.btnActivateADB);
   	    btnNordicMediaboxTest = (Button) findViewById(R.id.btnNordicMediaboxTest);
		btnClrEStop = (Button)findViewById(R.id.btnClrEStop);
		btnSetEStop = (Button)findViewById(R.id.btnSetEStop);
//		btnChangeRange = (Button)findViewById(R.id.btnChangeRange);
	//	btnGotoBeacon3 = (Button)findViewById(R.id.btnGotoBeacon3);
		btnGoto = (Button)findViewById(R.id.btnGoto);
		btnBleDisconnect = (Button)findViewById(R.id.btnBleDisconnect);
		//btnStatus = (Button)findViewById(R.id.btnStatus);
		//btnRC = (Button)findViewById(R.id.btnRC);
		btnBeaconsList = (Button)findViewById(R.id.btnDrivePath);
		btnConnect = (Button)findViewById(R.id.btnConnect_main);
		ledWifi = (ImageButton)findViewById(R.id.ledWifi_main); 
	//	btnTrack = (Button)findViewById(R.id.btnTrack);

	//	

     //   mWSClient = new EventClient(wsClientListener);
   
		/*
		Robot.setRobotListener(new RobotListener() {
			@Override
			public void onMessage(String message) {
			  log(message);	
			}
			

		});
		
		*/
		addItemsOnSpinner();
		showSettings();
		setListeners();
		
		
		Robot.getInstance().setRobotListener(new RobotListener() {

			@Override
			public void onNotify(String action, String data) {
				if (action.equals(Robot.ACTION_DATA_AVAILABLE)) {
					log("msg: " + data);
				}
				if (action.equals(Robot.ACTION_ROBOT_CONNECTED)) {
					log("connected");
					runOnUiThread(new Runnable() {
						public void run() {
							btnConnect.setText("Disconnect");
							ledWifi.setPressed(true);
						}
					});

				}
				if (action.equals(Robot.ACTION_ROBOT_DISCONNECTED)) {

					runOnUiThread(new Runnable() {
						public void run() {
							btnConnect.setText("Connect");
							ledWifi.setPressed(false);

						}
					});
				//	displayStatus((byte) 0x00);
				//	log("disconnected");
				}
			}
		});	


	}
	
	
	protected void log(String string) {
	    Log.d(TAG7, string);	
	}


	private void setListeners(){
		
 
		
		btnConnect.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				if (btnConnect.getText().equals("Connect")) {
                //    isDisconnectRequested = false;
					new Thread(new Runnable() {
						public void run() {
							
                    Robot.getInstance().connect(); 
						}
					}).start();
				} else {
					// Disconnect button pressed
					//isDisconnectRequested = true;
					new Thread(new Runnable() {
						
						@Override
						public void run() {
							
     					Robot.getInstance().disconnect(); 
						}
					}).start();
    			}	
			}
		});
	    btnNordicMediaboxTest.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				 sendRequest(SBProtocol.JETTY_NORDIC_MEDIABOX_TEST + SBProtocol.JETTY_SPLIT_CHAR );
			}
		});	
		
	    btnBleDisconnect.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				 sendRequest(SBProtocol.JETTY_DISCONNECT_BEACON + SBProtocol.JETTY_SPLIT_CHAR );
			}
		});	
//	    btnGotoBeacon3.setOnClickListener(new OnClickListener() {
//			
//			@Override
//			public void onClick(View v) {
//				 sendRequest(SBProtocol.JETTY_DRIVETO_BEACON + SBProtocol.JETTY_SPLIT_CHAR + "3");
//			}
//		});	
//		btnChangeRange.setOnClickListener(new OnClickListener() {
//			
//			@Override
//			public void onClick(View v) {
//				if(txtRange.getText() == null || txtRange.getText().equals("")) return;
//			    int range = Integer.parseInt(txtRange.getText().toString());	
//			    
//				 sendRequest(SBProtocol.JETTY_CHANGE_RANGE + SBProtocol.JETTY_SPLIT_CHAR + range);
//				
//			}
//		});
//		
		//btnStatus.setOnClickListener(new OnClickListener() {
			
//			@Override
		//	public void onClick(View v) {
		//     startActivity(new Intent(MainActivity.this, SwitchBotStatus.class));		
		//	}
	//	});
		
		
	//	btnRC.setOnClickListener(new OnClickListener() {
			
////			@Override
//	//		public void onClick(View v) {
//		//      startActivity(new Intent(MainActivity.this, SwitchBotRC.class));		
//			}
//		});
		
		btnBeaconsList.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
		      startActivity(new Intent(MainActivity.this, DeviceListActivity.class));		
			}
		});

//		   btnTrack.setOnTouchListener(new OnTouchListener() {
//				
//				@Override
//				public boolean onTouch(View v, MotionEvent event) {
//					if (event.getAction() == MotionEvent.ACTION_UP) {
//
//
//					//trackOnOff(); 
//					sendRequest("trackOnOff/");
//						Log.d(TAG7, " onLongClick - Up released");
//					}
//					return false;
//				}
//			} );
//					
			
			btnADB.setOnTouchListener(new OnTouchListener() {
				
				@Override
				public boolean onTouch(View v, MotionEvent event) {
					if (event.getAction() == MotionEvent.ACTION_UP) {


						//powerOnOffProjector();
						sendRequest(SBProtocol.JETTY_ACTIVATE_ADB + SBProtocol.JETTY_SPLIT_CHAR);
						Log.d(TAG7, " onLongClick - Up released");
					}
					return false;
				}
			} );
			
			


			btnGoto.setOnTouchListener(new OnTouchListener() {

				@Override
				public boolean onTouch(View v, MotionEvent event) {

					if (event.getAction() == MotionEvent.ACTION_DOWN) {
						//moveProjectorTo(1);
						 String id = txtBeaconId.getText().toString();
						 sendRequest(SBProtocol.JETTY_GOTO_BEACON + SBProtocol.JETTY_SPLIT_CHAR + id );
						Log.d(TAG7, " onLongClick - pos :" + id);
					}
					return false;
				}
			});
			
	     btnClrEStop.setOnTouchListener(new OnTouchListener() {
				
				@Override
				public boolean onTouch(View v, MotionEvent event) {
					if (event.getAction() == MotionEvent.ACTION_DOWN) {
						//moveProjectorTo(1);
						 sendRequest(SBProtocol.JETTY_CLR_ESTOP + SBProtocol.JETTY_SPLIT_CHAR );
						Log.d(TAG7, " clear eStop" );
					}
					return false;
				}
			} );
	     
	     btnSetEStop.setOnTouchListener(new OnTouchListener() {
				
				@Override
				public boolean onTouch(View v, MotionEvent event) {
					if (event.getAction() == MotionEvent.ACTION_DOWN) {
						//moveProjectorTo(1);
						 sendRequest(SBProtocol.JETTY_SET_ESTOP + SBProtocol.JETTY_SPLIT_CHAR );
						Log.d(TAG7, " set eStop" );
					}
					return false;
				}
			} );
//
//			btnPos2.setOnTouchListener(new OnTouchListener() {
//
//				@Override
//				public boolean onTouch(View v, MotionEvent event) {
//
//					if (event.getAction() == MotionEvent.ACTION_DOWN) {
////						moveProjectorTo(2);
//						
//						 sendRequest("moveProjectorTo/" + 1 );
//						Log.d(TAG7, " onLongClick - pos 2");
//					}
//					return false;
//				}
//			});

//			btnPos3.setOnTouchListener(new OnTouchListener() {
//
//				@Override
//				public boolean onTouch(View v, MotionEvent event) {
//
//					if (event.getAction() == MotionEvent.ACTION_DOWN) {
////						moveProjectorTo(3);
//						 sendRequest("moveProjectorTo/" + 1 );
//						Log.d(TAG7, " onLongClick - pos 2");
//					}
//					return false;
//				}
//			});
	}

	private void addItemsOnSpinner() {
		

		
	}

	private void initSettings() {
//		 PropertyReader pReader = new PropertyReader(this);
//		 Properties prop = pReader.getProperties("params.properties");
//		 host = prop.getProperty("host");
		 
		SharedPreferences sharedPrefs = PreferenceManager
				.getDefaultSharedPreferences(this);
		ROBOT_IP = sharedPrefs.getString("prefHostname", "10.10.250.173");
		//mHost = "http://"+ mIp + ":8080/";
		

	}
	


	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.settings, menu);
		return true;
	}
	
	
 
	
	private void sendRequest(final String request) {
		threadMoveProjectorTo = new Thread(new Runnable() {

			@Override
			public void run() {


				Log.d(TAG7, "request: " + request );
				  
			//	mWSClient.send(request);
				Robot.getInstance().send(request);
	

			}
		});

		threadMoveProjectorTo.start();

	}
	
	
    private void mipStop() {

		threadStop = new Thread(new Runnable() {

			@Override
			public void run() {

				String url = mHost + "stop/13/5";

				URL obj = null;
				HttpURLConnection con = null;
				Log.d(TAG7, "thread stop ...");
				try {
					obj = new URL(url);

				} catch (IOException e1) {
					Log.d(TAG7, "thread ... block catch !!");
					e1.printStackTrace();
				}

				try {
					con = (HttpURLConnection) obj.openConnection();
					con.setRequestMethod("GET");
					con.setRequestProperty("User-Agent", "Mozilla/5.0");
					int responseCode = con.getResponseCode();

				} catch (IOException e1) {
					Log.d(TAG7, "thread ... block catch !!");
					e1.printStackTrace();
				}

			}
		});

		threadStop.start();

	}


	public class MoveForwardRunnable implements Runnable {

		@Override
		public void run() {

			String url = mHost + "moveForward/"+mSpeed+"/5";

			URL obj = null;
			HttpURLConnection con = null;
			int max = 0;

			try {
				obj = new URL(url);

			} catch (IOException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}

			while (flagForward && (max <= MAXIMUM_STEPS)) {
				Log.d(TAG7, "thread forward...");

				try {
					con = (HttpURLConnection) obj.openConnection();
					con.setRequestMethod("GET");
					con.setRequestProperty("User-Agent", "Mozilla/5.0");
					int responseCode = con.getResponseCode();
					Thread.sleep(REFRESH_RATE_FORWARD);

				} catch (InterruptedException e1) {
					Log.d(TAG7, "thread ... block catch !!");
					e1.printStackTrace();

				} catch (SocketException e2) {
					Log.d(TAG7, "thread ... block catch !!");
					e2.printStackTrace();
				} catch (IOException e3) {
					Log.d(TAG7, "thread ... block catch !!");
					e3.printStackTrace();
				}

				max++;
			}

		}

	}

	public class MoveBackwardRunnable implements Runnable {

		@Override
		public void run() {

			String url = mHost + "moveBackward/"+mSpeed+"/5";
			int max = 0;
			URL obj = null;
			HttpURLConnection con = null;

			try {
				obj = new URL(url);

			} catch (IOException e1) {
				Log.d(TAG7, "thread ... block catch !!");
				e1.printStackTrace();
			}

			while (flagBackward && (max <= MAXIMUM_STEPS)) {
				Log.d(TAG7, "thread backward...");

				try {
					con = (HttpURLConnection) obj.openConnection();
					con.setRequestMethod("GET");
					con.setRequestProperty("User-Agent", "Mozilla/5.0");
					int responseCode = con.getResponseCode();
					Thread.sleep(REFRESH_RATE_FORWARD);

				} catch (InterruptedException e) {
					Log.d(TAG7, "thread ... block catch !!");
					e.printStackTrace();
				} catch (SocketException e2) {
					Log.d(TAG7, "thread ... block catch !!");
					e2.printStackTrace();

				} catch (IOException e1) {
					Log.d(TAG7, "thread ... block catch !!");
					e1.printStackTrace();
				}
				max++;
			}

		}

	}

	public class MoveLeftRunnable implements Runnable {

		@Override
		public void run() {

			String url = mHost + "moveLeft/"+mSpeed+"/5";
			int max = 0;
			URL obj = null;
			HttpURLConnection con = null;

			try {
				obj = new URL(url);

			} catch (IOException e1) {
				Log.d(TAG7, "thread ... block catch !!");
				e1.printStackTrace();
			}

			while (flagLeft && (max <= MAXIMUM_STEPS)) {
				Log.d(TAG7, "thread Left...");

				try {
					con = (HttpURLConnection) obj.openConnection();
					con.setRequestMethod("GET");
					con.setRequestProperty("User-Agent", "Mozilla/5.0");
					int responseCode = con.getResponseCode();
					Thread.sleep(REFRESH_RATE_TURN);

				} catch (InterruptedException e) {
					Log.d(TAG7, "thread ... block catch !!");
					e.printStackTrace();
				} catch (SocketException e2) {
					Log.d(TAG7, "thread ... block catch !!"); 
					e2.printStackTrace();

				} catch (IOException e1) {
					Log.d(TAG7, "thread ... block catch !!");
					e1.printStackTrace();
				}
				max++;
			}

		}

	}

	public class MoveRightRunnable implements Runnable {

		@Override
		public void run() {

			String url = mHost + "moveRight/"+mSpeed+"/5";
			int max = 0;
			URL obj = null;
			HttpURLConnection con = null;
			Log.d(TAG7, "url: " + url);
			try {
				obj = new URL(url);

			} catch (IOException e1) {
				Log.d(TAG7, "thread ... block catch !!" + url);
				e1.printStackTrace();
			}

			while (flagRight && (max <= MAXIMUM_STEPS)) {
				Log.d(TAG7, "thread right...");

				try {
					con = (HttpURLConnection) obj.openConnection();
					con.setRequestMethod("GET");
					con.setRequestProperty("User-Agent", "Mozilla/5.0");
					int responseCode = con.getResponseCode();
					Thread.sleep(REFRESH_RATE_TURN);

				} catch (InterruptedException e) {
					Log.d(TAG7, "thread ... block catch 1 !! url: ");
					e.printStackTrace();
				} catch (SocketException e2) {
					Log.d(TAG7, "thread ... block catch 2!!");
					e2.printStackTrace();

				} catch (IOException e1) {
					Log.d(TAG7, "thread ... block catch 3!!");
					e1.printStackTrace();
				}
				max++;
			}

		}

	}

	
	
	// ---------- Prefs handling

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {

		switch (item.getItemId()) {
		case R.id.menu_settings:
			Intent i = new Intent(this, UserSettingActivity.class);
			startActivityForResult(i, RESULT_SETTINGS);
			break;

		}
		return true;
	}

	private void showSettings() {

		SharedPreferences sharedPrefs = PreferenceManager
				.getDefaultSharedPreferences(this);
		StringBuilder builder = new StringBuilder();
		builder.append("\n \t Host IP:\t\t \t"
				+ sharedPrefs.getString("prefHostname", "NULL"));
		builder.append("\n \t Username :\t"
				+ sharedPrefs.getString("prefUsername", "NULL"));
		TextView settings = (TextView) findViewById(R.id.txtSettings);
		settings.setText(builder);

	}
	private boolean isWsConnected() {
		//return mBtClient.getState() == SBBluetoothClient.UART_PROFILE_CONNECTED;
	    return Robot.getInstance().isConnected();	
	}
	
	@Override
	protected void onResume() {
		super.onResume();
		
		
		Log.d("MainActivity", "onResume");
		if(isWsConnected()) {
			ledWifi.setPressed(true);
		}
		
		initSettings();
		Robot.getInstance().setRobotListener(new RobotListener() {

			@Override
			public void onNotify(String action, String data) {
				if (action.equals(Robot.ACTION_DATA_AVAILABLE)) {
					log("msg: " + data);
				}
				if (action.equals(Robot.ACTION_ROBOT_CONNECTED)) {
					log("connected");
					runOnUiThread(new Runnable() {
						public void run() {
							btnConnect.setText("Disconnect");
							ledWifi.setPressed(true);
						}
					});

				}
				if (action.equals(Robot.ACTION_ROBOT_DISCONNECTED)) {

					runOnUiThread(new Runnable() {
						public void run() {
							btnConnect.setText("Connect");
							ledWifi.setPressed(false);

						}
					});
				//	displayStatus((byte) 0x00);
				//	log("disconnected");
				}
			}
		});	
		
	}
	@Override
	public void onDestroy() {
		super.onDestroy();
//		isDisconnectRequested = true;
		//mBtClient.onDestroy();
		Robot.getInstance().disconnect();

	}
		@Override
	public void onBackPressed() {;
//	    isDisconnectRequested = true;
	    Robot.getInstance().disconnect();
		btnConnect.setText("Connect");
		this.finish();
	}
	
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);

		switch (requestCode) {
		case RESULT_SETTINGS:
			showSettings();
			SharedPreferences sharedPrefs = PreferenceManager
					.getDefaultSharedPreferences(this);
			ROBOT_IP = sharedPrefs.getString("prefHostname", "10.10.250.115");
			//mHost = "http://" + mIp + ":8080/";

			break;

		}
	}

}
