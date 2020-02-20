/*---------------------------------------------------------------------------------------------------------*/
/*                          Program Written By: SAAM OSTOVARI                                              */
/*																			NDA SD2013-802																				     			   */
/*---------------------------------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------------------------------*/
/*									   Test code on using External Interrupts for encoders																 */
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
#include "Encoders\Encoders.h"
#include "GPIO\GPIO.h"

//Declaring Variables
static uint32_t Timer_Count = 0;

/////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
int main(void)
{
	Init_System_Clocks_PLL();				//Initialize System Clocks
	Init_Uart0(115200);					    //Initialize UART0
	Init_Encoders();
	Init_GPIO_Output(3,6);					//Initialize GPIO as output out on (Port,Pin) for onboard LED
	
	while(1)
	{
	  Timer_Count++;
		if (Timer_Count%100 > 50)	digitalWrite(3,6,0);
		else	digitalWrite(3,6,1);
		//printf("Loop Count: %d\n",Timer_Count);
		printf("%f\t%f\n",get_encoderLcount(),get_encoderRcount());
		//printf("%f\n",get_encoderLcount());
	}
 
}
