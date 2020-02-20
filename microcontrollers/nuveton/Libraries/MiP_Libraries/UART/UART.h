/*---------------------------------------------------------------------------------------------------------*/
/*                          Program Written By: SAAM OSTOVARI and Nick Morozovsky                          */
/*																			NDA SD2013-802																				     			   */
/*---------------------------------------------------------------------------------------------------------*/


#ifndef __UART_H__
#define __UART_H__

//int parseUART0buffer(float joy[]);						// parse UART0 buffer and set command variables
int parseUART0buffer(float joy[]);						// parse UART0 buffer and set command variables
void Init_Uart0(uint32_t BaudRate);					//Function to set up and initialize UART0. Must pass desired Baud Rate to this function
void UART0_IRQHandler(void);								//UART0 Interrupt called everytime data is recieved by UART1. It prints data out through UART0
//void Init_Uart1(uint32_t BaudRate);					//Function to set up and initialize UART1. Must pass desired Baud Rate to this function
//void UART1_IRQHandler(void);								//UART1 Interrupt called everytime data is recieved by UART1. It prints data out through UART1

#endif
