/*---------------------------------------------------------------------------------------------------------*/
/*                   Program Written By: SAAM OSTOVARI and NICK NICK MOROZOVSKY           				         */
/*																			NDA SD2013-802																										 */
/*---------------------------------------------------------------------------------------------------------*/


#ifndef __MOTOR_DRIVE_H__
#define __MOTOR_DRIVE_H__

void Init_Motors(void);																												//Function to Initialize All PWM and GPIO Pins for Motors Being Used
void motorEnable(void);																												//Function to Enable Motors that have Standby Pins
void motorESTOP(void);																												//Function to Disable Motors that have Standby Pins
void Drive_Motor(int Motor_Number,int Duty_Cycle,signed int Spin_dir);				//Function to write to specific PWM pin and change that specific PWM pins Duty Cycle. PWM Duty Cycle Range: 0 - 552
void Drive_Motor_by_U(int Motor_Number,float u);															//Function to write to specific PWM pin and change that specific PWM pins Duty Cycle. u = # between -1 and 1.
void driveMotors(float u[]);																									//Function to Drive 6 motors with one u array

#endif
