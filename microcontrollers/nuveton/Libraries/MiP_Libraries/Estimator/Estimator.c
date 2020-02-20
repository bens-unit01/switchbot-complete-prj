/*---------------------------------------------------------------------------------------------------------*/
/*                          Program Written By: SAAM OSTOVARI and Nick Morozovsky                          */
/*																			NDA SD2013-802																				     			   */
/*---------------------------------------------------------------------------------------------------------*/

//Including Nuvoton Libraries
#include <stdio.h>
#include <stdint.h>
#include "M051.h"
#include "Register_Bit.h"
#include "Common.h"
#include "Retarget.h"
//Including MiP Libraries
#include "Estimator.h"
#include "..\IMU\IMU.h"
#include "..\UART\UART.h"
#include "..\Encoders\Encoders.h"
#include "..\System_Clock\System_Clock.h"
#include "..\Robot_Values\Robot_Values.h"

// Declaring Variables for Filter and Estimator
//float SensorData[5] = {0,0,0,0,0};
float accLP;
float gyroIntHP = 0;
float theta;
float thetad;
float phi;
float phid;
//float Encoder;
//float Encoderd ;
//float Encoderd = 0;
//float EncoderOld[3] = {0,0,0};
//float beforeSPI = 0;
//float afterSPI = 0;

/////////////////////////////////////////////////////////////////////////////////////////////////////////

//Initialize Estimator
void Initialize_Estimator(void){
  accLP = get_acc_theta();
  thetad = get_gyro_thetad();
  theta = accLP;
} 

/////////////////////////////////////////////////////////////////////////////////////////////////////////

//Complementary filter used to translate sensor data into data for controllers and balancing
	void Complementary_Filter(void)
	{
		//beforeSPI = get_encoderRcount();//millis();
		 //Reading Accel and Gyro measurements
		IMU_Update2();																											//Update IMU Data
		//afterSPI = get_encoderRcount();//millis();
		//printf("%f\t", afterSPI-beforeSPI);

		//Filtering Accel Data. get_acc_theta comes from IMU.c, ALPC from Robot_Values.h
		accLP = accLP + ALPC*(get_acc_theta() - accLP);
		
		//Filtering Gyro Data. get_gyro_thetad comes from IMU.c, GHPC from Robot_Values.h
		thetad = get_gyro_thetad();
		gyroIntHP = GHPC*(gyroIntHP + dt*thetad);
		
		//Combining Filtered Data
		theta = accLP + gyroIntHP;
	}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
	
//Encoder filter used to translate sensor data into data for controllers and balancing
/*void Encoder_Filter(void)
{
	//Setting up values from previous timestep/initial condtions
	EncoderOld[0]= SensorData[2]; EncoderOld[1]= SensorData[3]; EncoderOld[2]= SensorData[4];
	//Getting encoder value gathered by external interrupts. Encoder_Update comes from encoder.c
	Encoder = Encoder_Update();
	//Weighted moving average for encoder velocity
	Encoderd =( 4*(Encoder-EncoderOld[0])/dt + 2*(Encoder-EncoderOld[1])/(2*dt) + (Encoder-EncoderOld[2])/(3*dt) ) / (7); //using the average of the left and right encoder values in the estimator
	//Calculating phi using Encoders and calculated theta/thetad
	phi = Encoder + theta;
	phid = Encoderd + thetad;
	//Saving Data for Use in Next Timestep
	SensorData[2] = Encoder; SensorData[3] = EncoderOld[0]; SensorData[4] = EncoderOld[1];
}*/

/////////////////////////////////////////////////////////////////////////////////////////////////////////

	//Function to get updated vehicle state estimation for use in controller
/*void Estimator(void)
{
	Complementary_Filter();
	Encoder_Filter();
}	*/
	
/////////////////////////////////////////////////////////////////////////////////////////////////////////

	//Functions to get variables used in other functions
float get_theta(){return theta;}
float get_thetad(){return thetad;}
//float get_phi(){return phi;}
//float get_phid(){return phid;}
//float get_Encoderd(){return Encoderd;}

/////////////////////////////////////////////////////////////////////////////////////////////////////////

// Reset Estimator values for Safeties
/*void reset_Estimator()
{
  phi=0;
}*/

/////////////////////////////////////////////////////////////////////////////////////////////////////////

//Function to Print Out Debugging Info for Estimator
/*void Outputs4Debugging_Estimator(void)
{
	printf("%f\t", accLP);
	printf("%f\t", thetad);
	printf("%f\t", gyroIntHP);
	printf("%f\t", theta);
	printf("%f\t", thetad * Rad2PI);
	printf("%f\t", phi * Rad2PI);
	printf("%f\t", phid * Rad2PI);
	printf("%f\t", Encoderd);
}*/
