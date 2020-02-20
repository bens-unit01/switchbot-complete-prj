/*---------------------------------------------------------------------------------------------------------*/
/*                          Program Written By: SAAM OSTOVARI                                              */
/*																			NDA SD2013-802																				     			   */
/*---------------------------------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------------------------------*/
/* 								Example on how to initalize all pwm pins and output on them															 */
/* 									Note that PWM FREQUENCY is currently sett for ~19.9kHz																 */
/*---------------------------------------------------------------------------------------------------------*/

//Including Nuvoton Libraries
#include <stdio.h>
#include <stdint.h>
#include "M051.h"
#include "Register_Bit.h"
#include "Common.h"
#include "Retarget.h"
//Including MiP Libraries 
#include "System_Clock\System_Clock.h"
#include "UART\UART.h"
#include "PWM\PWM.h"

//Declaring Variables
static uint32_t Timer_Count = 0;

/////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
int main(void)
{
	Init_System_Clocks_PLL();				//Initialize System Clocks
	Init_Uart0(115200);							//Initialize UART0
	Init_PWM(0);										//Initialize PWM pins.  Init_PWM( pin )
	Init_PWM(1);										//Initialize PWM pins.  Init_PWM( pin )
  Init_PWM(2);										//Initialize PWM pins.  Init_PWM( pin )
  Init_PWM(3);										//Initialize PWM pins.  Init_PWM( pin )
  Init_PWM(4);										//Initialize PWM pins.  Init_PWM( pin )
  Init_PWM(5);										//Initialize PWM pins.  Init_PWM( pin )
  Init_PWM(6);										//Initialize PWM pins.  Init_PWM( pin )
  Init_PWM(7);										//Initialize PWM pins.  Init_PWM( pin )
	
	PWM_Write(0,256);								//Setting PWM Duty Cycle. PWM_Write( pin , duty cycle ).  Note: 100% duty cycle is 552	
	PWM_Write(1,256);								//Setting PWM Duty Cycle. PWM_Write( pin , duty cycle ).  Note: 100% duty cycle is 552	
	PWM_Write(2,256);								//Setting PWM Duty Cycle. PWM_Write( pin , duty cycle ).  Note: 100% duty cycle is 552	
	PWM_Write(3,256);								//Setting PWM Duty Cycle. PWM_Write( pin , duty cycle ).  Note: 100% duty cycle is 552	
	PWM_Write(4,256);								//Setting PWM Duty Cycle. PWM_Write( pin , duty cycle ).  Note: 100% duty cycle is 552	
  PWM_Write(5,256);								//Setting PWM Duty Cycle. PWM_Write( pin , duty cycle ).  Note: 100% duty cycle is 552	 

	while(1)
  {
	 //Check to make sure programming is running
	 Timer_Count++;
	 printf("\n Loop Count:%d \n",Timer_Count);
	}
 }
