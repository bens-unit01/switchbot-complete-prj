package com.att.widgets.lib.button;

import android.content.Context;
import android.content.res.TypedArray;
import android.util.AttributeSet;

import com.att.widgets.lib.R;

/**
 * The Checkbox widget enables users to choose among a number of possibilities
 * in an application. There are two kinds of check boxes: normal (in which a check
 * mark can be set or cleared) and mixed (in which an en-dash can be set or
 * cleared). The mixed check boxes might be used at the top of a list, to show that
 * only some of the subcategories have been selected, or in other situations in
 * which a simple off / on state is not appropriate.
 */
public class CheckBox extends android.widget.CheckBox {

	private boolean isDash = false;
	
	/**
	 * Creates an CheckBox Widget.
	 * @param context
	 */
	public CheckBox(Context context) {
		super(context);
		init();
	}
	
	/**
	 * Creates an CheckBox Widget with a set of attributes.
	 * @param context
	 * @param attrs
	 */
	public CheckBox(Context context, AttributeSet attrs) {
		super(context, attrs);
		init(attrs);
	}
	
	/**
	 * Creates an CheckBox Widget with the defined style given by the user.
	 * @param context
	 * @param attrs
	 * @param defStyle
	 */
	public CheckBox(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
		init(attrs);
	}

	

	/**
	 * Initialize the class with a set of attributes defined in the XML layout.
	 * @param attrs
	 */
	private void init(AttributeSet attrs) {
		
		TypedArray a = getContext().obtainStyledAttributes(attrs, R.styleable.CheckBox);
		isDash = a.getBoolean(R.styleable.CheckBox_is_dash, false);
		
		if(isDash) {
			setButtonDrawable(R.drawable.checkbox_dash_style);
		}else {
			setButtonDrawable(R.drawable.checkbox_style);
		}
	}
	
	/**
	 * Initialize the class with default values.
	 */
	private void init() {
		setButtonDrawable(R.drawable.checkbox_style);
	}

	/**
	 * Return {@value <code>true</code>}
	 * if it's in the dash mode.
	 * @return
	 */
	public boolean isDash() {
		return isDash;
	}

	/**
	 * Set the check box to the dash mode
	 * or not.
	 * @param isDash
	 */
	public void setDash(boolean isDash) {
		if(isDash) {
			setButtonDrawable(R.drawable.checkbox_dash_style);
		}else {
			setButtonDrawable(R.drawable.checkbox_style);
		}
	}
	
}
