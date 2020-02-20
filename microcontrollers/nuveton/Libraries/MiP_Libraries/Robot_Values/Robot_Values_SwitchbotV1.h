/*---------------------------------------------------------------------------------------------------------*/
/*                          Program Written By: SAAM OSTOVARI and Nick Morozovsky                          */
/*										NDA SD2013-802													   */
/*---------------------------------------------------------------------------------------------------------*/

// This file is specific to Switchbot V1, although many constants are general

#ifndef __Robot_Values_H__
#define __Robot_Values_H__

//Define Constants for General Use
#define PI 	    				3.14159
#define Rad2PI					180/3.14159
#define	true					0x01
#define	false					0x00

//Define Constants for Timing
#define dt 						0.010        		//Control loop time in secs

//Define Constants for Motor
#define MaxPWM  				552

//Define Constants for UART
#define UART0BytesSent  6									//The number of bytes that will be transmitted via bluetooth to UART0
#define UART1BytesSent  6									//The number of bytes that will be transmitted via bluetooth to UART1

//Define Constants for Estimator
#define theta_mix_Tc 			2.0
#define GHPC  					theta_mix_Tc / (theta_mix_Tc + dt)
#define ALPC  					dt / (theta_mix_Tc + dt)

////Define Constants for IMU .  
#define AccelSensitivity 		16384.0 	      	//AFS_SEL=0
//#define GyroSensitivity 		131.0 	        	//FS_SEL=0 131 LSB/(º/s) 
#define GyroSensitivity 		32.8 	        	//FS_SEL=? 32.8 LSB/(º/s) 

// ***IMU Addresses for Accelerometer and Gyro Axes***
#define AccelX_low 				0xBC00				//AccelX Low Bit Address
#define AccelX_high  			0xBB00				//AccelX High Bit Address
#define AccelY_low				0xBE00				//AccelY Low Bit Address
#define AccelY_high				0xBD00				//AccelY High Bit Address
#define AccelZ_low				0xC000				//AccelZ Low Bit Address
#define AccelZ_high				0xBF00				//AccelZ High Bit Address
#define GyroX_low		    	0xC400				//GyroX Low Bit Address
#define GyroX_high				0xC300				//GyroX High Bit Address
#define GyroY_low				0xC600				//GyroY Low Bit Address
#define GyroY_high				0xC500				//GyroY High Bit Address
#define GyroZ_low				0xC800				//GyroZ Low Bit Address
#define GyroZ_high				0xC700				//GyroZ High Bit Address

//Note that in IMU Code:  atan( Accel1 , Accel2 ) 
//Use the IMU Addresses in *** to read the correct address. Change the axis directions using the Direction variables above.
#define Accel1_low 				AccelZ_low
#define Accel1_high  			AccelZ_high
#define Accel2_low				AccelY_low
#define Accel2_high				AccelY_high
#define Accel1Dir 				-1          		//Accounts for sensor orientation 1 or -1
#define Accel2Dir				-1           		//Accounts for sensor orientation 1 or -1
#define Gyro1_low			  	GyroX_low
#define Gyro1_high				GyroX_high
#define Gyro1Dir 				-1.0           		//Accounts for sensor orientation 1 or -1
#define GYRO2RADS				Gyro1Dir*PI/(180.0*GyroSensitivity)
#define AccelOffset  			20.06*PI/180.0		// radians, Makes the vertical zero degrees.

#define Gyro					1
#define Accel					0

//Define Constants for Encoders
#define LEncDir					-1.0				//Changes direction that encoder counts. Value = -1 or 1
#define REncDir					1.0					//Changes direction that encoder counts. Value = -1 or 1
#define CountsPerRev  			12.0	         	//Encoder Count per every 1 revolution of the wheel
#define CountsPerTick  			4.0           		//Depends if external interrupt is counting falling,rising or both. CHANGE =2,FALLING=1, RISING=1, both channels rising and falling = 4
#define GearRatio  				34.014         		//Equals 1 if encoder is on placed after gear reduction from motor. Equals the motors gear ratio if on Motor's output shaft before gear reduction
#define Ticks2Rads  			2.0*PI/(CountsPerRev*CountsPerTick*GearRatio)  
#define encVelLPC				0.333				// encoder velocity low pass filter

#define POT2RAD   				(320.0/4096.0)*(PI/180.0) 		// NEED TO ADJUST FOR ADC BIT LEVEL
#define KNEER0					2070							// pot calibration value, ADC 0
#define KNEEL0					2071							// pot calibration value, ADC 1
#define HIPR0					2094							// pot calibration value, ADC 5
#define HIPL0					2014							// pot calibration value, ADC 6
#define numPotVelWMAsamples 12									// number of samples for calculating pot velocity weighted moving average
#define numPotMFsamples 5										// number of samples for calculating pot median filter
#define sumPotVelWMAsamples 	numPotVelWMAsamples*(1+numPotVelWMAsamples)/2 // sum of weights
#define	potVelTC				6.0								// pot velocity low pass filter cutoff frequency
#define potVelLPC				dt / (1.0/potVelTC + dt)		// pot velocity low pass filter constant
#define	potTC					60.0							// pot low pass filter cutoff frequency
#define potLPC					dt / (1.0/potTC + dt)			// pot low pass filter constant

#define Grad 					120.0							// gyro low pass filter cutoff frequency, myRIO/L3GD20 was 6000
#define GLPC  					0.010 / ((1.0/Grad) + 0.010)  	// gyro low pass filter constant

// no onboard battery
/*#define a  						-0.2711 						//  -g*(Ll*ml + Lk*(mu+mb))/(2*sk)
#define b  						-7.5346 						// -g/(2*sh)
#define c  						0.1001 							// (Ll*ml + Lk*(mu+mb))
#define d   					0.0638 							// (Lh*mb + Lu*mu)
#define e							0.0416							// Lb*mb
*/

// no onboard battery, Nuvoton electronics
#define a  						-0.2788 						//  -g*(Ll*ml + Lk*(mu+mb))/(2*sk)
#define b  						-7.5346 						// -g/(2*sh)
#define c  						0.1029 							// (Ll*ml + Lk*(mu+mb))
#define d   					0.0664 							// (Lh*mb + Lu*mu)
#define e							0.0453							// Lb*mb

// define constants for joysticks
#define JOYSTICK_ZERO 127									// zero point
#define JOYSTICK_SCALE 127.0							// scale, half of full scale range
#define JOYSTICK_DRIVE_GAIN 10.0						// labview was 0.1 w/o dt on position
#define JOYSTICK_BOOM_GAIN -0.004*100			// for rate of squatting in modes 3 and 4
#define JOYSTICK_TURN_GAIN -0.05
#define JOYSTICK_YAW_GAIN -5.0						// for yawRef

#define KNEEL_JOINT_P_GAIN -1.5						// for locking knees and hips in position while kneeling
#define JOYSTICK_HIP_GAIN -0.004*-2.0*100.0			// for pivoting upper body about hips in mode 1

#define THETA_KNEELING_LIMIT 1.7					// limit theta reference command while kneeling RC, mode 1
#define THETA_STAND_TO_KNEEL -1.2					// point to transition from balancing (mode 4) to kneeling (mode 1)

#endif
