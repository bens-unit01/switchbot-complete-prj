/*---------------------------------------------------------------------------------------------------------*/
/*                          Program Written By: SAAM OSTOVARI                                              */
/*																			NDA SD2013-802																				     			   */
/*---------------------------------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------------------------------*/
/*									  Test code on using all fucntions needed for balancing a robot												 */
/*								       Code specifically wriite for the Switchbot Carrier Boad	    										 */
/*---------------------------------------------------------------------------------------------------------*/

//Including Nuvoton Libraries
#include <stdio.h>
#include <stdint.h>
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
#include "Timers\Timers.h"
#include "GPIO\GPIO.h"
#include "PWM\PWM.h"
#include "ADC\ADC.h"
#include "Encoders\Encoders.h"
#include "Motor_Drive\Motor_Drive.h"
#include "Estimator\Estimator.h"
#include "Controller\Controller.h"
#include "Robot_Values\Robot_Values.h"

//Declaring General Variables
static int loop = 0; 
static uint32_t Timer_Count = 0;
static uint32_t Timer_Count1 = 0;

//Declaring ADC Variables
int an0 =9999;
int an1 =9999;
int an5 =9999;
int an6 =9999;
int LED = 1;

/////////////////////////////////////////////////////////////////////////////////////////////////////////                                                                                      
/////////////////////////////////////////////////////////////////////////////////////////////////////////

void main(void)
{   
	Init_System_Clocks_PLL();				//Initialize System Clocks
	Init_Uart0(115200);							//Initialize UART0 and set to baud rate of 115200
  Init_Digital_IMU();							//Initialize and Calibrate IMU
	Init_GPIO_Output(3,6);					//Initialize GPIO as output out on (Port,Pin)
	Init_Motors();									//Initialize all Motors with PWM and Direction GPIO pins on Switchbot Carrier Board
	Init_Encoders();								//Initialize Encoders which Initializes External Interrupts
  Init_ADC(0);										//Enabling ADC in continousmode on pin.  Init_ADC(pin)
	Init_ADC(1);										//Enabling ADC in continousmode on pin.  Init_ADC(pin)
	Init_ADC(5);										//Enabling ADC in continousmode on pin.  Init_ADC(pin)
	Init_ADC(6);										//Enabling ADC in continousmode on pin.  Init_ADC(pin)
	Initialize_Estimator();					//Initialize Estimator
	Init_Timer2_ISR();    					//Initalize Timer 2 ISR. ISR can be located in Timer.c library file or in this main file. Currently set to 10ms
	
	printf("Setup and Configuration Complete! Begin Readings\n\n");

  while(1)
  {
	  ////Uncomment to make sure microcontroller is actually running and that UART is working	
		//Timer_Count1 ++;
		//printf("%d\n",Timer_Count1);
   }
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////                                                                                      

////Timer2 ISR routine (10ms)
void TMR2_IRQHandler(void)
{
	TISR2 |= TMR_TIF; 																		//Clear timer2 interrupt flag
	
	Estimator();
	SLC_Control();	
	Drive_Motor_by_U(1,get_u());
	Drive_Motor_by_U(2,get_u());

	////Function calls that output data through UART for Debugging////
	Outputs4Debugging_IMU();
	//Outputs4Debugging_Estimator();
	//Outputs4Debugging_Encoders();
	//Outputs4Debugging_ADC();
	
	//Checks to see that timer interrupt is working.
	digitalWrite(3,6,~LED); 			//Setting GPIO Output to High (1) or Low (0) on (Port, Pin , Output). Will flash LED on board
	Timer_Count++;																							
	printf("ISR2 Loop Count: %d\n",Timer_Count);
	Timer_Count1 =0;
}
