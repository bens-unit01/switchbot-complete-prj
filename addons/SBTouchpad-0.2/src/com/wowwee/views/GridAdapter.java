package com.wowwee.views;

import com.wowwee.touchpad.DrivePathActivity;
import com.wowwee.touchpad.R;

import android.content.Context;
import android.view.TextureView;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.GridView;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ImageView.ScaleType;
import android.widget.TextView;
import android.widget.ToggleButton;

public class GridAdapter extends BaseAdapter {
	   Context mContext;
		 public GridAdapter(Context context) {
				super();
				mContext = context;
			}

		private Integer[] tabId = {
				 R.drawable.dp_node,
				 R.drawable.dp_node,
				 R.drawable.dp_node,
				 R.drawable.dp_node,
				 R.drawable.dp_node,
				 R.drawable.dp_node,
				 R.drawable.dp_node,
				 R.drawable.dp_node,
				 R.drawable.dp_node
		 };	
			@Override
			public int getCount() {
				return tabId.length;
			}

			@Override
			public Object getItem(int position) {
				return tabId[position];
			}

			@Override
			public long getItemId(int position) {
				return position;
			}

			@Override
			public View getView(int position, View convertView, ViewGroup parent) {
				
				ImageView iv = new ImageView(mContext);
				GridView.LayoutParams flp = new GridView.LayoutParams(120,
						120);

				iv.setLayoutParams(flp);	
//				iv.setLayoutParams(new GridView.LayoutParams(30,30));  
				iv.setImageResource(tabId[position]);
				iv.setMinimumHeight(160);
//				
//				ToggleButton tb = new ToggleButton(mContext);
//				tb.setLayoutParams(new GridView.LayoutParams(30,30));  
//				tb.setText(".");
				TextView txtId = new TextView(mContext);
				TextView txtLabel = new TextView(mContext);
				int index = position;
				index++;
				txtId.setText("beacon " + index + " ");
				txtLabel.setText(DrivePathActivity.labels[position] );
				LinearLayout ll = new LinearLayout(mContext);
				ll.addView(iv);
				ll.addView(txtId);
				ll.addView(txtLabel);
				DrivePathActivity.LOG("getView ..." + position);
				return ll;
			}
}
