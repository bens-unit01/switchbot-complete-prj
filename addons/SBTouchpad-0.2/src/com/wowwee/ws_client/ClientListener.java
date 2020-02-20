package com.wowwee.ws_client;

import org.eclipse.jetty.websocket.api.Session;

public interface ClientListener {
	
	public void onText(String str);
	public void onConnect(Session session);
	public void onDisconnect(int statusCode, String reason);
	public void onError(Throwable cause);

}
