/*---------------------------------------------------------------------------------------------------------*/
/*                          Program Written By: SAAM OSTOVARI                                              */
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
#include "System_Clock\System_Clock.h"
#include "UART\UART.h"

//Declaring Variables
static uint32_t Timer_Count = 0;

/////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
int main(void)
{
	Init_System_Clocks_PLL();				//Initialize System Clocks
	Init_Uart0(115200);					//Initialize UART0
	Init_Uart1(115200);					//Initialize UART0

	while(1)
  {
		//Open a UART WINDOW in ARDUINO IDE and send data through either UART0 or UART1. This program will output that data through UART 0
		//The printf() to UART0 comes from the UART0_IRQHandler and UART1_IRQHandler which are in the UART library.
	}
 }
