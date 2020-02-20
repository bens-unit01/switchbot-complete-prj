package com.wowwee.websocket_server;

/*
 * source: https://github.com/jetty-project/embedded-jetty-websocket-examples 
 */
import org.eclipse.jetty.server.Server;
import org.eclipse.jetty.server.ServerConnector;
import org.eclipse.jetty.servlet.ServletContextHandler;
import org.eclipse.jetty.servlet.ServletHolder;

public class CommServer {
public static final int PORT = 8089;
	
	public CommServer(CommHandler handler){
		EventSocket.setCommHandler(handler); 
		startServer();

	}

	private void startServer() {
		new Thread(new Runnable() {
 
			@Override
			public void run() {

				Server server = new Server();
				ServerConnector connector = new ServerConnector(server);
				connector.setPort(PORT);
				server.addConnector(connector);

				// Setup the basic application "context" for this application at
				// "/"
				// This is also known as the handler tree (in jetty speak)
				ServletContextHandler context = new ServletContextHandler(
						ServletContextHandler.SESSIONS);
				context.setContextPath("/");
				server.setHandler(context);

				// Add a websocket to a specific path spec
				ServletHolder holderEvents = new ServletHolder("ws-events",
						EventServlet.class);
				context.addServlet(holderEvents, "/events/*");

				try {
					server.start();
					server.dump(System.err);
					server.join();
				} catch (Throwable t) {
					t.printStackTrace(System.err);
				}
			}
		}).start();
	}
}
