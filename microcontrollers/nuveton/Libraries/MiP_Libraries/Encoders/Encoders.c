/*---------------------------------------------------------------------------------------------------------*/
/*                          Program Written By: SAAM OSTOVARI and Nick Morozovsky                          */
/*																		NDA SD2013-802								  												     			   */
/*---------------------------------------------------------------------------------------------------------*/

//Including Nuvoton Libraries
#include <stdio.h>
#include <stdint.h>
#include "M051.h"
#include "Register_Bit.h"
#include "Common.h"
#include "Retarget.h"
//Including MiP Libraries
#include "Encoders.h"
#include "..\UART\UART.h"
#include "..\Robot_Values\Robot_Values.h"

//Declaring Encoder Variables
float encoderLcount = 0;
float encoderRcount = 0;
float encoderRcountOld = 0;
float encoderLcountOld = 0;
float encoderLvelWMA = 0;
float encoderRvelWMA = 0;
float encoderRvelLP = 0;
float encoderLvelLP = 0;
float encoderLold[] = {0,0,0};
float encoderRold[] = {0,0,0};
//int p00old = 0;
//int p01old = 0;
//int p44old = 0;
//int p45old = 0;

/////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////

//Initialize External Interuppts which Initalizes Encoder Readings
void Init_Encoders(void){
	Init_Port0_Ext_Int();													//Initialize External Interrupt on Port 0
	Init_Port4_Ext_Int();													//Initialize External Interrupt on Port 4
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////

//Setting Up External Interrupt on P0.0 and set P0.1 as an input for Quadrature Encoder
void Init_Port0_Ext_Int(void)
{
	//P0_MFP = (P0_MFP & (~P00_AD0_CTS1)) | P00;		//Set P0.0 as external interrupt function.
	P1_MFP = (P1_MFP & (~P12_AIN2_RXD1)) | P12;		//Set P1.2 as external interrupt function.
	P0_MFP = (P0_MFP & (~P01_AD1_RTS1)) | P01;		//Set P0.1 as external interrupt function.
	
	//P0_MFP |= P00_SCHMITT;     										//Initial Schmitt Trigger function on P0.0
	P1_MFP |= P12_SCHMITT;     										//Initial Schmitt Trigger function on P1.2
	P0_MFP |= P01_SCHMITT;     										//Initial Schmitt Trigger function on P0.1
	
	//P0_PMD |= Px0_PMD;	 			 										//Set P0.0 pin to Quasi-bidirectional mode
	P1_PMD |= Px2_PMD;	 			 										//Set P1.2 pin to Quasi-bidirectional mode
	P0_PMD |= Px1_PMD;	 			 										//Set P0.1 pin to Quasi-bidirectional mode
	//////P0_PMD |= Px1_IN;	 			 										//Set P0.1 pin to Input mode
	//////P0_PMD |= Px0_IN;	 			 										//Set P0.0 pin to Input mode
	
	/*P0_IMD &= IMD0_EDG;				 										//Set to Edge Trigger Interrupt
	P0_IEN |= IF_EN0;					 										//Set to Falling Edge Mode
	P0_IEN |= IR_EN0;				 	 										//Set to Rising Edge Mode */
	P0_IMD &= IMD1_EDG;				 										//Set to Edge Trigger Interrupt
	P0_IEN |= IF_EN1;					 										//Set to Falling Edge Mode
	P0_IEN |= IR_EN1;				 	 										//Set to Rising Edge Mode */
	//P00_DOUT |= 0x1;                    //Set P0.0 output value high 
	P12_DOUT |= 0x1;                    //Set P1.2 output value high 
	P01_DOUT |= 0x1;                    //Set P0.1 output value high
	NVIC_ISER |= GP01_INT;		 										//Enable GP01_INT Interrupts 
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////

//Setting Up External Interrupt on P4.4 and set P4.5 as an input for Quadrature Encoder
void Init_Port4_Ext_Int(void)
{
	P4_MFP = (P4_MFP & (~P44_CS )) | P44;					//Set up P4.4 as external interrupt function.										
	P4_MFP = (P4_MFP & (~P45_ALE)) | P45;					//Set up P4.5 as external interrupt function.
	P4_MFP |= P44_SCHMITT;     										//Initial Schmitt Trigger function on P4.4
	P4_MFP |= P45_SCHMITT;     										//Initial Schmitt Trigger function on P4.5
	P4_PMD |= Px4_PMD;	  												//Set P4.4 pins to Quasi-bidirectional mode
	P4_PMD |= Px5_PMD;	  												//Set P4.5 pins to Quasi-bidirectional mode
	P4_IMD &= IMD4_EDG;				  									//Set to Edge Trigger Interrupt	
	//P4_IMD &= IMD5_EDG;				  									//Set to Edge Trigger Interrupt							
	P4_IEN |= IF_EN4;			 	  										//Set to Falling Edge Mode
	P4_IEN |= IR_EN4;			 	  										//Set to Rising Edge Mode bidirectional mode
	//P4_IEN |= IF_EN5;			 	  										//Set to Falling Edge Mode
	//P4_IEN |= IR_EN5;			 	  										//Set to Rising Edge Mode
	P44_DOUT |= 0x1;                    //Set P4.4 output value high 
	P45_DOUT |= 0x1;                    //Set P4.5 output value high
	NVIC_ISER |= GP234_INT;	 	 										//Enable GP234_INT Interrupt
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////

//Update Encoder Variable with New Encoder Values. Averages Left and Right Encoder Counts
float Encoder_Update(){
  float encoder;
	encoder = (encoderLcount+encoderRcount)/2;  	//Using the Average of the Left and Right Encoder Values in the Estimator
  return encoder;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////

//Reset Encoder Variables for Safeties
void reset_Encoder(){
    encoderLcount=0; encoderRcount=0;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////

// Encoder velocity estimation using weighted moving average filter
float encVelWMA_R(void)
{
	encoderRvelWMA = ( 4*(encoderRcount-encoderRold[0])/dt + 2*(encoderRcount-encoderRold[1])/(2*dt) + (encoderRcount-encoderRold[2])/(3*dt) ) / 7;
  encoderRold[2] = encoderRold[1];
	encoderRold[1] = encoderRold[0];
  encoderRold[0] = encoderRcount;
  return encoderRvelWMA;
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////

// Encoder velocity estimation using weighted moving average filter
float encVelWMA_L(void)
{
	encoderLvelWMA = ( 4*(encoderLcount-encoderLold[0])/dt + 2*(encoderLcount-encoderLold[1])/(2*dt) + (encoderLcount-encoderLold[2])/(3*dt) ) / 7;
  encoderLold[2] = encoderLold[1];
	encoderLold[1] = encoderLold[0];
  encoderLold[0] = encoderLcount;
  return encoderLvelWMA;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////

// Encoder velocity estimation using weighted moving average filter
float encVelLP_R(void)
{
	encoderRvelLP = encoderRvelLP + encVelLPC*((encoderRcount-encoderRcountOld)/dt - encoderRvelLP);
	encoderRcountOld = encoderRcount;
  return encoderRvelLP;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////

// Encoder velocity estimation using weighted moving average filter
float encVelLP_L(void)
{
	encoderLvelLP = encoderLvelLP + encVelLPC*((encoderLcount-encoderLcountOld)/dt - encoderLvelLP);
	encoderLcountOld = encoderLcount;
  return encoderLvelLP;
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////

//Functions to Return Specific Values
float get_encoderLcount(void){return encoderLcount;}
float get_encoderRcount(void){return encoderRcount;}

/////////////////////////////////////////////////////////////////////////////////////////////////////////

//Function to Print Out Debugging Info for Encoders
void Outputs4Debugging_Encoders(void)
{
	printf("%f\t%f\t",encoderRcount,encoderLcount);
	//printf("%f\t%f\t",encoderRvelWMA,encoderLvelWMA);
	printf("%f\t%f\t",encoderRvelLP,encoderLvelLP);
	//printf("%f\t%f\t",encoderLcount,encoderLvelLP);
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
////INTERUPT FUNCTIONS

//Port0,1 Interrupt Function
void GPIOP0P1_IRQHandler(void)
{
	//int Port0Pin0Value;
	int Port0Pin1Value;
	int Port1Pin2Value;
	int Raw_Digital0_Value;
	int Raw_Digital1_Value;
	
	P0_ISRC = P0_ISRC;														//Notifies processer that Interrupt has triggered	
	//printf("interrupt\n");
	//Reading the digital lines to see if they are high or low
	Raw_Digital0_Value = P0_PIN;
	Raw_Digital1_Value = P1_PIN;
	//Port0Pin0Value = ((Raw_Digital0_Value>>0) & 0x01);	 
	Port1Pin2Value = ((Raw_Digital1_Value>>2) & 0x01);
	Port0Pin1Value = ((Raw_Digital0_Value>>1) & 0x01);	 
	
	// 4x encoding
	/*if (p01old ^ Port0Pin0Value) // Aold XOR B
		encoderLcount -= Ticks2Rads * LEncDir; // decrement
	else
		encoderLcount += Ticks2Rads * LEncDir; // increment
	
	p01old = Port0Pin1Value; // A
	//p00old = Port0Pin0Value; // B
	//*/
	
	//printf("%d\t%d\n",Port0Pin0Value,Port0Pin1Value);
	//if (Port0Pin0Value == 0)
		//printf("%d\n",0);
	
	// 2x encoding
	//if Encoder channels read the same then count up. If they are not the same, count down
  //if (Port0Pin0Value == Port0Pin1Value)
  if (Port1Pin2Value == Port0Pin1Value)
    encoderLcount -= Ticks2Rads * LEncDir;
  else
		encoderLcount += Ticks2Rads * LEncDir; //*/     
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////

//Port2,3,4 Interrupt Function
void GPIOP2P3P4_IRQHandler(void)
{
	int Port4Pin4Value;
	int Port4Pin5Value;
	int Raw_Digital4_Value;
	
	P4_ISRC = P4_ISRC; 		 												//Notifies processer that Interrupt has triggered
	//printf("interrupt\n");
	//Reading the digital lines to see if they are high or low
	Raw_Digital4_Value = P4_PIN;
	Port4Pin4Value = ((Raw_Digital4_Value>>4) & 0x01);	 
	Port4Pin5Value = ((Raw_Digital4_Value>>5) & 0x01);	 
	
	// 4x encoding
	/*if (p44old ^ Port4Pin5Value) // Aold XOR B
		encoderRcount -= Ticks2Rads * REncDir; // decrement
	else
		encoderRcount += Ticks2Rads * REncDir; // increment
	
	p44old = Port4Pin4Value; // A
	//p45old = Port4Pin5Value; // B
	//*/

	// 2x encoding
  //if Encoder channels read the same then count down. If they are not the same, count up
  if (Port4Pin4Value == Port4Pin5Value)
    {encoderRcount -= Ticks2Rads * REncDir;}   
  else{encoderRcount += Ticks2Rads * REncDir;} //*/ 
}
