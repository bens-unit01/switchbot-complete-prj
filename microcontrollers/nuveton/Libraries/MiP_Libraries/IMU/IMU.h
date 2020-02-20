/*---------------------------------------------------------------------------------------------------------*/
/*                          Program Written By: SAAM OSTOVARI and Nick Morozovsky                          */
/*																			NDA SD2013-802																				     			   */
/*---------------------------------------------------------------------------------------------------------*/

#ifndef __IMU_H__
#define __IMU_H__

void ConfigureMIPIMU(void);										//Function to Configure the MPU-6880 IMU. This is the IMU in MiP
//void Init_Digital_IMU(void);									//Initial IMU 
void Init_Digital_IMU2(void);									// Initialize IMU
//void IMU_Update(void);												//Get New Data From IMU
void IMU_Update2(void);												//Get New Data From IMU, no  unit scaling
float get_acc_theta(void);										//Functions to Get Variable to Other Functions
float get_gyro_thetad(void);									//Functions to Get Variable to Other Functions
//void Outputs4Debugging_IMU(void);							//Functions to print out Debugging info for IMU

#endif
