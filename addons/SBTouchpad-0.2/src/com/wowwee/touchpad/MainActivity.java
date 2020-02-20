package com.wowwee.touchpad;

import java.net.URISyntaxException;
import java.util.Set;

import com.wowwee.util.SBProtocol;

import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.preference.PreferenceManager;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem; 
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.ImageButton; 
import android.widget.Toast;
import android.app.Activity;
import android.content.ActivityNotFoundException;
import android.content.Intent;
import android.content.SharedPreferences;
import at.markushi.ui.CircleButton;

public class MainActivity extends Activity implements OnClickListener {

	final String TAG = getClass().getSimpleName();
	private Button btnRc, btnShe, btnStatus, btnTelepresence;
	private final String SHE_PACKAGE_NAME = "com.godog.godogfetch";
	private ImageButton btnSwitchbot;
	
	public static final int REQUEST_CODE_CHANGE_SETTINGS =  3;
	public static final int REQUEST_CODE_SELECT_SWITCHBOT = 5;
	public static final int SWITCHBOT_1_GREEN  = 1;
	public static final int SWITCHBOT_2_YELLOW = 2;
	public static final int SWITCHBOT_3_RED    = 3;
	public static final int SWITCHBOT_4_BLUE   = 4;
	public static int SELECTED_SWITCHBOT =  SWITCHBOT_1_GREEN;
	public static String SWITCHBOT_IP =  "10.10.250.173";
	
  	

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);
		
         btnSwitchbot = (ImageButton)findViewById(R.id.btn_selected_switchbot); 
 		SharedPreferences sharedPrefs = PreferenceManager
				.getDefaultSharedPreferences(this);	
         SWITCHBOT_IP = sharedPrefs.getString("ipSB"+ SELECTED_SWITCHBOT, "10.10.250.173");
	}

	@Override
	protected void onPause() {
		super.onPause();

	}

	@Override
	protected void onResume() {
		super.onResume();
     Log.d(TAG, "onResume ..."); 
     switch (SELECTED_SWITCHBOT) {
	case SWITCHBOT_1_GREEN:
		btnSwitchbot.setBackgroundResource(R.drawable.btn_robotlist_green);
		//btnSwitchbot.
		break;
	case SWITCHBOT_2_YELLOW:
		btnSwitchbot.setBackgroundResource(R.drawable.btn_robotlist_yellow);
		break;
	case SWITCHBOT_3_RED:
		btnSwitchbot.setBackgroundResource(R.drawable.btn_robotlist_red);
		break;
	case SWITCHBOT_4_BLUE:
		btnSwitchbot.setBackgroundResource(R.drawable.btn_robotlist_bleu);
		break;
	default:
		break;
	}

	}

	@Override
	public void onClick(View v) {
		Intent intent;
		switch (v.getId()) {
		
		

		case R.id.btn_selected_switchbot:
		     intent	 = new Intent(MainActivity.this, RobotListActivity.class);
			 startActivityForResult(intent, REQUEST_CODE_SELECT_SWITCHBOT);
			break;
		case R.id.btnRC:
		 	if (isRightOS()) {
				intent = new Intent(this, SwitchBotRC.class);
				startActivity(intent);
			}
			break;
		case R.id.btnShe:
		    intent = new Intent(MainActivity.this, MemoActivity.class);
			startActivityForResult(intent, 1);
			break;
		case R.id.btnStatus:
			if (isRightOS()) {
				intent = new Intent(this, SwitchBotStatus.class);
				startActivity(intent);
			}

			break;
		case R.id.btnTelepresence:
			try {
				intent = Intent.parseUri("telepresenceapp://" + "LAUNCH" + SELECTED_SWITCHBOT +"//",
						Intent.URI_INTENT_SCHEME);
				
				startActivity(intent);
			} catch (URISyntaxException e) {
				e.printStackTrace();
			} catch (ActivityNotFoundException e) {
				e.printStackTrace();
			}
			break;
			
			
		case R.id.btnDrivePath:
			   intent = new Intent(this, DrivePathActivity.class);
			   startActivity(intent);
			break;

		}

	}
	
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);
		
		
		if (resultCode == Activity.RESULT_OK && requestCode == REQUEST_CODE_SELECT_SWITCHBOT
				&& data != null){
		 SELECTED_SWITCHBOT = data.getIntExtra("id", SWITCHBOT_1_GREEN);	
			
		}
		
		
		if(requestCode == REQUEST_CODE_SELECT_SWITCHBOT || requestCode == REQUEST_CODE_CHANGE_SETTINGS){
			SharedPreferences sharedPrefs = PreferenceManager
					.getDefaultSharedPreferences(this);
			SWITCHBOT_IP = sharedPrefs.getString("ipSB"+ SELECTED_SWITCHBOT, "10.10.250.173");
			Log.d(TAG, "onActivityResult  ip: " + SWITCHBOT_IP);
			
		}
	}

	private boolean isRightOS() {
		return true;
		/*
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR2) {
			return true;
		} else {
			Toast t = Toast.makeText(this,
					"This activity uses BLE, you need Android 4.3 or higher",
					Toast.LENGTH_LONG);
			t.show();
			return false;
		}
		*/
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.settings, menu);
		return true;
	}
	
	@Override
	public boolean onOptionsItemSelected(MenuItem item) {

		switch (item.getItemId()) {
		case R.id.menu_settings:
			Intent i = new Intent(this, UserSettingActivity.class);
			startActivityForResult(i, REQUEST_CODE_CHANGE_SETTINGS);
			break;

		}
		return true;
	}
		

}
