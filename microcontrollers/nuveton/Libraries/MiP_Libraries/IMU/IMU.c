/*---------------------------------------------------------------------------------------------------------*/
/*                          Program Written By: SAAM OSTOVARI and Nick Morozovsky                          */
/*																			NDA SD2013-802																				     			   */
/*---------------------------------------------------------------------------------------------------------*/


//Including Nuvoton Libraries
#include <stdio.h>
#include <stdint.h>
#include <math.h>
#include "M051.h"
#include "Register_Bit.h"
#include "Common.h"
#include "Retarget.h"
//Including MiP Libraries
#include "IMU.h"
#include "..\SPI\SPI.h"
#include "..\Robot_Values\Robot_Values.h"


// Declaring Variables for Accel
float Accel1,Accel2;   
long Accel1L;
long Accel2L;

// Declaring Variables for Gyro
long Gyro1L;
long Gyro1 = 0;           
float GyroOffset;                          //This is to make the vertical zero degrees. Will calibrate in setup()
float acc_theta;
float gyro_thetad;


/////////////////////////////////////////////////////////////////////////////////////////////////////////

//Function to Configure the MPU-6880 IMU. This is the IMU in MiP
	void ConfigureMIPIMU(void)
{
	//#define	USER_CTRL         
	SPI_WriteAndWait(0x6A10);  		// Write the config data to the IMU. Serial interface in SPI mode only
	//#define	SMPLRT_DIV. Setting the sample rate.  
	SPI_WriteAndWait(0x1907);  		 
  //#define	CONFIG 
	SPI_WriteAndWait(0x1A00);
  //#define	GYRO_CONFIG. Gyro set to read at ±1000dps (16bit) 32.8LSB/(dps)  	    
	SPI_WriteAndWait(0x1B10); 
  //#define	ACCEL_CONFIG. Accel set to ±2g  16,384LSB/(g) 
	SPI_WriteAndWait(0x1C00);
  //#define	ACCEL_CONFIG_2. Setting up lowpass filter
	SPI_WriteAndWait(0x1D0C);  
  //#define	LP_ACCEL_ODR. setting up low power option on accel. Don't believe this effects anything for us      
	SPI_WriteAndWait(0x1E00); 
  //#define	WOM_THR. Wake-on Motion Threshold.            
    SPI_WriteAndWait(0x1F00);  
  //#define	FIFO_EN. All First in First out (FIFO) outputs are disabled
	SPI_WriteAndWait(0x2300); 
	//#define	INT_ENABLE. All interrupts are disabled
	SPI_WriteAndWait(0x3800);
	//#define	PWR_MGMT_1. Setting up clock 
	SPI_WriteAndWait(0x6B01);  
  //#define	PWR_MGMT_2. All sensors are on.
	SPI_WriteAndWait(0x6C00);
	
	SPI_WriteAndWait(0xC100);
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////                                                                                      

//Initial IMU 
/*void Init_Digital_IMU()
{
  float Accel1Pin, Accel2Pin;
  float Gyro1Pin;
  float Accel1Count = 0;
  float Accel2Count = 0;              
  float Gyro1Count = 0;
  int x;
	int numMeas = 20;
	
	Init_SPI();											//Initalize SPI
	ConfigureMIPIMU();
	
	//put into it's own configure function. EEPROM?
//////////////////////////////////////////////////
 // Initialize sensors. Note: Accel Data comes as Radians and Gyro Data comes as degrees/s 
  for(x = 0; x < numMeas; x++){ 
		Accel1Pin = SPI_Sensor_Read(Accel1_low, Accel1_high, Accel);   //Read Accel1 Values (units: g)
		Accel2Pin = SPI_Sensor_Read(Accel2_low, Accel2_high, Accel);   //Read Accel2 Values (units: g)
		Gyro1Pin = SPI_Sensor_Read(Gyro1_low, Gyro1_high, Gyro);     //Read Gyro1 Values (units degrees per sec)
		//printf("%f\n",Gyro1Pin);
    Accel1Count = Accel1Count + Accel1Dir*(Accel1Pin);
    Accel2Count = Accel2Count + Accel2Dir*(Accel2Pin);
    Gyro1Count = Gyro1Count + Gyro1Dir*(Gyro1Pin);
  } 
	
  Accel1 = Accel1Count/((float) numMeas);
  Accel2 = Accel2Count/((float) numMeas);
  Gyro1 = Gyro1Count/((float) numMeas); 
  GyroOffset = -(Gyro1);  
	//printf("%f\n", Gyro1);
  acc_theta = atan2(Accel1,Accel2) + AccelOffset ;
  gyro_thetad = (Gyro1 + GyroOffset) * PI/180;  //we are trusting gyro for accurate thetadot value
}*/

//Initialize IMU 
void Init_Digital_IMU2()
{
	Init_SPI();											//Initalize SPI
	ConfigureMIPIMU();
	IMU_Update2();
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////                                                                                      
//Get New Data From IMU
/*void IMU_Update(void){

   Accel1 = Accel1Dir *( SPI_Sensor_Read(Accel1_low, Accel1_high, Accel) );		//Read Accel1 Values (units: g)
   Accel2 = Accel2Dir *( SPI_Sensor_Read(Accel2_low, Accel2_high, Accel) );		//Read Accel2 Values (units: g)
   Gyro1 = Gyro1Dir *( SPI_Sensor_Read(Gyro1_low, Gyro1_high, Gyro) );				//Read Gyro1 Values (units degrees per sec)
	
   acc_theta = atan2(Accel1,Accel2) + AccelOffset ;
   gyro_thetad = (Gyro1 + GyroOffset) * PI/180;  //we are trusting gyro for accurate thetadot value
}*/


/////////////////////////////////////////////////////////////////////////////////////////////////////////                                                                                      
//Get New Data From IMU
void IMU_Update2(void){

  Accel1L = Accel1Dir *( SPI_Sensor_Read_Int(Accel1_low, Accel1_high) );		//Read Accel1 Values unscaled
  Accel2L = Accel2Dir *( SPI_Sensor_Read_Int(Accel2_low, Accel2_high) );		//Read Accel2 Values unscaled
  Gyro1L =  (SPI_Sensor_Read_Int(Gyro1_low, Gyro1_high));				//Read Gyro1 Values unscaled
	
	// only update gyro if neither high nor low byte is 0
	if ( ( ( (Gyro1L>>8) & 0x00FF ) ^ (Gyro1L & 0x00FF) ) < 254 )
		gyro_thetad = ((float)Gyro1L) * GYRO2RADS;	 // NEED GYRO OFFSET?
	
	//printf("%f\t", ((float)Gyro1L) * GYRO2RADS);
	//printf("%f\n", gyro_thetad);
	
   acc_theta = atan2( ((double)Accel1L), ((double)Accel2L) ) + AccelOffset ;
	
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////                                                                                      

//Functions to Get Variable to Other Functions
float get_acc_theta(void){
  return acc_theta;
}
float get_gyro_thetad(void){
  return gyro_thetad;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////

//Functions to print out Debugging info for IMU
/*void Outputs4Debugging_IMU(void)
{
	//printf("%f\t", Accel1);
	//printf("%f\t", Accel2);
	//printf("%d\t", Gyro1L);
	printf("%f\t", acc_theta);
	printf("%f\t", gyro_thetad);
	//printf("%f\t", get_acc_theta() * Rad2PI );						//Get Theta value, converts to degrees and prints out
  //printf("%f\t", get_gyro_thetad() * Rad2PI );					//Get Thetad value,  converts to degrees and prints out
	//printf("%f\t", Gyro1);
}*/
