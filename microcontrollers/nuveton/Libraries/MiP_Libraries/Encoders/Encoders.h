/*---------------------------------------------------------------------------------------------------------*/
/*                          Program Written By: SAAM OSTOVARI and Nick Morozovsky                          */
/*																			NDA SD2013-802																				     			   */
/*---------------------------------------------------------------------------------------------------------*/


#ifndef __Encoders_H__
#define __Encoders_H__

void Init_Encoders(void);													//Initialize External Interuppts which Initalizes Encoder Readings
void Init_Port0_Ext_Int(void);										//Setting Up External Interrupt on P0.0 and set P0.1 as an input for Quadrature Encoder
void Init_Port4_Ext_Int(void);										//Setting Up External Interrupt on P4.4 and set P4.5 as an input for Quadrature Encoder
float Encoder_Update(void);												//Update Encoder Variable with New Encoder Values. Averages Left and Right Encoder Counts
void reset_Encoder(void);													//Reset Encoder Variables for Safeties
float encVelWMA_R(void);														// Encoder velocity estimation using weighted moving average filter
float encVelWMA_L(void);														// Encoder velocity estimation using weighted moving average filter
float encVelLP_R(void);														// Encoder velocity estimation using low pass filter
float encVelLP_L(void);														// Encoder velocity estimation using low pass filter
float get_encoderLcount(void);											//Functions to Return Left Encoder Total Count 
float get_encoderRcount(void);											//Functions to Return Right Encoder Total Count
void Outputs4Debugging_Encoders(void);						//Function to Print Out Debugging Info for Encoders
void GPIOP0P1_IRQHandler(void);										//Port0,1 Interrupt Function
void GPIOP2P3P4_IRQHandler(void);									//Port2,3,4 Interrupt Function

#endif
