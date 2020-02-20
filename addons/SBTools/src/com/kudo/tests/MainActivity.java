package com.kudo.tests; import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import com.wowwee.switchbot.SBRealDeviceFactory;
import com.wowwee.switchbot.SBRobot;
import com.wowwee.switchbot.SBRobot.RobotEvent;
import com.wowwee.switchbot.SBRobot.RobotListener;

import android.media.AudioManager;
import android.media.MediaPlayer;
import android.net.wifi.ScanResult;
import android.net.wifi.WifiConfiguration;
import android.net.wifi.WifiManager;
import android.os.Bundle;
import android.os.Handler;
import android.app.Activity;
import android.app.Dialog;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.speech.RecognitionListener;
import android.speech.RecognizerIntent;
import android.speech.SpeechRecognizer;
import android.util.Log;
import android.view.Menu;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;
import android.view.View.OnClickListener;;

public class MainActivity extends Activity {
	
	  ListView lv;
      WifiManager wm;
	  String wifis[];
	  WifiScanReceiver wifiReciever;

	 private TextView mText;
	 private Context context = this;
	 private Dialog refDialog;
	   private SpeechRecognizer sr;
	   private static final String TAG = "SBTools";
	   
	//   private Intent intent; 
	   
	   Handler handler; 
	   @Override
	   public void onCreate(Bundle savedInstanceState) 
	   {
	            super.onCreate(savedInstanceState);
	            setContentView(R.layout.activity_main);
	            
	              
	            Button btnSpeak = (Button) findViewById(R.id.btn_speak);
	            Button btnActivateAdb = (Button) findViewById(R.id.btn_activate_adb); 
	            mText = (TextView) findViewById(R.id.textView1);   
	            
	            
//	       	uart_test();
//          adb_test(btnActivateAdb);
//          sd_storage_test(); 
// 	        wifi_test_1(); 
//            wifi_test_2();  
          speech_recognizer_test(btnSpeak);
//	        audio_in_test();         
//       audio_out_test(); 	              
	           	       
   }

	private void uart_test() {
		final SBRobot mSwitchBotMcu; 
		final int SB_Q410_BOARD = 3;
		
		Log.d(TAG, "uart test ..."); 
		SBRealDeviceFactory.setSelectedDevice(SB_Q410_BOARD, context);
		SBRealDeviceFactory.getInstance().addRobotListener(new RobotListener() {
			
			@Override
			public void onNotify(RobotEvent e) {
			Log.d(TAG, "-- input: " + bytesToHex2(e.getData()));
			}
		});
		
       mSwitchBotMcu =		SBRealDeviceFactory.getInstance(); 	
		
	     new Thread(new Runnable() {
	      byte data[] = {0x54, 0x01, 0x02}; 	
		@Override
		public void run() {
		      while(true){
		    	  
		    	 mSwitchBotMcu.write(data);
		    	 Log.d(TAG, "uart test ..."); 
		    	 try {
					Thread.sleep(1000);
				} catch (InterruptedException e) {
					e.printStackTrace();
				}
		      }	
		    }
	    }).start(); 
	}
	   
		public static String bytesToHex2(byte[] a) {
			StringBuilder sb = new StringBuilder(a.length * 4);
			for (byte b : a) {
				sb.append(String.format("%02x", b & 0xff));
				sb.append("-");
			}
			return sb.toString();
	 	}	
	  

