/*---------------------------------------------------------------------------------------------------------*/
/*                          Program Written By: SAAM OSTOVARI                                              */
/*																			NDA SD2013-802																				     			   */
/*---------------------------------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------------------------------*/
/*									  Test code on using all ADC on M0 Arm Cortex Chip																		 */
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
#include "ADC\ADC.h"

//Declaring Variables
int an0 =9999;
int an1 =9999;
int an2 =9999;
int an3 =9999;
int an4 =9999;
int an5 =9999;
int an6 =9999;
int an7 =9999;

/////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
int main(void)
{
	Init_System_Clocks_PLL();				//Initialize System Clocks
	Init_Uart0(115200);							//Initialize UART0
	Init_ADC(0);										// Enabling ADC in continousmode on pin.  Init_ADC(pin)
	Init_ADC(1);										// Enabling ADC in continousmode on pin.  Init_ADC(pin)
	Init_ADC(2);										// Enabling ADC in continousmode on pin.  Init_ADC(pin)
	Init_ADC(3);										// Enabling ADC in continousmode on pin.  Init_ADC(pin)
	Init_ADC(4);										// Enabling ADC in continousmode on pin.  Init_ADC(pin)
	Init_ADC(5);										// Enabling ADC in continousmode on pin.  Init_ADC(pin)
	Init_ADC(6);										// Enabling ADC in continousmode on pin.  Init_ADC(pin)
	Init_ADC(7);										// Enabling ADC in continousmode on pin.  Init_ADC(pin)
	
	while(1)
  {	
	 UpdateAnalogRead();          // Updates all analog pins enabled
	 an0 = analogRead(0);					// Reading new value on specific pin. analogRead(pin)
	 an1 = analogRead(1);					// Reading new value on specific pin. analogRead(pin)
	 an2 = analogRead(2);					// Reading new value on specific pin. analogRead(pin)
	 an3 = analogRead(3);					// Reading new value on specific pin. analogRead(pin)
	 an4 = analogRead(4);					// Reading new value on specific pin. analogRead(pin)
	 an5 = analogRead(5);					// Reading new value on specific pin. analogRead(pin)
	 an6 = analogRead(6);					// Reading new value on specific pin. analogRead(pin)
	 an7 = analogRead(7);					// Reading new value on specific pin. analogRead(pin)
 
	 //Outputing data received from ADC
	 printf("an0 = %d\t an1 = %d\t an2 = %d\t an3 = %d\t an4 = %d\t an5 = %d\t an6 = %d\t an7 = %d\n",an0,an1,an2,an3,an4,an5,an6,an7);				// Outputing data received from ADC
	}
 }
