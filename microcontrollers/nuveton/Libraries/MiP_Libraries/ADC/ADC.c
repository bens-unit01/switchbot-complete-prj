/*---------------------------------------------------------------------------------------------------------*/
/*                          Program Written By: SAAM OSTOVARI and Nick Morozovsky                          */
/*																		NDA SD2013-802																	  									 */
/*---------------------------------------------------------------------------------------------------------*/

//Including Nuvoton Libraries
#include <stdio.h>
#include <stdint.h>
#include "M051.h"
#include "Register_Bit.h"
#include "Common.h"
#include "retarget.h"
//Including MiP Libraries
#include "ADC.h"
#include "..\UART\UART.h"
#include "..\Robot_Values\Robot_Values.h"


//Declaring Variables for ADC
#define ADC_Clock_Divider     0x00040000
int RawAnalogData[8];
int Run_Init_Only_Once = 0;
int Already_Init = 0;
int ADC_Activated[8] = {0,0,0,0,0,0,0,0};

/////////////////////////////////////////////////////////////////////////////////////////////////////////

//Setting Up Analog to Digital Converter to Continuous Mode. ADC is 12bit
void Init_ADC(int ADC_Pin)
	{
		if (Already_Init == 0){
			// Reset ADC. Recommended by ARM Tech. Manual 
			IPRSTC2 |= (1<<28);                           //ADC block reset        		                        		
			IPRSTC2 &= ~(1<<28);													//ADC block normal operation

			APBCLK |= (1<<28);														//Enable ADC clock
			CLKSEL1 = ((CLKSEL1 & (~ADC_CLK)) | ADC_12M);	//Set External Clock as ADC clock source
			CLKDIV = ADC_Clock_Divider;    								//Set ADC divisor
			ADCR |= (1<<0);																//Enable ADC
	
			//Self Calibration Enable
			ADCALR |= CALEN;				
			while(!(ADCALR&CALDONE));
        
			// Continuous scan mode 
			ADCR &= ~ADMD;
			ADCR |= MD_CON_SCN;                    
			// Single end input 
			ADCR &= ~DIFFEN;

			Already_Init =1;															//Prevents everything in if statement from being set multiples times. Would cause problems without this
		}
		
	switch (ADC_Pin)
		{
		case 0:		
			//Setup ADC channel AIN0
			ADCHER |= CHEN0; 															//Enable Analog input channel 0
			P1_MFP &= ~P10_AIN0_T2;												//Set P10 as ADC0 input
			P1_MFP |= AIN0;																//Set P10 as ADC0 input
			P1_OFFD &= ~OFFD0;														//Disable P1.0 digital input path
			P1_OFFD |= OFFD0; 														//Disable P1.0 digital input path
			P1_PMD &= ~Px0_PMD; 													//Set P1.0 input mode 
			P1_PMD |= Px0_IN; 														//Set P1.0 input mode 
			ADC_Activated[0] = 1;													//AIN0 has been initialized											
			break;
		
		case 1:		
			//Setup ADC channel AIN1   
			ADCHER |= CHEN1; 															//Enable Analog input channel 1
			P1_MFP &= ~P11_AIN1_T3;												//Set P11 as ADC1 input
			P1_MFP |= AIN1;																//Set P11 as ADC1 input	
			P1_OFFD &= ~OFFD1;														//Disable P1.1 digital input path
			P1_OFFD |= OFFD1;															//Disable P1.1 digital input path
			P1_PMD &= ~Px1_PMD; 													//Set P1.1 input mode
			P1_PMD |= Px1_IN; 														//Set P1.1 input mode
			ADC_Activated[1] = 1;													//AIN1 has been initialized
			break;
	 
		case 2:		
			//Setup ADC channel AIN2   
			ADCHER |= CHEN2; 															//Enable Analog input channel 2
			P1_MFP &= ~P12_AIN2_RXD1;											//Set P11 as ADC1 input
			P1_MFP |= AIN2;																//Set P11 as ADC1 input	
			P1_OFFD &= ~OFFD2;														//Disable P1.1 digital input path
			P1_OFFD |= OFFD2;															//Disable P1.1 digital input path
			P1_PMD &= ~Px2_PMD; 													//Set P1.1 input mode
			P1_PMD |= Px2_IN; 														//Set P1.1 input mode
		  ADC_Activated[2] = 1;													//AIN2 has been initialized
			break;
	 
		case 3:		
			//Setup ADC channel AIN3
			ADCHER |= CHEN3; 															//Enable Analog input channel 3
			P1_MFP &= ~P13_AIN3_TXD1;											//Set P13 as ADC0 input
			P1_MFP |= AIN3;																//Set P13 as ADC0 input
			P1_OFFD &= ~OFFD3;														//Disable P1.3 digital input path
			P1_OFFD |= OFFD3; 														//Disable P1.3 digital input path
			P1_PMD &= ~Px3_PMD; 													//Set P1.3 input mode 
			P1_PMD |= Px3_IN; 														//Set P1.3 input mode 
		  ADC_Activated[3] = 1;													//AIN3 has been initialized
			break;

		case 4:		
			//Setup ADC channel AIN4   
			ADCHER |= CHEN4; 															//Enable Analog input channel 4
			P1_MFP &= ~P14_AIN4_SPI0SS;										//Set P14 as ADC1 input
			P1_MFP |= AIN4;																//Set P14 as ADC1 input	
			P1_OFFD &= ~OFFD4;														//Disable P1.4 digital input path
			P1_OFFD |= OFFD4;															//Disable P1.4 digital input path
			P1_PMD &= ~Px4_PMD; 													//Set P1.4 input mode
			P1_PMD |= Px4_IN; 														//Set P1.4 input mode
		  ADC_Activated[4] = 1;													//AIN4 has been initialized
			break;
	 
		case 5:		
			//Setup ADC channel AIN5
			ADCHER |= CHEN5; 															//Enable Analog input channel 5
			P1_MFP &= ~P15_AIN5_SPI0MOSI;									//Set P15 as ADC0 input
			P1_MFP |= AIN5;																//Set P15 as ADC0 input
			P1_OFFD &= ~OFFD5;														//Disable P1.5 digital input path
			P1_OFFD |= OFFD5; 														//Disable P1.5 digital input path
			P1_PMD &= ~Px5_PMD; 													//Set P1.5 input mode 
			P1_PMD |= Px5_IN; 														//Set P1.5 input mode 
		  ADC_Activated[5] = 1;													//AIN5 has been initialized
			break;

		case 6:		
			//Setup ADC channel AIN6   
			ADCHER |= CHEN6; 															//Enable Analog input channel 6
			P1_MFP &= ~P16_AIN6_SPI0MISO;									//Set P16 as ADC1 input
			P1_MFP |= AIN6;																//Set P16 as ADC1 input	
			P1_OFFD &= ~OFFD6;														//Disable P1.6 digital input path
			P1_OFFD |= OFFD6;															//Disable P1.6 digital input path
			P1_PMD &= ~Px6_PMD; 													//Set P1.6 input mode
			P1_PMD |= Px6_IN; 														//Set P1.6 input mode
			ADC_Activated[6] = 1;													//AIN6 has been initialized
			break;

		case 7:		
			//Setup ADC channel AIN7   
			ADCHER |= CHEN7; 															//Enable Analog input channel 7
			P1_MFP &= ~P17_AIN7_SPI0CLK;									//Set P17 as ADC1 input
			P1_MFP |= AIN7;																//Set P17 as ADC1 input	
			P1_OFFD &= ~OFFD7;														//Disable P1.7 digital input path
			P1_OFFD |= OFFD7;															//Disable P1.7 digital input path
			P1_PMD &= ~Px7_PMD; 													//Set P1.7 input mode
			P1_PMD |= Px7_IN; 														//Set P1.7 input mode
			ADC_Activated[7] = 1;													//AIN7 has been initialized
			break;
	
	}
   
	ADSR |= ADF;																			//Clear A/D Conversion End Flag       
	ADCR |= ADST;																			//Start A/D convert 
	//ADCR &= ~ADST;																		//Stop A/D convert
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////

//Update All Initialized Analog Pins
/*void UpdateAnalogRead(void)
{	
	while(ADSR&ADF==0);
	ADSR |= ADF;					// Clear A/D Conversion End Flag
	if( ADC_Activated[0] == 1){ RawAnalogData[0] = ADDR0&0xFFF; }
	if( ADC_Activated[1] == 1){ RawAnalogData[1] = ADDR1&0xFFF; }
  if( ADC_Activated[2] == 1){ RawAnalogData[2] = ADDR2&0xFFF; }
	if( ADC_Activated[3] == 1){ RawAnalogData[3] = ADDR3&0xFFF; }
	if( ADC_Activated[4] == 1){ RawAnalogData[4] = ADDR4&0xFFF; }
	if( ADC_Activated[5] == 1){ RawAnalogData[5] = ADDR5&0xFFF; }
	if( ADC_Activated[6] == 1){ RawAnalogData[6] = ADDR6&0xFFF; }
	if( ADC_Activated[7] == 1){ RawAnalogData[7] = ADDR7&0xFFF; }
}*/

/////////////////////////////////////////////////////////////////////////////////////////////////////////

//Get Updated Analog Value for Specified Pin. UpdateAnalogRead() must be called to update values. 
/*int analogRead(int analogRead_Pin)
{
 return RawAnalogData[analogRead_Pin];	
}*/

/////////////////////////////////////////////////////////////////////////////////////////////////////////

// read ADC pins for switchbot Pots
void readPots(float pots[])
{	
	while(ADSR&ADF==0);
	ADSR |= ADF;					// Clear A/D Conversion End Flag
	pots[0] =  (((long) (ADDR0&0xFFF)) - KNEER0)*POT2RAD;
	pots[1] = -(((long) (ADDR1&0xFFF)) - KNEEL0)*POT2RAD;  // V1 had a negative sign in front, V2 #1 didn't
	pots[2] = -(((long) (ADDR5&0xFFF)) - HIPR0)*POT2RAD;	 // V1 had no negative sign in front
	pots[3] =  (((long) (ADDR6&0xFFF)) - HIPL0)*POT2RAD;   // V1 had a negative sign in front
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////

//Function to Print Out Debugging Info for ADC
/*void Outputs4Debugging_ADC(void)
{
	if( ADC_Activated[0] == 1){ printf("%d\t",RawAnalogData[0]); }
	if( ADC_Activated[1] == 1){ printf("%d\t",RawAnalogData[1]); }
  if( ADC_Activated[2] == 1){ printf("%d\t",RawAnalogData[2]); }
	if( ADC_Activated[3] == 1){ printf("%d\t",RawAnalogData[3]); }
	if( ADC_Activated[4] == 1){ printf("%d\t",RawAnalogData[4]); }
	if( ADC_Activated[5] == 1){ printf("%d\t",RawAnalogData[5]); }
	if( ADC_Activated[6] == 1){ printf("%d\t",RawAnalogData[6]); }
	if( ADC_Activated[7] == 1){ printf("%d\t",RawAnalogData[7]); }
}*/
