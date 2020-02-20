package com.wowwee.touchpad;

import java.net.ConnectException;
import java.net.SocketTimeoutException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;

import com.att.widgets.lib.button.SegmentedTextToggleButton;
import com.att.widgets.lib.button.StaticTextButton;
import com.google.gson.Gson;
import com.wowwee.drivepath.DPMap;
import com.wowwee.drivepath.DPLine;
import com.wowwee.drivepath.DPNode;
import com.wowwee.touchpad.Robot.RobotListener;
import com.wowwee.util.SBProtocol;
import com.wowwee.util.Utils;
import com.wowwee.views.GridAdapter;
import com.wowwee.views.LedImageButton;
import com.wowwee.views.LedImageButton.OnDrawListener;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnFocusChangeListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.GridView;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

public class DrivePathActivity extends Activity {
	
	
	
    private Handler mHandler;
	String FILENAME; 
	final String TAG = getClass().getSimpleName();
	static public DPMap map;
	private DPLine currentLine;
	Button btnInsertDelete, btnSetLabel, btnSwap, btnSave, btnGotoTarget, btnConnect;
	LedImageButton ledWifi;
	Spinner spnTargets;
	private int mLastPosition;
    public final static int REQUEST_CODE = 1;
	enum Mode {INSERT, DELETE, SWAP, SET_LABEL, DEL_LABEL}
	private SegmentedTextToggleButton toggleButtons;
	private MapView mMapView;
    private DPNode currentPt;
    private TextView currentLabel;
    private Mode mode = Mode.INSERT;
    ArrayAdapter<String> spnAdapter;
    
    
    public static ArrayList<Label> getMapLabels(){
     //   map.	
    	return null;
    }
	public static ArrayList<Label> labels2 = new ArrayList<Label>();
	
	
	public static int getX(View view) {
		return view.getLeft() + 302;
	}
 	
	public static int getY(View view) {
		return view.getBottom() + 343;
//		return view.getBottom();
	}
	public static String[] labels = new String[9];
    public static LabelsList    labelsList = new LabelsList(); 
	private ArrayList<String> spnLabels = new ArrayList<String>();
    private java.util.Map<String, Integer> spnIds = new HashMap();	
    
