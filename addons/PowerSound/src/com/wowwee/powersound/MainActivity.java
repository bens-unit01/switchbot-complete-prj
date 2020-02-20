package com.wowwee.powersound;

import java.io.IOException;

import com.example.powersound.R;

import android.app.Activity;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.media.MediaPlayer.OnPreparedListener;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;

public class MainActivity extends Activity {
    
	private final String TAG = getClass().getSimpleName();
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);
	try {
			Thread.sleep(10000);
	
		} catch (InterruptedException e) {
			e.printStackTrace();
			Log.d("PowerSound", "bloc catch ... ex: " + e.getMessage());
		} 
	
	
     MediaPlayer mediaPlayer = MediaPlayer.create(this, R.raw.powerup);
     mediaPlayer.start();
     
     // activating adb through wifi 
     
 
	/*new Thread(new Runnable() {
		
		@Override
		public void run() {
			// wait until we connect to the wifi network 
            while(!Utils.isWifiConnected()){
               delay(1000); 
            }
            
             delay(40000); 
             try {
            	Log.d(TAG, "activating adb through wifi, have root: " + AdbUtilS.haveRoot()); 
				AdbUtilS.set(5555);
			} catch (IOException | InterruptedException e) {
				e.printStackTrace();
			}
            
            MainActivity.this.finish();
            return;
			
		}

		private void delay(int time) {
			      	try {
					Thread.sleep(time);
				} catch (InterruptedException e) {
					e.printStackTrace();
				}
		}

		
	}).start();	
	*/
    this.finish();
    return;
		
	}
}
