package com.wowwee.touchpad;

import java.util.ArrayList;

import com.google.gson.Gson;
import com.wowwee.util.SBProtocol;
import com.wowwee.util.Utils;

public class LabelsList {
	
	public final static String FILENAME = "json_labels_list";
	
	private ArrayList<Label> labelsList;
	private String mPackageName;
public LabelsList(String packageName){
	  mPackageName = packageName;
	  labelsList = new ArrayList<Label>();
}

public LabelsList(){
	  labelsList = new ArrayList<Label>();
	 for (int i = 0; i < SBProtocol.DP_LABELS.length; i++) {
		     labelsList.add(new Label(SBProtocol.DP_LABELS[i], true));	
		}
	
}

public ArrayList<Label> getLabelsList() {
	return labelsList;
}

public void setLabelsList(ArrayList<Label> labelsList) {
	this.labelsList = labelsList;
}

public void loadList(){

    	  for (int i = 0; i < SBProtocol.DP_LABELS.length; i++) {
 		     labelsList.add(new Label(SBProtocol.DP_LABELS[i], true));	
 		}
         
         
}

public void saveList(){
     String  fileName = "/data/data/" + mPackageName + "/" + FILENAME;
     Gson gson = new Gson();
     final  String jsonLabelsList= gson.toJson(this);
	 Utils utils = new Utils();
     utils.saveData(fileName, jsonLabelsList);
}


public void deactivate(Label label){
	int index = labelsList.indexOf(label);
	labelsList.get(index).setState(false);;
}

public void activate(Label label){
	int index = labelsList.indexOf(label);
	labelsList.get(index).setState(true);;
}

@Override
public String toString() {

	return "LabelsList [labelsList=" + labelsList + ", mPackageName="
			+ mPackageName + "]";
}


}
