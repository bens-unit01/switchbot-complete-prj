/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.wowwee.drivepath;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.LinkedList;
import java.util.Map;
import java.util.Set;

import android.util.Log;

/**
 *
 * @author user
 */
public class DPAlgorithmBFS {
    
    //private static final String START = "B";
    //private  final String END = "E";
    private static Integer startNode = 0;
    private Integer endNode = 0;
    private ArrayList<LinkedList<Integer>> results = null;
    private Map<String, LinkedHashSet<Integer>> map = null;
    
    
    public DPAlgorithmBFS(){
    	results = new ArrayList<LinkedList<Integer>>();
        map = new HashMap();
    }

    public void addEdge(Integer node1, Integer node2) {
        LinkedHashSet<Integer> adjacent = map.get(node1.toString());
        if(adjacent==null) {
            adjacent = new LinkedHashSet();
            map.put(node1.toString(), adjacent);
        }
        adjacent.add(node2);
    }

    public void addTwoWayVertex(Integer node1, Integer node2) {
        addEdge(node1, node2);
        addEdge(node2, node1);
    }

    public boolean isConnected(Integer node1, Integer node2) {
        Set adjacent = map.get(node1.toString());
        if(adjacent==null) {
            return false;
        }
        return adjacent.contains(node2);
    }

    public LinkedList<Integer> adjacentNodes(Integer last) {
        LinkedHashSet<Integer> adjacent = map.get(last.toString());
        if(adjacent==null) {
            return new LinkedList();
        }
        return new LinkedList<Integer>(adjacent);
    }
    
        private void breadthFirst(DPAlgorithmBFS graph, LinkedList<Integer> visited) {
        LinkedList<Integer> nodes = graph.adjacentNodes(visited.getLast());
        // examine adjacent nodes
        for (Integer node : nodes) {
            if (visited.contains(node)) {
                continue;
            }
            if (node.equals(endNode)) {
                visited.add(node);
               // printPath(visited);
                savePath(visited);
                visited.removeLast();
                break;
            }
        }
        // in breadth-first, recursion needs to come after visiting adjacent nodes
        for (Integer node : nodes) {
            if (visited.contains(node) || node.equals(endNode)) {
                continue;
            }
            visited.addLast(node);
            breadthFirst(graph, visited);
            visited.removeLast();
        }
    }

    private void printPath(LinkedList<Integer> visited) {
        for (Integer node : visited) {
            System.out.print(node);
            System.out.print(" ");
        }
        System.out.println();
    }
    
     private void savePath(LinkedList<Integer> visited) {
         // cloning the results 
         LinkedList<Integer> clone = new LinkedList<Integer>();
         for(Integer id: visited){
           clone.add(id);
         }
         results.add(clone);
     }
    public static void test01(String args[]){
    
    System.out.println("App started ...");
    
     DPAlgorithmBFS graph = new DPAlgorithmBFS();
       /* 
        *
        graph.addEdge("A", "B");
        graph.addEdge("A", "C");
        graph.addEdge("B", "A");
        graph.addEdge("B", "D");
        graph.addEdge("B", "E"); // this is the only one-way connection
        graph.addEdge("B", "F");
        graph.addEdge("C", "A");
        graph.addEdge("C", "E");
        graph.addEdge("C", "F");
        graph.addEdge("D", "B");
        graph.addEdge("E", "C");
        graph.addEdge("E", "F");
        graph.addEdge("F", "B");
        graph.addEdge("F", "C");
        graph.addEdge("F", "E");
        LinkedList<String> visited = new LinkedList();
        visited.add(START);
         graph.breadthFirst(graph, visited);
         * 
         * */
     /*
        graph.addEdge(1, 2);
        graph.addEdge(1, 3);
        graph.addEdge(2, 1);
        graph.addEdge(2, 4);
        graph.addEdge(2, 5); // this is the only one-way connection
        graph.addEdge(2, 6);
        graph.addEdge(3, 1);
        graph.addEdge(3, 5);
        graph.addEdge(3, 6);
        graph.addEdge(4, 2);
        graph.addEdge(5, 3);
        graph.addEdge(5, 6);
        graph.addEdge(6, 2);
        graph.addEdge(6, 3);
        graph.addEdge(6, 5);
        
        LinkedList<Integer> visited = new LinkedList();
        visited.add(startNode);
         graph.breadthFirst(graph, visited);
         */
         /* 
          * results : 
            2 5 
            2 1 3 5 
            2 1 3 6 5 
            2 6 5 
            2 6 3 5 
          */
     
           DPNode node1 = new DPNode(0, 0, 1);
           DPNode node2 = new DPNode(0, 0, 2);
           DPNode node3 = new DPNode(0, 0, 3);
           DPNode node4 = new DPNode(0, 0, 4);
           DPNode node5 = new DPNode(0, 0, 5);
           DPNode node6 = new DPNode(0, 0, 6);
           DPMap dpMap = new DPMap();
           DPLine line1 = new DPLine();
           line1.startPoint = node1;
           line1.endPoint = node2;
           DPLine line2 = new DPLine();
           line2.startPoint = node1;
           line2.endPoint = node3;
           DPLine line3 = new DPLine();
           line3.startPoint = node2;
           line3.endPoint = node4;
           DPLine line4 = new DPLine();
           line4.startPoint = node2;
           line4.endPoint = node6;
           DPLine line5 = new DPLine();
           line5.startPoint = node2;
           line5.endPoint = node5;
           DPLine line6 = new DPLine();
           line6.startPoint = node6;
           line6.endPoint = node5;
           DPLine line7 = new DPLine();
           line7.startPoint = node3;
           line7.endPoint = node5;
           DPLine line8 = new DPLine();
           line8.startPoint = node3;
           line8.endPoint = node6;
           dpMap.add(line1);
           dpMap.add(line2);
           dpMap.add(line3);
           dpMap.add(line4);
           dpMap.add(line5);
           dpMap.add(line6);
           dpMap.add(line7);
           dpMap.add(line8);
           
           graph.getPath(node2, node5, dpMap);
           
           
    }
    
public    LinkedList<Integer> getPath(DPNode startNode, DPNode endNode, DPMap dpMap ){
	
	         LinkedList<Integer> rv = null;

             ArrayList<DPLine> lines = dpMap.getLines();
             for (DPLine  line : lines) {
                this.addEdge(line.startPoint.id, line.endPoint.id);
                this.addEdge(line.endPoint.id, line.startPoint.id);
             }
             
              this.startNode = startNode.id;
              this.endNode = endNode.id;
              LinkedList<Integer> visited = new LinkedList();
              visited.add(this.startNode);
              this.breadthFirst(this, visited);
          /*
              for(LinkedList<Integer> item:results){
                 for(Integer node:item){
                     System.out.print(" " + node);
                 }
              System.out.println();
             }      
             */
             // finding the index for the shortest path
             
             int index = 0;
             int newSize = 20;
               for(LinkedList<Integer> item:results){
                       if(item.size() < newSize){
                          newSize = item.size();
                          index = results.indexOf(item);
                       }
               }
               
           try{
        	   rv = results.get(index);
        	   for(Integer i: rv){
        	   Log.d("DPAlgorithmBSF node : ", i.toString() );
        	   }
           }catch(IndexOutOfBoundsException ex){
        	  ex.printStackTrace(); 
           } 
             //  System.out.println(" " + newSize + " " + index);
             
    return rv;
}
    
}
