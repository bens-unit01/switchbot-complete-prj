package com.wowwee.drivepath;


public class DPLine {
	
    public	DPNode startPoint;
	public DPNode endPoint;

	@Override
	public boolean equals(Object o) {
		boolean returnValue = false;
		DPLine firstLine = (DPLine) this;
		DPLine secondLine = (DPLine) o;
		returnValue = firstLine.startPoint.id == secondLine.startPoint.id
				&& firstLine.endPoint.id == secondLine.endPoint.id;
	    if(!returnValue){
	    	returnValue = firstLine.startPoint.id == secondLine.endPoint.id
					&& firstLine.endPoint.id == secondLine.startPoint.id;
	    }	
		return returnValue;
	}

	@Override
	public String toString() {
		return "Line [startPoint=" + startPoint + ", endPoint="
				+ endPoint + "]";
	}
  
	public DPLine clone(){
	    DPNode startPt = new DPNode(this.startPoint.x, this.startPoint.y, this.startPoint.id );	
	    DPNode endPt = new DPNode(this.endPoint.x, this.endPoint.y, this.endPoint.id );
	    DPLine cloneLine = new DPLine();
	    cloneLine.startPoint = startPt;
	    cloneLine.endPoint = endPt;
		return cloneLine;
	}

}
