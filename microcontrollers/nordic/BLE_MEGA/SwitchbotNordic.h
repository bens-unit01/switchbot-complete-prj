/*

   setup for the new SB board ( board integrating both nuvoton and nordics boards)
 */
#ifndef SWITCHBOT_NORDIC_H
#define SWITCHBOT_NORDIC_H

#include "debug.h"
#include "nrf_gpio.h"

/*
#define LED_left          20
#define LED_head	  12
#define LED_right   	 22// 16//22
#define LED_tail         23 // 17 //23
*/

#define BLINKM_ADDR  9

#define LED_left          24
#define LED_head	      24
#define LED_right         24// 16//22
#define LED_tail          24 // 17 //23

#define	RGB_RED 	24 //	8
#define RGB_GREEN 	24 //	7
#define RGB_BLUE 	24 //	6
#define Switch 		24 //	5

//jason board
 #define	IRM_right		21	//IRM receive right  R6
 #define	IRM_tail		24	//IRM receive tail   R3
 #define	IRM_left		25	//IRM receive left   R2
 #define	IRM_head		26	//IRM receive head   R4





#define Q410_BOARD        1   // settings for Andrew Kohlsmith board (motors board)

#ifdef  Q410_BOARD   // settings for Andrew Kohlsmith board (motors board)
#define RX_PIN_NUMBER       2 // UART RX pin number.
#define TX_PIN_NUMBER       1 // UART TX pin number.
#define CTS_PIN_NUMBER      18    // UART Clear To Send pin number. Not used if HWFC is set to false
#define RTS_PIN_NUMBER      25//19    // Not used if HWFC is set to false
#define HWFC               false // UART hardware flow control
#else
#ifdef DEBUG_MODE
#define RX_PIN_NUMBER   2 //4 // UART RX pin number.
#define TX_PIN_NUMBER   0 //5// UART TX pin number.
#else
#define RX_PIN_NUMBER   2 // UART RX pin number.
#define TX_PIN_NUMBER   0 // UART TX pin number.
#endif
#endif
// --- rx-tx for SwitchBot ---- real board
#define TX_MEDIA_BOX    20 // UART TX pin number.
//------------------------------
#define CTS_PIN_NUMBER 18    // UART Clear To Send pin number. Not used if HWFC is set to false
#define RTS_PIN_NUMBER  25//19    // Not used if HWFC is set to false
#define HWFC           false // UART hardware flow control


/* yes, thrust is inverted */
#define THRUST_MIN	0xe1
#define THRUST_MAX	0x00

#define YAW_MIN		0x00
#define YAW_MAX		0xe1
#define PITCH_MIN	0x00
#define PITCH_MAX	0xe1
#define ROLL_MIN	0x00
#define ROLL_MAX	0xe1



struct qr_cmd {
	uint16_t thrust;					/* left joystick, up/down */
	uint16_t yaw;					/* left joystick, left/right */
	uint16_t pitch;					/* right joystick, up/down */
	uint16_t roll;					/* right joystick, left/right */
	uint16_t aux1;
	uint16_t aux2;
	uint16_t aux3;
	uint16_t aux4;

};

enum DP_MODE {
	TRACKING_MODE = 0,
	READING_MODE,
	APPROACH_MODE,
	APPROACHING_MODE,
	ROTATING_MODE,
	STOP_MODE,
	WAIT_MODE,
	RSSI_MEASURING_MODE,
	IR_MEASURING_MODE,
	SEND_DATA_MODE
};

enum DP_REQUEST {
	DISCONNECT = 0,
    SEND_DATA
};

// SwitchBot protocol commands
#define NOTF_GET_STATUS        0x51
#define NOTF_SET_STATUS        0x52
#define NOTF_ACTIVATE_ADB      0x53
#define RGB_CTRL_COMMAND       0x54
#define STAND_UP               0x61
#define KNEEL                  0x62
#define LEAN                   0x63
#define ESTOP                  0x65
#define CLEAR_ESTOP            0x66
#define TEST_01                0x67
#define TEST_02                0x68

#define DRIVE                   0x81

#define	 DP_GOTO_BEACON         0x40
#define  DP_STOP                0x41
#define  NOTF_GET_NEXT_BEACON   0x42
#define  DP_REACH_BEACON        0x43

#define DP_NORDIC_MB_TEST       0x44
#define	NOTF_NORDIC_MB_TEST     0x45
#define	NOTF_DP_TARGET_REACHED  0x46
#define DP_GET_CLOSEST_BEACON   0x48
#define NOTF_DP_CLOSEST_BEACON  0x47
#define DP_CHANGE_RANGE         0x49

// debug commands 

#define DEBUG_DUMP                0x35
#define DEBUG_STATE               0x36


// IR control
#define IR_CTRL                  0x20
#define IR_GUN_ON                0x01
#define IR_BACK_ON               0x02
#define IR_HEAD_ON               0x03
#define IR_ALL_ON                0x04
#define IR_ALL_OFF               0x05


#define MAX_BEACONS         5

#define   BUTTON_1  24                           /**< Button used for deleting all bonded centrals during startup. */
#define   LED_2     24
#define   LED_0     7                                     /**< Is on when device is scanning. */
#define   LED_1     6                                     /**< Is on when device has connected. */
#define   LED_7     24


bool calculate_speed(uint8_t IR[],int MaxRange,  int16_t * fwd_bwd,  int16_t * lft_rgt, uint8_t debug_values[]);
int calc_coord(uint8_t IR[], int *Head, int *Range );

#endif  // REV
