/*---------------------------------------------------------------------------------------------------------*/
/*                          Program Written By: SAAM OSTOVARI and Nick Morozovsky                          */
/*										NDA SD2013-802													   */
/*---------------------------------------------------------------------------------------------------------*/

// This file is specific to Switchbot V2, although many constants are general

#ifndef __Robot_Values_H__
#define __Robot_Values_H__

//Define Constants for General Use
#define PI 	    				3.14159
#define Rad2PI					180.0/3.14159
#define	true						0x01
#define	false						0x00

//Define Constants for Timing
#define dt 						0.010        		//Control loop time in secs

//Define Constants for Motor
#define MaxPWM  				552
#define ULIM						1.0					// needs to be 1.0 when not testing. not previously defined in V1 file

//Define Constants for UART
#define UART0BytesSent  3						// 3 for new protocol, 6 for processing sketch			//The number of bytes that will be transmitted via bluetooth to UART0
//#define UART1BytesSent  6									//The number of bytes that will be transmitted via bluetooth to UART1
#define UART_TIMEOUT		270.0					// milliseconds

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
#define GyroY_low					0xC600				//GyroY Low Bit Address
#define GyroY_high				0xC500				//GyroY High Bit Address
#define GyroZ_low					0xC800				//GyroZ Low Bit Address
#define GyroZ_high				0xC700				//GyroZ High Bit Address

//Note that in IMU Code:  atan( Accel1 , Accel2 ) 
//Use the IMU Addresses in *** to read the correct address. Change the axis directions using the Direction variables above.
#define Accel1_low 				AccelZ_low
#define Accel1_high  			AccelZ_high
#define Accel2_low				AccelY_low
#define Accel2_high				AccelY_high
#define Accel1Dir 				-1          		//Accounts for sensor orientation 1 or -1
#define Accel2Dir					-1           		//Accounts for sensor orientation 1 or -1
#define Gyro1_low			  	GyroX_low
#define Gyro1_high				GyroX_high
#define Gyro1Dir 					-1.0           		//Accounts for sensor orientation 1 or -1
#define GYRO2RADS					Gyro1Dir*PI/(180.0*GyroSensitivity)
#define ACCEL_MOUNTING_OFFSET -0.0045
#define BODY_COM_THETA_OFFSET 0.1//-0.17
#define AccelOffset  			ACCEL_MOUNTING_OFFSET+BODY_COM_THETA_OFFSET						// radians, Makes the vertical zero degrees. DIFFERENT FOR V2

#define Gyro					1
#define Accel					0

//Define Constants for Encoders
#define LEncDir					1.0				// Changes direction that encoder counts. Value = -1 or 1
#define REncDir					-1.0			// Changes direction that encoder counts. Value = -1 or 1
#define CountsPerRev  	15.0	    // Encoder Count per every 1 revolution of the wheel DIFFERENT FOR V2
#define CountsPerTick  	2.0       // Depends if external interrupt is counting falling,rising or both. CHANGE =2,FALLING=1, RISING=1, both channels rising and falling = 4 DIFFERENT FOR V2
#define GearRatio  			44.0*2.0  // Equals 1 if encoder is on placed after gear reduction from motor. Equals the motor's gear ratio if on motor's output shaft before gear reduction, V1 was 34.014, times 2 for bevel gear reduction
#define Ticks2Rads  		2.0*PI/(CountsPerRev*CountsPerTick*GearRatio)  
#define encVelLPrad			30.0			// encoder velocity low pass filter cutoff frequency in rad/s, 20 mostly works dec 20, 2014
#define encVelLPC				dt / ((1.0/encVelLPrad) + dt) 	// encoder velocity low pass filter, V1 was 0.333

#define POT2RAD 	  		1.0*(320.0/4096.0)*(PI/180.0) 		// 1.1 is fudge factor

// first number is V2 #2, then V2 #1, then V1
#define KNEER0					2153//2013//2015							// pot calibration value, ADC 0 DIFFERENT FOR V2
#define KNEEL0					1935//1971//1970							// pot calibration value, ADC 1 DIFFERENT FOR V2
#define HIPR0						2187//2039//2090							// pot calibration value, ADC 5 DIFFERENT FOR V2
#define HIPL0						1881//2138//2115							// pot calibration value, ADC 6 DIFFERENT FOR V2

#define HIP_OFFSET			0//-BODY_COM_THETA_OFFSET							// angle (rad) between visually centered hips and weight centered hips
#define numPotVelWMAsamples 4									// number of samples for calculating pot velocity weighted moving average
#define numPotMFsamples 5										// number of samples for calculating pot median filter
#define sumPotVelWMAsamples 	numPotVelWMAsamples*(1+numPotVelWMAsamples)/2 // sum of weights
#define	potVelTC				6.0								// pot velocity low pass filter cutoff frequency
#define potVelLPC				dt / (1.0/potVelTC + dt)		// pot velocity low pass filter constant
#define	potTC						encVelLPrad							// pot low pass filter cutoff frequency, was 60
#define potLPC					dt / (1.0/potTC + dt)			// pot low pass filter constant

