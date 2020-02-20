
#ifndef SWITCHBOT_H_
#define SWITCHBOT_H_



#define BLINKM_ADDR  19

#define  ESTOP                      0x65
#define  CLEAR_ESTOP                0x66
#define  DRIVE                      0x81
#define	 DP_GOTO_BEACON             0x40
#define  DP_STOP                    0x41
#define  NOTF_GET_NEXT_BEACON       0x42
#define  DP_REACH_BEACON            0x43
#define  DP_NORDIC_MB_TEST          0x44
#define	 NOTF_NORDIC_MB_TEST        0x45
#define	 NOTF_DP_TARGET_REACHED     0x46
#define  NOTF_VOICE_RECORD          0x50
#define  DP_GET_CLOSEST_BEACON      0x48
#define  NOTF_DP_CLOSEST_BEACON     0x47
#define  DP_CHANGE_RANGE            0x49
#define  UART0                      0x00
#define  UART1                      0x01
#define  NOTF_MCU_UP                0x55
#define  ACK_BYTE                   0xFD

#define DEBUG_DUMP                  0x35
#define DEBUG_STATE                 0x36
#define DEBUG_ST_STATE              0x37
#define DEBUG_TEST_01               0x38

// BlinkM RGB commands

#define RGB_CTRL_COMMAND   0x54

    // RGB supported values

/*
1) Active Internet connection - Blue
2) No Internet connection - Red
3) Listening – Amber / orange
4) Thinking Green long pulse
5) Speaking? Green flashing (with intonation of voice?)
6) resting state – green solid (if none of the above present)

  */

#define RGB_OFF               0x00
#define RGB_SOLID_RED         0x01
#define RGB_SOLID_BLUE        0x02
#define RGB_SOLID_AMBER       0x03
#define RGB_SOLID_GREEN       0x04
#define RGB_FLASH_GREEN_SLOW  0x05
#define RGB_FLASH_GREEN_QUICK 0x06
#define RGB_FLASH_BLUE_SLOW   0x07
#define RGB_FLASH_BLUE_QUICK  0x08


#define DEBUG_MODE    1

#ifdef DEBUG_MODE
#define LOG printf 
#define PGM_LOG(...) 
#else
#define LOG(...)
#define PGM_LOG(...)
#endif



#endif /* SWITCHBOT_H_ */
