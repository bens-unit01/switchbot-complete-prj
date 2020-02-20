/*---------------------------------------------------------------------------------------------------------*/
/*                          Program Written By: SAAM OSTOVARI                                              */
/*																			NDA SD2013-802																				     			   */
/*---------------------------------------------------------------------------------------------------------*/


#ifndef __ESTIMATOR_H__
#define __ESTIMATOR_H__

void Initialize_Estimator(void);									//Initialize Estimator
void Complementary_Filter(void);									//Complementary filter used to translate sensor data into data for controllers and balancing
//void Encoder_Filter(void);												//Encoder filter used to translate sensor data into data for controllers and balancing
//void Estimator(void);															//Function to get updated vehicle state estimation for use in controller
float get_theta(void);														//Functions to get theta for use in other functions
float get_thetad(void);														//Functions to get thetad for use in other functions
//float get_phi(void);															//Functions to get phi for use in other functions
//float get_phid(void);															//Functions to get phid for use in other functions
//float get_Encoderd(void);													//Functions to get Encoderd for use in other functions
//void reset_Estimator(void);											  //Reset Estimator values for Safeties
//void Outputs4Debugging_Estimator(void);						//Function to Print Out Debugging Info for Estimator
								
#endif
