package com.att.widgets.lib.button;

import com.att.widgets.lib.R;

import android.content.Context;
import android.graphics.Paint;
import android.util.AttributeSet;

public class TextToggleButton extends ImageToggleButton{

	/**
	 * Creates a TextToggleButton Widget.
	 * @param context
	 */
	public TextToggleButton(Context context) {
		super(context);
	}
	
	/**
	 * Creates an TextToggleButton Widget with a set of attributes.
	 * @param context
	 * @param attrs
	 */
	public TextToggleButton(Context context, AttributeSet attrs) {
		super(context, attrs);
	}

	@Override
	protected void init(Context context) {
		image = getResources().getDrawable(R.drawable.text_toggle_button);
		setBackgroundDrawable(image);
	}

	@Override
	protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
		Paint p = new Paint();
		p.setTextSize(getTextSize());
		
		int height = (int)Math.max(image.getMinimumHeight(), getTextSize());
		int width = (int)Math.max(image.getMinimumWidth(), 150);//p.measureText(getText().toString()));
		setMeasuredDimension(width, height);
	}
}
