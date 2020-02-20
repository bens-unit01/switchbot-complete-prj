/*---------------------------------------------------------------------------------------------------------*/
/*                          Program Written By: SAAM OSTOVARI and Nick Morozovsky                          */
/*																		NDA SD2013-802																					     			   */
/*---------------------------------------------------------------------------------------------------------*/


#ifndef __SPI_H__
#define __SPI_H__

//Declaring Variables for SPI
#define CLOCK_SETUP           1
#define CLOCK_EN              0xF
#define PLL_Engine_Enable     0 
#define PLL_SEL               0x00080000 
#define CLOCK_SEL             0x0
#define SPI_DIVIDER_EN        1
#define SPI0_DIVIDER_VALUE    0x00000002
#define SPI1_DIVIDER_VALUE    0x00000002

//Declaring Functions for SPI
void Timer0_Init(void);																					//Setup Timer 0 and place into period mode.                                    
void TMR0_Delay1ms(uint32_t ulCNT);															//Setup Timer 0 for use as a delay function. This function was copied directly from Nuvoton Code
void Init_SPI(void);																						//Initalizing SPI on Arm M0 Chip
uint8_t SPI_SingleWrite(uint32_t SPIRawData);										//SPI Write Function
uint8_t SPI_IsBusy(void);																				//Function for checking if SPI is busy transmitting data
void SPI_WriteAndWait(uint32_t SPIRawData);											//Function that does an SPI write and waits for SPI to complete
float SPI_Read(uint32_t SPIRawData);														//SPI Read Function
float SPI_Sensor_Read(uint16_t low_byte_address, uint16_t high_byte_address,int8_t sensor_type);				//SPI Read for MPU-6880 IMU
long SPI_Sensor_Read_Int(uint16_t low_byte_address, uint16_t high_byte_address);				//SPI Read for MPU-6880 IMU

#endif
