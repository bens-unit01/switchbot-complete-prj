package com.wowwee.telepresence;


import android.os.Handler;
import android.util.Log;
import com.lightstreamer.ls_client.UpdateInfo;

public class LsListener implements LightstreamerListener {

	  public static final String TAG = LsListener.class.getSimpleName();
	  private Handler handler;
	  private PushServer client;
	  

      public LsListener(PushServer client) { 	  
          handler = new Handler();
		  this.client = client;
	  }
	@Override
	public void onStatusChange(int phase, int status) {
		
		
		String statusTxt = "";
		switch(status) {
        case LightstreamerConnectionStatus.DISCONNECTED:
            statusTxt = "Disconnected";
            break;
        case LightstreamerConnectionStatus.CONNECTING:
            statusTxt = "Connecting to Lightstreamer server ";
            break;
        case LightstreamerConnectionStatus.CONNECTED:
            statusTxt = "Connected to Lightstreamer server ";
            break;
        case LightstreamerConnectionStatus.STREAMING:
            statusTxt = "Session started in streaming";
            break;
        case LightstreamerConnectionStatus.POLLING:
            statusTxt = "Session started in smart polling";
            break;
        case LightstreamerConnectionStatus.STALLED:
            statusTxt = "Connection stalled";
            break;
        case LightstreamerConnectionStatus.ERROR:
            statusTxt = "Data error";
            break;
        case LightstreamerConnectionStatus.CONNECTION_ERROR:
            statusTxt = "Connection error";
            break;
        case LightstreamerConnectionStatus.SERVER_ERROR:
            statusTxt = "Server error";
            break;
        default:
            statusTxt = "Disconnected";
    }
    updateStatus(statusTxt);
    Log.d(TAG, "LsListener - onStatusChange() - status: "+status);

		
	}

	private void updateStatus(String message) {
		  this.handler.postDelayed(
	                new MessageRunnable(message), 0);
	      
	        Log.d(TAG, "updateStatus() - message: "+message);
		
	}
	@Override
	public void onItemUpdate(int phase, int itemPos, String itemName,
			UpdateInfo update) {
		
 
            boolean snapshot = update.isSnapshot();


               
                String field = "message";
                String value = update.getNewValue(field);

//                if (update.isValueChanged(field)) {
                    
                    handler.postDelayed(
                            new MessageRunnable(value), 0);

//	                    if (!snapshot) {
	//                        /* update cell color */
	//                        String oldValue = update.getOldValue(field);
	//                        try {
	//                            double valueInt = Double.parseDouble(value);
	//                            double oldValueInt = Double.parseDouble(oldValue);
	//                            upDown = valueInt - oldValueInt;
	//                        } catch (NumberFormatException nfe) { /* ignore */ }
	//                        updateCellColor(view, upDown);
//	                    } else {
	//                        /* mark entire row as updated */
	//                        updateCellColor(row, 1.0);
//	                    }
//                }
                
                Log.d(TAG, "onItemUpdate() message: "+value);
            }
		


	@Override
	public void onLostUpdate(int phase, int itemPos, String itemName,
			int lostUpdates) {
		  Log.d(TAG, "onLostUpdate");
		
	}

	@Override
	public void onReconnectRequest(int phase) {
		 Log.d(TAG, "onReconnectRequest");
		
	}
	
	private class MessageRunnable implements Runnable {
        private String message;

        MessageRunnable(String message) {
            super();
            this.message = message;
          
        }

        public void run() {
           Log.d(TAG, "run() message: "+this.message);
           client.update(this.message);
        }
    }

}
