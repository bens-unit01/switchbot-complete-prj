/*---------------------------------------------------------------------------------------------------------*/
/*                          Program Written By: SAAM OSTOVARI                                              */
/*																			NDA SD2013-802																				     			   */
/*---------------------------------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------------------------------*/
/* 							Example on how to initalize pin as GPIO Output and to write to it													 */
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

//Declaring Variables
static uint32_t Timer_Count = 0;

/////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
int main(void)
{
	Init_System_Clocks_PLL();		//Initialize System Clocks
	Init_Uart0(115200);					//Initialize UART0
	
	////Initailizing some pints as GPIO Outputs for this example.
	////Init_GPIO_Output(Port,Pin)
	Init_GPIO_Output(0,0);			//Initialize GPIO as output out on (Port,Pin)
	Init_GPIO_Output(0,1);			//Initialize GPIO as output out on (Port,Pin)	
	Init_GPIO_Output(0,2);			//Initialize GPIO as output out on (Port,Pin)
	Init_GPIO_Output(0,3);			//Initialize GPIO as output out on (Port,Pin)
	Init_GPIO_Output(1,4);			//Initialize GPIO as output out on (Port,Pin)
	Init_GPIO_Output(1,7);			//Initialize GPIO as output out on (Port,Pin)
	Init_GPIO_Output(2,6);			//Initialize GPIO as output out on (Port,Pin)
	Init_GPIO_Output(2,7);			//Initialize GPIO as output out on (Port,Pin)
	Init_GPIO_Output(3,2);			//Initialize GPIO as output out on (Port,Pin)
	Init_GPIO_Output(3,3);			//Initialize GPIO as output out on (Port,Pin)
	Init_GPIO_Output(3,6);			//Initialize GPIO as output out on (Port,Pin)
	Init_GPIO_Output(3,7);			//Initialize GPIO as output out on (Port,Pin)
	Init_GPIO_Output(4,0);			//Initialize GPIO as output out on (Port,Pin)	
	Init_GPIO_Output(4,1);			//Initialize GPIO as output out on (Port,Pin)
	Init_GPIO_Output(4,2);			//Initialize GPIO as output out on (Port,Pin)	
	Init_GPIO_Output(4,3);			//Initialize GPIO as output out on (Port,Pin)	
	Init_GPIO_Output(4,4);			//Initialize GPIO as output out on (Port,Pin)	
	Init_GPIO_Output(4,5);			//Initialize GPIO as output out on (Port,Pin)

	////Write to different pins that are initalized as GPIO
  ////digitalWrite(port,pin,output);   Output = 1 (for High) or 0 (for Low) 
	digitalWrite(0,0,1);				//Setting GPIO Output to High (1) on (Port, Pin , Output)
	digitalWrite(0,1,1);				//Setting GPIO Output to High (1) on (Port, Pin , Output)
	digitalWrite(0,2,1);				//Setting GPIO Output to High (1) on (Port, Pin , Output)
	digitalWrite(0,3,1);				//Setting GPIO Output to High (1) on (Port, Pin , Output)
	digitalWrite(1,4,1);				//Setting GPIO Output to High (1) on (Port, Pin , Output)
	digitalWrite(1,7,1);				//Setting GPIO Output to High (1) on (Port, Pin , Output)
	digitalWrite(2,6,1);				//Setting GPIO Output to High (1) on (Port, Pin , Output)
	digitalWrite(2,7,1);				//Setting GPIO Output to High (1) on (Port, Pin , Output)
	digitalWrite(3,2,0);				//Setting GPIO Output to Low (0) on (Port, Pin , Output)
	digitalWrite(3,3,0);				//Setting GPIO Output to Low (0) on (Port, Pin , Output)
	digitalWrite(3,6,0);				//Setting GPIO Output to Low (0) on (Port, Pin , Output)
	digitalWrite(3,7,0);				//Setting GPIO Output to Low (0) on (Port, Pin , Output)
	digitalWrite(4,0,0);				//Setting GPIO Output to Low (0) on (Port, Pin , Output)
	digitalWrite(4,1,0);				//Setting GPIO Output to Low (0) on (Port, Pin , Output)
	digitalWrite(4,2,0);				//Setting GPIO Output to Low (0) on (Port, Pin , Output)
	digitalWrite(4,3,0);				//Setting GPIO Output to Low (0) on (Port, Pin , Output)
	digitalWrite(4,4,0);				//Setting GPIO Output to Low (0) on (Port, Pin , Output)
	digitalWrite(4,5,0);				//Setting GPIO Output to Low (0) on (Port, Pin , Output)

	
	while(1)
  {
	 //Check to make sure code is running
	 Timer_Count++;
	 printf("\n Loop Count: %d!\n",Timer_Count);
	}
 }
