/*---------------------------------------------------------------------------------------------------------*/
/*                          Program Written By: SAAM OSTOVARI and Nick Morozovsky                          */
/*																			NDA SD2013-802																				     			   */
/*---------------------------------------------------------------------------------------------------------*/
/*								Please pay attention to the format of the value you are getting from the buffer 				 */		
/*															as well as the format in which you are printing it out										 */	
/*---------------------------------------------------------------------------------------------------------*/

//Including Nuvoton Libraries
#include <stdio.h>
#include <stdint.h>
#include "M051.h"
#include "Register_Bit.h"
#include "Common.h"
#include "Retarget.h"
//Including MiP Libraries
#include "UART.h"
#include "..\Robot_Values\Robot_Values.h"
#include "..\System_Clock\System_Clock.h"

unsigned long RX0Data[UART0BytesSent] = {0};						//UART0BytesSent is a value set in Robot Values that signifies the number of bytes that will be sent by UART0
//uint16_t RX1Data[UART1BytesSent] = {0};						//UART1BytesSent is a value set in Robot Values that signifies the number of bytes that will be sent by UART1
int count0 = 0;
float timestamp0 = 0;
//int count1 = 0;
//int jj;

/////////////////////////////////////////////////////////////////////////////////////////////////////////
// parse UART0 buffer and set command variables

/*int parseUART0buffer(float joy[])
{
	
	// checksum is calculated by adding message bytes, chopping off overflow bits, and taking the 2's complement (subtracting from 2^8 = 256)
	// check checksum by adding all bytes, chopping off overflow bits, and comparing to 0
	int checksum = 0;
	for (jj = 0; jj < UART0BytesSent; jj++)
		checksum = checksum + (int) RX0Data[jj];
	checksum = checksum & 0xFF;
	if (checksum == 0) // checks out
	{
		for (jj = 0; jj < 4; jj++)
			joy[jj] = ((float)(((int) RX0Data[1+jj]) - JOYSTICK_ZERO)) / JOYSTICK_SCALE;
		return (int) RX0Data[0];
	}
	else // checksum doesn't match, don't update joysticks or button
		return 0; // means no button pressed
} //*/

/////////////////////////////////////////////////////////////////////////////////////////////////////////
// parse UART0 buffer and set command variables

