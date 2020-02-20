package com.wowwee.drivepath;

import java.util.ArrayList;

import com.wowwee.touchpad.Label;


public class DPMap {
	
	ArrayList<DPLine> lines;
	public DPMap(){
		lines = new ArrayList<DPLine>();
	}
	
	public void add(DPLine newLine){
		lines.add(newLine);
	}
	
	public void remove(DPLine line){
		lines.remove(line);
	}
	
	public ArrayList<DPLine> getLines(){
		return lines;
	}
   
	@Override
	public String toString() {
		return "Map [lines=" + lines + "]";
	}
	
	public DPMap clone() {
	    DPMap clone = new DPMap();   
		for(DPLine line: this.getLines()) clone.add(line.clone());
	    return clone;
	}
	
	public void setLabel(DPNode selectedPt, String label){
	 ArrayList<DPLine> lines = this.getLines();
	 for (DPLine line : lines) {
	   if(line.startPoint.equals(selectedPt)){
		  line.startPoint.label = label;
	   }
	   if(line.endPoint.equals(selectedPt)){
		   line.endPoint.label = label;
	   } 
	}
	}
	
     public ArrayList<Label> getLabels(){
    	 ArrayList<Label> labels = new ArrayList<Label>();
    	 
    	 for (DPLine line : lines) {
    		 
    		 if(line.startPoint.label != null){
    			 if(!labels.contains(new Label(line.startPoint.label, false))){
    				 labels.add(new Label(line.startPoint.label, true));
    			 }
    		 }
    		 if(line.endPoint.label != null){
    			 if(!labels.contains(new Label(line.endPoint.label, false))){
    				 labels.add(new Label(line.endPoint.label, true));
    			 }
    		 }
    	 }
    	 return labels;
     }
}
