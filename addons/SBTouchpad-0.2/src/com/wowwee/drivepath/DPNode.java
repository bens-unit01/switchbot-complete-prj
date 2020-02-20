package com.wowwee.drivepath;

import java.util.ArrayList;


public class DPNode {
	
	   	

		  public int	 x, y ; // x and y position on the screen
		  public int id;      // this represent the beacon id 
		  public  String label;
		  public	DPNode(int _x, int _y) {
				x = _x;
				y = _y;

			}
			
			public DPNode(int _x, int _y, int _id) {
				x = _x;
				y = _y;
				id = _id;

			}
			
			@Override
				public boolean equals(Object o) {
					return this.id == ((DPNode)o).id ;
				}

			@Override
			public String toString() {
				return "Pt [x=" + x + ", y=" + y + ", id=" + id + ", label=" +label + "]";
			}
			
		
	
		

}
