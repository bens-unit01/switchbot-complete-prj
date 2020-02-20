package com.wowwee.ws_client;

/* This class was inspired by source : https://github.com/jetty-project/embedded-jetty-websocket-examples
 */
import java.io.IOException;
import java.net.URI;
import java.nio.ByteBuffer;
import java.util.concurrent.Future;

import org.eclipse.jetty.security.SecurityHandler.NotChecked;
import org.eclipse.jetty.websocket.api.Session;
import org.eclipse.jetty.websocket.api.WriteCallback;
import org.eclipse.jetty.websocket.client.WebSocketClient;

import com.example.touchpad01.MainActivity;

import android.util.Log;

public class EventClient {

	@Override
	public String toString() {
		return "EventClient [mSession=" + mSession + ", mSocket=" + mSocket
				+ ", mClientListener=" + mClientListener
				+ ", mWebSocketClient=" + mWebSocketClient + "]";
	}

	private Session mSession = null;
	private EventSocket mSocket = null;
	private ClientListener mClientListener = null;
	private WebSocketClient mWebSocketClient = null;

	public EventClient() {
		//connect();
	}
	public EventClient(ClientListener listener) {
		this();
		mClientListener = listener; // this reference is needed when we reconnect 
	//	mSocket.setClientListener(listener);
	}
	public void connect() {
		// URI uri = URI.create("ws://localhost:8080/events/");
//		URI uri = URI.create("ws://10.10.250.158:8080/events/");
	//	URI uri = URI.create("ws://10.10.250.156:8080/events/");
	//	URI uri = URI.create("ws://10.10.250.173:8080/events/");
		URI uri = URI.create("ws://"+ MainActivity.ROBOT_IP+":8089/events/");

		mWebSocketClient = new WebSocketClient();
		mSession = null;
		try {
			try {
				mWebSocketClient.start();
				// The socket that receives events
				mSocket = new EventSocket();
	        	mSocket.setClientListener(mClientListener);
				// Attempt Connect
				Future<Session> fut = mWebSocketClient.connect(mSocket, uri);
				// Wait for Connect
				mSession = fut.get();
				// session.getRemote().sendString("Hello");

			} finally {
				// session.close();
				// client.stop();
			}
		} catch (Throwable t) {
			t.printStackTrace(System.err);
			
		}
	}



	public void send(String str) {
		ByteBuffer b;
		// session.getRemote().sendString(str);
		if( null == mSession ){
			Log.d("EventClient#send", " mSession == null");
			return;
		}
		try {
			mSession.getRemote().sendString(str);
		} catch (IOException e) {
			e.printStackTrace();
		} catch (NullPointerException e){
			e.printStackTrace();
			mClientListener.onError(e);
		}

	}

	public Boolean isOpen() {
		if(null == mSession) return false;
		return mSession.isOpen();
	}

	public void test() {

	}

	public void reconnect() {
		try {
			if( null != mSession){
			mSession.close();
			mWebSocketClient.stop();
			connect();
			if (mClientListener != null) {
				mSocket.setClientListener(mClientListener);
			}	
			} else {
				mClientListener.onError(new Throwable());
			}

		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	public void disconnect() {
		new Thread(new Runnable() {

			@Override
			public void run() {
				try {
					mSession.close();
					mSession = null;
					mWebSocketClient.stop();
					mWebSocketClient = null;
					mSocket = null;
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		}).start();

	}

}
