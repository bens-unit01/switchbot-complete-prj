package com.wowwee.touchpad;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.AdapterView.OnItemSelectedListener;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.GridView;
import android.widget.ListView;

public class LabelInputDialog extends Activity {

	public final static String NEW_LABEL = "new_label";
	private EditText txtLabel;
	private ListView listLabels;
	  ArrayList<String> labelsStringList;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_label_input_dialog);
      listLabels = (ListView)findViewById(R.id.list_view_labels);
       labelsStringList = new ArrayList<String>();
       
    
        // we remove the labels that already exists in the map
 
       for(Label label:DrivePathActivity.labels2){
    	  if(label.isState()){
    	      labelsStringList.add(label.getText()); 
    	  }
      }
      
      Log.d("LabelInputDialog", DrivePathActivity.labels2.toString());
      
      final StableArrayAdapter adapter = new StableArrayAdapter(this,
    	        android.R.layout.simple_list_item_1, labelsStringList);
      listLabels.setAdapter(adapter);
	  //listLabels.setAdapter(new GridAdapterLabels(this));

    listLabels.setOnItemClickListener(new OnItemClickListener() {

		@Override
		public void onItemClick(AdapterView<?> parent, final View view, int position,
				long arg3) {
			 final String item = (String) parent.getItemAtPosition(position);
			
	                Log.d("-", String.valueOf(position) + " " + item  );
	                Bundle b = new Bundle();
	                b.putString("label", item);
	             

	                Intent result = new Intent();
	                result.putExtras(b);
	                setResult(Activity.RESULT_OK, result);
	                finish();
		 //LabelInputDialog.this.finish();	
		}
	});	
	}
	private class StableArrayAdapter extends ArrayAdapter<String> {

	    HashMap<String, Integer> mIdMap = new HashMap<String, Integer>();

	    public StableArrayAdapter(Context context, int textViewResourceId,
	        List<String> objects) {
	      super(context, textViewResourceId, objects);
	      for (int i = 0; i < objects.size(); ++i) {
	        mIdMap.put(objects.get(i), i);
	      }
	    }
	}
	
	
}