#define Grad 						encVelLPrad				// gyro low pass filter cutoff frequency, myRIO/L3GD20 was 6000, V1 was 120.0
#define GLPC  					dt / ((1.0/Grad) + dt)  	// gyro low pass filter constant

// no onboard battery
/*#define a  						-0.2711 						//  -g*(Ll*ml + Lk*(mu+mb))/(2*sk)
#define b  						-7.5346 						// -g/(2*sh)
#define c  						0.1001 							// (Ll*ml + Lk*(mu+mb))
#define d   					0.0638 							// (Lh*mb + Lu*mu)
#define e							0.0416							// Lb*mb
*/

// no onboard battery, Nuvoton electronics
/*#define a  						-0.2788 						//  -g*(Ll*ml + Lk*(mu+mb))/(2*sk)
#define b  						-7.5346 						// -g/(2*sh)
#define c  						0.1029 							// (Ll*ml + Lk*(mu+mb))
#define d   					0.0664 							// (Lh*mb + Lu*mu)
#define e							0.0453							// Lb*mb
*/

// V2 without head or media box
/*#define a							-0.3521							// -g*(Lk*mb + 2*Ll*ml + 2*Lk*mu)/(2*sk)
#define b							-7.5346 						// -g/(2*sh)
#define c							0.1268							// Lk*mb + 2*Ll*ml + 2*Lk*mu
#define d							0.0946							// Lh*mb + 2*Lu*mu
#define e							0.0346							// Lb*mb*/

// V2 with everything Jan 1, 2015
#define a							-0.4029							// -g*(Lk*mb + 2*Ll*ml + 2*Lk*mu)/(2*sk)
#define b							-7.5346 						// -g/(2*sh)
#define c							0.1451							// Lk*mb + 2*Ll*ml + 2*Lk*mu
#define d							0.1135							// Lh*mb + 2*Lu*mu
#define e							0.0547							// Lb*mb

// friction compensator
#define FC_ALPHA			0.0//5										// max friction compensation to add, 0.05
#define FC_BETA				0.2											// saturation limit for u, 0.2
#define FC_ABS				1.0 + FC_ALPHA/FC_BETA	// scaling factor for u near 0

// define constants for joysticks
#define JOYSTICK_ZERO 127									// zero point
#define JOYSTICK_SCALE 127.0							// scale, half of full scale range
#define JOYSTICK_DRIVE_GAIN 10.0						// labview was 0.1 w/o dt on position
#define JOYSTICK_BOOM_GAIN -0.004*100			// for rate of squatting in modes 3 and 4
#define JOYSTICK_TURN_GAIN -0.05
#define JOYSTICK_YAW_GAIN -5.0						// for yawRef

//#define KNEEL_JOINT_P_GAIN -1.5						// for locking knees and hips in position while kneeling
#define KNEEL_KNEE_P_GAIN		-2.5
#define KNEEL_HIP_P_GAIN		-2.5
#define JOYSTICK_HIP_GAIN -0.004*-2.0*100.0			// for pivoting upper body about hips in mode 1

#define THETA_KNEELING_LIMIT_POS  0.8					// limit theta reference command while kneeling RC, mode 3
#define THETA_KNEELING_LIMIT_NEG -0.5					// limit theta reference command while kneeling RC, mode 3
#define THETA_STAND_TO_KNEEL		 -0.8					// point to transition from balancing (mode 49) to kneeling (mode 39)
#define THETA_KNEEL2STAND				 -0.15					// point to transition from standing up (mode 41) to standing (mode 4)
#define THETA_LEAN_BACK					 -0.7033			// point to transition from mode 31 to 41
#define THETA_KNEEL_UPRIGHT 		 -0.1					// point to transition from mode 39 to 3
#define THETA39										0.2					// theta reference point in mode 39

#define PHI_RUNAWAY					30						// distance in radians to indicate runaway fall condition

#define TREADYAWGAIN				-0.005				// for turning and to keep left and right pulleys in sync, V1 was -0.005
#define HIPYAWGAIN					-2.5//-2.0					// to keep left and right hips symmetric, V1 was -1
#define KNEEYAWGAIN					-2.5//-2.0					// to keep left and right knees symmetric, V1 was -1

#define STAND2KNEEL_INCREMENT	0.1				// rate at which Switchbot will squat down to transition from standing to kneeling, 0.2 is about 3 seconds
#define T41										0.698				// point at which to switch from KNEEL2STAND_INCREMENT1 to KNEEL2STAND_INCREMENT2
#define KNEEL2STAND_INCREMENT1	-0.002			// rate at which Switchbot will squat down to transition from standing to kneeling
#define KNEEL2STAND_INCREMENT2	-0.15			// rate at which Switchbot will squat down to transition from standing to kneeling
#define STAND2KNEEL_U1				-0.5			// control input to u[0] and u[1] to catch self while "downrighting"
#define KNEEL2STAND_U1				-0.3			// control input to u[0] and u[1] to tip body while "uprighting"

// kneeling position
#define GAMMA_KNEEL					-0.4519
#define ALPHA_KNEEL					1.5714

#endif