int parseUART0buffer(float joy[])
{
	int button = 0;
	joy[0] = 0;
	joy[1] = 0;
	joy[3] = 0;
	
	/*for (jj = 0; jj < UART0BytesSent; jj++)
		printf("%lu\t", RX0Data[jj]);
	printf("\n");//*/
	
	if (millis() - timestamp0 < UART_TIMEOUT)
		switch(RX0Data[0])
		{
			case 0x50: // push to talk has been pressed
				printf("P");
				break;
			case 0x65: // emergency stop
				button = 6;
				break;
			case 0x66: // reset emergency stop
				button = 8;
				break;
			case 0x78: // drive, any mode
				// 0 is stop, 01-32 is forward, 33-64 is backwards
				// 0 is straight, 65-96 is right, 97-128 is left
				if (RX0Data[1] > 0) // not stopped
				{
					if (RX0Data[1] < 33) // forward
						joy[1] = ((float) RX0Data[1]) / 32.0;
					else if (RX0Data[1] < 65)// backward
						joy[1] = -((float) (RX0Data[1] - 32)) / 32.0;
				}
				if (RX0Data[2] > 64) // not straight
				{
					if (RX0Data[2] < 97) // right
						joy[0] = ((float) (RX0Data[2] - 64)) / 32.0;
					else if (RX0Data[2] < 129)// left
						joy[0] = -((float) (RX0Data[2] - 96)) / 32.0;
				}
				
				//joy[0] = ((float)(((int) RX0Data[2]) - JOYSTICK_ZERO)) / JOYSTICK_SCALE;
				//joy[1] = ((float)(((int) RX0Data[1]) - JOYSTICK_ZERO)) / JOYSTICK_SCALE;
				break;
			case 0x63: // lean, any mode
				joy[3] = ((float)(((int) RX0Data[1]) - JOYSTICK_ZERO)) / JOYSTICK_SCALE;
				break;
			case 0x62: // kneel, mode 3
				button = 3;
				break;
			case 0x61: // stand, mode 4
				button = 4;
				break;
			case 1:
				button = 1; // lock joints in current position, manual tread driving
				break;
			case 2:
				button = 2; // balance with current joint positions
				break;
		}
	
	//printf("%lu\t%lu\t%f\t%f\n",RX0Data[1],RX0Data[2],joy[0],joy[1]);
	return button;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//Function to set up and initialize UART0. Must pass desired Baud Rate to this function
//Use printf to output over UART0

void Init_Uart0(uint32_t BaudRate)
{
	/* Step 1. Set specific GPIOs to UART */ 
   P3_MFP &= ~(P31_TXD0 | P30_RXD0);   
   P3_MFP |= (TXD0 | RXD0);    					//P3.0 --> UART0 RX and P3.1 --> UART0 TX
	/* Step 2. Enable and Select UART clock sources*/
   APBCLK |= UART0_CLKEN;  							// Enable UART0 clock
	 CLKSEL1 = ((CLKSEL1 & (~UART_CLK)) | UART_12M); //Set Uart clock source to 2MHz External clock
	 CLKDIV &= ~(15<<8); 	       					//UART Clock DIV Number = 0;
	/* Step 3. Select Operation mode */
   IPRSTC2 |= UART0_RST;   							//Reset UART0
   IPRSTC2 &= ~UART0_RST; 							//Reset end
   UA0_FCR |= TX_RST;      							//Tx FIFO Reset
   UA0_FCR |= RX_RST;      							//Rx FIFO Reset
	 UA0_LCR &= ~PBE;     	 							//Parity Bit Disable
	 UA0_LCR &= ~WLS;
   UA0_LCR |= WL_8BIT;     							//8 bits Data Length 
   UA0_LCR &= NSB_ONE;     							//1 stop bit
 /* Step 4. Set BaudRate to 115200*/
   UA0_BAUD |= DIV_X_EN;   							//Mode2:DIV_X_EN = 1
   UA0_BAUD |= DIV_X_ONE;  							//Mode2:DIV_X_ONE = 1
	/* For XTAL = 12 MHz */	
   UA0_BAUD |= ((12000000 / BaudRate) -2);	//Set BaudRate to 115200;  UART_CLK/(A+2) = 115200, UART_CLK=12MHz
  /* Enable Interrupt */ 								//Hardware interrupt for UART to know when it is getting data and when it finish. a heads up signal 
	 UA0_IER	|= (RDA_IEN);
	 NVIC_ISER |= UART0_INT;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//UART0 Interrupt called everytime data is recieved by UART1. It prints data out through UART0

 void UART0_IRQHandler(void)
{
	int UART0BuffCount=0;
	int UART0BuffEmpty=1;

	UART0BuffCount = (((UA0_FSR)<<18)>>26);												//Outputs the number of bytes in the UART1 RX buffer
	if(UART0BuffCount>=UART0BytesSent){count0=1; timestamp0 = millis();}
	//printf("%d\n",UART0BuffCount);
	
	if(count0==1){
		//printf("Buff Count: %d\t\t",UART0BuffCount);
		RX0Data[UART0BytesSent-UART0BuffCount] = UA0_RBR;												//Reads the oldest byte of data in the buffer. 		  		
		//printf("UART0 Data: %lu\t\t", RX0Data[UART0BytesSent-UART0BuffCount]);
		//printf("%lu\n",RX0Data[UART0BytesSent-UART0BuffCount]);
		UART0BuffEmpty = ((UA0_FSR & RX_EMPTY)>>14);								//Outputs 1 when buffer is empty
		//printf("Empty(y=1,n=0): %d\n",UART0BuffEmpty);
		if(UART0BuffEmpty ==1){count0=0;}
	}
}

/* UART1 commented out to try to save space
/////////////////////////////////////////////////////////////////////////////////////////////////////////
//Function to set up and initialize UART1. Must pass desired Baud Rate to this function
//A write function still needs to be written. printf does not work with UART1

void Init_Uart1(uint32_t BaudRate)
{
	// Step 1. Set specific GPIOs to UART
   P1_MFP &= ~(P13_AIN3_TXD1 | P12_AIN2_RXD1);   
   P1_MFP |= (TXD1 | RXD1);    				//P3.0 --> UART0 RX and P3.1 --> UART0 TX
	// Step 2. Enable and Select UART clock sources
   APBCLK |= UART1_CLKEN;  						// Enable UART0 clock
	 CLKSEL1 = ((CLKSEL1 & (~UART_CLK)) | UART_12M); //Set Uart clock source to 2MHz External clock
	 CLKDIV &= ~(15<<8); 	       				//UART Clock DIV Number = 0;
	// Step 3. Select Operation mode
   IPRSTC2 |= UART1_RST;   						//Reset UART0
   IPRSTC2 &= ~UART1_RST; 						//Reset end
   UA1_FCR |= TX_RST;      						//Tx FIFO Reset
   UA1_FCR |= RX_RST;      						//Rx FIFO Reset
	 UA1_LCR &= ~PBE;     	 						//Parity Bit Disable
	 UA1_LCR = (UA1_LCR & (~WLS)) | WL_8BIT;  //8 bits Data Length
   UA1_LCR &= NSB_ONE;                      //1 stop bit
 // Step 4. Set BaudRate to 115200
   UA1_BAUD |= DIV_X_EN;   						//Mode2:DIV_X_EN = 1
   UA1_BAUD |= DIV_X_ONE;  						//Mode2:DIV_X_ONE = 1
	// For XTAL = 12 MHz 
   UA1_BAUD |= ((12000000 / BaudRate) -2);	//Set BaudRate to 115200;  UART_CLK/(A+2) = 115200, UART_CLK=12MHz
  // Enable Interrupt 							//hardware interrupt for uart to know when it is getting data and when it finish. a heads up signal 
	 UA1_IER	|= (RDA_IEN);
	 NVIC_ISER |= UART1_INT;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//UART1 Interrupt called everytime data is recieved by UART1. It prints data out through UART0
 
void UART1_IRQHandler(void)
{
 	int UART1BuffCount=0;
	int UART1BuffEmpty=1;

	UART1BuffCount = (((UA1_FSR)<<18)>>26);												//Outputs the number of bytes in the UART1 RX buffer
	if(UART1BuffCount>=UART1BytesSent){count1=1;}
	
	if(count1==1){
		printf("Buff Count: %d\t\t",UART1BuffCount);
		RX1Data[(UART1BuffCount)] = UA1_RBR;												//Reads the oldest byte of data in the buffer. 		  		
		printf("UART1 Data: %d\t\t", RX1Data[(UART1BuffCount)]);
		UART1BuffEmpty = ((UA1_FSR & RX_EMPTY)>>14);								//Outputs 1 when buffer is empty
		printf("Empty(y=1,n=0): %d\n",UART1BuffEmpty);
		if(UART1BuffEmpty ==1){count1=0;}
	}
} //*/

/*/////////////////////////////////////////////////////////////////////////////////////////////////////////
//ALTERNATE 
UART1 Interrupt called everytime data is recieved by UART1. It prints data out through UART0
void UART1_IRQHandler(void)
{
 	int UART1BuffCount=0;
	int UART1BuffEmpty=1;
	int i=0;

	printf("\n-------------INTERRUPT TRIPPED-------------\n");
	UART1BuffCount = (((UA1_FSR)<<18)>>26);							//Outputs the number of bytes in the UART1 RX buffer
	printf("Buff Count: %d\t\t",UART1BuffCount);
	RXData[(UART1BuffCount)] = UA1_RBR;													//Reads the oldest byte of data in the buffer. 		  		
	printf("UART1 Data: %d\t\t", RXData[(UART1BuffCount)]);
	UART1BuffEmpty = ((UA1_FSR & RX_EMPTY)>>14);				//Outputs 1 when buffer is empty
	printf("Empty(y=1,n=0): %d\n",UART1BuffEmpty);
}
*/
