package com.wowwee.touchpad;



import java.net.URISyntaxException;
import java.util.Set;

import com.wowwee.touchpad.Robot.RobotListener;
import com.wowwee.util.SBProtocol;
import com.wowwee.views.JoystickView;
import com.wowwee.views.JoystickView.OnJoystickMoveListener;

import android.os.Bundle;
import android.os.Handler;
import android.app.Activity;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.content.Context;
import android.content.Intent;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnTouchListener;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.ScrollView;
import android.widget.SeekBar;
import android.widget.Toast;
import android.widget.ToggleButton;
import android.widget.SeekBar.OnSeekBarChangeListener;
import android.widget.TextView;

public class SwitchBotRC extends Activity  implements OnClickListener {
	private static final int REQUEST_SELECT_DEVICE = 1;
	private static final int REQUEST_ENABLE_BT = 2;
	//private BluetoothDevice mDevice = null;
	//private BluetoothAdapter mBtAdapter = null;
	private boolean isDisconnectRequested = false;
	//private String mDeviceAdress = null; 
	//private SBBluetoothClient mBtClient = null;
	private final int MAX_VALUE = 0x10;
	private final int MAX_VALUE_LR = 0x07;

	final String TAG = getClass().getSimpleName();
	private Button  btnConnect;
	private ImageButton ledBluetooth;
	//public BluetoothAdapter mBluetoothAdapter;
    private JoystickView joystick; 
    
	private void log(final String str) {
				Log.d(TAG, " log " + str  );
	}
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.switchbot_rc);
		
		btnConnect = (Button)findViewById(R.id.btnConnect);
		//tglContinuesMode.setChecked(false);
		joystick = (JoystickView)findViewById(R.id.joystick);
		ledBluetooth = (ImageButton)findViewById(R.id.btnLedBluetooth);
		//mBtAdapter = BluetoothAdapter.getDefaultAdapter();
		Log.d(TAG, "selected SB: " + MainActivity.SELECTED_SWITCHBOT);
		setListeners();
		
		 

	}

	private void setListeners() {
		
		
	joystick.setOnJoystickMoveListener(new OnJoystickMoveListener() {
		
		@Override
		public void onValueChanged(int angle, int power, int direction) {
			
			updateValues(angle, power);
		}


	}, 200);	
	
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
						ledBluetooth.setPressed(true);
					}
				});

			}
			if (action.equals(Robot.ACTION_ROBOT_DISCONNECTED)) {

				runOnUiThread(new Runnable() {
					public void run() {
						btnConnect.setText("Connect");
						ledBluetooth.setPressed(false);

					}
				});
				log("disconnected");
			}
		}
	});
