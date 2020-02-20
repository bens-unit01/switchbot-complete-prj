/*---------------------------------------------------------------------------------------------------------*/
/*                          Program Written By: SAAM OSTOVARI                                              */
/*																		NDA SD2013-802			  																	     			   */
/*---------------------------------------------------------------------------------------------------------*/

//Including Nuvoton Libraries
#include <stdio.h>
#include <stdint.h>
#include "M051.h"
#include "Register_Bit.h"
#include "Common.h"
#include "Retarget.h"
//Including MiP Libraries
#include "GPIO.h"


/////////////////////////////////////////////////////////////////////////////////////////////////////////

//Setup GPIO Ports as Outputs.  Init_GPIO_OUTPUT( PORT# , PIN# )
void Init_GPIO_Output( int port, int pin )
{
	//The switch selects which port to set. Each case sets the specific pin on the port selected
	switch(port)
 {
	case 0:
		P0_PMD |= (1<<(2*pin));
		P0_PMD &= ~(1<<(2*pin+1));
		break;
	
	case 1:
		P1_PMD |= (1<<(2*pin));
		P1_PMD &= ~(1<<(2*pin+1));
		break;
	
	case 2:
		P2_PMD |= (1<<(2*pin));
		P2_PMD &= ~(1<<(2*pin+1));
		break;
	
	case 3:
		P3_PMD |= (1<<(2*pin));
		P3_PMD &= ~(1<<(2*pin+1));
		break;
	
	case 4:
		P4_PMD |= (1<<(2*pin));
		P4_PMD &= ~(1<<(2*pin+1));
		break;
 }
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////

//Setup GPIO Ports as Inputs.  Init_GPIO_Input( Port# , Pin# )
void Init_GPIO_Input( int port, int pin )
{
 //The switch selects which port to set. Each case sets the specific pin on the port selected	
 switch(port)
 {
	case 0:
		P0_PMD &= ~(1<<(2*pin));
		P0_PMD &= ~(1<<(2*pin+1));
		break;
	
	case 1:
		P1_PMD &= ~(1<<(2*pin));
		P1_PMD &= ~(1<<(2*pin+1));
		break;
	
	case 2:
		P2_PMD &= ~(1<<(2*pin));
		P2_PMD &= ~(1<<(2*pin+1));
		break;
	
	case 3:
		P3_PMD &= ~(1<<(2*pin));
		P3_PMD &= ~(1<<(2*pin+1));
		break;
	
	case 4:
		P4_PMD &= ~(1<<(2*pin));
		P4_PMD &= ~(1<<(2*pin+1));
		break;
 }
	
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////

//Write GPIO Output to Pin. digitalWrite( Port# , Pin# , State ) 
void digitalWrite(int port, int pin , int value)
{	
	//The if statements states whether it is being set to high or low. 
	//The switch selects which port to set. Each case sets the specific pin on the port selected
	if( value == 1){ 
		switch(port)
		{
			case 0:
				P0_DOUT |= (1<<pin);
				break;
	
			case 1:
				P1_DOUT |= (1<<pin);
				break;
	
			case 2:
				P2_DOUT |= (1<<pin);
				break;
	
			case 3:
				P3_DOUT |= (1<<pin);
				break;
	
			case 4:
				P4_DOUT |= (1<<pin);
				break;
	 }
	}
	else
	{
		switch(port)
		{
			case 0:
				P0_DOUT &= ~(1<<pin);
				break;
	
			case 1:
				P1_DOUT &= ~(1<<pin);
				break;
	
			case 2:
				P2_DOUT &= ~(1<<pin);
				break;
	
			case 3:
				P3_DOUT &= ~(1<<pin);
				break;
	
			case 4:
				P4_DOUT &= ~(1<<pin);
				break;
		}
	}
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////

//Read GPIO Input on Pin.  digitalRead( Port# , Pin3 )
int digitalRead (int port, int pin )
{
	int raw_digital_data;
	int digitalRead_pin_value;
	
	//The switch selects which port to set. Each case sets the specific pin on the port selected
	switch(port)
		{
			case 0:
			raw_digital_data = P0_PIN;
			break;
	
			case 1:
			raw_digital_data = P1_PIN;
			break;
	
			case 2:
			raw_digital_data = P2_PIN;
			break;
	
			case 3:
			raw_digital_data = P3_PIN;
			break;
	
			case 4:
			raw_digital_data = P4_PIN;
			break;
	 }
   digitalRead_pin_value = ((raw_digital_data>>pin) & 0x01);	 
	 
	 return digitalRead_pin_value;
}

