package com.wowwee.telepresence;

import java.util.ArrayList;
import java.util.EventObject;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicInteger;
import com.lightstreamer.ls_client.PushConnException;
import com.lightstreamer.ls_client.PushServerException;
import com.lightstreamer.ls_client.PushUserException;
import com.lightstreamer.ls_client.SubscrException;
import android.content.res.Resources.NotFoundException;
import android.util.Log;

public class PushServer {

	// connection status
	public static final int DISCONNECTED = 0;
	public static final int CONNECTING = 1;
	public static final int CONNECTED = 2;
	public static final int STREAMING = 3;
	public static final int POLLING = 4;
	public static final int STALLED = 5;
	public static final int ERROR = 6;
	public static final int CONNECTION_ERROR = 7;
	public static final int SERVER_ERROR = 8;

	public static final String TAG = PushServer.class.getSimpleName();

	private LsListener lsListener;
	private final static String[] items = { "chat_room" };
	private final static String[] fields = { "timestamp", "IP", "nick",
			"message" };
	private LightstreamerClient lsClient;
	private ArrayList<LSClientListener> mListeListeners = new ArrayList<LSClientListener>();
	private boolean userDisconnect = false;

	private static AtomicBoolean connected = new AtomicBoolean(false);

	private static AtomicInteger phase = new AtomicInteger(0);

	public static boolean checkPhase(int ph) {
		return ph == phase.get();
	}

	public static boolean isConnected() {
		return connected.get();
	}

	public static void setConnected(boolean status) {
		connected.set(status);
	}

	// /--------------------------------------------------------------------------------------

	// constructors
	public PushServer() {

		lsListener = new LsListener(this);
		lsListener.onStatusChange(phase.get(),
				LightstreamerConnectionStatus.DISCONNECTED);
		lsClient = new LightstreamerClient(items, fields);

	}
	


	public interface LSClientListener {
		public void onNotify(LsServerEvent e);

		public void onError(LsServerEvent e);
	}

	public class LsServerEvent extends EventObject {
		// -- members
		private String params;

		public String getParams() {
			return params;
		}

		// -- constructors
		public LsServerEvent(Object source, String params) {
			super(source);
			this.params = params;
		}
	}

	public void addLSClientListener(
			LSClientListener megamipLSClientListener) {
		mListeListeners.add(megamipLSClientListener);
		Log.d(TAG, "new Lightstreamer listener added ...");

	}

	// ------------------------------------------------------------------

	private void start(int ph) throws NotFoundException {
		// Asynchronously start
		Thread th = new Thread(new Runnable() {
			LsListener ui;
			LightstreamerClient ls;
			int ph;

			@Override
			public void run() {
				try {
					if (!checkPhase(ph)) {
						return;
					}
					ph = phase.incrementAndGet();
					ls.start(ph, LightstreamerClient.LS_SERVER_URL, ui);
					if (!checkPhase(ph)) {
						return;
					}
					ls.subscribe(ph, ui);

				} catch (PushConnException pce) {
					ui.onStatusChange(ph,
							LightstreamerConnectionStatus.CONNECTION_ERROR);
					notifyError(LightstreamerConnectionStatus.CONNECTION_ERROR);
				} catch (PushServerException pse) {
					ui.onStatusChange(ph,
							LightstreamerConnectionStatus.SERVER_ERROR);
				} catch (PushUserException pue) {
					ui.onStatusChange(ph, LightstreamerConnectionStatus.ERROR);
				} catch (SubscrException e) {
					e.printStackTrace();
					ui.onStatusChange(ph, LightstreamerConnectionStatus.ERROR);
				}
			}

			private void notifyError(int connectionError) {
				String message;
				for (LSClientListener b : mListeListeners) {
					message = new Integer(connectionError).toString();
					b.onError(new LsServerEvent(this, message));
					Log.d(TAG, "MegamipLSClientListener onError()  - message: "
							+ message);
				}

			}

			public Runnable setData(int ph, LsListener ui,
					LightstreamerClient ls) {
				this.ph = ph;
				this.ui = ui;
				this.ls = ls;
				return this;
			}

		}.setData(ph, lsListener, lsClient));
		th.setName("StockListDemo.Lightstreamer.start-" + ph);
		th.start();
	}

	private void stop(int ph) {
		// Asynchronously stop
		Thread th = new Thread(new Runnable() {
			LightstreamerClient ls;
			int ph;

			@Override
			public void run() {
				if (!checkPhase(ph)) {
					return;
				}
				ls.stop();
			}

			public Runnable setData(int ph, LightstreamerClient ls) {
				this.ph = ph;
				this.ls = ls;
				return this;
			}

		}.setData(ph, lsClient));
		th.setName("StockListDemo.Lightstreamer.stop-" + ph);
		th.start();
	}

	public void onResume() {

		/*
		 * if user explicitly chose to disconnect the application before hiding
		 * it, do not start it back once it's back visible.
		 */
		Log.d(TAG, "Lightstreamer onResume() ...");
		if (!userDisconnect) {
			start(phase.get());
		}
	}

	public void onPause() {

		// disconnect when application is paused
		Log.d(TAG, "Lightstreamer onPause() ...");
		stop(phase.get());
	}

	/*
	 * called when a push message arrive from the Lightstreamer server
	 */
	public void update(String message) {

		for (LSClientListener b : mListeListeners) {

			if (message.equals("Disconnected")) {
				connected.set(false);
				b.onError(new LsServerEvent(this, "8"));
			} else {

				if (message.equals("Connected to Lightstreamer server ")){
					connected.set(true);
				}
				
				b.onNotify(new LsServerEvent(this, message));
			}

			Log.d(TAG, "MegamipLSClientListener onNotify()  - message: "
					+ message);
		}

	}

}
