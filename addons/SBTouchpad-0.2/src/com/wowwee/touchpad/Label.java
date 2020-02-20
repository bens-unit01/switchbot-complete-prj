package com.wowwee.touchpad;

public class Label {
	
	
	private String text;
	private boolean state;
	public Label(String text, boolean state) {
		super();
		this.text = text;
		this.state = state;
	}
	public String getText() {
		return text;
	}
	public void setText(String text) {
		this.text = text;
	}
	public boolean isState() {
		return state;
	}
	public void setState(boolean state) {
		this.state = state;
	}
	
 @Override
public boolean equals(Object o) {
	return ((Label)o).getText().equals(this.getText());
}
@Override
public String toString() {
	return "Label [text=" + text + ", state=" + state + "]";
}
 
 
 

}