    static {
    		    // ----- initialization of the labels list 
	       labels2 = labelsList.getLabelsList();
	       
	      
       
    }
    
    
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);;
		mMapView = new MapView(this);
		setContentView(mMapView);
	
		mHandler = new Handler();
		spnTargets =(Spinner)findViewById(R.id.spnTargets);
		btnGotoTarget = (Button)findViewById(R.id.btnGotoTarget);
		btnConnect = (Button)findViewById(R.id.btnConnect_main);
		ledWifi = (LedImageButton)findViewById(R.id.ledWifi_main); 
        
		ledWifi.setOnDrawListener(new OnDrawListener() {
			
			@Override
			public void notifyOnDraw() {
			 refreshWifiLed(); 	
			}
		});
		

	
	    Log.d(TAG, "DrivePathActivity.onCreate ... selected SB: " + MainActivity.SELECTED_SWITCHBOT); 
		
        spnLabels.add(" "); 
        String[] targets = {"beacon 01", "beacon 02", "beacon 03",
           "beacon 04", "beacon 05", "beacon 06", "beacon 07", "beacon 08", "beacon 09" };
		spnAdapter = new ArrayAdapter<String>(this, R.layout.spinner_item, targets);
		spnTargets.setAdapter(spnAdapter);
		
		FILENAME = "/data/data/" + DrivePathActivity.this.getPackageName() + "/json_data";
				Utils utils = new Utils();
		String jsonMap = utils.readData(FILENAME);
		//utils.saveData(FILENAME, "");
		Gson gson = new Gson();
		DPMap result = gson.fromJson(jsonMap, DPMap.class);
		if (null != result){
			map = result;
			// initialisation of the nodes labels 
			ArrayList<DPLine> lines = map.getLines();
			for ( DPLine line: lines) {
			 labels[line.startPoint.id -1] = line.startPoint.label;
			 labels[line.endPoint.id -1] = line.endPoint.label;
			}
			
			for(int i= 0; i < 9; i++){
				if(labels[i] != null){
					spnLabels.add(labels[i]);
					spnIds.put(labels[i], i);
				}
			}
			
		    spnAdapter.notifyDataSetChanged();	
			mMapView.drawMap();
		}else {
    		map = new DPMap();
		}
			
		Log.d(TAG, " reading result: " + map);
		//spnTargets.
	    //testJson();	
	    btnSave = (Button)findViewById(R.id.btnSave);
	    toggleButtons = (SegmentedTextToggleButton)findViewById(R.id.segmented_enabled);
        toggleButtons.getChildAt(0).setActivated(true);
		toggleButtons.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View arg0) {
			
				switch (toggleButtons.getSelectedIndex()) {
				case 0: mode = Mode.INSERT;
					break;
				case 1: mode = Mode.DELETE;
				     break;
				case 2: mode = Mode.SWAP;
				     break;
				case 3: mode = Mode.SET_LABEL;
				     break;
				case 4: mode = Mode.DEL_LABEL;
				default:
					break;
				}
			}
		});  
		
		btnSave.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
		        Gson gson = new Gson();
                final  String jsonMap = gson.toJson(map);
		        Log.d(TAG, "saving map : " + jsonMap);
		        Utils utils = new Utils();
		        utils.saveData(FILENAME, jsonMap);
			  //  labelsList.saveList();
		        // send the map data to  Switchbot
		      String cmd = SBProtocol.JETTY_SAVE_DATA + SBProtocol.JETTY_SPLIT_CHAR + jsonMap; 

           	    sendData(cmd);    
           
           	   if(btnConnect.getText().equals("Connect")){
           		   
           	    Toast.makeText(DrivePathActivity.this, "Map saved locally, you're not connected", Toast.LENGTH_LONG).show();
           		   
           	   }else{
           		   
           	    Toast.makeText(DrivePathActivity.this, "Map saved", Toast.LENGTH_LONG).show();
           	   } 
		
			}


		});
		
		

		
		btnGotoTarget.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
			
				//Robot.getInstance().connect();
			    int index = (int)spnTargets.getSelectedItemId();
			    index++;
			    String cmd = SBProtocol.JETTY_DRIVETO_BEACON + SBProtocol.JETTY_SPLIT_CHAR + index;
			    sendData(cmd);
			 
			}
		});
		
		
		
		Robot.getInstance().setRobotListener(new RobotListener() {

			@Override
			public void onNotify(String action, String data) {
				if (action.equals(Robot.ACTION_DATA_AVAILABLE)) {
					LOG("msg: " + data);
				}
				if (action.equals(Robot.ACTION_ROBOT_CONNECTED)) {
					LOG("connected");
					runOnUiThread(new Runnable() {
						public void run() {
							btnConnect.setText("Disconnect");
							ledWifi.setPressed(true);
						}
					});

				}
				if (action.equals(Robot.ACTION_ROBOT_DISCONNECTED)) {

					runOnUiThread(new Runnable() {
						public void run() {
							btnConnect.setText("Connect");
							ledWifi.setPressed(false);

						}
					});
				//	displayStatus((byte) 0x00);
				//	log("disconnected");
				}
			}
		});	
		
		
	btnConnect.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				if (btnConnect.getText().equals("Connect")) {
                //    isDisconnectRequested = false;
					new Thread(new Runnable() {
						
						@Override
						public void run() {
							
                    Robot.getInstance().connect(); 
						}
					}).start();
				} else {
					// Disconnect button pressed
					
					new Thread(new Runnable() {
						
						@Override
						public void run() {
							
					Robot.getInstance().disconnect(); 
						}
					}).start();
    			}	
			}
		});
		
		
	}
	
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);

		if (resultCode == Activity.RESULT_OK && requestCode == REQUEST_CODE
				&& data != null) {
			// String newLabel =
			// data.getStringExtra(LabelInputDialog.NEW_LABEL);
			// Log.d(TAG, " onActivityResult label: " + newLabel );

			String newLabel = data.getStringExtra("label");
			Log.d("MainActivity", " " + newLabel);

			labelsList.deactivate(new Label(newLabel, false));
			labels2 = labelsList.getLabelsList();
			//labelsList.saveList();

			if (!newLabel.equals("")) {
				labels[currentPt.id - 1] = newLabel;
				spnLabels.add(newLabel);
				spnAdapter.notifyDataSetChanged();
				spnIds.put(newLabel, currentPt.id - 1);
				currentLabel.setText(newLabel);
				map.setLabel(currentPt, newLabel);
				mMapView.drawMap();
			} else {
				if (currentPt.label != null) {
					spnIds.remove(currentPt.label);
					spnLabels.remove(currentPt.id - 1);
				}
			}
			Log.d("MainActivity ", labelsList.toString());
			Log.d("MainActivity ", "labels" + labels.toString());
		}

	}

	private void sendData(final String data) {
		new Thread(new Runnable() {
			
			@Override
			public void run() {
		   // final Robot robot = Robot.getInstance();	
			Robot.getInstance().send(data);
			}
		}).start();
		
	}

	

	


