/*---------------------------------------------------------------------------------------------------------*/
/*                          Program Written By: SAAM OSTOVARI                                              */
/*																			NDA SD2013-802																				     			   */
/*---------------------------------------------------------------------------------------------------------*/


#ifndef __GPIO_H__
#define __GPIO_H__

void Init_GPIO_Output( int port, int pin );													//Setup GPIO Ports as Outputs.  Init_GPIO_OUTPUT( PORT# , PIN# )
void Init_GPIO_Input( int port, int pin );													//Setup GPIO Ports as Inputs.  Init_GPIO_Input( Port# , Pin# )
void digitalWrite (int port, int pin , int value);									//Write GPIO Output to Pin. digitalWrite( Port# , Pin# , State ) 
int digitalRead (int port, int pin );																//Read GPIO Input on Pin.  digitalRead( Port# , Pin3 )

#endif
