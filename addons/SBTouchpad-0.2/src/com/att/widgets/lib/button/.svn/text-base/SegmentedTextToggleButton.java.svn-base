package com.att.widgets.lib.button;

import java.util.Vector;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.LinearLayout;

import com.att.widgets.lib.R;

/**
 *A Segmented Toggle Button widget contains two or more toggle buttons. One
 *button is always in the active state. When one of the toggle buttons is tapped, it
 *is switched to the active state, and the other buttons are switched to the enabled
 *state. If one of the toggle buttons is disabled, that toggle button is disabled until
 *the disabling event is cleared. If the entire Segmented Toggle Button is disabled,
 *it remains disabled until the disabling event is cleared.  
 */
public class SegmentedTextToggleButton extends LinearLayout implements OnClickListener{
	
	//Toggle buttons
	private Vector<ImageToggleButton> buttons;
	
	//Listener
	private OnClickListener listener;
	
	/**
	 * Creates a SegmentedTextToggleButton widget	
	 * @param context
	 */
	public SegmentedTextToggleButton(Context context){
		super(context);
	}
	
	/**
	 * Creates an SegmentedTextToggleButton Widget with a set of attributes.
	 * @param context
	 * @param attrs
	 */
	public SegmentedTextToggleButton(Context context, AttributeSet attrs) {
		super(context, attrs);
	}
	
	@Override
	protected void onFinishInflate() {
		super.onFinishInflate();
		init();
	}
	
	
	/**
	 * Initialize the toggle buttons (set images and listeners).
	 * It's responsibility of the user call this
	 * method after he add a new {@link ImageToggleButton}}.
	 */
	public void init(){
		buttons = new Vector<ImageToggleButton>();
		addLayoutButtons();
		changeButtonsImage();
		setListeners();
	}
	
	/**
	 * Add a {@link ImageToggleButton} to the
	 * {@link SegmentedTextToggleButton}}
	 * @param toggleButton
	 */
	public void addButton(ImageToggleButton toggleButton){
		if(buttons == null){
			buttons = new Vector<ImageToggleButton>();
		}
					
		addView(toggleButton);
		buttons.add(toggleButton);
	}
	
	/**
	 * Remove the {@link ImageToggleButton} in
	 * the given index position.
	 * @param index
	 */
	public void removeButton(int index){
		if(buttons != null){
			if(index >= 0 && index < buttons.size()){
				buttons.remove(index);
				removeViewAt(index);
			}
		}
	}
	
	private void addLayoutButtons(){
		int n = getChildCount();
		for(int i=0; i<n; i++){
			View v = getChildAt(i);
			if(v instanceof ImageToggleButton){
				buttons.add((ImageToggleButton)v);
			}
		}
	}
	
	private void changeButtonsImage(){
		if(buttons.size() > 1){
			buttons.get(0).setBackgroundResource(R.drawable.segment_toggle_left);
			for(int i=1; i < buttons.size()-1; i++){
				buttons.get(i).setBackgroundResource(R.drawable.segment_toggle_middle);
			}
			buttons.get(buttons.size()-1).setBackgroundResource(R.drawable.segment_toggle_right);
		}else{
			//TODO:set an image with rounded sides
		}
	}
	
	private void setListeners(){
		for(int i=0; i<buttons.size(); i++){
			buttons.get(i).setOnClickListener(this);
			buttons.get(i).setFocusable(true);
		}
	}

	public void onClick(View v) {
		setSelectedView(v);
		if(listener != null){
			listener.onClick(this);
		}
		
	}

	/**
	 * Enable or disable the {@link SegmentedTextToggleButton}
	 */
	@Override
	public void setEnabled(boolean enabled) {
		super.setEnabled(enabled);
		for(int i = 0; i < buttons.size(); i++){
			buttons.get(i).setEnabled(enabled);
		}
	}
	
	/**
	 * Enabled or disabled the {@link ImageToggleButton}
	 * at the given index.
	 * @param enabled
	 * @param index
	 */
	public void setEnabledIndex(boolean enabled, int index){
		if(index >= 0 && index < buttons.size()){
			buttons.get(index).setEnabled(enabled);
		}
	}
	
	/**
	 * Set Selected the {@link ImageToggleButton}
	 * in the given index position.
	 * @param index
	 */
	public void setSelectedIndex(int index){
		if(index >= 0 && index < buttons.size()){
			setSelectedView(buttons.get(index));
		}
	}
	
	/**
	 * Return the index of the selected {@link ImageToggleButton}
	 * or -1 if none was selected
	 * @return
	 */
	public int getSelectedIndex(){
		int selected = -1;
		for(int i=0; i<buttons.size(); i++){
			ImageToggleButton b = buttons.get(i);
			if(b.isChecked()){
				selected = i;
				break;
			}
		}	
		
		return selected;
	}
	
	private void setSelectedView(View v){
		for(int i=0; i<buttons.size(); i++){
			ImageToggleButton b = buttons.get(i);
			b.setChecked(v == b);
		}	
	}
	
	/**
	 * Set an onclick listener to the {@link SegmentedTextToggleButton}.
	 * If an {@link ImageToggleButton} is clicked the onclick method
	 * of this listener will be called.
	 */
	@Override
	public void setOnClickListener(OnClickListener l) {
		this.listener = l;
	}
	
}
