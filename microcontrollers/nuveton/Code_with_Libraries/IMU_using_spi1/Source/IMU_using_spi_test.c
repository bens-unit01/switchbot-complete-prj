/*---------------------------------------------------------------------------------------------------------*/
/*                          Program Written By: SAAM OSTOVARI                                              */
/*																			NDA SD2013-802																				     			   */
/*---------------------------------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------------------------------*/
/* 											 Example on how to read MPU-6880 IMU through SPI																	 */
/*---------------------------------------------------------------------------------------------------------*/

//Including Nuvoton Libraries
#include <stdio.h>
#include <stdint.h>
#include <math.h>
#include "M051.h"
#include "Register_Bit.h"
#include "Common.h"
#include "Retarget.h"
#include "Macro_SystemClock.h"
#include "Macro_Timer.h"
//Including MiP Libraries 
#include "System_Clock\System_Clock.h"
#include "UART\UART.h"
#include "SPI\SPI.h"
#include "IMU\IMU.h"

// ***IMU Addresses for Accelerometer and Gyro Axises***
#define AccelX_low 				0xBC00					//AccelX Low Bit Address
#define AccelX_high  			0xBB00					//AccelX High Bit Address
#define AccelY_low				0xBE00					//AccelY Low Bit Address
#define AccelY_high				0xBD00					//AccelY High Bit Address
#define AccelZ_low				0xC000					//AccelZ Low Bit Address
#define AccelZ_high				0xBF00					//AccelZ High Bit Address
#define GyroX_low		    	0xC400					//GyroX Low Bit Address
#define GyroX_high				0xC300					//GyroX High Bit Address
#define GyroY_low					0xC600					//GyroY Low Bit Address
#define GyroY_high				0xC500					//GyroY High Bit Address
#define GyroZ_low					0xC800					//GyroZ Low Bit Address
#define GyroZ_high				0xC700					//GyroZ High Bit Address
#define Gyro							1
#define Accel							0

main(void)
{   
	Init_System_Clocks_PLL();				//Initialize System Clocks
	Init_Uart0(115200);					//Initialize UART0
	Init_Digital_IMU();							//Initialize and Calibrate IMU
	
	printf("Setup and Configuration Complete! Begin Readings\n");

  while(1)
  {
  //Reads raw data from IMU. 
	float xAccel = SPI_Sensor_Read(AccelX_low, AccelX_high, Accel);   //Read AccelX Values (units: g)
	float yAccel = SPI_Sensor_Read(AccelY_low, AccelY_high, Accel);   //Read AccelY Values (units: g)
	float zAccel = SPI_Sensor_Read(AccelZ_low, AccelZ_high, Accel);   //Read AccelZ Values (units: g)
	float xGyro = SPI_Sensor_Read(GyroX_low, GyroX_high, Gyro);     //Read GyroX Values (units degrees per sec)
	float yGyro = SPI_Sensor_Read(GyroY_low, GyroY_high, Gyro);     //Read GyroY Values (units degrees per sec)
	float zGyro = SPI_Sensor_Read(GyroZ_low, GyroZ_high, Gyro);     //Read GyroZ Values (units degrees per sec)
	
	//Outputing Raw Data from IMU
	printf("%f\t%f\t%f\t%f\t%f\t%f\t\n",xAccel,yAccel,zAccel,xGyro,yGyro,zGyro);
  //printf("%f\t%f\t%f\t\n",xAccel,yAccel,xGyro);
	
	}
}
