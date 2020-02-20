/*---------------------------------------------------------------------------------------------------------*/
/*                          Program Written By: SAAM OSTOVARI and Nick Morozovsky                          */
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
#include "Interrupt_Priority.h"


/////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
Interrupt priority registers NVIC_IPR2 and NVIC_IPR3 are defined on pages 76 and 77 of
the ARM cortex technical reference manual. The list of interrupts is on pages 66-67.
0 is the highest priority, 3 (0b11) is the lowest
default is all zeros

NVIC_IPR2
bits 31:30 define the priority of IRQ11, Timer 3
bits 23:22 define the priority of IRQ10, Timer 2
bits 15:14 define the priority of IRQ9, Timer 1
bits 7:6 define the priority of IRQ8, Timer 0

NVIC_IPR3
bits 31:30 define the priority of IRQ15, SPI1
bits 23:22 define the priority of IRQ14, SPI0
bits 15:14 define the priority of IRQ13, UART1
bits 7:6 define the priority of IRQ12, UART0
*/

void Init_Interrupt_Priority(int config)
{
		//Setting up Interrupt Priorities. Priority 0 is highest, Priority 3 is lowest. Default is 0
   switch (config) {
		 case 1:
			NVIC_IPR2 |= (1<<6);				//TMR0 = set to priority 1 
			NVIC_IPR2 |= (1<<14);			//TMR1 = set to priority 1 
			NVIC_IPR2 |= (1<<22);			//TMR2 = set to priority 1 
			NVIC_IPR2 |= (1<<30);			//TMR3 = set to priority 1 
   
			NVIC_IPR3 |= (1<<6);				//UART0 = set to priority 3 
			NVIC_IPR3 |= (1<<7);				//UART0 = set to priority 3 
			NVIC_IPR3 |= (1<<14);			//UART1 = set to priority 3 
			NVIC_IPR3 |= (1<<15);			//UART1 = set to priority 3 
		break;
		 
		 case 2:
			NVIC_IPR2 |= (1<<6);				//TMR0 = set to priority 1 
			NVIC_IPR2 |= (1<<14);			//TMR1 = set to priority 1 
			NVIC_IPR2 |= (1<<22);			//TMR2 = set to priority 1 
			NVIC_IPR2 |= (1<<30);			//TMR3 = set to priority 1 
      NVIC_IPR3 |= (1<<7);				//UART0 = set to priority 2 
			NVIC_IPR3 |= (1<<15);			//UART1 = set to priority 2 
		break;
		
		 case 3:
			NVIC_IPR3 |= (1<<6);				//UART0 = set to priority 3 
			NVIC_IPR3 |= (1<<7);				//UART0 = set to priority 3 
			NVIC_IPR3 |= (1<<14);			//UART1 = set to priority 3 
			NVIC_IPR3 |= (1<<15);			//UART1 = set to priority 3 
		break;
		
		 case 4:
			NVIC_IPR3 |= (1<<7);				//UART0 = set to priority 2 
			NVIC_IPR3 |= (1<<15);			//UART1 = set to priority 2
		break;
		
		 case 5:
			NVIC_IPR3 |= (1<<6);				//UART0 = set to priority 1 
			NVIC_IPR3 |= (1<<14);			//UART1 = set to priority 1 
		break;
		
		 case 6:
			NVIC_IPR0=0xc0c00000;			// EINTO = EINT1 = 3
			NVIC_IPR1=0xc0c00000;			// PWMA_INT = PWMB = 3
			NVIC_IPR2=0x40c0c000;			// TMR1 = TMR2 = 3   TMR3 = 1
			NVIC_IPR3=0x00c0c0c0;     // UART0 = UART1 = SPI0 = 3
			NVIC_IPR4=0xc0c0c0c0;     // i2c = 3
			NVIC_IPR6=0xc0c0c0c0;			// ACMP_INT = 3
			NVIC_IPR7=0xc0c04000;			// ADC = 1
		 break;

		 case 7:
			NVIC_IPR2 |= (1<<6);				//TMR0 = set to priority 1 
			NVIC_IPR2 |= (1<<14);			//TMR1 = set to priority 1 
			NVIC_IPR2 |= (1<<22);			//TMR2 = set to priority 1 
			NVIC_IPR2 |= (1<<30);			//TMR3 = set to priority 1 
   		NVIC_IPR3 |= (1<<6);				//UART0 = set to priority 1 
			NVIC_IPR3 |= (1<<14);			//UART1 = set to priority 1 
		break;

		 case 8:
			NVIC_IPR2 |= (1<<6);				//TMR0 = set to priority 1 
			NVIC_IPR2 |= (1<<14);			//TMR1 = set to priority 1 
			NVIC_IPR2 |= (1<<22);			//TMR2 = set to priority 1 
			NVIC_IPR2 |= (1<<30);			//TMR3 = set to priority 1 
		break;
	 
		case 9:
			NVIC_IPR2 |= (1<<6);			//TMR0 = set to priority 1 
			NVIC_IPR2 |= (1<<14);			//TMR1 = set to priority 1 
			NVIC_IPR2 |= (1<<22);			//TMR2 = set to priority 1 
			NVIC_IPR2 |= (1<<30);			//TMR3 = set to priority 1 
      NVIC_IPR3 |= (1<<7);			//UART0 = set to priority 2 
			NVIC_IPR3 |= (1<<15);			//UART1 = set to priority 2 
			NVIC_IPR3 |= (1<<31);			//SPI1 = set to priority 2 
			NVIC_IPR5=0xc0c0c0c0;     // Does nothing as far as I can tell
			NVIC_IPR6=0xc0c0c0c0;			// ACMP_INT = 3
		break;
		case 10:
			NVIC_IPR0=0xc0c00000;			// EINTO = EINT1 = 3
			NVIC_IPR1=0xc0c00000;			// PWMA_INT = PWMB = 3
			NVIC_IPR2=0x40404000;			// TMR1 = TMR2 = TMR3 = 1
			NVIC_IPR3=0x00c0c0c0;     // UART0 = UART1 = SPI0 = 3
			NVIC_IPR4=0xc0c0c0c0;     // i2c = 3
			NVIC_IPR6=0xc0c0c0c0;			// ACMP_INT = 3
			NVIC_IPR7=0xc0c04000;			// ADC = 1
		 break;


	 }
   
   
   
   }

