package com.example.touchpad01;

import android.content.Context;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.GridView;
import android.widget.ImageView;

public class GridAdapter extends BaseAdapter {
	   Context mContext;
		 public GridAdapter(Context context) {
				super();
				mContext = context;
			}

		private Integer[] tabId = {
				 R.drawable.pos01,
				 R.drawable.pos02,
				 R.drawable.pos03,
				 R.drawable.pos04,
				 R.drawable.pos05,
				 R.drawable.pos06
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
				iv.setLayoutParams(new GridView.LayoutParams(150,80));  
				iv.setImageResource(tabId[position]);
				
				return iv;
			}
}
