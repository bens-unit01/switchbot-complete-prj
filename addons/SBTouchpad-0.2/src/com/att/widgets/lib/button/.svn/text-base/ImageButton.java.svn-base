package com.att.widgets.lib.button;

import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.drawable.Drawable;
import android.util.AttributeSet;

import com.att.widgets.lib.R;

/**
 * The Image Button widget is a simple UI item with three states: enabled, pressed,
 * and disabled.
 */
public class ImageButton extends android.widget.ImageButton {

	public static final int CUSTOM = 0, CLOSE = 1, LIST = 2, 
		REMOVE = 3, LEVELUP = 4, SEC = 5, PLAY = 6;
	
	/**
	 * Creates an ImageButton Widget with the defined style given by the user.
	 * @param context
	 * @param attrs
	 * @param defStyle
	 */
	public ImageButton(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
		init(attrs);
	}

	/**
	 * Creates an ImageButton Widget with a set of attributes.
	 * @param context
	 * @param attrs
	 */
	public ImageButton(Context context, AttributeSet attrs) {
		super(context, attrs);
		init(attrs);
	}

	/**
	 * Creates an ImageButton Widget.
	 * @param context
	 */
	public ImageButton(Context context) {
		super(context);
	}
	
	/**
	 * Initialize the class with a set of attributes defined in the XML layout.
	 * @param attrs
	 */
	private void init(AttributeSet attrs) {
		TypedArray a = getContext().obtainStyledAttributes(attrs, R.styleable.ImageButton);
		super.setEnabled(a.getBoolean(R.styleable.ImageButton_enabled, true));
		int type = a.getInt(R.styleable.ImageButton_imageType, CUSTOM);
		setImageType(type);
	}
	
	@Override
	protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
		Drawable d = getBackground();
		setMeasuredDimension(d.getMinimumWidth(), d.getMinimumHeight());
	}
	
	/**
	 * Set a pre-designed image to the
	 * {@link ImageButton}. 
	 * @param type
	 */
	public void setImageType(int type){
		switch (type) {
			case CUSTOM:
				break;
			case CLOSE:
				setBackgroundResource(R.drawable.close_button);
				break;
			case LIST:
				setBackgroundResource(R.drawable.list_button);
				break;
			case REMOVE:
				setBackgroundResource(R.drawable.remove_button);
				break;
			case LEVELUP:
				setBackgroundResource(R.drawable.levelup_button);
				break;
			case SEC:
				setBackgroundResource(R.drawable.secondary_button);
				break;
			case PLAY:
				setBackgroundResource(R.drawable.play_button);
				break;
			default:
				break;
		}
	}
	
}