	private void speech_recognizer_test(Button btnSpeak) {
		handler = new Handler();         
		sr = SpeechRecognizer.createSpeechRecognizer(this);       
		sr.setRecognitionListener(new TestListener());   

		
	handler.post(new Runnable() {
		
		@Override
		public void run() {
				testSpeechRecognizer(); 
		    try {
				Thread.sleep(2000);
				Log.d(TAG, "test ... "); 
			} catch (InterruptedException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} 
		}
	}); 	
	
    btnSpeak.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				
//                     testDialog(v); 
			   testSpeechRecognizer(); 
			}
		});
	}


	private void adb_test(Button btnActivateAdb) {
		btnActivateAdb.setOnClickListener(new OnClickListener() {
		
		@Override
		public void onClick(View v) {
		try {
			Log.d(TAG, "Activating adb ..."); 
			AdbUtils.set(5555);
		} catch (IOException e) {
		    Log.d(TAG, "activate adb exception IOExcepton ..."); 	
			e.printStackTrace();
		} catch (InterruptedException e) {
		    Log.d(TAG, "activate adb exception InterruptedException ..."); 	
			e.printStackTrace();
		} 	
		}
        });
	}


	private void sd_storage_test() {
		Boolean isSd = android.os.Environment.getExternalStorageState().equals(android.os.Environment.MEDIA_MOUNTED);
		   Log.d(TAG, " isSd : " + isSd);
	}


	private void wifi_test_2() {
		new Thread(new Runnable() {
			
			@Override
			public void run() {
			
				while(true){
					
				try {
				
		         List<ScanResult> sr = wm.getScanResults();
		         Log.d(TAG, " Nb hotspots : " + sr.size()); 
				 for(ScanResult r:sr){
			     Log.d(TAG, " scan-result: " + r.SSID +  " level " + WifiManager.calculateSignalLevel(r.level, 5) + " dbm: " + r.level);  
		         }
			     Log.d(TAG, "------"); 	
				 Thread.sleep(1000);
				} catch (InterruptedException e) {
					e.printStackTrace();
				}	
				}
			}
		}).start();
	}


	private void wifi_test_1() {
		wm = (WifiManager)this.getSystemService(Context.WIFI_SERVICE);
		wifiReciever = new WifiScanReceiver();
		wm.startScan(); 
        List<ScanResult> sr = wm.getScanResults();
        List<WifiConfiguration> lw = wm.getConfiguredNetworks(); 
         for(WifiConfiguration c:lw){
		  Log.d(TAG, " wifi-conf: " + c.SSID + " id: " + c.networkId);  
         } 
        
         for(ScanResult r:sr){
          Log.d(TAG, " scan-result: " + r.SSID +  " level " + WifiManager.calculateSignalLevel(r.level, 5) + 
        		  " dbm: " + r.level);  
        	 
         }
        wm.disconnect();  
        wm.enableNetwork(0, true);
         Log.d(TAG, " reconnect: " +  wm.reconnect());
	}
	   
	   
	   
	   private class WifiScanReceiver extends BroadcastReceiver{
		      public void onReceive(Context c, Intent intent) {
		         List<ScanResult> wifiScanList = wm.getScanResults();
		         wifis = new String[wifiScanList.size()];
		         
		         for(int i = 0; i < wifiScanList.size(); i++){
		            wifis[i] = ((wifiScanList.get(i)).toString());
		            Log.d(TAG, " WifiScanReceiver i: " + i + " scan-list: " + wifis[i]);  
		            
		         }
		      //   lv.setAdapter(new ArrayAdapter<String>(getApplicationContext(),android.R.layout.simple_list_item_1,wifis));
		      }
		   }
	   
	   
	   private void audio_out_test(){
		   
//		   final MediaPlayer mediaPlayer = MediaPlayer.create(this, R.raw.song);
		   final MediaPlayer mediaPlayer = MediaPlayer.create(this, R.raw.powerup);
//			AudioManager am = 
//				    (AudioManager) getSystemService(Context.AUDIO_SERVICE);
//
//				am.setStreamVolume(AudioManager.STREAM_MUSIC, am.getStreamMaxVolume(AudioManager.STREAM_MUSIC), 4);
//				am.setStreamVolume(
//					    AudioManager.STREAM_SYSTEM,
//					    am.getStreamMaxVolume(AudioManager.STREAM_SYSTEM),
//					    4);
//			Log.d(TAG, " audio-volume: " +  am.getStreamMaxVolume(AudioManager.STREAM_SYSTEM) + " " + am.getStreamMaxVolume(AudioManager.STREAM_MUSIC)); 
//		  for(int i = 0; i < 10; i++){    
//			am.adjustVolume(AudioManager.ADJUST_RAISE, AudioManager.FLAG_ALLOW_RINGER_MODES);	
//		  } 
		  new Thread(new Runnable() {  
			
			@Override
			public void run() { 
			while(true){	
 		      mediaPlayer.start(); 
 		      Log.d(TAG, " playing sound ...");  
 		      try {
				Thread.sleep(3000);
			} catch (InterruptedException e) {
	            Log.d(TAG, " bloc catch ..."); 		  	
				e.printStackTrace();
			}
			}
			}
		}).start();  
	   }
	   
	   
	   private void audio_in_test(){
		         
	            
	            handler.post(new Runnable() {
					
					@Override
					public void run() {
					
						try {
						   Log.d(TAG, " speech thread init ..."); 
							Thread.sleep(3000);
							} catch (InterruptedException e) {
								e.printStackTrace();
							}
					
					   testSpeechRecognizer(); 
					   Log.d(TAG, " speech thread loop ..."); 
	                	
				  

					}
				}); 
	       
		   
	   }
	 
	   private void testSpeechRecognizer(){
		   
       Intent intent = new Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH);        
       intent.putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL,RecognizerIntent.LANGUAGE_MODEL_FREE_FORM);
