/*---------------------------------------------------------------------------------------------------------*/
/*                          Program Written By: SAAM OSTOVARI                                              */
/*																			NDA SD2013-802																				     			   */
/*---------------------------------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------------------------------*/
/* 							     Example on how to initalize and use Timer Interrupts																	 */
/*---------------------------------------------------------------------------------------------------------*/

//Including Nuvoton Libraries
#include <stdio.h>
#include <stdint.h>
#include "M051.h"
#include "Register_Bit.h"
#include "Common.h"
#include "Retarget.h"
//Including MiP Libraries 
#include "UART\UART.h"
#include "System_Clock\System_Clock.h"
#include "Timers\Timers.h"
#include "GPIO\GPIO.h"

static int loop = 0; 
static uint32_t Timer_Count = 0;
float MillisData = 0;

/////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
int main(void)
{
	Init_System_Clocks_PLL();				//Initialize System Clocks
	Init_Uart0(115200);							//Initialize UART0
	Init_GPIO_Output(3,6);					//Initialize GPIO as output out on (Port,Pin)
	Init_System_Millis_Timer();			//Initialize Millis() function for measuring time
	
	//Init_Timer0_ISR();    				//Initalize Timer 0 ISR. ISR Located in Timer.c file. Currently set to 2.5ms
	//Init_Timer1_ISR();    				//Initalize Timer 1 ISR. ISR Located in Timer.c file. Currently set to 5ms
	Init_Timer2_ISR();    					//Initalize Timer 2 ISR. ISR Located in Timer.c file. Currently set to 10ms
	//Init_Timer3_ISR();    				//Initalize Timer 3 ISR. ISR Located in Timer.c file. Currently set to 7.5ms

	while(1){}
 }

 
///////////////////////////////////////////////////////////////////////////////////////////////////////// 
/////////////////////////////////////////////////////////////////////////////////////////////////////////
 //BELOW ARE THE ISR ROUTINES FOR THE TIMERS. YOU MUST PLACE EVERYTHING YOU WANT RUN AT THE SPECIFIC LOOP RATE IN THE CORRECT ISR 
 // Init_Timer0_ISR  -- > use --> TMR0_IRQHandler --> 2.5ms loop rate
 // Init_Timer1_ISR  -- > use --> TMR1_IRQHandler --> 5ms loop rate
 // Init_Timer2_ISR  -- > use --> TMR2_IRQHandler --> 10ms loop rate
 // Init_Timer3_ISR  -- > use --> TMR3_IRQHandler --> 7.5ms loop rate

 ////Timer0 ISR routine (2.5ms)
void TMR0_IRQHandler(void)
{
	TISR0 |= TMR_TIF;																				//MUST REMAIN AT BEGINNING THIS FUNCTION. Clear timer0 interrupt flag			
	Timer_Count++;																					//Increase count by one				
	printf("ISR0 Loop Count:\t%d\t",Timer_Count);

	MillisData = millis();																	//Gets the time that has passed. Accurate for 75ms but then needs to be reset
  printf("%f\n",MillisData);

	if(loop == 0){digitalWrite(3,6,0); loop =1;}						//Setting GPIO Output to High (1) or Low (0) on (Port, Pin , Output)
	else if (loop == 1){digitalWrite(3,6,1);loop = 0; }			//Setting GPIO Output to High (1) or Low (0) on (Port, Pin , Output)
	else{ printf("\nERROR!!!!\n");}
	
	//TCSR0 &= ~CEN;  //This disables timer interrupt
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////

////Timer1 ISR routine (5ms)
void TMR1_IRQHandler(void)
{
	TISR1 |= TMR_TIF; 																			//Clear timer1 interrupt flag	
	Timer_Count++;																					//Increase count by one				
	printf("ISR1 Loop Count:\t%d\t",Timer_Count);

	MillisData = millis();																	//Gets the time that has passed. Accurate for 75ms but then needs to be reset
  printf("%f\n",MillisData);

	if(loop == 0){digitalWrite(3,6,0); loop =1;}						//Setting GPIO Output to High (1) or Low (0) on (Port, Pin , Output)
	else if (loop == 1){digitalWrite(3,6,1);loop = 0; }			//Setting GPIO Output to High (1) or Low (0) on (Port, Pin , Output)
	else{ printf("\nERROR!!!!\n");}

}


/////////////////////////////////////////////////////////////////////////////////////////////////////////

////Timer2 ISR routine (10ms)
void TMR2_IRQHandler(void)
{
	TISR2 |= TMR_TIF; 																			//Clear timer2 interrupt flag
	Timer_Count++;																					//Increase count by one				
	//printf("ISR2 Loop Count:\t%d\t",Timer_Count);

	MillisData = millis();																	//Gets the time that has passed. Accurate for 75ms but then needs to be reset
  printf("%f\n",MillisData);
	
	if(loop == 0){digitalWrite(3,6,0); loop =1;	}						//Setting GPIO Output to High (1) or Low (0) on (Port, Pin , Output)
	else if (loop == 1){digitalWrite(3,6,1);loop = 0; }			//Setting GPIO Output to High (1) or Low (0) on (Port, Pin , Output)
	else{ printf("\nERROR!!!!\n");}
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////

////Timer3 ISR routine (7.5ms)
void TMR3_IRQHandler(void)
{
	TISR3 |= TMR_TIF;																				//Clear timer2 interrupt flag
	Timer_Count++;																					//Increase count by one				
	printf("ISR3 Loop Count:\t%d\t",Timer_Count);

	MillisData = millis();																	//Gets the time that has passed. Accurate for 75ms but then needs to be reset
  printf("%f\n",MillisData);
	
	if(loop == 0){digitalWrite(3,6,0); loop =1;}						//Setting GPIO Output to High (1) or Low (0) on (Port, Pin , Output)
	else if (loop == 1){digitalWrite(3,6,1);loop = 0; }			//Setting GPIO Output to High (1) or Low (0) on (Port, Pin , Output)
	else{ printf("\nERROR!!!!\n");}
}

