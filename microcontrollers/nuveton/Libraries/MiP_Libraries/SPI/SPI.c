/*---------------------------------------------------------------------------------------------------------*/
/*                          Program Written By: SAAM OSTOVARI and Nick Morozovsky                          */
/*																		NDA SD2013-802																					     			   */
/*---------------------------------------------------------------------------------------------------------*/


//Including Nuvoton Libraries
#include <stdio.h>
#include <stdint.h>
#include <math.h>
#include "M051.h"
#include "Register_Bit.h"
#include "Common.h"
#include "Retarget.h"
#include "Macro_SystemClock.h"
#include "Macro_Timer.h"
//Including MiP Libraries
#include "SPI.h"
#include "..\Robot_Values\Robot_Values.h"

/////////////////////////////////////////////////////////////////////////////////////////////////////////                                                                                      
/////////////////////////////////////////////////////////////////////////////////////////////////////////                                                                                      
//Setup Timer 0 and place into period mode.                                    
void Timer0_Init(void)
{
    TMR0_Clock_EN;
	  TMR0ClkSource_ex12MHz;
    TCSR0  = 0x00000000;    //Pre-Scaler
    setTMR0_PERIOD;
    setTMR0_IE;             //Timer0 interrupt enable
    setTMR0_CRST;           //Reset the timer/counter0, after set, this bit will be clear by H/W
}
//Setup Timer 0 for use as a delay function. This function was copied directly from Nuvoton Code
void TMR0_Delay1ms(uint32_t ulCNT)
{
    TCMPR0 = 120;         //Fosc=12MHz, so 12000000/120=100000Hz=.00001s
    setTMR0_CEN;            //Start timer0
    while (ulCNT != 1)
    {
        while ((TISR0&TMR_TIF) != TMR_TIF); //check TIF0
        TISR0 |= TMR_TIF;   //Clear TIF0
        ulCNT --;
    }
    clrTMR0_CEN;            //Stop timer0
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//Initalizing SPI on Arm M0 Chip
void Init_SPI(void)
{
  P0_MFP &= ~(P04_AD4_SPI1SS | P05_AD5_SPI1MOSI | P06_AD6_SPI1MISO | P07_AD7_SPI1CLK) ;  		//Set Port pins to SPI1 Pins 
	P0_MFP |= (SPI1SS |	SPI1MOSI |  SPI1MISO | SPI1CLK) ;   																	//Set Port pins to SPI1 Pins 
	APBCLK |= SPI1_CLKEN;           	//Enable SPI1 clock
	IPRSTC2 |= SPI1_RST; 							//SPI1 Controller reset
	IPRSTC2 &= ~SPI1_RST;							//SPI1 Controller reset
	SPI1_SSR &= ~LVL_H;        				//Slave select signal is active fat low-level/falling edge (i.e SS_LVL = 0 ) 
	SPI1_CNTRL &= ~LSB_FIRST; 				//MSB Transmitted/Received first (i.e. bit set to 0)
	SPI1_CNTRL &= ~CLKP_IDLE_H;    		//SPI clock idle set to low
	SPI1_CNTRL |= TX_NEG_F;     			//The transmit data input (SDO signal) is changed at the falling edge (i.e Tx_NEG = 1)
	SPI1_CNTRL &= ~RX_NEG_F;     			//The recieve data input (SDI signal) is latched at the rising edge (i.e Rx_NEG = 0)
 
	 /* Setting Up SPI Clock Speed*/
	CLKDIV &= 0xFFFFFFF0;             //Setting HCLK_N = 0 , Note1: Pclk = SYSclk/(HCLK_N+1) , 	Note2: SYSclk=48000000Hz , Note3: This changes divider value for UART, ADC.. etc. See data sheet
	SPI1_DIVIDER &= 0xFFFF0000;       //Setting SPI Master Divider value to 0. Note: SPI clock source = Pclk/((Divider+1)*2)
	SPI1_DIVIDER |= 0x17;							//Setting SPI Master Divider value to 23. Note: SPI clock source = Pclk/((Divider+1)*2). SPI Clock Speed set to 1MHz

  SPI1_CNTRL |= (1<<7);	            //Setting up number of bits transmitted in one SPI transaction. Set to transmit 16bits (i.e 2 Bytes)
  SPI1_CNTRL &= ~SPI_MODE_SLAVE;	  //Set SPI1 master mode
  SPI1_SSR |= ASS_AUTO;           	//Enable SPI1 auto slave select
  SPI1_SSR |= SSR_ACT;		        	//Auto Chip Slave Select Register on SPI1.0, SPI1.1
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//SPI Write Function
uint8_t SPI_SingleWrite(uint32_t SPIRawData)
{                                                                                               	
	  if((SPI1_CNTRL & GO_BUSY) != 0){return false;}		// if false is returned then SPI is busy. The data has not been transferred.

		SPI1_CNTRL &= TX_NUM_ONE;     										//Setting SPI to only do one Tx0/Rx0 (i.e. single write mode)
		SPI1_TX0 = SPIRawData;														//Setting the data to be written in the appropriate register. Note: this register can take up to 32bits but must be set to expect 32bits in SPI_CNTRL register
    SPI1_CNTRL |= GO_BUSY;     	  										//Start transfer by setting this bit to 1. Will automatically reset itself to 0 when the transmit is complete
		return true;																			// if true is returned then data has been transferred.
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//Function for checking if SPI is busy transmitting data
uint8_t SPI_IsBusy(void)
{  
	if((SPI1_CNTRL & GO_BUSY) != 0)
		{return true;} //SPI port is busy
	else
		{return false;} //SPI port is not busy
}

////////////////////////////////////////////////////////////////////////////////////////////////////////
//Function that does an SPI write and waits for SPI to complete
void SPI_WriteAndWait(uint32_t SPIRawData)
{
	 SPI_SingleWrite(SPIRawData);
	 while(SPI_IsBusy()){} //Continously checks till SPI1 is not busy meaning that SPI1 has completed transfer
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//SPI Read Function
float SPI_Read(uint32_t SPIRawData){
	  float SPIReadData = 0;
	
	  if((SPI1_CNTRL & GO_BUSY) != 0){return 0;}		// if false is returned then SPI is busy. The data has not been transferred.

 	  SPI_WriteAndWait(SPIRawData);
		SPIReadData = SPI1_RX0;

			return SPIReadData;// if true is returned then data has been transferred.
		}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//SPI Read for MPU-6880 IMU
float SPI_Sensor_Read(uint16_t low_byte_address, uint16_t high_byte_address,int8_t sensor_type){
	//Declaring local variables and 	
	uint8_t HighRxRawData = 0;
	uint8_t LowRxRawData = 0;
	uint16_t Unsigned_Read_Data = 0;
	int16_t Signed_Read_Data = 0;
	float SPIReadData = 0;

	if((SPI1_CNTRL & GO_BUSY) != 0){return false;}		// if false is returned then SPI is busy. The data has not been transferred.

	//Read Sensor Low Byte
  SPI_WriteAndWait(low_byte_address);									//Write to IMU to get Low Byte data back
	//TMR0_Delay1ms(5);									//Pausing for less than 1ms
	LowRxRawData = SPI1_RX0;						//Read IMU Data stored in SPI recieve register
	//TMR0_Delay1ms(5);									//Pausing for less than 1ms
			
	//Read Sensor High Byte
  SPI_WriteAndWait(high_byte_address);									//Write to IMU to get High Byte data back
	//TMR0_Delay1ms(5);									//Pausing for less than 1ms
  HighRxRawData = SPI1_RX0;						//Read IMU Data stored in SPI recieve register
			
  //Combining high byte and low byte data into one 16bit value
	Unsigned_Read_Data |=  (HighRxRawData << 8);
	Unsigned_Read_Data |=  (LowRxRawData);
	Signed_Read_Data = (int16_t) Unsigned_Read_Data;   //Casting unsigned int as signed int
	
	//Converting Raw data into correct units for the specific sensor. Note: a signed int is divided by a float to equal a float
	if(sensor_type == 0){SPIReadData = Signed_Read_Data/AccelSensitivity;}
	else{SPIReadData = (Signed_Read_Data/GyroSensitivity);}

	return SPIReadData;	
	}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//SPI Read for MPU-6880 IMU
long SPI_Sensor_Read_Int(uint16_t low_byte_address, uint16_t high_byte_address){
	//Declaring local variables and 	
	uint8_t HighRxRawData = 0;
	uint8_t LowRxRawData = 0;
	uint16_t Unsigned_Read_Data = 0;
	int16_t Signed_Read_Data = 0;

	if((SPI1_CNTRL & GO_BUSY) != 0){return false;}		// if false is returned then SPI is busy. The data has not been transferred.

	/*Read Sensor Low Byte*/
  SPI_WriteAndWait(low_byte_address);									//Write to IMU to get Low Byte data back
	//TMR0_Delay1ms(5);									//Pausing for less than 1ms
	LowRxRawData = SPI1_RX0;						//Read IMU Data stored in SPI recieve register
	//TMR0_Delay1ms(5);									//Pausing for less than 1ms
			
	/*Read Sensor High Byte*/
  SPI_WriteAndWait(high_byte_address);									//Write to IMU to get High Byte data back
	//TMR0_Delay1ms(5);									//Pausing for less than 1ms
  HighRxRawData = SPI1_RX0;						//Read IMU Data stored in SPI recieve register
			
	//printf("%u\t", HighRxRawData);
	//printf("%u\t", LowRxRawData);
	
  /*Combining high byte and low byte data into one 16bit value */
	Unsigned_Read_Data |=  (HighRxRawData << 8);
	//printf("%u\t", Unsigned_Read_Data);
	Unsigned_Read_Data |=  (LowRxRawData);
	Signed_Read_Data = (int16_t) Unsigned_Read_Data;   //Casting unsigned int as signed int
	
	// either low byte or high byte is all zeros and other is large (negative)
	// if (low byte bitwise XOR high byte) < 252, update gyro
	
	/*printf("%u\t", Unsigned_Read_Data);
	printf("%d\t", Signed_Read_Data);
	printf("%u\t", (HighRxRawData ^ LowRxRawData));*/
	
	return Signed_Read_Data;	
	}
