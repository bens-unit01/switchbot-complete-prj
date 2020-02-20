package com.example.touchpad01;

import org.eclipse.jetty.websocket.api.Session;

import android.util.Log;

import com.wowwee.ws_client.ClientListener;
import com.wowwee.ws_client.EventClient;

/*
 * Singleton desing pattern
 * This class provide a communication link to SwitchBot through WebSockets  
 */
public class Robot {

	private static Robot mRobot = null;
	private static RobotListener mRobotListener = null;
	private EventClient mEventClient = null;
	private Boolean isCloseRequested = false;
	
    public final static String ACTION_ROBOT_CONNECTED = "CONNECTED";
    public final static String ACTION_ROBOT_DISCONNECTED = "DISCONNECTED";
    public final static String ACTION_DATA_AVAILABLE = "DATA";
  
	private static final String TAG = "Robot";
	private Robot() {
		super();
		mEventClient = new EventClient(new ClientListener() {

			@Override
			public void onText(String str) {
				if (null != mRobotListener) {
					mRobotListener.onNotify(ACTION_DATA_AVAILABLE, str);
				}
			}

			@Override
			public void onError(Throwable cause) {
				log("Robot#onError  " + g());
                // reconnect();
			}

			@Override
			public void onDisconnect(int statusCode, String reason) {
				// reconnect();
				if (null != mRobotListener) {
					mRobotListener.onNotify(ACTION_ROBOT_DISCONNECTED, "");
				}

			}

			private void reconnect() {
				new Thread(new Runnable() {

					@Override
					public void run() {
						log("Robot#reconnect ...");
                        try {
							Thread.sleep(2000);
						
							if (!mEventClient.isOpen() && !isCloseRequested) {
							    mEventClient.reconnect();
						    }
						} catch (InterruptedException e) {
							e.printStackTrace();
						} 
	
					}
				}).start();

			}

			@Override
			public void onConnect(Session session) {
				if (null != mRobotListener) {
					mRobotListener.onNotify(ACTION_ROBOT_CONNECTED, "");
				}


			}
		});
	}

	protected void log(String string) {
	   Log.d(TAG, string);	
	}


	public String g() {
		return "Robot [mEventClient=" + mEventClient + ", isCloseRequested="
				+ isCloseRequested + ", mRobot =" + mRobot + ", mRobotListener ="+ mRobotListener+ "]";
	}

	public static Robot getInstance() {

		if (null == mRobot) {
			mRobot = new Robot();
		}

		return mRobot;
	}

	public interface RobotListener {
		public void onNotify(String action, String data); 
	}

	public void setRobotListener(RobotListener listener) {
	
		mRobotListener = listener;
			    
	}

	public void disconnect() {
		isCloseRequested = true;
		mEventClient.disconnect();
	}
	
	public void send(String str){
	   mEventClient.send(str);	
	}

	
	public void connect(){
		mEventClient.connect();
	}
   public Boolean isConnected(){
	   return mEventClient.isOpen();
   }	
}
