/*---------------------------------------------------------------------------------------------------------*/
/*                          Program Written By: SAAM OSTOVARI                                              */
/*																			NDA SD2013-802																				     			   */
/*---------------------------------------------------------------------------------------------------------*/


#ifndef __TIMERS_H__
#define __TIMERS_H__

void Init_Timer0_ISR(void);										//Setting Up Timer0. Associated Timer Interrupt Function is: void TMR0_IRQHandler(void) .  Interrupt Function can be in Main Program or this Library
void Init_Timer1_ISR(void);										//Setting Up Timer1. Associated Timer Interrupt Function is: void TMR1_IRQHandler(void) .  Interrupt Function can be in Main Program or this Library
void Init_Timer2_ISR(void);										//Setting Up Timer2. Associated Timer Interrupt Function is: void TMR2_IRQHandler(void) .  Interrupt Function can be in Main Program or this Library
void Init_Timer3_ISR(void);										//Setting Up Timer3. Associated Timer Interrupt Function is: void TMR3_IRQHandler(void) .  Interrupt Function can be in Main Program or this Library

#endif
