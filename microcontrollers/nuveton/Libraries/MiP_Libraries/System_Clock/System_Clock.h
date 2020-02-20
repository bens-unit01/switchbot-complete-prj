/*---------------------------------------------------------------------------------------------------------*/
/*                          Program Written By: SAAM OSTOVARI                                              */
/*																		NDA SD2013-802																				     			     */
/*---------------------------------------------------------------------------------------------------------*/


#ifndef __System_Clock_H__
#define __System_Clock_H__

void Init_System_Clocks_PLL(void);														//Setting Up System Clock as PLL Clock (Default Speed is 48MHz)
void Init_System_Clocks_External_12MHz(void);									//Setting Up System Clock as External 12MHz clock
float millis(void);																						//Call function to get time in ms. Accurate for 75ms, then needs to be reset
void Reset_millis(void);																			//Reset Timer for purpose of getting time
void Init_System_Millis_Timer(void);													//Initialize Millis() function for measuring time in millissec
void SysTick_Handler(void);																		//Interrupt for Systick which is the register that does allows for the Millis() command


#endif
