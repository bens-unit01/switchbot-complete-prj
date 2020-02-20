package com.wowwee.util;

public class SBProtocol {
	
	
	public static final byte START_BYTE         = (byte) 0xFE; 
	public static final byte END_BYTE           = (byte) 0xFF;  
	public static final byte NOTF_VOICE_RECORD  = 0x50;
	public static final byte NOTF_GET_STATUS    = 0x51;
	public static final byte NOTF_SET_STATUS    = 0x52;
	public static final byte NOTF_ACTIVATE_ADB  = 0x53;  // activate adb through wifi 
	public static final byte MOVE_FORWARD       = 0x10; 
	public static final byte MOVE_BACKWARD      = 0x11; 
	public static final byte TURN_LEFT          = 0x20; 
	public static final byte TURN_RIGHT         = 0x21;
	public static final byte LEAN_FORWARD       = 0x30;
	public static final byte LEAN_BACKWARD      = 0x31;
	
	
	
	
	   public static final byte BLASTER_TV_ON       = 0x35;
	   public static final byte BLASTER_TV_OFF      = 0x36;
	   public static final byte BLASTER_GOTO_CHANNEL  = 0x37;
	
	
// DrivePath commands 
	
	public static final byte DP_GOTO_BEACON          = 0x40;
	public static final byte DP_STOP                 = 0x41;
	public static final byte NOTF_GET_NEXT_BEACON    = 0x42;
	public static final byte DP_REACH_BEACON         = 0x43;
	public static final byte DP_NORDIC_MB_TEST       = 0x44;
	public static final byte NOTF_NORDIC_MB_TEST     = 0x45;
	public static final byte NOTF_DP_TARGET_REACHED  = 0x46;  
	public static final byte NOTF_DP_CLOSEST_BEACON  = 0x47;   
	public static final byte DP_GET_CLOSEST_BEACON   = 0x48;  
	public static final byte DP_CHANGE_RANGE         = 0x49;   
	public static final String DP_LABELS[] = {"BEDROOM", "DEN", "DINING ROOM", "ENTRYWAY", 
        "KITCHEN", "FRONT DOOR", "BACK DOOR", "SIDE DOOR",
        "PATIO", "FAMILY ROOM","HALLWAY", "LIVING ROOM",
        "MASTER BEDROOM","KIDS ROOM", "PLAYROOM", "KIDS BEDROOM",
        "GUEST BEDROOM", "GUEST ROOM", "OFFICE","UPSTAIRS", 
        "DOWNSTAIRS", "BASEMENT","GARAGE", "LIBRARY", 
        "STUDY", "LAUNDRY ROOM" }; 
	
	
	// body cons codes
//	public static final byte BODY_CON           = 0x30;
	public static final byte DANCE              = 0x60;
	public static final byte STAND_UP           = 0x61;
//	public static final byte TRACK              = 0x62;
	public static final byte KNEEL              = 0x62;
	public static final byte LEAN               = 0x63;   
	public static final byte DRIVE              = 0x78;  
    public static final byte ESTOP              = 0x65;
    public static final byte CLEAR_ESTOP        = 0x66;
	
/*
   speed byte: 0x00 - 0x20 is forwards slow to full speed, 
   0x21 - 0x40 is reverse slow to full speed
   direction byte: 0x41 - 0x60 is right turn gentle arc to sharp turn, 
   0x61 - 0x80 is left turn gentle arc to sharp turn
 * */	
	// encoded commands 
    public static final byte[] ENCODED_DRIVE_FORWARD  = {DRIVE, 0x10, 0}; 
    public static final byte[] ENCODED_DRIVE_BACKWARD = {DRIVE, 0x30, 0}; 
    public static final byte[] ENCODED_TURN_LEFT      = {DRIVE, 0, 0x70}; 
    public static final byte[] ENCODED_TURN_RIGHT     = {DRIVE, 0, 0x50}; 
    public static final byte[] ENCODED_LEAN_FORWARD   = {LEAN, (byte) 0xB1 , 0}; 
    public static final byte[] ENCODED_LEAN_BACKWARD  = {LEAN, 0x4D, 0x50}; 
    public static final int    DRIVE_NB_STEPS         = 10;
    
    
    // jetty server protocol 
    
	public static final String  JETTY_SPLIT_CHAR           = "/";
    public static final String  JETTY_GOTO_BEACON          = "drivepathGo"; 
    public static final String  JETTY_DISCONNECT_BEACON    = "drivepathDisconnect"; 
    public static final String  JETTY_CLR_ESTOP            = "clrEStop"; 
    public static final String  JETTY_SET_ESTOP            = "setEStop"; 
    public static final String  JETTY_DRIVEPATH_INIT       = "drivepathInit"; 
    public static final String  JETTY_DRIVETO_BEACON       = "driveToBeacon"; 
    public static final String  JETTY_ACTIVATE_ADB         = "activateAdb"; 
    public static final String  JETTY_NORDIC_MEDIABOX_TEST = "nordicMediabox";
	public static final String  JETTY_GET_STATUS           = "getStatus"; 
	public static final String  JETTY_SET_STATUS           = "setStatus"; 
	public static final String  JETTY_DRIVE                = "drive"; 
	public static final String  JETTY_STAND_UP             = "standup"; 
	public static final String  JETTY_LEAN_FORWARD         = "leanForward"; 
	public static final String  JETTY_LEAN_BACKWARD        = "leanBack"; 
	public static final String  JETTY_KNEEL                = "kneel"; 
	public static final String  JETTY_SAVE_DATA            = "saveData"; 
	public static final String  JETTY_CHANGE_RANGE         = "changeRange";
    
    
    
    
}
