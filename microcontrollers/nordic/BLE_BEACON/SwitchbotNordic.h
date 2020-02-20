/* Copyright (c) 2012 Nordic Semiconductor. All Rights Reserved.
 *
 * The information contained herein is property of Nordic Semiconductor ASA.
 * Terms and conditions of usage are described in detail in NORDIC
 * SEMICONDUCTOR STANDARD SOFTWARE LICENSE AGREEMENT.
 *
 * Licensees are granted free, non-transferable use of the information. NO
 * WARRANTY of ANY KIND is provided. This heading must NOT be removed from
 * the file.
 *
 */
#ifndef REV
#define REV

#include "nrf_gpio.h"

/*
#define LED_left          20
#define LED_head	  12
#define LED_right   	 22// 16//22
#define LED_tail         23 // 17 //23
*/

#define LED_left          24
#define LED_head	  24
#define LED_right         24// 16//22
#define LED_tail          24 // 17 //23

#define	RGB_RED 	24 //	8
#define RGB_GREEN 	24 //	7
#define RGB_BLUE 	24 //	6
#define Switch 		24 //	5

//jason board
 #define	IRM_head		16	//IRM receive head   R4
 #define	IRM_tail		27	//IRM receive tail   R3
 #define	IRM_left		18	//IRM receive left   R2
 #define	IRM_right		26	//IRM receive right  R6




//new board
//#define	IRM_right						21					//IRM receive right
//#define	IRM_tail						19					//IRM receive tail
//#define	IRM_left						16					//IRM receive left
//#define	IRM_head						2					//IRM receive head

//#define	IRM_down						3					//IRM receive pointed down
//#define	IRM_forward						1					//IRM receive forward

//  --- rx-tx for dev board
//#define RX_PIN_NUMBER  16//16    // UART RX pin number.
//#define TX_PIN_NUMBER  17//8//6//17    // UART TX pin number.
//------------------------------------

// --- rx-tx for SwitchBot ---- dev board
//#define RX_PIN_NUMBER   16 // UART RX pin number.
//#define TX_PIN_NUMBER   17 // UART TX pin number.

// --- rx-tx for SwitchBot ---- real board
#define RX_PIN_NUMBER   22 // UART RX pin number.
#define TX_PIN_NUMBER   23 // UART TX pin number.
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

// motors settings
#define PWMA          10     // left motor pwm
#define AIN1          8      // direction pins AIN1-AIN2 --> 1-0 forward, 0-1 backward
#define AIN2          9
#define PWMB          5     // right motor pwm
#define BIN1          7
#define BIN2          6
#define STDBY         13



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

// SwitchBot protocol commands
#define NOTF_GET_STATUS        0x51
#define NOTF_SET_STATUS        0x52
#define NOTF_ACTIVATE_ADB      0x53
#define STAND_UP               0x61
#define KNEEL                  0x62
#define LEAN                   0x63
#define ESTOP                  0x65
#define CLEAR_ESTOP            0x66
#define DRIVE                  0x78

#define	 DP_GOTO_BEACON        0x40
#define  DP_STOP               0x41
#define  NOTF_GET_NEXT_BEACON  0x42



#define   BUTTON_1  24                           /**< Button used for deleting all bonded centrals during startup. */
#define   LED_2     24
#define   LED_0     24                                     /**< Is on when device is scanning. */
#define   LED_1     24                                     /**< Is on when device has connected. */
#define   LED_7     24
#define   MCLR      25
#endif  // REV
