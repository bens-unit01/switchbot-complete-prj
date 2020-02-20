package com.example.touchpad01;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

import android.content.Context;
import android.content.res.AssetManager;
import android.util.Log;

public class PropertyManager {
	public final String TAG7 = "A7";
	// attributes 
	private Context context;
	private Properties properties;
	public PropertyManager(Context context) {
		super();
		this.context = context;
		properties = new Properties();
	}
	
	
	public Properties getProperties(String filename){
		
		
		try {
			AssetManager assetManager = context.getAssets();
			InputStream inputStream = assetManager.open(filename);
			properties.load(inputStream);
			
		} catch (IOException e) {
			// TODO: handle exception
			Log.d(TAG7, e.toString());
		}
		
		return properties;
	}
	

}
