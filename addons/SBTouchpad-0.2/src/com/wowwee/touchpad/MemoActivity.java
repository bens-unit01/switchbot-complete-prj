package com.wowwee.touchpad;

import org.json.JSONObject;

import com.shenetics.sheai.SHE;
import com.wowwee.util.SBProtocol;

import android.app.Activity;
import android.graphics.Color;
import android.os.Bundle;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.view.View.OnClickListener;
import android.webkit.WebView;


public class MemoActivity extends Activity {
   
    public static String TAG = "Memo";
	private final String SB1_USER_NAME=  "sbot2@she.ai";
    private final String SB2_USER_NAME=  "sbot2@she.ai";
	private final String SB3_USER_NAME=  "sbot2@she.ai";
	private final String SB4_USER_NAME=  "sbot2@she.ai";

	
	private WebView	 mWebView = null;
    private SHE mAI = null;
    private FloatingActionButton mFAB = null;
    private String mUsername = SB1_USER_NAME;
    
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.memo);
		
		switch (MainActivity.SELECTED_SWITCHBOT) {
		case MainActivity.SWITCHBOT_1_GREEN: mUsername = SB1_USER_NAME;
			break;
		case MainActivity.SWITCHBOT_2_YELLOW: mUsername = SB2_USER_NAME; 
			break;
		case MainActivity.SWITCHBOT_3_RED: mUsername = SB3_USER_NAME;
			break;
		case MainActivity.SWITCHBOT_4_BLUE: mUsername = SB4_USER_NAME; 
			break;
		}

		mWebView = (WebView) findViewById(R.id.webview);
		
		mFAB = new FloatingActionButton.Builder(this)
			.withDrawable(getResources().getDrawable(R.drawable.ic_action_mic))
	        .withButtonColor(Color.BLUE)
	        .withGravity(Gravity.BOTTOM | Gravity.RIGHT)
	        .withButtonSize(86)
	        .create();
		 
		if (mFAB != null) {
			 mFAB.setOnClickListener(new View.OnClickListener() {
				 @Override
				 public void onClick(View v) {
					 if (mAI != null) {
						 mFAB.setFloatingActionButtonColor(Color.RED);
						 mAI.startAsr();
					 }
		         }
			 });			 
		}
		
		mAI = new SHE(this) {
			@Override
			public void loginAuth(boolean isValid) {
				Log.d("SHE::loginAuth", (isValid ? "True" : "False"));
			}

			@Override
			public void listeningStart() {
				// update LEDs
				super.listeningStart();
			}
			
			@Override
			public void listeningStop() {
				// update LEDs
				super.listeningStop();
				 mFAB.setFloatingActionButtonColor(Color.BLUE);
			}
			
			@Override
			public void thinkingStart() {
				// update LEDs
				super.thinkingStart();
			}
			
			@Override
			public void thinkingStop() {
				// update LEDs
				super.thinkingStop();
			}
		};
		if (mAI == null) {
			Log.d("MemoActivity", "SHE cannot create assistant, exiting program ...");
			this.finish();
			return;
		}
		mAI.setWebView(mWebView);
		mAI.login(mUsername, "GoDogLabs2");
	}

	
	

	
   
}