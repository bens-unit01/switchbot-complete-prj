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
#include "..\UART\UART.h"
#include "..\System_Clock\System_Clock.h"
#include "Timers.h"

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//static uint32_t Timer_Count = 0;

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//Setting Up Timer0
void Init_Timer0_ISR(void)
{
  //Enable Timer0 clock source
	APBCLK |= TMR0_CLKEN;														
	//Select Timer0 clock source as external 12M
	CLKSEL1 = (CLKSEL1 & (~TM0_CLK)) | TM0_12M;    	    	
	//Reset IP TMR0
	IPRSTC2 |= TMR0_RST;
	IPRSTC2 &= ~TMR0_RST;
	//Select timer0 Operation mode as period mode
	TCSR0 &= ~TMR_MODE;
	TCSR0 |= MODE_PERIOD;			
	//Select Time out period = (Period of timer clock input) * (8-bit Prescale + 1) * (24-bit TCMP)
	TCSR0 = TCSR0 & 0xFFFFFF00;						//Set Prescale [0~255].
	TCMPR0 = 30000;												//Set TCMPR [0~16777215]
	//Enable timer0 interrupt
	TCSR0 |= TMR_IE;		
	NVIC_ISER = TMR0_INT;	
	//Reset timer0 counter on interrupt
	TCSR0 |= CRST;
	//Enable Timer0																	
	TCSR0 |= CEN;																						
}

/*
////Timer0 ISR routine
//Note1: Uncomment this if you initialize timer0 interrupt. 
//Note2: This interrupt function can either be located in the main program
void TMR0_IRQHandler(void)
{
	TISR0 |= TMR_TIF;																//Clear timer0 interrupt flag			
	
  Timer_Count++;																	//Increase count by one				
	printf("\nISR0 Loop Count: %d",Timer_Count);
	if (Timer_Count == 100){
		//TCSR0 &= ~CEN;  //This disables timer interrupt
		printf("\nTimer0 has ran 100 times now\n");
	 }
}
*/

/////////////////////////////////////////////////////////////////////////////////////////////////////////
////Setting Up Timer1
void Init_Timer1_ISR(void)
{
	//Enable Timer0 clock source
  APBCLK |= TMR1_CLKEN;					
	//Select Timer0 clock source as external 12M								
	CLKSEL1 = (CLKSEL1 & (~TM1_CLK)) | TM1_12M; 	  
	//Reset IP TMR1
	IPRSTC2 |= TMR1_RST;
	IPRSTC2 &= ~TMR1_RST;
	//Select timer1 Operation mode as period mode
	TCSR1 &= ~TMR_MODE;
	TCSR1 |= MODE_PERIOD;		
	//Select Time out period = (Period of timer clock input) /( (8-bit Prescale + 1) * (24-bit TCMP))*/
	TCSR1 = TCSR1 & 0xFFFFFF00;									//Set Prescale [0~255]
	TCMPR1 = 60000;															//Set TCMPR [0~16777215]
	//Enable timer1 interrupt
	TCSR1 |= TMR_IE;		
	NVIC_ISER = TMR1_INT;	
	//Reset timer1 counter
	TCSR1 |= CRST;		
	//Enable Timer1														
	TCSR1 |= CEN;																					
	
}

/*
////Timer1 ISR routine  
//Note1: Uncomment this if you initialize timer1 interrupt. 
//Note2: This interrupt function can either be located in the main program
void TMR1_IRQHandler(void)
{
	TISR1 |= TMR_TIF; 															//Clear timer1 interrupt flag	
	
  Timer_Count++;																	//Increase count by one	
	printf("\nISR1 Loop Count: %d",Timer_Count);
	if (Timer_Count == 100){
		//TCSR1 &= ~CEN; //This disables timer interrupt
		printf("\nTimer1 10ms period test is over\n");
	}
}
*/

/////////////////////////////////////////////////////////////////////////////////////////////////////////
////Setting Up Timer2
void Init_Timer2_ISR(void)
{
	//Enable Timer0 clock source
  APBCLK |= TMR2_CLKEN;
	//Select Timer0 clock source as external 12M  
	CLKSEL1 = (CLKSEL1 & (~TM2_CLK)) | TM2_12M;	
	//Reset IP TMR2 
	IPRSTC2 |= TMR2_RST;
	IPRSTC2 &= ~TMR2_RST;
	// Select timer2 Operation mode as period mode 
	TCSR2 &= ~TMR_MODE;
	TCSR2 |= MODE_PERIOD;			
  // Select Time out period = (Period of timer clock input) * (8-bit Prescale + 1) * (24-bit TCMP)*/
	TCSR2 = TCSR2 & 0xFFFFFF00;		// Set Prescale [0~255]
	TCMPR2 = 120000;							// Set TCMPR [0~16777215]
	// Enable timer2 interrupt 
	TCSR2 |= TMR_IE;		
	NVIC_ISER = TMR2_INT;	
	//Reset timer2 counter 
	TCSR2 |= CRST;	
	// Enable Timer2 				
	TCSR2 |= CEN;			
}

/*
////Timer2 ISR routine 
//Note1: Uncomment this if you initialize timer2 interrupt. 
//Note2: This interrupt function can either be located in the main program
void TMR2_IRQHandler(void)
{
	TISR2 |= TMR_TIF; 															//Clear timer2 interrupt flag
	
  Timer_Count++;																	//Increase count by one	
	printf("\nISR2 Loop Count: %d",Timer_Count);
	if (Timer_Count == 100){
		//TCSR2 &= ~CEN; //This disables timer interrupt
		printf("\nTimer2 10ms period test is over\n");
	}
}
*/

//////////////////////////////////////////////////////////////////////////////////////////////////////////
////Setting Up Timer3
void Init_Timer3_ISR(void)
{
	//Enable Timer0 clock source
  APBCLK |= TMR3_CLKEN;
	//Select Timer0 clock source as external 12M  
	CLKSEL1 = (CLKSEL1 & (~TM3_CLK)) | TM3_12M;	
	//Reset IP TMR3
	IPRSTC2 |= TMR3_RST;
	IPRSTC2 &= ~TMR3_RST;
	//Select timer3 Operation mode as period mode	
	TCSR3 &= ~TMR_MODE;
	TCSR3 |= MODE_PERIOD;		
  //Select Time out period = (Period of timer clock input) * (8-bit Prescale + 1) * (24-bit TCMP)*/
	TCSR3 = TCSR3 & 0xFFFFFF00;								//Set Prescale [0~255]
	TCMPR3 = 90000;														//Set TCMPR [0~16777215]
	//Enable timer3 interrupt
	TCSR3 |= TMR_IE;		
	NVIC_ISER = TMR3_INT;	
	//Reset timer3 counter
	TCSR3 |= CRST;	
	//Enable Timer3					
	TCSR3 |= CEN;		
}

/*
////Timer3 ISR routine 
//Note1: Uncomment this if you initialize timer3 interrupt. 
//Note2: This interrupt function can either be located in the main program
void TMR3_IRQHandler(void)
{
	TISR3 |= TMR_TIF;																//Clear timer2 interrupt flag
	
  Timer_Count++;																	//Increase count by one
	printf("\nISR3 Loop Count: %d",Timer_Count);
  if (Timer_Count == 100){
		//TCSR3 &= ~CEN; //This disables timer interrupt
		printf("\nTimer3 10ms period test is over\n");
	}
}
*/
