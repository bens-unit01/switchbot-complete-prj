package com.example.touchpad01;

import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.GridView;
import android.app.Activity;

public class DrivePathActivity extends Activity {

	private String mHostname;
	final String TAG = getClass().getSimpleName();


	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_drive_path);
	//	mHostname = "http://" + MainActivity.getHostname() + ":8080/";
	
     GridView gridView = (GridView)findViewById(R.id.grid_view);
     gridView.setAdapter(new GridAdapter(this));
	
	}


}