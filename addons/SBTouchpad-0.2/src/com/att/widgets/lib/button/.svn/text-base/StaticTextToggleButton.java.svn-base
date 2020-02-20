package com.att.widgets.lib.button;

import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.Drawable;
import android.util.AttributeSet;
import android.widget.ToggleButton;

import com.att.widgets.lib.R;

/**
 * The Static Text Toggle Button UI component is like a Static Text Button
 * widget except that after it is pressed it remains active until it is pressed
 * again.
 */
public class StaticTextToggleButton extends ToggleButton {

	/**
	 * Creates a StaticTextToggleButton widget	
	 * @param context
	 */
	public StaticTextToggleButton(Context context) {
		super(context);
		init(context);
	}

	/**
	 * Creates an StaticTextToggleButton Widget with a set of attributes.
	 * @param context
	 * @param attrs
	 */
	public StaticTextToggleButton(Context context, AttributeSet attrs) {
		super(context, attrs);
		init(context);
		
		String t = attrs.getAttributeValue(getResources().getString(R.string.namespace), "text");
		if(t != null){			
			setText(t);
		}
	}
	
	/**
	 * Initialize the class.
	 * @param context
	 */
	protected void init(Context context){
		this.setText("");
		this.setBackgroundResource(R.drawable.toggle_button);
	}
	
	@Override
	public void setBackgroundResource(int resid) {
		super.setBackgroundResource(resid);
	}
	
	@Override
	public void setBackgroundDrawable(Drawable d) {
		super.setBackgroundDrawable(d);
	}
	
	/**
	 * Set the text of the {@link StaticTextToggleButton}.
	 * @param s Button Text
	 */
	public void setText(String s){
		super.setText(s);
		setTextOn(s);
		setTextOff(s);				
	}

	@Override
	public void setEnabled(boolean enabled) {
		setTextColor(enabled ? Color.BLACK : Color.GRAY);
		super.setEnabled(enabled);
	}
	
}
