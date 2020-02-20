/*---------------------------------------------------------------------------------------------------------*/
/*                          Program Written By: SAAM OSTOVARI                                              */
/*																		NDA SD2013-802																				     			     */
/*---------------------------------------------------------------------------------------------------------*/

//Including Nuvoton Libraries
#include <stdio.h>
#include <stdint.h>
#include "M051.h"
#include "Register_Bit.h"
#include "Common.h"
#include "Retarget.h"
//Including MiP Libraries
#include "System_Clock.h"


uint32_t time_CPU_Cycle = 0;
float clkspeed = 1.0/22118.400;     //22.1148 MHz / 1000 to get answer in microsecs
float time_Millis_Sec = 0.0;
int count = 1;

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//Setting Up System Clock as PLL Clock (Default Speed is 48MHz)
void Init_System_Clocks_PLL(void)
{
    //Setting Up System Clock 
	  Un_Lock_Reg();	                      	 		//Unlock protected register bits so user can access them
    PWRCON |= XTL12M_EN;												//Enables External Cyrstal Oscillator 12MHz . Command same as PWRCON = PWRCON | XTL12M_EN
    PWRCON |= OSC10K_EN;												//Enables Internal Cyrstal Oscillator 10kHz
    PWRCON |= OSC22M_EN;												//Enables Internal Cyrstal Oscillator 22.1184 MHz
	  while((CLKSTATUS & XTL12M_STB) == 0); 			//Wait until 12M clock is stable.	
	  CLKSEL0 = (CLKSEL0 & (~HCLK)) | HCLK_PLL;		//Set PLL timer as system clock	
	  Lock_Reg();	
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//Setting Up System Clock as External 12MHz clock
void Init_System_Clocks_External_12MHz(void)
{
  //Setting Up System Clock 
	Un_Lock_Reg();	                      	 			//Unlock protected register bits so user can access them
  PWRCON |= XTL12M_EN;													//Enables External Cyrstal Oscillator 12MHz . Command same as PWRCON = PWRCON | XTL12M_EN
  PWRCON |= OSC10K_EN;													//Enables Internal Cyrstal Oscillator 10kHz
  PWRCON |= OSC22M_EN;													//Enables Internal Cyrstal Oscillator 22.1184 MHz
	while((CLKSTATUS & XTL12M_STB) == 0); 				//Wait until 12M clock is stable.	
	CLKSEL0 = (CLKSEL0 & (~HCLK)) | HCLK_12M;			//Set external crystal as the system clock
	Lock_Reg();		
}

////////////////////////////////////////////////////////////////////////////////////////////////////////
//Initialize the systick function to be able to run the millis seconds. 

void Init_System_Millis_Timer(void)
{
		//Settting Up Systick for being able to keep time count
	SYST_CVR = 0xFFFFFF;
	SYST_RVR = 0xFFFFFF;
  SYST_CSR |= CLKSRC_CORE;
	SYST_CSR |= TICKINT_EN;
	SYST_CSR |= ENABLE;	
}

////////////////////////////////////////////////////////////////////////////////////////////////////////
//Calling this time returns time in millis seconds. 
float millis(void)
{
  time_CPU_Cycle = (0xFFFFFF*count - SYST_CVR);
	time_Millis_Sec = clkspeed * time_CPU_Cycle ;
	return time_Millis_Sec;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////
//Function to reset cpu timer.
void Reset_millis(void)
{
		SYST_CVR = 0xFFFFFF;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////
//Function to reset cpu timer.
void SysTick_Handler(void){
	 count +=1;
}
