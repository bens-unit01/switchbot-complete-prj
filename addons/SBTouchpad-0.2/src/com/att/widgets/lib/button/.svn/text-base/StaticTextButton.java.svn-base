package com.att.widgets.lib.button;

import android.content.Context;
import android.content.res.TypedArray;
import android.util.AttributeSet;

import com.att.widgets.lib.R;

/**
 * The Static Text Button widget combines the functionality of the Static Text and
 * Button widgets. Applications can use this widget instead of using separate Static
 * Text and Button widgets to create a labeled button.
 * A Static Text Button has three states: enabled, active, and disabled.
 */
public class StaticTextButton extends android.widget.Button {

	public static final int PRIMARY_BUTTON = 1;
	public static final int PRIMARY_BUTTON_HIGHLIGHTED = 2;
	public static final int PRIMARY_BUTTON_WARNING = 3;
	public static final int SECONDARY_BUTTON_BLACK = 4;
	public static final int SECONDARY_BUTTON_WHITE = 5;
	
	private int type = PRIMARY_BUTTON;
	
	/**
	 * Creates a StaticTextButton widget	
	 * @param context
	 */
	public StaticTextButton(Context context) {
		super(context);
		init(context);
	}

	/**
	 * Creates an StaticTextButton Widget with a set of attributes.
	 * @param context
	 * @param attrs
	 */
	public StaticTextButton(Context context, AttributeSet attrs) {
		super(context, attrs);
		TypedArray a = getContext().obtainStyledAttributes(attrs, R.styleable.Button);
		setType(a.getInt(R.styleable.Button_buttonType, PRIMARY_BUTTON));
		init(context);
	}
	
	/**
	 * Creates an StaticTextButton Widget with the defined style given by the user.
	 * @param context
	 * @param attrs
	 * @param defStyle
	 */
	public StaticTextButton(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
		TypedArray a = getContext().obtainStyledAttributes(attrs, R.styleable.Button);
		setType(a.getInt(R.styleable.Button_buttonType, PRIMARY_BUTTON));
		init(context);
	}

	private void init(Context context) {
	}

	/**
	 * Sets the button type
	 * @param type
	 */
	public void setType(int type) {
		Context context = this.getContext();
		this.type = type;
		switch (type) {
		case PRIMARY_BUTTON:
			this.setBackgroundDrawable(context.getResources().getDrawable(R.drawable.button_primary));
			this.setTextColor(0xFFFFFFFF);
			break;
		case PRIMARY_BUTTON_HIGHLIGHTED:
			this.setBackgroundDrawable(context.getResources().getDrawable(R.drawable.button_blue));
			this.setTextColor(0xFF000000);
			break;
		case PRIMARY_BUTTON_WARNING:
			this.setBackgroundDrawable(context.getResources().getDrawable(R.drawable.button_red));
			this.setTextColor(0xFFFFFFFF);
			break;
		case SECONDARY_BUTTON_BLACK:
			this.setBackgroundDrawable(context.getResources().getDrawable(R.drawable.button_black));
			this.setTextColor(0xFFFFFFFF);
			break;
		case SECONDARY_BUTTON_WHITE:
			this.setBackgroundDrawable(context.getResources().getDrawable(R.drawable.button_white));
			this.setTextColor(0xFF000000);
			break;
		}
	}
	
	@Override
	public void setEnabled(boolean enabled) {
		super.setEnabled(enabled);
	}
	
	@Override
	public void setFocusable(boolean focusable) {
		super.setFocusable(focusable);
		
	}
	
}
