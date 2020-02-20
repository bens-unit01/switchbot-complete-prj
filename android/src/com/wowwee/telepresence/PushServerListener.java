package com.wowwee.telepresence;

import java.net.URISyntaxException;

import android.content.Context;
import android.content.Intent;
import android.util.Log;

import com.wowwee.switchbot.SBRealDevice;
import com.wowwee.switchbot.SBRealDeviceFactory;
import com.wowwee.switchbot.SBRobot;
import com.wowwee.switchbot.SBVirtualDevice;
import com.wowwee.telepresence.PushServer.LSClientListener;
import com.wowwee.telepresence.PushServer.LsServerEvent;
import com.wowwee.util.SBProtocol;

public class PushServerListener implements LSClientListener {

	private Context context;
	private SBRobot mUsbDevice = null;
	private boolean isDriving = false;
	public static final String TAG = "SwitchBot";
	private final int CHECK_LSCLIENT_INTERVAL_INMILLIS = 2000;
	private int counter1 = 0;
	private PushServer mLsClient;
	// consturctors

	public PushServerListener(Context context, PushServer lsClient) {
		super();
		this.context = context;
		this.mLsClient = lsClient;
	}

	public PushServerListener(Context context, SBRobot usbDevice, PushServer lsClient) {
		super();
		this.context = context;
		this.mUsbDevice = usbDevice;
		this.mLsClient = lsClient;
	}

	@Override
	public void onNotify(LsServerEvent e) {

		pushServerHandler(e.getParams());

	}

	@Override
	public void onError(LsServerEvent e) {
	 
		int error = Integer.parseInt(e.getParams());
		Log.d(TAG,
				"PushServerListener onError - MainActivity ... error: " + error);
		if (error == PushServer.ERROR
				|| error == PushServer.CONNECTION_ERROR
				|| error == PushServer.SERVER_ERROR) {

//			btnLed4.setPressed(false);

			// we retry to reconnect after 30 seconds
			new Thread(new Runnable() {
				public void run() {
					try {
						Thread.sleep(CHECK_LSCLIENT_INTERVAL_INMILLIS);
						counter1++;
						boolean isConnected = mLsClient.isConnected();
						Log.d(TAG, "is connected: "
								+ isConnected + " threadId: "
								+ counter1);
						if (!isConnected) {
							mLsClient.onResume();

						}

					} catch (InterruptedException e) {

						e.printStackTrace();
					}
				}
			}).start();
		}
	
	}

	private void pushServerHandler(String args) {

		String[] params = args.split( Constants.CMD_SEPARATOR);
		// int rotationAngle = (mScreenOrientation ==
		// ScreenOrientation.POSITION_0) ? 0
		// : 180;

		Log.d(TAG, " pushServerHandler args: " + params[0]);
		if (Constants.CMD_LAUNCH.equals(params[0])) {
			String p2pID = params[1];
			Log.d(TAG,
					"pushServerHandler - launching Telepresence module - p2pID:"
							+ p2pID);
			sendIntent(p2pID);
			return;
		}
		if ((Constants.CMD_CLOSE).equals(params[0])) {
		   // we close the telepresence app 
			//sendIntent(Constants.CMD_CLOSE);
			
		}
		if ((Constants.CMD_DRIVE_FORWARD  ).equals(params[0])) {

			drive(SBProtocol.ENCODED_DRIVE_FORWARD);
			Log.d(TAG,"PushServerListener  drive forward  ..." );
			return;
		}
		if ((Constants.CMD_DRIVE_BACKWARD ).equals(params[0] )) {
			drive(SBProtocol.ENCODED_DRIVE_BACKWARD);
			return;
		}
		if ((Constants.CMD_TURN_LEFT ).equals(params[0]  )) {
			drive(SBProtocol.ENCODED_TURN_LEFT);
			return;
		}
		if ((Constants.CMD_TURN_RIGHT ).equals(params[0] )) {
			drive(SBProtocol.ENCODED_TURN_RIGHT);
			return;
		}

	}

	private void sendIntent(String p2pID) {
		Intent intent;
		try {
			intent = Intent.parseUri("telepresenceapp://" + p2pID + "//"
					+ "0", Intent.URI_INTENT_SCHEME);
			context.startActivity(intent);
		} catch (URISyntaxException e) {
			e.printStackTrace();
		}
	}

	private void drive(byte[] encodedCmd) {

		if (isDriving)
			return;
		synchronized (this) {
			isDriving = true;
			int nbSteps = SBProtocol.DRIVE_NB_STEPS;
			for (int i = 0; i < nbSteps; i++) {
				try {
					SBRealDeviceFactory.getInstance().writeRaw(encodedCmd);
					Thread.sleep(200);
				} catch (InterruptedException e) {
					e.printStackTrace();
					Log.d(TAG, " write - block catch" + e.getMessage());
				} catch (Exception e) {
					Log.d(TAG, " write - block catch" + e.getMessage());
				}
			}
			
			// sending stop command
			SBRealDeviceFactory.getInstance().writeRaw(new byte[]{SBProtocol.DRIVE, 0, 0});
			isDriving = false;
		}

	}

}
