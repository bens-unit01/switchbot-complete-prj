/*---------------------------------------------------------------------------------------------------------*/
/*                          Program Written By: SAAM OSTOVARI                                              */
/*																			NDA SD2013-802																				     			   */
/*---------------------------------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------------------------------*/
/* 											Example for doing Digital Reads on M0 Arm Cortex Chip 														 */
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
#include "GPIO\GPIO.h"

/////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
int main(void)
{
	Init_System_Clocks_PLL();		//Initialize System Clocks
	Init_Uart0(115200);					//Initialize UART0
	
	//Initializing a few pins as GPIO Inputs
	//Init_GPIO_Input(Port,Pin)
	Init_GPIO_Input(1,2);       //Initialize GPIO as input on (Port,Pin)
	Init_GPIO_Input(0,1);       //Initialize GPIO as input on (Port,Pin)
	Init_GPIO_Input(4,4);       //Initialize GPIO as input on (Port,Pin)
	Init_GPIO_Input(4,5);       //Initialize GPIO as input on (Port,Pin)
	Init_GPIO_Output(3,6);       //Initialize GPIO as input on (Port,Pin)
 
	while(1)
  {
	//Reading inputs on pins specified as digital reads 
	//digitalRead(port,pin);
	int Data0 = digitalRead(1,2); 			//Reading GPIO pin value on specific pin. Returns 1 for high and 0 for low
	int Data1 = digitalRead(0,1); 			//Reading GPIO pin value on specific pin. Returns 1 for high and 0 for low
	int Data2 = digitalRead(4,4); 			//Reading GPIO pin value on specific pin. Returns 1 for high and 0 for low
	int Data3 = digitalRead(4,5); 			//Reading GPIO pin value on specific pin. Returns 1 for high and 0 for low
	printf("%d%d%d%d\n",Data0,Data1,Data2,Data3);
	if (Data0 == 1)
		digitalWrite(3,6,0);
	else
		digitalWrite(3,6,1);
	
	}
 }
