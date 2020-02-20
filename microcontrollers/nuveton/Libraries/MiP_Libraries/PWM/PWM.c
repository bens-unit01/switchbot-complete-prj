/*---------------------------------------------------------------------------------------------------------*/
/*                          Program Written By: SAAM OSTOVARI                                              */
/*																		NDA SD2013-802																	  									 */
/*---------------------------------------------------------------------------------------------------------*/

//Including Nuvoton Libraries
#include <stdio.h>
#include <stdint.h>
#include "M051.h"
#include "Register_Bit.h"
#include "Common.h"
#include "Retarget.h"
//Including MiP Libraries
#include "PWM.h"

//Declaring Variables for PWM
#define DEAD_ZONE_INTERVAL      0xC8FF0000
#define PWM_ENABLE              0x01010101    
#define	PWM0123_CLOCK_SOURCE	  0xF0000000		//Used to define clock source for Motor PWM:
#define	PWM4567_CLOCK_SOURCE	  0x000000F0    //Used to define clock source for Motor PWM: 
#define Pwm0123Period		        552						//PWM Period
#define Pwm4567Period	          552						//PWM period
#define PWM_PRESCALAE           0x00000101    //Currently set to 1 for all channels
#define PWM_CLOCK_DIVIDER       0x4444  			//Currently set to 1 for all channels
#define PWM_OUTPUT_INVERT       0x00040000
#define PWM_OUTPUT_ENABLE       0x0000000F


