/*---------------------------------------------------------------------------------------------------------*/
/*                          Program Written By: SAAM OSTOVARI                                              */
/*																		NDA SD2013-802																	  									 */
/*---------------------------------------------------------------------------------------------------------*/


#ifndef __PWM_H__
#define __PWM_H__

void Init_PWM(int PWM_Pin);														//Function to Initialize each PWM pin being used
void PWM_Write(int PWM_Pin,int Duty_Cycle);						//Function to write to specific PWM pin and change that specific PWM pins Duty Cycle. PWM Duty Cycle Range: 0 - 552

#endif
