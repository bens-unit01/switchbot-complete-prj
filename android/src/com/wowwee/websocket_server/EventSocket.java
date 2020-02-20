package com.wowwee.websocket_server;
/*
 * source: https://github.com/jetty-project/embedded-jetty-websocket-examples
 */
import java.io.IOException;

import org.eclipse.jetty.websocket.api.Session;
import org.eclipse.jetty.websocket.api.WebSocketAdapter;

import android.util.Log;



public class EventSocket extends WebSocketAdapter
{
	private static String TAG = EventSocket.class.getSimpleName();
	static Session sess = null;
	private static CommHandler mCommHandler = null;
	
	public static Session getCurrentSession(){
		return sess;
	}
    @Override
    public void onWebSocketConnect(Session sess)
    {
        super.onWebSocketConnect(sess);
        this.sess = sess;
        Log.d(TAG, "Socket Connected: " + sess);
    }
    
    @Override
    public void onWebSocketText(String message)
    {
        super.onWebSocketText(message);
        System.out.println("Received TEXT message: " + message);
			//sess.getRemote().sendString("Ok !! " + getCurrentSession().getRemoteAddress());
        if(mCommHandler != null){
        	mCommHandler.handle(message);
        }else{
        	Log.e(TAG, " EventSocket#onWebSocketText error: no commHandler instance");
        }
        	
    }
    
    @Override
    public void onWebSocketClose(int statusCode, String reason)
    {
        super.onWebSocketClose(statusCode,reason);
        System.out.println("Socket Closed: [" + statusCode + "] " + reason);
    }
    
    @Override
    public void onWebSocketError(Throwable cause)
    {
        super.onWebSocketError(cause);
        cause.printStackTrace(System.err);
    }
    
    public static void setCommHandler(CommHandler commHandler){
          mCommHandler = commHandler;	
    }
    
   
}