public static	 void LOG(String string){
		Log.d("TAG1", string);
	}

	public class MapView extends FrameLayout {

		private FrameLayout mGui;
		private Context mContext;
		private Paint mPaint;
		private Path mPath;
		private boolean isSelectMode = true;
        private DPNode startPt, endPt;
        private GridView gridView;
        private View lastView;
        
        
		

		public MapView(Context context) {

			super(context);
			mContext = context;
			setWillNotDraw(false);
			init();

		}

		private void init() {
			
			// pen init
			mPaint = new Paint();
			mPaint.setColor(Color.BLACK);
			mPaint.setStrokeWidth(13);
			mPaint.setStyle(Paint.Style.STROKE);
			mPath = new Path();
			
			
			// gui init 
			LayoutInflater inflator = (LayoutInflater) getContext()
					.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
			mGui = (FrameLayout) inflator.inflate(R.layout.activity_drive_path,
					this, false);
			// setWillNotDraw(false);
			gridView = (GridView) mGui.findViewById(R.id.grid_view);
			gridView.setAdapter(new GridAdapter(mContext));
			gridView.setOnItemClickListener(new ClickHandler());
			addView(mGui);

		}
		

		@Override
		protected void onDraw(Canvas canvas) {

			super.onDraw(canvas);
			LOG("onDraw ...");
            canvas.drawPath(mPath, mPaint);
		

		}
		

		
		
	  
	  
		public class ClickHandler implements OnItemClickListener {

			@Override
			public void onItemClick(AdapterView<?> parent, View view,
					int position, long id) {
				
				// view.setPressed(isSelectMode);
				if (isSelectMode) {
					startPt = new DPNode(DrivePathActivity.getX(view),
							DrivePathActivity.getY(view), position + 1);
				    currentPt = startPt; // reference needed to set a label 	
					LinearLayout ll = (LinearLayout)view;
                    if(mode == Mode.SET_LABEL || mode == Mode.DEL_LABEL){
                    	switch (mode) {
						case SET_LABEL: 
							
							ArrayList<Label> l = DrivePathActivity.map
									.getLabels();
							for (Label label : l) {
								if (labels2.contains(label)) {
									labelsList.deactivate(label);
								}
							}
							labels2 = labelsList.getLabelsList();
      
							Intent i = new Intent(DrivePathActivity.this, LabelInputDialog.class);
                            DrivePathActivity.this.startActivityForResult(i,REQUEST_CODE);
                            currentLabel = (TextView)ll.getChildAt(2);
							break;
						case DEL_LABEL:
							 
						
                            currentLabel = (TextView)ll.getChildAt(2);
							if (currentLabel.getText() != null) {	
								if(currentLabel.getText().equals("")) return;
									
								String label = currentLabel.getText().toString();
								labelsList.activate(new Label(label, true));
							    labels2 = labelsList.getLabelsList();
							    labels[currentPt.id - 1] = "";
								//spnIds.remove(currentPt.label);
								//spnLabels.remove(currentPt.id - 1);
								currentLabel.setText("");
								map.setLabel(currentPt, "");
								mMapView.drawMap();
								
							
							}
							break;
						default:
							break;
						}
                     
                    } else {					
					isSelectMode = false;
					
					// ImageView iv = (ImageView)gridView.getI;
					// iv.setImageResource(R.drawable.pos01);
					// ImageView iv =
					// (ImageView)gridView.getAdapter().getView(position,
					// view, gridView);
					ImageView iv = (ImageView)ll.getChildAt(0);
					iv.setImageResource(R.drawable.dp_node_red);
					lastView = view;
					currentLine = new DPLine();
					currentLine.startPoint = startPt;
					mLastPosition = position;
					LOG("if ... x: " + startPt.x + " y: " + startPt.y);
                    }
				} else {
	                    endPt = new DPNode(DrivePathActivity.getX(view),
								DrivePathActivity.getY(view), position + 1);
						// mPath = new Path();
					
						isSelectMode = true;
						LOG("else ...start-> x: " + startPt.x + " y: "
								+ startPt.y + " end x" + endPt.x + " y:"
								+ endPt.y);
						LinearLayout ll = (LinearLayout)lastView;
						ImageView iv = (ImageView) ll.getChildAt(0);
						iv.setImageResource(R.drawable.dp_node);
						currentLine.endPoint = endPt;
						if(currentLine.endPoint.equals(currentLine.startPoint)) return; // line not accepted
			
				switch (mode) {
				case INSERT:
				
						//LOG("i contains: " + map.contains(currentLine));
						if(!map.getLines().contains(currentLine)) {
							map.add(currentLine);
						//drawing the new line 	
							mPath.moveTo(startPt.x, startPt.y);
							mPath.lineTo(endPt.x, endPt.y);
						// updating mDPMap with the new nodes 	
						//addLine(mLastPosition + 1, position + 1);
						}

					
					break;
				case DELETE:
			
						//LOG("d contains: " + map.contains(currentLine));
						
						if(map.getLines().contains(currentLine)){
							map.remove(currentLine);
						    drawMap();	
			
						}

					break;
					
				case SWAP: 
					LOG("swap ...");
					DPMap mapCopy = map.clone();
					DPLine currentLine;
					int index = 0;
						for (DPLine l:map.getLines()){
						  // endPt, startPt
						currentLine = mapCopy.getLines().get(index);	
						  if(currentLine.startPoint.equals(startPt)){
							  l.startPoint.x = endPt.x;
							  l.startPoint.y = endPt.y;
							  l.startPoint.id = endPt.id;
						  };	
						  if(currentLine.startPoint.equals(endPt)){
							 l.startPoint.x = startPt.x; 
							 l.startPoint.y = startPt.y;
							 l.startPoint.id = startPt.id;
						  };	
						  if(currentLine.endPoint.equals(startPt)) {
							 l.endPoint.x = endPt.x; 
							 l.endPoint.y = endPt.y;
							 l.endPoint.id = endPt.id;
						  };	
						  if(currentLine.endPoint.equals(endPt)) {
							  l.endPoint.x = startPt.x; 
							  l.endPoint.y = startPt.y;
							  l.endPoint.id = startPt.id;
						  };
						  index++;
						}
						drawMap();
					break;
				}
				
				
			LOG("ID: " + id)	;
//				Log.d(TAG, "mDPMap: " + mDPMap + " mode: " + mode);
				Log.d(TAG, "map: " + map + " mode: " + mode);
			 MapView.this.invalidate();


			}


		}

			



	}
		
		

	 	
		public void drawMap() {
			mPath.reset();
			for (DPLine l : map.getLines()) {
				mPath.moveTo(l.startPoint.x, l.startPoint.y);
				mPath.lineTo(l.endPoint.x, l.endPoint.y);
			}
		}
	 	

	
	}  // end of MapView class declaration --------------------------------------------
	
	

  @Override
protected void onResume() {
	super.onResume();
	Log.d(TAG, "DrivePathActivity#onResume ... ");
	//refreshWifiLed();
	
}
  
	protected void refreshWifiLed() {
		runOnUiThread(new Runnable() {

			@Override
			public void run() {
				if (btnConnect.getText().equals("Connect")) {
					ledWifi.setPressed(false);
				} else {

					ledWifi.setPressed(true);
				}
			}
		});

	}
     
	

	@Override
	public void onDestroy() {
		super.onDestroy();
	//	isDisconnectRequested = true;
		//mBtClient.onDestroy();
		Robot.getInstance().disconnect();

	}
		@Override
	public void onBackPressed() {;
	  //  isDisconnectRequested = true;
	    Robot.getInstance().disconnect();
		btnConnect.setText("Connect");
		this.finish();
	}

}
