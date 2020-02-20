/*---------------------------------------------------------------------------------------------------------*/
/*                          Program Written By: SAAM OSTOVARI and Nick Morozovsky                          */
/*																		NDA SD2013-802																	  									 */
/*---------------------------------------------------------------------------------------------------------*/


#ifndef __ADC_H__
#define __ADC_H__

void Init_ADC(int ADC_Pin);															//Setting Up Analog to Digital Converter to Continuous Mode. ADC is 12bit
//void UpdateAnalogRead(void);																	//Update All Initialized Analog Pins
//int analogRead(int analogRead_Pin);														//Get Updated Analog Value for Specified Pin. UpdateAnalogRead() must be called to update values. 
void readPots(float pots[]);																	// read ADC pins for switchbot Pots
//void Outputs4Debugging_ADC(void);															//Function to Print Out Debugging Info for ADC

#endif