/*	
	mBtClient = new SBBluetoothClient(this);
	mBtClient.addSBBluetoothListener(new SBBluetoothListener() {

		@Override
		public void onNotify(String action, byte[] data) {
			if (action.equals(UartService.ACTION_DATA_AVAILABLE)) {
				if(data.length < 2) return;  // we need at least 2 bytes   
				//displayStatus(data[1]);

			}

			if (action.equals(UartService.ACTION_GATT_CONNECTED)) {
				log(mDevice.getName() + " - ready");
				ledBluetooth.setPressed(true);
				btnConnect.setText("Disconnect");
			}

			if (action.equals(UartService.ACTION_GATT_DISCONNECTED)) {
				log(" Disconnected from: " + mDevice.getName());
				btnConnect.setText("Connect");
				ledBluetooth.setPressed(false);
			// we reconnect	
				if(!isDisconnectRequested)
					mBtClient.connect(mDeviceAdress);
			}
			
			Log.i(TAG, "onNotify action: " + action  + " mState: " + mBtClient.getState());

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

	}
	
	private void updateValues(int angle, int power) {
	 
		int fwd_bwd = 0, left_right = 0;
		String cmd = "";
        
		if( angle <= 90 && angle >= -90){
        	 fwd_bwd = power * 0x20 / 100;
			   fwd_bwd = power * MAX_VALUE / 100;
        	if(angle >= 0 ){
        	    left_right  = getAngle(angle, 0x41);	
        		log("forward right " + fwd_bwd + " " + left_right);
        	}else {
        	    left_right  = getAngle(-angle, 0x61);	
        		log("forward left "+ fwd_bwd + " " + left_right);
        	}
        }else{
        	fwd_bwd = (power * 0x20 /100) + 0x21;
        	fwd_bwd = (power * MAX_VALUE/100) + 0x21;
        	if(angle <= -90){
        	    left_right  = getAngle(180 + angle, 0x61);	
        		log("backward left "+ fwd_bwd + " " + left_right);
        	}else {
        	    left_right  = getAngle(180 - angle, 0x41);	
        		log("backward right "+ fwd_bwd + " " + left_right);
        	}
        }

		
     //   		log(" f-b -->"+ fwd_bwd + " " + left_right);
		cmd = SBProtocol.JETTY_DRIVE + SBProtocol.JETTY_SPLIT_CHAR;
		cmd +=  fwd_bwd + SBProtocol.JETTY_SPLIT_CHAR;
		cmd +=  left_right + SBProtocol.JETTY_SPLIT_CHAR;
		
		if(isWsConnected()) {
		  send(cmd);	
		}           
		
	}
	private int getAngle(int angle, int minValue) {
		//return angle * 0x1f / 90 + minValue;  
		return angle * MAX_VALUE_LR/ 90 + minValue;  
	}

	@Override
	public void onClick(View view) {
		
	  String cmd = "nop";	
      switch (view.getId()) {
		
//		case R.id.btnKneel:
//			cmd = SBProtocol.JETTY_KNEEL; 
//			break;
//		case R.id.btnStandup:
//			cmd = SBProtocol.JETTY_STAND_UP; 
//			break;
//		case R.id.btnLeanForward:
//			//byte[] tmp8 = SBProtocol.ENCODED_LEAN_FORWARD; 
//			cmd = SBProtocol.JETTY_LEAN_FORWARD; 
//			break;
//		case R.id.btnLeanbackward:
////			byte[] tmp9 =  SBProtocol.ENCODED_LEAN_BACKWARD ; 
//			cmd = SBProtocol.JETTY_LEAN_BACKWARD;
//			break;
		case R.id.btnEStop:
//			byte[] tmp10 = {SBProtocol.ESTOP, 0, 0}; 
			cmd = SBProtocol.JETTY_SET_ESTOP;
			break;
		case R.id.btnClrEStop:
//			byte[] tmp11 = {SBProtocol.CLEAR_ESTOP, 0, 0}; 
			cmd = SBProtocol.JETTY_CLR_ESTOP;
			break;

	default:
		break;
	}
  
      if(isWsConnected() && !cmd.equals("nop")){    
    	  cmd += SBProtocol.JETTY_SPLIT_CHAR;
    	  //mBtClient.writeRX(cmd);
    	  send(cmd);
      }
		
	}
	
	private boolean isWsConnected() {
		//return mBtClient.getState() == SBBluetoothClient.UART_PROFILE_CONNECTED;
	    return Robot.getInstance().isConnected();	
	}

	
	@Override
	protected void onPause() {
		super.onPause();
	}
	

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {


	}
	
	

	@Override
	public void onResume() {
		super.onResume();
		Log.d(TAG, "onResume");
	
		
		ledBluetooth.setPressed(false);
		if(isWsConnected()) {
			ledBluetooth.setPressed(true);
		}

	}
	
	@Override
	public void onDestroy() {
		super.onDestroy();
		isDisconnectRequested = true;
		//mBtClient.onDestroy();
		Robot.getInstance().disconnect();

	}
		@Override
	public void onBackPressed() {;
	    isDisconnectRequested = true;
	    Robot.getInstance().disconnect();
		btnConnect.setText("Connect");
		this.finish();
	}
	
	
	private void send(final String cmd){
		new Thread(new Runnable() {
			public void run() {
			Robot.getInstance().send(cmd);	
			}
		}).start();
	}


}
