package com.wowwee.views;

import android.content.Context;
import android.graphics.Canvas;
import android.util.AttributeSet;
import android.util.Log;
import android.widget.ImageView;

public class LedImageButton extends ImageView {
	
	OnDrawListener mOnDrawListener;

public LedImageButton(Context context, AttributeSet attrs) {
		super(context, attrs);
	}

	public LedImageButton(Context context) {
		super(context);
	}
  @Override
protected void onDraw(Canvas canvas) {
	super.onDraw(canvas);
	
	Log.d("LedImageButton", "onDraw ...");
	mOnDrawListener.notifyOnDraw();
}
  
  public interface OnDrawListener {
	 void notifyOnDraw();
  }
  
  public void setOnDrawListener(OnDrawListener l){
	 mOnDrawListener = l; 
  }
}
