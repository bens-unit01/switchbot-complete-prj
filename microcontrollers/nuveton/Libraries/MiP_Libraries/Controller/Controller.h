/*---------------------------------------------------------------------------------------------------------*/
/*                          Program Written By: SAAM OSTOVARI                                              */
/*																			NDA SD2013-802																				     			   */
/*---------------------------------------------------------------------------------------------------------*/


#ifndef __Controller_H__
#define __Controller_H__

void Initialize_Controller(void);							//Initialize Controller for Balancing
void SLC_Control(void);												//Succesive Loop Closure Control for Balancing. USER NEEDS TO CHANGE DEPENDING ON ROBOT
void LQR_Control(void);												//LQR Controller for Balancing. USER NEEDS TO CHANGE DEPENDING ON ROBOT
float get_u(void);														//Functions to Get Variable in Other Functions
void reset_Controller(void);									//Reset Controller Variables for Safeties
void reset_refPhi(void);											//Reset Phi variable for Safeties
void Outputs4Debugging_Controller(void);  		//Function to Print Out Debugging Info for Controller

#endif