//   intent.putExtra(RecognizerIntent.EXTRA_CALLING_PACKAGE,"voice.recognition.test");
//       intent.putExtra(RecognizerIntent.EXTRA_CALLING_PACKAGE, "com.example.a5voice");
       intent.putExtra(RecognizerIntent.EXTRA_CALLING_PACKAGE, "com.kudo.tests");

       intent.putExtra(RecognizerIntent.EXTRA_MAX_RESULTS,1); 
                sr.startListening(intent);
                Log.i("A3","11111111"); 
		   
	   }
	   private void testDialog(View v){
							final Dialog dialog = new Dialog(context);
						refDialog = dialog;
						dialog.setContentView(R.layout.speak_now);
						dialog.setTitle("Title...");
			 
						// set the custom dialog components - text, image and button
						TextView text = (TextView) dialog.findViewById(R.id.text);
						text.setText("Android custom dialog example!");
						ImageView image = (ImageView) dialog.findViewById(R.id.image);
						image.setImageResource(R.drawable.ic_launcher);
						dialog.show();
			 
						Button dialogButton = (Button) dialog.findViewById(R.id.dialogButtonOK);
						  if (v.getId() == R.id.btn_speak) 
				            {
				                Intent intent = new Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH);        
				                intent.putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL,RecognizerIntent.LANGUAGE_MODEL_FREE_FORM);
				                intent.putExtra(RecognizerIntent.EXTRA_CALLING_PACKAGE,"voice.recognition.test");

				                intent.putExtra(RecognizerIntent.EXTRA_MAX_RESULTS,1); 
				                     sr.startListening(intent);
				                     Log.i("A3","11111111");
					         }	   
		   
	   }

	   class TestListener implements RecognitionListener          
	   {
	            public void onReadyForSpeech(Bundle params)
	            {
	                     Log.d(TAG, "onReadyForSpeech");
	            }
	            public void onBeginningOfSpeech()
	            {
	                     Log.d(TAG, "onBeginningOfSpeech");
	            }
	            public void onRmsChanged(float rmsdB)
	            {
	                     Log.d(TAG, "onRmsChanged");
	            }
	            public void onBufferReceived(byte[] buffer)
	            {
	                     Log.d(TAG, "onBufferReceived");
	            }
	            public void onEndOfSpeech()
	            {
	                     Log.d(TAG, "onEndofSpeech");
	            }
	            public void onError(int error)
	            {
	                     Log.d(TAG,  "error " +  error);
	                     mText.setText("error " + error);
	                     
	                     try {
							Thread.sleep(1000);
						} catch (InterruptedException e) {
							// TODO Auto-generated catch block
							e.printStackTrace();
						}
	                     
	                     testSpeechRecognizer(); 
	                     
	            }
	            public void onResults(Bundle results)                   
	            {
	                     String str = new String();
	                     
	                     ArrayList data = results.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION);
	                     for (int i = 0; i < data.size(); i++)
	                     {
	                               Log.d(TAG, "result " + data.get(i));
	                               str += data.get(i);
	                     }
	                     Log.d(TAG, "onResults results" + results+" str:"+str);
	                     mText.setText("results: "+String.valueOf(data.size()));  
	                     try {
							Thread.sleep(1000);
						} catch (InterruptedException e) {
							// TODO Auto-generated catch block
							e.printStackTrace();
						}  
	                     testSpeechRecognizer(); 
//	                    refDialog.dismiss();
	                     
	            }
	            public void onPartialResults(Bundle partialResults)
	            {
	                     Log.d(TAG, "onPartialResults");
	            }
	            public void onEvent(int eventType, Bundle params)
	            {
	                     Log.d(TAG, "onEvent " + eventType);
	            }
	   }
	   public void onClick(View v) {
	         /*   if (v.getId() == R.id.btn_speak) 
	            {
	                Intent intent = new Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH);        
	                intent.putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL,RecognizerIntent.LANGUAGE_MODEL_FREE_FORM);
	                intent.putExtra(RecognizerIntent.EXTRA_CALLING_PACKAGE,"voice.recognition.test");

	                intent.putExtra(RecognizerIntent.EXTRA_MAX_RESULTS,5); 
	                     sr.startListening(intent);
	                     Log.i("111111","11111111");
	            }*/
	   }
	   
	  @Override
	protected void onResume() {
	//	  registerReceiver(wifiReciever, new IntentFilter(WifiManager.SCAN_RESULTS_AVAILABLE_ACTION));
		super.onResume();
	} 
	   @Override
	protected void onPause() {
		
	//	unregisterReceiver(wifiReciever); 
		super.onPause();
	}

}
