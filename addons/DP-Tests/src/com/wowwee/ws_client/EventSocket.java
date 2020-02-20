package com.wowwee.ws_client;
/*
 * source: https://github.com/jetty-project/embedded-jetty-websocket-examples
 */
import java.util.ArrayList;
import org.eclipse.jetty.websocket.api.Session;
import org.eclipse.jetty.websocket.api.WebSocketAdapter;

public class EventSocket extends WebSocketAdapter
{
	
	private ClientListener mClientListener = null;
	
	
    public EventSocket() {
		super();
	}

	@Override
    public void onWebSocketConnect(Session sess)
    {
        super.onWebSocketConnect(sess);
        if(mClientListener != null){
            mClientListener.onConnect(sess); 
        }
     
        System.out.println("Socket Connected: " + sess);
    }
    
    @Override
    public void onWebSocketText(String message)
    {
        super.onWebSocketText(message);
        if(mClientListener != null){
             mClientListener.onText(message);
        }
        
       
        System.out.println("Received TEXT message: " + message);
    }
    
    @Override
    public void onWebSocketClose(int statusCode, String reason)
    {
        super.onWebSocketClose(statusCode,reason);
        if(mClientListener != null){
             mClientListener.onDisconnect(statusCode, reason); 
        }        
      
        System.out.println("Socket Closed: [" + statusCode + "] " + reason);
    }
    
    @Override
    public void onWebSocketError(Throwable cause)
    {
        super.onWebSocketError(cause);
        if(mClientListener != null){
            mClientListener.onError(cause); 
        }        
       
        cause.printStackTrace(System.err);
    }
    public void setClientListener(ClientListener newListener){
       mClientListener = newListener;
    }
    

}