/////////////////////////////////////////////////////////////////////////////////////////////////////////
//Function to Initialize each PWM pin being used
void Init_PWM(int PWM_Pin)
{
	//Setting Up PWM Channels
	switch (PWM_Pin)
		{
			case 0:		
			{	
				P2_MFP &= ~(P20_AD8_PWM0 );						//Sets the names P20, AD8, and PWM0 to the appropriate bit for the next line
				P2_MFP |= (PWM0 );   
				P2_PMD &= ~Px0_PMD;                   //Configure PWM0 output pins "push-pull" mode
				P2_PMD |= Px0_OUT;
				break;
			}
			case 1:
			{		
				P2_MFP &= ~(P21_AD9_PWM1 );						//Sets the names P21, AD9, and PWM1 to the appropriate bit for the next line
				P2_MFP |= PWM1;
				P2_PMD &= ~Px1_PMD;                   //Configure PWM1 output pins "push-pull" mode
				P2_PMD |= Px1_OUT;
				break;
			}
			case 2:
			{		
				P2_MFP &= ~(P22_AD10_PWM2);						//Sets the names P22, AD10, and PWM2 to the appropriate bit for the next line
				P2_MFP |= PWM2;
				P2_PMD &= ~Px2_PMD;                   //Configure PWM2 output pins "push-pull" mode
				P2_PMD |= Px2_OUT;
				break;
			}	
			case 3:
			{		
				P2_MFP &= ~(P23_AD11_PWM3);						//Sets the names P23, AD11, and PWM3 to the appropriate bit for the next line
				P2_MFP |= PWM3;
				P2_PMD &= ~Px3_PMD;                   //Configure PWM3 output pins "push-pull" mode
				P2_PMD |= Px3_OUT;
				break;
			}
			case 4:
			{		
				P2_MFP &= ~(P24_AD12_PWM4);						//Sets the names P24, AD12, and PWM4 to the appropriate bit for the next line
				P2_MFP |= PWM4;
				P2_PMD &= ~Px4_PMD;                   //Configure PWM4 output pins "push-pull" mode
				P2_PMD |= Px4_OUT;
				break;
			}
			case 5:
			{		
				P2_MFP &= ~(P25_AD13_PWM5);						//Sets the names P25, AD13, and PWM5 to the appropriate bit for the next line
				P2_MFP |= PWM5;
				P2_PMD &= ~Px5_PMD;                   //Configure PWM5 output pins "push-pull" mode
				P2_PMD |= Px5_OUT;
				break;
			}
			case 6:
			{		
				P2_MFP &= ~(P26_AD14_PWM6 );					//Sets the names P26, AD14, and PWM6 to the appropriate bit for the next line
				P2_MFP |= PWM6;
				P2_PMD &= ~Px6_PMD;                   //Configure PWM6 output pins "push-pull" mode
				P2_PMD |= Px6_OUT;
				break;
			}
			case 7:
			{		
				P2_MFP &= ~(P27_AD15_PWM7);						//Sets the names P27, AD15, and PWM7 to the appropriate bit for the next line
				P2_MFP |= PWM7;
				P2_PMD &= ~Px7_PMD;                   //Configure PWM7 output pins "push-pull" mode
				P2_PMD |= Px7_OUT;	
				break;
			}			
		}		
			
	  if((PWM_Pin == 0)|(PWM_Pin == 1)) { APBCLK |= PWM01_CLKEN; }					//Enable PWM0,1 and PWM0,1 clock
	  if((PWM_Pin == 2)|(PWM_Pin == 3)) { APBCLK |= PWM23_CLKEN; }					//Enable PWM2,3 and PWM2,3 clock	
		if((PWM_Pin == 4)|(PWM_Pin == 5)) { APBCLK |= PWM45_CLKEN; }					//Enable PWM4,5 and PWM4,5 clock
		if((PWM_Pin == 6)|(PWM_Pin == 7)) { APBCLK |= PWM67_CLKEN; } 					//Enable PWM6,7 and PWM6,7 clock
		  
		
		//SET UP FOR PWM 0,1,2,3
		if( (PWM_Pin >= 0) & (PWM_Pin <= 3) )
		{
			CLKSEL1 |= PWM0123_CLOCK_SOURCE;           						  						//Sets PWM 0,1,2,3 clock source
			PPRA |= PWM_PRESCALAE | DEAD_ZONE_INTERVAL;             						//Sets PWM 0,1,2,3 clock pre-scalar and dead-zone scale
			CSRA |= PWM_CLOCK_DIVIDER;                              						//Sets PWM 0,1,2.3 clock divider
			PCRA |= 0x08080808;																		  						//Set PWM under auto-reload (continuous) mode, select output channel invertion, set complement mode
			CNR0A = CNR1A = CNR2A = CNR3A = Pwm0123Period;          						//PWM0123 period. Freq 19.999kHz
    //Setting PWM Duty Cycle. CMR values are what need to be changed to set duty cycle. Set to 0 duty cycle to start
			CMR0A = 0;																													//PWM0 
			CMR1A = 0;																													//PWM1	
			CMR2A = 0;																													//PWM2	
			CMR3A = 0;																													//PWM3	
			POEA |= PWM_OUTPUT_ENABLE;                              						//PWM0,1,2,3 Output enable
			PCRA |= PWM_ENABLE;                                     						//PWM0,1,2,3 circuit enable and start to run
		}
		
	  //SET UP FOR PWM 4,5,6,7
		if( (PWM_Pin >= 4) & (PWM_Pin <= 7) )
		{
			CLKSEL2 |= PWM4567_CLOCK_SOURCE;																		//Select PWM4,5 and PWM6,7 clock source. Set to Internal 22MHz clock.  Note Clocks need to already be enabled. Default value: 0x0000_00FF
			PPRB |= PWM_PRESCALAE | DEAD_ZONE_INTERVAL;             						//Select PWM 4,5,6,7 clock pre-scalar and PWM6,7 dead-zone scale
			CSRB |= PWM_CLOCK_DIVIDER;                              						//Select PWM4~7 clock divider
			PCRB |= 0x08080808;																									//Set PWM under auto-reload (continuous) mode, select output channel invertion, set complement mode
			CNR0B = CNR1B = CNR2B = CNR3B = Pwm4567Period;          						//PWM4567 period. Freq 19.999kHz. 
			//Setting PWM Duty Cycle. CMR values are what need to be changed to set duty cycle. Set to 0 duty cycle to start
			CMR0B = 0 ;																													//PWM4	
			CMR1B = 0 ;																						  						//PWM5	
			CMR2B = 0  ;																												//PWM6	
			CMR3B = 0  ;																												//PWM7	
			POEB |= PWM_OUTPUT_ENABLE;                              						//PWM 4,5,6,7 Output enable
			PCRB |= PWM_ENABLE;                         												//PWM 4,5,6,7 circuit enable and start to run
		}
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//Function to write to specific PWM pin and change that specific PWM pins Duty Cycle. PWM Duty Cycle Range: 0 - 552
void PWM_Write(int PWM_Pin,int Duty_Cycle)
{
	//Setting PWM Duty Cycle. CMR values are what need to be changed to set duty cycle
	switch (PWM_Pin)
		{
			case 0:		
			{	CMR0A = Duty_Cycle; break;}												//PWM0 
			case 1:
			{	CMR1A = Duty_Cycle; break;}												//PWM1	
			case 2:
			{ CMR2A = Duty_Cycle; break;}												//PWM2	
			case 3:
			{	CMR3A = Duty_Cycle; break;}												//PWM3	
			case 4:
			{	CMR0B = Duty_Cycle; break;}												//PWM4	
			case 5:
			{	CMR1B = Duty_Cycle; break;}												//PWM5	
			case 6:
			{ CMR2B = Duty_Cycle; break;}												//PWM6	
			case 7:
			{	CMR3B = Duty_Cycle; break;}												//PWM7					
		}	
}		


