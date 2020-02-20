/*---------------------------------------------------------------------------------------------------------*/
/*                   Program Written By: SAAM OSTOVARI and NICK MOROZOVSKY                 				         */
/*																			NDA SD2013-802																										 */
/*---------------------------------------------------------------------------------------------------------*/

//Including Nuvoton Libraries
#include <stdio.h>
#include <stdint.h>
#include "M051.h"
#include "Register_Bit.h"
#include "Common.h"
#include "Retarget.h"
//Including MiP Libraries
#include "Motor_Drive.h"
#include "..\GPIO\GPIO.h"
#include "..\PWM\PWM.h"
#include "..\Robot_Values\Robot_Values.h"

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//Function to Initialize All PWM and GPIO Pins for Motors Being Used
void Init_Motors(void)
{
	//Initializing Motor #1
	Init_PWM(0);																//Initialize PWM pins.  Init_PWM( pin )
	Init_GPIO_Output(1,4);											//Initialize GPIO as output out on (Port,Pin)

	//Initializing Motor #2
	Init_PWM(1);																//Initialize PWM pins.  Init_PWM( pin )
	Init_GPIO_Output(3,2);											//Initialize GPIO as output out on (Port,Pin)

	//Initializing Motor #3
	Init_PWM(2);																//Initialize PWM pins.  Init_PWM( pin )
	Init_GPIO_Output(3,3);											//Initialize GPIO as output out on (Port,Pin)
	Init_GPIO_Output(4,3);											//Initialize GPIO as output out on (Port,Pin)

	//Initializing Motor 4
	Init_PWM(3);																//Initialize PWM pins.  Init_PWM( pin )
	Init_GPIO_Output(0,3);											//Initialize GPIO as output out on (Port,Pin)
	Init_GPIO_Output(0,2);											//Initialize GPIO as output out on (Port,Pin)

	//Initializing Motor #5
	Init_PWM(4);																//Initialize PWM pins.  Init_PWM( pin )
	Init_GPIO_Output(3,7);											//Initialize GPIO as output out on (Port,Pin)
	Init_GPIO_Output(1,7);											//Initialize GPIO as output out on (Port,Pin)

  //Initializing Motor #6
	Init_PWM(5);																//Initialize PWM pins.  Init_PWM( pin )
	Init_GPIO_Output(2,6);											//Initialize GPIO as output out on (Port,Pin)
	Init_GPIO_Output(2,7);											//Initialize GPIO as output out on (Port,Pin)

	// Initialize standby/enable pins
	Init_GPIO_Output(4,0);											//Initialize GPIO as output out on (Port,Pin)
	Init_GPIO_Output(4,1);											//Initialize GPIO as output out on (Port,Pin)
	Init_GPIO_Output(4,2);											//Initialize GPIO as output out on (Port,Pin)
	
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////

//Function to Enable Motors that have Standby Pins
void motorEnable(void) // enable motor drivers
{
	digitalWrite(4,0,1); // enable tread motors
	digitalWrite(4,1,1); // enable right hip/knee motors
	digitalWrite(4,2,1); // enable left hip/knee motors
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////

//Function to Disable Motors that have Standby Pins
void motorESTOP(void) // disable motor drivers
{
	digitalWrite(4,0,0); // disable tread motors
	digitalWrite(4,1,0); // disable right hip/knee motors
	digitalWrite(4,2,0); // disable left hip/knee motors
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////

//Function to write to specific PWM pin and change that specific PWM pins Duty Cycle. PWM Duty Cycle Range: 0 - 552
void Drive_Motor(int Motor_Number,int Duty_Cycle,signed int Spin_dir)
{
	int Spin_dir1 = 0;
	if( Spin_dir == -1){
		Spin_dir = 0; 
		Spin_dir1 = 1;
	}
	
	switch (Motor_Number)
		{
			case 1:		
			{	
				PWM_Write(0,Duty_Cycle);								//Setting PWM Duty Cycle. PWM_Write( pin , duty cycle ).  Note: 100% duty cycle is 552	
				digitalWrite(1,4,Spin_dir);							//Setting GPIO Output to High (1) or Low (0) on (Port, Pin , Output)
			}
			case 2:		
			{	
				PWM_Write(1,Duty_Cycle);								//Setting PWM Duty Cycle. PWM_Write( pin , duty cycle ).  Note: 100% duty cycle is 552	
				digitalWrite(3,2,Spin_dir);							//Setting GPIO Output to High (1) or Low (0) on (Port, Pin , Output)
			}
			case 3:		
			{	
				PWM_Write(2,Duty_Cycle);								//Setting PWM Duty Cycle. PWM_Write( pin , duty cycle ).  Note: 100% duty cycle is 552	
				digitalWrite(3,3,Spin_dir);							//Setting GPIO Output to High (1) or Low (0) on (Port, Pin , Output)
				digitalWrite(4,3,Spin_dir1);						//Setting GPIO Output to High (1) or Low (0) on (Port, Pin , Output)
			}
			case 4:		
			{	
				PWM_Write(3,Duty_Cycle);								//Setting PWM Duty Cycle. PWM_Write( pin , duty cycle ).  Note: 100% duty cycle is 552	
				digitalWrite(0,3,Spin_dir);							//Setting GPIO Output to High (1) or Low (0) on (Port, Pin , Output)
				digitalWrite(0,2,Spin_dir1);						//Setting GPIO Output to High (1) or Low (0) on (Port, Pin , Output)
			}
			case 5:		
			{	
				PWM_Write(4,Duty_Cycle);								//Setting PWM Duty Cycle. PWM_Write( pin , duty cycle ).  Note: 100% duty cycle is 552	
				digitalWrite(3,7,Spin_dir);							//Setting GPIO Output to High (1) or Low (0) on (Port, Pin , Output)
				digitalWrite(1,7,Spin_dir1);						//Setting GPIO Output to High (1) or Low (0) on (Port, Pin , Output)
			}
			case 6:		
			{	
				PWM_Write(5,Duty_Cycle);								//Setting PWM Duty Cycle. PWM_Write( pin , duty cycle ).  Note: 100% duty cycle is 552	
				digitalWrite(2,6,Spin_dir);							//Setting GPIO Output to High (1) or Low (0) on (Port, Pin , Output)
				digitalWrite(2,7,Spin_dir1);						//Setting GPIO Output to High (1) or Low (0) on (Port, Pin , Output)			
			}
		}		
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////

//Function to write to specific PWM pin and change that specific PWM pins Duty Cycle. u = # between -1 and 1. PWM Duty Cycle Range: 0 - 552
void Drive_Motor_by_U(int Motor_Number,float u)
{
	int Spin_dir = 1;
	int Spin_dir1 = 0;
	if (u<=0){
		Spin_dir = 0;
		Spin_dir1 = 1;
	}
	
	switch (Motor_Number)
		{
			case 1:		
			{	
				PWM_Write(0,u*MaxPWM);								//Setting PWM Duty Cycle. PWM_Write( pin , duty cycle ).  Note: 100% duty cycle is 552	
				digitalWrite(1,4,Spin_dir);						//Setting GPIO Output to High (1) or Low (0) on (Port, Pin , Output)
			}
			case 2:		
			{	
				PWM_Write(1,u*MaxPWM);								//Setting PWM Duty Cycle. PWM_Write( pin , duty cycle ).  Note: 100% duty cycle is 552	
				digitalWrite(3,2,Spin_dir);						//Setting GPIO Output to High (1) or Low (0) on (Port, Pin , Output)
			}
			case 3:		
			{	
				PWM_Write(2,u*MaxPWM);								//Setting PWM Duty Cycle. PWM_Write( pin , duty cycle ).  Note: 100% duty cycle is 552	
				digitalWrite(3,3,Spin_dir);						//Setting GPIO Output to High (1) or Low (0) on (Port, Pin , Output)
				digitalWrite(4,3,Spin_dir1);					//Setting GPIO Output to High (1) or Low (0) on (Port, Pin , Output)
			}
			case 4:		
			{	
				PWM_Write(3,u*MaxPWM);								//Setting PWM Duty Cycle. PWM_Write( pin , duty cycle ).  Note: 100% duty cycle is 552	
				digitalWrite(0,3,Spin_dir);						//Setting GPIO Output to High (1) or Low (0) on (Port, Pin , Output)
				digitalWrite(0,2,Spin_dir1);					//Setting GPIO Output to High (1) or Low (0) on (Port, Pin , Output)
			}
			case 5:		
			{	
				PWM_Write(4,u*MaxPWM);								//Setting PWM Duty Cycle. PWM_Write( pin , duty cycle ).  Note: 100% duty cycle is 552	
				digitalWrite(3,7,Spin_dir);						//Setting GPIO Output to High (1) or Low (0) on (Port, Pin , Output)
				digitalWrite(1,7,Spin_dir1);					//Setting GPIO Output to High (1) or Low (0) on (Port, Pin , Output)
			}
			case 6:		
			{	
				PWM_Write(5,u*MaxPWM);								//Setting PWM Duty Cycle. PWM_Write( pin , duty cycle ).  Note: 100% duty cycle is 552	
				digitalWrite(2,6,Spin_dir);						//Setting GPIO Output to High (1) or Low (0) on (Port, Pin , Output)
				digitalWrite(2,7,Spin_dir1);					//Setting GPIO Output to High (1) or Low (0) on (Port, Pin , Output)			
			}
		}		
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////

//Function to Drive 6 motors with one u array
void driveMotors(float u[])
{
	//Right Tread Motor
	if (u[0] > 0){
		PWM_Write(0,(int)(MaxPWM*(1-u[0])));			//Setting PWM Duty Cycle. PWM_Write( pin , duty cycle ).
		digitalWrite(1,4,1);											//Setting GPIO Output to High (1) or Low (0) on (Port, Pin , Output)
	} 
	else{
		PWM_Write(0,(int)(MaxPWM*(-u[0])));					//Setting PWM Duty Cycle. PWM_Write( pin , duty cycle ).
		digitalWrite(1,4,0);											//Setting GPIO Output to High (1) or Low (0) on (Port, Pin , Output)
	}
	
	//Left Tread Motor
	if (u[1] < 0){
		PWM_Write(1,(int)(MaxPWM*(1+u[1])));			//Setting PWM Duty Cycle. PWM_Write( pin , duty cycle ).
		digitalWrite(3,2,1);											//Setting GPIO Output to High (1) or Low (0) on (Port, Pin , Output)
	} 
	else{
		PWM_Write(1,(int)(MaxPWM*u[1]));					//Setting PWM Duty Cycle. PWM_Write( pin , duty cycle ).
		digitalWrite(3,2,0);											//Setting GPIO Output to High (1) or Low (0) on (Port, Pin , Output)
	}

	//Right Knee Motor
	if (u[2] < 0){
		PWM_Write(2,(int)(-MaxPWM*u[2]));					//Setting PWM Duty Cycle. PWM_Write( pin , duty cycle ).
		digitalWrite(4,3,1);											//Setting GPIO Output to High (1) or Low (0) on (Port, Pin , Output)
		digitalWrite(3,3,0);											//Setting GPIO Output to High (1) or Low (0) on (Port, Pin , Output)
	} 
	else{
		PWM_Write(2,(int)(MaxPWM*u[2]));					//Setting PWM Duty Cycle. PWM_Write( pin , duty cycle ).
		digitalWrite(4,3,0);											//Setting GPIO Output to High (1) or Low (0) on (Port, Pin , Output)
		digitalWrite(3,3,1);											//Setting GPIO Output to High (1) or Low (0) on (Port, Pin , Output)
	}
	
	//Left Knee Motor
	if (u[3] < 0){
		PWM_Write(4,(int)(-MaxPWM*u[3]));					//Setting PWM Duty Cycle. PWM_Write( pin , duty cycle ).
		digitalWrite(1,7,1);											//Setting GPIO Output to High (1) or Low (0) on (Port, Pin , Output)
		digitalWrite(3,7,0);											//Setting GPIO Output to High (1) or Low (0) on (Port, Pin , Output)
	} 
	else {
		PWM_Write(4,(int)(MaxPWM*u[3]));					//Setting PWM Duty Cycle. PWM_Write( pin , duty cycle ).
		digitalWrite(1,7,0);											//Setting GPIO Output to High (1) or Low (0) on (Port, Pin , Output)
		digitalWrite(3,7,1);											//Setting GPIO Output to High (1) or Low (0) on (Port, Pin , Output)
	}
	//Right Hip Motor
	if (u[4] < 0){
		PWM_Write(3,(int)(-MaxPWM*u[4]));					//Setting PWM Duty Cycle. PWM_Write( pin , duty cycle ).	
		digitalWrite(0,2,0);											//Setting GPIO Output to High (1) or Low (0) on (Port, Pin , Output)
		digitalWrite(0,3,1);											//Setting GPIO Output to High (1) or Low (0) on (Port, Pin , Output)
	} 
	else{
		PWM_Write(3,(int)(MaxPWM*u[4]));					//Setting PWM Duty Cycle. PWM_Write( pin , duty cycle ).	
		digitalWrite(0,2,1);											//Setting GPIO Output to High (1) or Low (0) on (Port, Pin , Output)
		digitalWrite(0,3,0);											//Setting GPIO Output to High (1) or Low (0) on (Port, Pin , Output)
	}
	
	//Left Hip Motor
	if (u[5] < 0){
		PWM_Write(5,(int)(-MaxPWM*u[5]));					//Setting PWM Duty Cycle. PWM_Write( pin , duty cycle ).
		digitalWrite(2,7,0);											//Setting GPIO Output to High (1) or Low (0) on (Port, Pin , Output)
		digitalWrite(2,6,1);											//Setting GPIO Output to High (1) or Low (0) on (Port, Pin , Output)
	} 
	else{
		PWM_Write(5,(int)(MaxPWM*u[5]));					//Setting PWM Duty Cycle. PWM_Write( pin , duty cycle ).
		digitalWrite(2,7,1);											//Setting GPIO Output to High (1) or Low (0) on (Port, Pin , Output)
		digitalWrite(2,6,0);											//Setting GPIO Output to High (1) or Low (0) on (Port, Pin , Output)
	}
}
