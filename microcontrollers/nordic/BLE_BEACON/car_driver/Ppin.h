//=======================================================================
//.T		包含文件.
//=======================================================================
#include <stdbool.h>
#include <stdint.h>
//-----------------------
#ifndef		__JC_PUBLIC_GPIO_H__
#define		__JC_PUBLIC_GPIO_H__
//=======================================================================
//.T0		通用IO口声明.
//=======================================================================
#define		test_LED						19			//testing led define P0.19.
//-----------------------RGB led pin.
#define		RGB_red							21			//RGB red   led define P0.21.
#define		RGB_green						22			//RGB green led define P0.22.
#define		RGB_blue						23			//RGB blue  led define P0.23.
//-----------------------IR RX pin.
#define		IRM_head						26			//IRM receive head  data pin define P0.26.
#define		IRM_tail						25			//IRM receive tail  data pin define P0.25.
#define		IRM_rec_Vctl				00			//IRM receive right data pin define P0.00.
//-----------------------I2C cmd pin.
#define		ble_Vctl						24			//ble Vctl for DAC power define P0.24.
#define		ble_GPC2_ctl				10			//ble GPC iic data pin define P0.08.
#define		ble_GPC_data				9				//ble GPC iic data pin define P0.09.
//-----------------------IR TX ctrl pin.
#define		IR_left							11			//IR plane send pin define P0.11.
#define		IR_right						12			//IR plane send pin define P0.12.
#define		IR_back							13			//IR plane send pin define P0.13.
#define		IR_head							14			//IR plane send pin define P0.14.
#define		IR_gun							15			//IR plane send pin define P0.18.
//=======================================================================
//.T1		常数声明.
//=======================================================================
//-----------------------事件通道.
#define		GPIOTE_ch0					0
#define		GPIOTE_ch1					1
#define		GPIOTE_ch2					2
#define		GPIOTE_ch3					3
//-----------------------PPI通道.
#define		PPI_ch0							0
#define		PPI_ch1							1
#define		PPI_ch2							2
#define		PPI_ch3							3
#define		PPI_ch4							4
#define		PPI_ch5							5
#define		PPI_ch6							6
#define		PPI_ch7							7
//-----------------------color define.
#define		clr_Black						0				//黑.
#define		clr_Red							1				//红.
#define		clr_Green						2				//绿.
#define		clr_Yollow					    3				//黄.
#define		clr_Blue						4				//蓝.
#define		clr_Magenta					    5				//品红.
#define		clr_Cyan						6				//青.
#define		clr_White						7				//白.
#define		clr_NULL						0xff		//空闲.
//-----------------------角度距离计算.//Period Test Range.
#define		PER_MIN							401*0.9
#define		PER_MID							401
#define		PER_MAX							401*1.1
#define		overflow_MAX				1200
//-----------------------打枪码检测.
#define		GUN_MIN							53			//56*0.95
#define		GUN_MID							56			//56*1.05
#define		GUN_MAX							58			//56*1.05

//--------------------- IR control
#define IR_CTRL                  0x20
#define IR_GUN_ON                0x01
#define IR_BACK_ON               0x02
#define IR_HEAD_ON              0x03
#define IR_ALL_ON                0x04
#define IR_ALL_OFF               0x05
//=======================================================================
#endif	//__JC_PUBLIC_GPIO_H__.

//********************************* end *********************************//
