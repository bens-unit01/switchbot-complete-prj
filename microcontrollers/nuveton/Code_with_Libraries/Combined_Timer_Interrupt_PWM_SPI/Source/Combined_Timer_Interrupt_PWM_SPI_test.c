/*---------------------------------------------------------------------------------------------------------*/
/*                          Program Written By: SAAM OSTOVARI                                              */
/*																			NDA SD2013-802																				     			   */
/*---------------------------------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------------------------------*/
/*									  Test code on using Timer Interrupt, PWM and SPI/IMU   															 */
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
#include "IMU\IMU.h"
#include "SPI\SPI.h"
#include "Timers\Timers.h"
#include "GPIO\GPIO.h"
#include "PWM\PWM.h"

//Declaring General Variables
static int loop = 0; 
static uint32_t Timer_Count = 0;
static uint32_t Timer_Count1 = 0;

/////////////////////////////////////////////////////////////////////////////////////////////////////////                                                                                      
/////////////////////////////////////////////////////////////////////////////////////////////////////////

main(void)
{   
	Init_System_Clocks_PLL();				//Initialize System Clocks
	Init_Uart0(115200);							//Initialize UART0
	Init_SPI();											//Initalize SPI
  Init_Digital_IMU();							//Initialize and calibrate IMU
	Init_GPIO_Output(3,6);					//Initialize GPIO as output out on (Port,Pin)
	Init_Timer2_ISR();    					//Initalize Timer 2 ISR. ISR Located in Timer.c file. Currently set to 10ms
  Init_PWM(0);										//Initialize PWM pins.  Init_PWM( pin )
	Init_PWM(1);										//Initialize PWM pins.  Init_PWM( pin )
  Init_PWM(2);										//Initialize PWM pins.  Init_PWM( pin )
  Init_PWM(3);										//Initialize PWM pins.  Init_PWM( pin )
  Init_PWM(4);										//Initialize PWM pins.  Init_PWM( pin )
  Init_PWM(5);										//Initialize PWM pins.  Init_PWM( pin )
	
	printf("Setup and Configuration Complete! Begin Readings\n");

  while(1)
  {
	////Uncomment to make sure microcontroller is actually running and that UART is working	
		Timer_Count1 ++;
		printf("%d\n",Timer_Count1);
   }
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////                                                                                      
/////////////////////////////////////////////////////////////////////////////////////////////////////////

////Timer2 ISR routine (10ms)
void TMR2_IRQHandler(void)
{
	TISR2 |= TMR_TIF; 															//Clear timer2 interrupt flag
	Timer_Count++;																	//Increase count by one				
	printf("ISR2 Loop Count: %d\t",Timer_Count);

	////Uncomment to read theta and thetadot values from IMU
	IMU_Update();																		//Update IMU data
	printf("%f\t",get_acc_theta());									//Get Theta value and print out
	printf("%f\n",get_gyro_thetad());								//Get Thetad value and pring out

	PWM_Write(0,256);								//Setting PWM Duty Cycle. PWM_Write( pin , duty cycle ).  Note: 100% duty cycle is 512	
	PWM_Write(1,256);								//Setting PWM Duty Cycle. PWM_Write( pin , duty cycle ).  Note: 100% duty cycle is 512	
	PWM_Write(2,256);								//Setting PWM Duty Cycle. PWM_Write( pin , duty cycle ).  Note: 100% duty cycle is 512	
	PWM_Write(3,256);								//Setting PWM Duty Cycle. PWM_Write( pin , duty cycle ).  Note: 100% duty cycle is 512	
	PWM_Write(4,256);								//Setting PWM Duty Cycle. PWM_Write( pin , duty cycle ).  Note: 100% duty cycle is 512	
  PWM_Write(5,256);								//Setting PWM Duty Cycle. PWM_Write( pin , duty cycle ).  Note: 100% duty cycle is 512	 
	
	if(loop == 0){digitalWrite(3,6,0); loop =1;	}							//Setting GPIO Output to High (1) or Low (0) on (Port, Pin , Output)
	else if (loop == 1){digitalWrite(3,6,1);loop = 0; }				//Setting GPIO Output to High (1) or Low (0) on (Port, Pin , Output)
	else{ printf("\nERROR!!!!\n");}
	Timer_Count1 =0;

}

