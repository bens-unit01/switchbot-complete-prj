package com.wowwee.touchpad;


import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import at.markushi.ui.CircleButton;


public class RobotListActivity extends Activity {

	private CircleButton btnRed, btnBleu, btnGreen, btnYellow;
	
	private OnClickListener mRobotSelectListener = new OnClickListener() {
			
			@Override
			public void onClick(View v) {
			int id = 1;	
				switch (v.getId()) {
				case R.id.btn_green:
					id = MainActivity.SWITCHBOT_1_GREEN;
					break;

				case R.id.btn_yellow: 
					id = MainActivity.SWITCHBOT_2_YELLOW;
					break;

				case R.id.btn_red:
					id = MainActivity.SWITCHBOT_3_RED;
					break; 
			
				case R.id.btn_blue: 
					id = MainActivity.SWITCHBOT_4_BLUE;
					break;
				default:
					break;
				}
				Log.d("RobotListActivity", " onClick id:  "  + id); 
				 Bundle b = new Bundle();
				 b.putInt("id", id);
				 Intent result = new Intent();
				 result.putExtras(b);
				 setResult(Activity.RESULT_OK, result);
			     RobotListActivity.this.finish();	
			}
	};
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.robot_list);
		
		
		btnRed = (CircleButton)findViewById(R.id.btn_red); 
		btnBleu = (CircleButton)findViewById(R.id.btn_blue); 
		btnGreen = (CircleButton)findViewById(R.id.btn_green); 
		btnYellow  = (CircleButton)findViewById(R.id.btn_yellow);
		
		
		btnRed.setOnClickListener(mRobotSelectListener);
		btnBleu.setOnClickListener(mRobotSelectListener);
		btnGreen.setOnClickListener(mRobotSelectListener);
		btnYellow.setOnClickListener(mRobotSelectListener);

	}


}
