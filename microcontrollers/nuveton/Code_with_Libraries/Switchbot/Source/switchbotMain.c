/*---------------------------------------------------------------------------------------------------------*/
/*                      Program Written By: Nick Morozovsky, based on template by SAAM OSTOVARI            */
/*																			NDA SD2013-802																				     			   */
/*---------------------------------------------------------------------------------------------------------*/
/*  Note: System clock uses PLL instead of the external 12MHz	like all my other test programs 				 		 */
/*---------------------------------------------------------------------------------------------------------*/

//Including Libraries
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <math.h>
#include "M051.h"
#include "Register_Bit.h"

#include "Common.h"
#include "Retarget.h"
#include "Macro_SystemClock.h"
#include "Macro_Timer.h"
//Including MiP libraries 
#include "..\..\Libraries\MiP_Libraries\System_Clock\System_Clock.h"
#include "..\..\Libraries\MiP_Libraries\UART\UART.h"
#include "..\..\Libraries\MiP_Libraries\SPI\SPI.h"
#include "..\..\Libraries\MiP_Libraries\IMU\IMU.h"
#include "..\..\Libraries\MiP_Libraries\Timers\Timers.h"
#include "..\..\Libraries\MiP_Libraries\GPIO\GPIO.h"
#include "..\..\Libraries\MiP_Libraries\PWM\PWM.h"
#include "..\..\Libraries\MiP_Libraries\ADC\ADC.h"
#include "..\..\Libraries\MiP_Libraries\Encoders\Encoders.h"
#include "..\..\Libraries\MiP_Libraries\Motor_Drive\Motor_Drive.h"
#include "..\..\Libraries\MiP_Libraries\Estimator\Estimator.h"
//#include "Controller\Controller.h"
#include "..\..\Libraries\MiP_Libraries\Robot_Values\Robot_Values.h"
#include "..\..\Libraries\MiP_Libraries\Interrupt_Priority\Interrupt_Priority.h"

//static int loop = 0; 

static uint32_t Timer_Count = 0;
//static uint32_t Timer_Count1 = 0;

int i;
int j;
float u1y;
float u2y;
float u3y;
float xhat[14];
float ref[14] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0};
float refOld[14] = {0};
float u[6];
float pots[4];
float potsLP[4] = {0,0,0,0};
float potVelLP[4] = {0,0,0,0};
float potVelWMA[4] = {0,0,0,0};
float potsOld[4][numPotVelWMAsamples] = {{0}};
float potsMFold[4][numPotMFsamples] = {{0}};
float potsMed[numPotMFsamples] = {0};
float temp = 0;
float gyroLP = 0;
float ustar[6] = {0,0,0,0,0,0};
float joy[4] = {0};
float yawRef = 0;
int8_t button = 0;
int8_t mode = 3; // probably want to switch to 3 after initial testing
int8_t modeOld = 0;
int8_t ESTOP = 1;
//float timeStamp = 0;
//float execTime = 0;
//float loopStart = 0;
//float beforeDebug = 0;
//float afterDebug = 0;
const double UDIR[] = {-1.0, -1.0, 1.0, -1.0, 1.0, -1.0};					// was not previously defined in V1 (all positive)
//float r[8] = {1,1,1,1,1,0.5,0.5,1};//{1,1,1,1,0.25,0.25,0.25,1};			// is the maskK function call commented out?
// V1
/*float K[3][14] = {
   { 0.0357,    0.0357,    3.2134,    3.2134,    2.1429,    2.1429,    3.1177,    0.0427,    0.0427,    0.5013,    0.5013,    0.3424,    0.3424,    0.5163},
   {-0.0009,   -0.0009,   -1.0677,   -1.0677,    1.1303,    1.1303,    0.8678,   -0.0008,   -0.0008,   -0.0145,   -0.0145,    0.0135,    0.0135,    0.0325},
   {-0.0032,   -0.0032,   -0.3666,   -0.3666,   -0.8671,   -0.8671,    2.8909,   -0.0025,   -0.0025,   -0.0326,   -0.0326,   -0.0083,   -0.0083,    0.0376}
}; //*/
// V2 w/everything Jan 2, 2015
float K[3][14] = {
	{  0.0478,  0.0478,  2.1697,  2.1697,  1.9171,  1.9171,  2.5646,  0.0501,  0.0501,  0.2047,  0.2047,  0.1971,  0.1971,  0.2806 },
  { -0.0044, -0.0044, -1.5831, -1.5831,  1.2381,  1.2381,  0.8352, -0.0036, -0.0036, -0.1210, -0.1210,  0.0826,  0.0826,  0.0428 },
  { -0.0021, -0.0021, -0.2618, -0.2618, -0.5454, -0.5454,  1.9745, -0.0017, -0.0017, -0.0177, -0.0177, -0.0409, -0.0409,  0.1462 }
 }; //*/

int nGains = 6; // number of gains for equilibrium manifold, gains defined below
// V1
/*float KS[6][3][14] = {
{ {  0.036000,  0.036000,  3.660700,  3.660700,  2.584550,  2.584550,  3.168600,  0.013175,  0.013175,  0.158925,  0.158925,  0.122650,  0.122650,  0.558500 },
  { -0.005850, -0.005850, -1.466800, -1.466800,  1.246000,  1.246000,  0.276300, -0.005100, -0.005100, -0.063000, -0.063000, -0.015400, -0.015400, -0.017500 },
  {  0.001350,  0.001350, -0.353950, -0.353950, -0.563650, -0.563650,  3.283200,  0.000950,  0.000950, -0.016050, -0.016050, -0.000100, -0.000100,  0.120400 } },
{ {  0.035800,  0.035800,  3.594600,  3.594600,  2.580950,  2.580950,  3.248300,  0.013125,  0.013125,  0.155025,  0.155025,  0.122800,  0.122800,  0.566200 },
  { -0.006700, -0.006700, -1.499900, -1.499900,  1.228950,  1.228950,  0.115400, -0.005850, -0.005850, -0.072950, -0.072950, -0.018650, -0.018650, -0.027100 },
  {  0.001750,  0.001750, -0.403950, -0.403950, -0.501000, -0.501000,  3.297300,  0.001250,  0.001250, -0.022100, -0.022100,  0.008500,  0.008500,  0.125200 } },
{ {  0.035600,  0.035600,  3.518700,  3.518700,  2.670100,  2.670100,  3.263800,  0.013100,  0.013100,  0.152275,  0.152275,  0.128725,  0.128725,  0.568700 },
  { -0.007600, -0.007600, -1.536700, -1.536700,  1.186850,  1.186850, -0.098800, -0.006600, -0.006600, -0.084450, -0.084450, -0.025000, -0.025000, -0.037200 },
  {  0.002000,  0.002000, -0.458050, -0.458050, -0.411400, -0.411400,  3.306900,  0.001450,  0.001450, -0.031800, -0.031800,  0.019450,  0.019450,  0.133200 } },
{ {  0.035750,  0.035750,  3.503700,  3.503700,  2.961800,  2.961800,  3.271600,  0.013300,  0.013300,  0.159887,  0.159887,  0.149737,  0.149737,  0.599200 },
  { -0.007300, -0.007300, -1.540950, -1.540950,  1.134700,  1.134700, -0.279800, -0.006350, -0.006350, -0.089600, -0.089600, -0.030500, -0.030500, -0.040800 },
  {  0.002150,  0.002150, -0.482850, -0.482850, -0.311550, -0.311550,  3.302100,  0.001600,  0.001600, -0.039200, -0.039200,  0.031800,  0.031800,  0.142600 } },
{ {  0.036900,  0.036900,  3.720400,  3.720400,  3.842150,  3.842150,  3.469100,  0.014075,  0.014075,  0.208163,  0.208163,  0.217963,  0.217963,  0.768500 },
  {  0.002550,  0.002550, -1.167100, -1.167100,  1.436300,  1.436300, -0.075000,  0.002500,  0.002500,  0.000050,  0.000050,  0.058950,  0.058950,  0.042300 },
  {  0.000650,  0.000650, -0.521650, -0.521650, -0.265250, -0.265250,  3.236000,  0.000400,  0.000400, -0.053300, -0.053300,  0.031400,  0.031400,  0.140000 } },
{ { -0.017850, -0.017850,  1.542650,  1.542650,  2.314800,  2.314800,  1.477400,  0.002425,  0.002425,  0.124100,  0.124100,  0.136362,  0.136362,  0.448100 },
  {  0.030450,  0.030450,  0.450350,  0.450350,  4.265300,  4.265300,  1.567400,  0.027100,  0.027100,  0.719550,  0.719550,  0.852800,  0.852800,  0.691600 },
  { -0.006800, -0.006800, -0.856900, -0.856900, -0.848150, -0.848150,  2.811400, -0.005750, -0.005750, -0.205950, -0.205950, -0.134800, -0.134800,  0.004300 } }
}; //*/
// V2 without head or media box
/*float KS[6][3][14] = {
{ {  0.0461,  0.0461,  2.1427,  2.1427,  1.8499,  1.8499,  2.3730,  0.0481,  0.0481,  0.1956,  0.1956,  0.1821,  0.1821,  0.2223 },
  { -0.0057, -0.0057, -1.5847, -1.5847,  1.2219,  1.2219,  0.7996, -0.0047, -0.0047, -0.1250, -0.1250,  0.0782,  0.0782,  0.0369 },
  { -0.0033, -0.0033, -0.2599, -0.2599, -0.5351, -0.5351,  1.8384, -0.0027, -0.0027, -0.0218, -0.0218, -0.0444, -0.0444,  0.1308 } },
{ {  0.0462,  0.0462,  2.1018,  2.1018,  1.8167,  1.8167,  2.4282,  0.0480,  0.0480,  0.1770,  0.1770,  0.1696,  0.1696,  0.2264 },
  { -0.0058, -0.0058, -1.5738, -1.5738,  1.2272,  1.2272,  0.7432, -0.0047, -0.0047, -0.1257, -0.1257,  0.0817,  0.0817,  0.0349 },
  { -0.0033, -0.0033, -0.2679, -0.2679, -0.5243, -0.5243,  1.8235, -0.0027, -0.0027, -0.0230, -0.0230, -0.0414, -0.0414,  0.1306 } },
{ {  0.0465,  0.0465,  2.0485,  2.0485,  1.7985,  1.7985,  2.5049,  0.0480,  0.0480,  0.1483,  0.1483,  0.1553,  0.1553,  0.2323 },
  { -0.0058, -0.0058, -1.5527, -1.5527,  1.2354,  1.2354,  0.6532, -0.0046, -0.0046, -0.1257, -0.1257,  0.0865,  0.0865,  0.0326 },
  { -0.0035, -0.0035, -0.2779, -0.2779, -0.5072, -0.5072,  1.7890, -0.0028, -0.0028, -0.0254, -0.0254, -0.0377, -0.0377,  0.1299 } },
{ {  0.0483,  0.0483,  2.0327,  2.0327,  1.8652,  1.8652,  2.6952,  0.0493,  0.0493,  0.1147,  0.1147,  0.1505,  0.1505,  0.2620 },
  { -0.0056, -0.0056, -1.5219, -1.5219,  1.2395,  1.2395,  0.5514, -0.0043, -0.0043, -0.1238, -0.1238,  0.0911,  0.0911,  0.0296 },
  { -0.0039, -0.0039, -0.2839, -0.2839, -0.4899, -0.4899,  1.7347, -0.0030, -0.0030, -0.0273, -0.0273, -0.0344, -0.0344,  0.1271 } },
{ {  0.0560,  0.0560,  2.1763,  2.1763,  2.3220,  2.3220,  3.3803,  0.0555,  0.0555,  0.0807,  0.0807,  0.1996,  0.1996,  0.4172 },
  { -0.0042, -0.0042, -1.4802, -1.4802,  1.2333,  1.2333,  0.4440, -0.0025, -0.0025, -0.1189, -0.1189,  0.0963,  0.0963,  0.0296 },
  { -0.0051, -0.0051, -0.2823, -0.2823, -0.4903, -0.4903,  1.6546, -0.0038, -0.0038, -0.0274, -0.0274, -0.0354, -0.0354,  0.1149 } },
{ {  0.0494,  0.0494,  1.4898,  1.4898,  4.9208,  4.9208,  5.9598,  0.0524,  0.0524, -0.0098, -0.0098,  0.5642,  0.5642,  1.3026 },
  {  0.0155,  0.0155, -1.7152, -1.7152,  1.7916,  1.7916,  0.4270,  0.0130,  0.0130, -0.1400, -0.1400,  0.2299,  0.2299,  0.3206 },
  { -0.0125, -0.0125, -0.1968, -0.1968, -0.8033, -0.8033,  1.3382, -0.0074, -0.0074, -0.0167, -0.0167, -0.0879, -0.0879, -0.0113 } }
}; // */
// V2 with everything, Jan 2 2015
float KS[6][3][14] = {
{ {  0.0478,  0.0478,  2.1697,  2.1697,  1.9171,  1.9171,  2.5646,  0.0501,  0.0501,  0.2047,  0.2047,  0.1971,  0.1971,  0.2806 },
  { -0.0044, -0.0044, -1.5831, -1.5831,  1.2381,  1.2381,  0.8352, -0.0036, -0.0036, -0.1210, -0.1210,  0.0826,  0.0826,  0.0428 },
  { -0.0021, -0.0021, -0.2618, -0.2618, -0.5454, -0.5454,  1.9745, -0.0017, -0.0017, -0.0177, -0.0177, -0.0409, -0.0409,  0.1462 } },
{ {  0.0480,  0.0480,  2.1191,  2.1191,  1.9122,  1.9122,  2.6197,  0.0501,  0.0501,  0.1856,  0.1856,  0.1891,  0.1891,  0.2832 },
  { -0.0040, -0.0040, -1.5657, -1.5657,  1.2492,  1.2492,  0.7526, -0.0032, -0.0032, -0.1214, -0.1214,  0.0872,  0.0872,  0.0421 },
  { -0.0022, -0.0022, -0.2731, -0.2731, -0.5326, -0.5326,  1.9558, -0.0017, -0.0017, -0.0209, -0.0209, -0.0377, -0.0377,  0.1464 } },
{ {  0.0485,  0.0485,  2.0376,  2.0376,  1.9500,  1.9500,  2.6674,  0.0503,  0.0503,  0.1550,  0.1550,  0.1827,  0.1827,  0.2814 },
  { -0.0031, -0.0031, -1.5323, -1.5323,  1.2677,  1.2677,  0.6242, -0.0023, -0.0023, -0.1204, -0.1204,  0.0941,  0.0941,  0.0435 },
  { -0.0025, -0.0025, -0.2854, -0.2854, -0.5132, -0.5132,  1.9070, -0.0020, -0.0020, -0.0265, -0.0265, -0.0341, -0.0341,  0.1466 } },
{ {  0.0499,  0.0499,  1.9311,  1.9311,  2.0997,  2.0997,  2.7363,  0.0510,  0.0510,  0.1152,  0.1152,  0.1859,  0.1859,  0.2868 },
  { -0.0007, -0.0007, -1.4865, -1.4865,  1.2948,  1.2948,  0.4866, -0.0001, -0.0001, -0.1170, -0.1170,  0.1044,  0.1044,  0.0501 },
  { -0.0034, -0.0034, -0.2879, -0.2879, -0.4969, -0.4969,  1.8331, -0.0026, -0.0026, -0.0317, -0.0317, -0.0319, -0.0319,  0.1449 } },
{ {  0.0526,  0.0526,  1.7765,  1.7765,  2.5501,  2.5501,  2.9006,  0.0520,  0.0520,  0.0647,  0.0647,  0.2141,  0.2141,  0.3234 },
  {  0.0051,  0.0051, -1.4614, -1.4614,  1.3809,  1.3809,  0.3527,  0.0052,  0.0052, -0.1147, -0.1147,  0.1262,  0.1262,  0.0726 },
  { -0.0051, -0.0051, -0.2661, -0.2661, -0.5049, -0.5049,  1.7464, -0.0039, -0.0039, -0.0330, -0.0330, -0.0342, -0.0342,  0.1380 } },
{ {  0.0506,  0.0506,  1.4493,  1.4493,  3.6913,  3.6913,  3.3363,  0.0464,  0.0464,  0.0006,  0.0006,  0.2784,  0.2784,  0.4260 },
  {  0.0177,  0.0177, -1.6738, -1.6738,  1.8008,  1.8008,  0.1531,  0.0140,  0.0140, -0.1346, -0.1346,  0.1859,  0.1859,  0.1432 },
  { -0.0082, -0.0082, -0.1804, -0.1804, -0.5919, -0.5919,  1.6597, -0.0053, -0.0053, -0.0255, -0.0255, -0.0453, -0.0453,  0.1208 } }
	}; // */

float t;
float tread = 0;
float treadd = 0;
/////////////////////////////////////////////////////////////////////////////////////////////////////////                                                                                      

void maskK(float r[])
{
	K[0][0]  = r[0]*K[0][0];
	K[0][1]  = r[0]*K[0][1];
	K[0][2]  = r[1]*K[0][2];
	K[0][3]  = r[1]*K[0][3];
	K[0][4]  = r[2]*K[0][4];
	K[0][5]  = r[2]*K[0][5];
	K[0][6]  = r[3]*K[0][6];
	K[0][7]  = r[4]*K[0][7];
	K[0][8]  = r[4]*K[0][8];
	K[0][9]  = r[5]*K[0][9];
	K[0][10] = r[5]*K[0][10];
	K[0][11] = r[6]*K[0][11];
	K[0][12] = r[6]*K[0][12];
	K[0][13] = r[7]*K[0][13];
}

float median(float list[], int n)
{
	int k = n/2;
	int l;
	int m;
	for (l = 0; l <= k; l++)
	{
		int minIndex = l;
		float minValue = list[l];
		for (m = l+1; m < n; m++)
			 if (list[m] < minValue)
			 {
					 minIndex = m;
					 minValue = list[m];
			 }

		// swap list[l] and list[minIndex]
		temp = list[l];
		list[l] = list[minIndex];
		list[minIndex] = temp;
	}
	return list[k];
}
	
void estimator()
{	
	Complementary_Filter();
	xhat[6] = get_theta();
	gyroLP = gyroLP + GLPC*(get_thetad() - gyroLP);
	xhat[13] = gyroLP;
	
	readPots(pots);	// update ADC values in pots
	
	for (i = 0; i < 4; i++)
	{
		
		// find median of potsOld
		for (j = numPotMFsamples-1; j > 0; j--)
		{
			potsMFold[i][j] = potsMFold[i][j-1];
			potsMed[j] = potsMFold[i][j];
		}
		potsMFold[i][0] = pots[i];
		potsMed[0] = pots[i];
		pots[i] = median(potsMed, numPotMFsamples);
		
		// low pass pot position
		potsLP[i] = potsLP[i] + potLPC*(pots[i] - potsLP[i]);
		pots[i] = potsLP[i];
		
		// WMA pot velocity
		potVelWMA[i] = ( (pots[i]-potsOld[i][0])/dt + 2*(pots[i]-potsOld[i][1])/(2*dt) + 3*(pots[i]-potsOld[i][2])/(3*dt) + 4*(pots[i]-potsOld[i][3])/(4*dt) ) / 10;
		/*potVelWMA[i] = 0;
		for (j = numPotVelWMAsamples-1; j > 0; j--)
		{
			potVelWMA[i] += (j+1)*(pots[i]-potsOld[i][j])/((j+1)*dt);
			/*temp = (j+1)*(pots[i]-potsOld[i][j])/((j+1)*dt);
			if (temp/ < 1.1)
				potVelWMA[i] += temp;
			else
				potVelWMA[i] += *//*
			potsOld[i][j] = potsOld[i][j-1];
		}
		potVelWMA[i] += (potsLP[i]-potsOld[i][0])/(1*dt);
		potVelWMA[i] = potVelWMA[i]/((float)sumPotVelWMAsamples);*/
		potsOld[i][3] = potsOld[i][2];
		potsOld[i][2] = potsOld[i][1];
		potsOld[i][1] = potsOld[i][0];
		potsOld[i][0] = pots[i];
		
		
		// low pass pot velocity
		potVelLP[i] = potVelLP[i] + potVelLPC*(potVelWMA[i] - potVelLP[i]);
	}
	
	xhat[4] = xhat[6] + pots[2] + HIP_OFFSET;	//gammaR = theta + hipR;
	xhat[5] = xhat[6] + pots[3] + HIP_OFFSET;	//gammaL = theta + hipL;
	xhat[2] = xhat[4] + pots[0];	//alphaR = gammaR + kneeR;
	xhat[3] = xhat[5] + pots[1];	//alphaL = gammaL + kneeL;
	
	xhat[0] = xhat[2] + get_encoderRcount();	//phiR = alphaR + treadR;
	xhat[1] = xhat[3] + get_encoderLcount();	//phiL = alphaL + treadL;
	
	xhat[11] = xhat[13] + potVelLP[2];	//gammaRDot = thetaDotLP + hipRDot;
	xhat[12] = xhat[13] + potVelLP[3];	//gammaLDot = thetaDotLP + hipLDot;
	xhat[9]  = xhat[11] + potVelLP[0];	//alphaRDot = gammaRDot + kneeRDot;
	xhat[10] = xhat[12] + potVelLP[1];	//alphaLDot = gammaLDot + kneeLDot;
	
	xhat[7] = xhat[9] + encVelLP_R();	//phiRDot = alphaRDot + treadRDot;
	xhat[8] = xhat[10] + encVelLP_L();	//phiLDot = alphaLDot + treadLDot;
}


/* MODES
1: treads override with joystick control, hip angle override with joystick control
2: balancing with pose of initial condition, joystick driving
3: kneeling w/fixed gamma and variable theta (joystick driving)
31: kneeling and lowering theta ref to prepare for uprighting (mode 41)
41: transitioning from kneeling to standing
	starts when button 4 is pressed while in mode 3
	ends by switching to mode 4 when high enough in trajectory
4: uprighting trajectory w/balancing turned on
	limited in trajectory
49: transitioning from standing to kneeling
	starts when button 3 is pressed while in mode 4
	ends by switching to mode 39 when low enough in trajectory
39: kneeling w/fixed theta ref = 0, for returning to kneeling (mode 3) after standing (mode 49)
*/
void stateMachine()
{
	modeOld = mode;
	
	button = parseUART0buffer(joy);
	
	switch (button)
	{
		//case 0: // no button press
			//break;
		case 6:	// ESTOP motors
			motorESTOP();
			ESTOP = 1;
			break;
		case 8: // disable ESTOP
			motorEnable();
			ESTOP = 0;
			break;
		case 1:	// kneeling RC drive, old mode 4
			mode = 1;
			break;
		case 2: // balancing (standing) at initial joint positions RC drive, old mode 7
			mode = 2;
			break;
		case 3:	// move joints through up/downrighting equilbrium manifold w/o balancing, old mode 9
			if ( (modeOld == 4) || (modeOld == 41) || (modeOld == 49) ) // mode is 4, 41, or 49
				mode = 49;
			else // mode is 1, 2, 3, 31, 39
				mode = 3;
			break;
		case 4: // balancing (standing) with variable joint positions, up/downright equilbrium manifold, old mode 10
			if ( (modeOld == 3) || (modeOld == 31) || (modeOld == 39) ) // mode is 3, 31, 39
				mode = 31;
			else if (modeOld != 41) // mode is 1, 2, 4, 49
				mode = 4;
			break;
	}
	//printf("%d\n",mode);
	
	// automatic mode switches and safety checks - have I fallen over?
	switch (mode)
	{
		case 2:  // balancing (standing) at initial joint positions RC drive, old mode 7
			if (abs(xhat[6]) > 0.99)			// if leaning too far forward or backward. abs() only defined for integers
			{
				//mode = 1;
				motorESTOP();
				ESTOP = 1;
			}
			break;
		case 31: // leaning back for transitioning from kneeling to standing
			if (xhat[6] < THETA_LEAN_BACK) // leaned back far enough
				mode = 41; // stand up, activate balancing controller
			// add case for tip over?
			break;
		case 41: // raising theta while transitioning from kneeling to standing
			if (xhat[6] > THETA_KNEEL2STAND) // nearly fully upright
				mode = 4;
			else if ( abs(xhat[0] + xhat[1] - ref[0] - ref[1]) > PHI_RUNAWAY) // run away
				mode = 1; // should be 3 or crash recovery mode?
			break;
		case 4:  // balancing (standing) with variable joint positions, up/downright equilbrium manifold, old mode 10
			/*if (xhat[6] > 0.99) // fell forward
				mode = 1; // should be 3 or crash recovery mode?
			else*/ if ( abs(xhat[0] + xhat[1] - ref[0] - ref[1]) > PHI_RUNAWAY) // run away
				mode = 1; // should be 3 or crash recovery mode?
			break;
		case 49:
			if (xhat[6] < THETA_STAND_TO_KNEEL) // ready to tip down into kneeling mode
				mode = 39; // mode 39 then puts theta ref ~0
			else if ( abs(xhat[0] + xhat[1] - ref[0] - ref[1]) > PHI_RUNAWAY) // run away
				mode = 1; // should be 3 or crash recovery mode?
			break;
		case 39:
			if (xhat[6] > THETA_KNEEL_UPRIGHT) // theta ~0 while kneeling
				mode = 3;
			break;
	}
}

void reference()
{
	
	for (i = 0; i < 14; i++)
		refOld[i] = ref[i];
	
	switch (mode)
	{
		case 1: // kneeling RC driving w/synced and locked hip and knee joints
			if (modeOld != 1)
			{
				ref[2] = (xhat[2]+xhat[3])/2;
				ref[3] = ref[2];
				//ref[0] = (xhat[0]+xhat[1])/2;
				ref[0] = ref[2];
				ref[1] = ref[0];
				ref[4] = (xhat[4]+xhat[5])/2;
				ref[5] = ref[4];
				ref[6] = xhat[6];
				for (i = 7; i < 14; i++)
					ref[i] = 0;
				//reset_Encoder();	// UNCOMMENT FOR PROPER RESETTING BEFORE BALANCING
			}
			else
			{
				ref[6] = ref[6] + JOYSTICK_HIP_GAIN*dt*joy[3];
				if (ref[6] > THETA_KNEELING_LIMIT_POS)
					ref[6] = THETA_KNEELING_LIMIT_POS;
				else if (ref[6] < THETA_KNEELING_LIMIT_NEG)
					ref[6] = THETA_KNEELING_LIMIT_NEG;
			}
			yawRef = 0;
			reset_Encoder();	// UNCOMMENT WHEN NOT TESTING LEFT ENCODER ISSUE
			break;
		case 2: // balancing (standing)
			if (modeOld != 2)
			{
				ref[2] = (xhat[2]+xhat[3])/2;
				ref[3] = ref[2];
				ref[0] = ref[2];
				ref[1] = ref[0];
				ref[4] = (xhat[4]+xhat[5])/2;
				ref[5] = ref[4];
				ref[6] = xhat[6];
				for (i = 7; i < 14; i++)
					ref[i] = 0;
				reset_Encoder();
				yawRef = 0;
			}
			ref[7] = JOYSTICK_DRIVE_GAIN*joy[1];
			ref[8] = ref[7];
			ref[0] = ref[0] + dt*ref[7];
			ref[1] = ref[0];
			yawRef = yawRef + JOYSTICK_YAW_GAIN*joy[0];
			break;
		case 3: // drive around in kneeling mode, thighs at fixed angle, theta adjustable within bounds
		case 31: // lean back before uprighting
		case 39: // lean forward after downrighting
			switch(mode)
			{
				case 3:
					if (modeOld != 3)
						ref[6] = 0;//( xhat[6] - 0.5*(xhat[4]+xhat[5]) ) + GAMMA_KNEEL;	//xhat[6];
					else
						ref[6] = ref[6] + JOYSTICK_HIP_GAIN*dt*joy[3];
					if (ref[6] > THETA_KNEELING_LIMIT_POS)
						ref[6] = THETA_KNEELING_LIMIT_POS;
					else if (ref[6] < THETA_KNEELING_LIMIT_NEG)
						ref[6] = THETA_KNEELING_LIMIT_NEG;
					break;
				case 31:
					ref[6] = THETA_LEAN_BACK;
					reset_Encoder();
					break;
				case 39:
					ref[6] = THETA39; // torso upright while kneeling
					break;
			}
			ref[2] = ALPHA_KNEEL;
			ref[3] = ALPHA_KNEEL;
			ref[4] = GAMMA_KNEEL;
			ref[5] = GAMMA_KNEEL;
			break;
		//case 33: // move joints through up/downrighting equilbrium manifold w/o balancing, old mode 9
		case 4: // balancing (standing) with variable joint positions, up/downright equilbrium manifold, old mode 10
		case 41: // transitioning from kneeling to standing
		case 49: // transitioning from standing to kneeling
			if (modeOld == 31)
			{
				yawRef = (22.087)*(xhat[0]-xhat[1]);
				treadd = 0;
				tread = ( xhat[0] + xhat[1] - xhat[2] - xhat[3] ) / 2;
				t = 0.7;
			}
			else if ( (modeOld != 4) && (modeOld != 41) && (modeOld != 49))	// mode is not any of 33, 4, 41, 49
			{
				// initialize ref based on current joint positions
				yawRef = (22.087)*(xhat[0]-xhat[1]);
				treadd = 0;
				tread = ( xhat[0] + xhat[1] - xhat[2] - xhat[3] ) / 2;
				t = xhat[6]/(-PI/2); 
			}
			else 
			{
				// integrate joysticks
				switch(mode)
				{
					case 4:
						yawRef = yawRef + JOYSTICK_YAW_GAIN*joy[0];
						treadd = JOYSTICK_DRIVE_GAIN*joy[1];
						tread = tread + dt*treadd;
						t = t + JOYSTICK_BOOM_GAIN*dt*joy[3];
						break;
					case 41:
						treadd = 0;
						if (t > T41)
							t = t + KNEEL2STAND_INCREMENT1*dt;
						else
							t = t + KNEEL2STAND_INCREMENT2*dt;
						break;
					case 49:
						treadd = 0;
						t = t + STAND2KNEEL_INCREMENT*dt;
						break;
					/*case 33:
						reset_Encoder();
						yawRef = 0;
						treadd = 0;
						tread = ( xhat[0] + xhat[1] - xhat[2] - xhat[3] ) / 2;
						t = t + JOYSTICK_BOOM_GAIN*dt*joy[3];
						break;*/
				}
				if (t < 0)
					t = 0;
				else if (t > 1)
					t = 1;

			}
			ref[6]  = -PI/2*t;
			ref[2]  = 0.25 + (PI/2 - 0.25)*t;
			ref[3]  = ref[2];
			ref[4]  = (asin(-( c*sin(ref[2]) + e*sin(ref[6]))/d));
			ref[5]  = ref[4];
			ref[0]  = ref[2] + tread;
			ref[1]  = ref[0];
			ref[13] = (ref[6] - refOld[6])/dt;
			ref[11] = (ref[4] - refOld[4])/dt;
			ref[12] = ref[11];
			ref[9]  = (ref[2] - refOld[2])/dt;
			ref[10] = ref[9];
			ref[7]  = ref[9] + treadd;
			ref[8]  = ref[7];
			break;
	}
}

void controller()
{	
	switch (mode)
	{
		case 1: // kneeling RC driving, old mode 4
		case 3: // kneeling RC driving w/fixed gamma and variable theta
		case 31: // leaning backward before uprighting
		case 39: // leaning forward after downrighting
			switch (mode)
			{
				case 1:
				case 3:
					u[0] = joy[1] - joy[0];
					u[1] = joy[1] + joy[0];
					break;
				case 31:
					if (xhat[6] < THETA_KNEELING_LIMIT_NEG)
					{
						u[0] = KNEEL2STAND_U1;
						u[1] = KNEEL2STAND_U1;
					}
					else
					{
						u[0] = 0;
						u[1] = 0;
					}
					break;
				case 39:
					u[0] = STAND2KNEEL_U1;
					u[1] = STAND2KNEEL_U1;
					break;
			}
			for (i = 2; i < 4; i++)
				u[i] = KNEEL_KNEE_P_GAIN*( (xhat[i]-ref[i])-(xhat[i+2]-ref[i+2]) );
			for (i = 4; i < 6; i++)
				u[i] = KNEEL_HIP_P_GAIN*( (xhat[i]-ref[i])-(xhat[6]-ref[6]) );
			break;
		case 2: // balancing (standing) with fixed/initial joint positions, old mode 7
		case 4: // balancing (standing) with variable joint positions, up/downright equilbrium manifold, old mode 10
		case 41: // transitioning from kneeling to standing
		case 49: // transitioning from standing to kneeling
			
			// a, b, c, and d defined in Robot_Values.h
			ustar[1] = a*sin(ref[2]);
			ustar[2] = b*( c*sin(ref[2]) + d*sin(ref[4]) );
			
			if (mode != 2) // 4, 41, or 49, do gain scheduling
			{
				//u = K*(xhat - ref) + ustar; with gain scheduling
				int lowRow = nGains - 1;
				float high = 0;
				float index = abs(xhat[6])/((PI/2)/(nGains-1));
				if (index < nGains - 1)
				{
					 lowRow = floor(index);
					 high = index-lowRow;
				}
				for (i = 0; i < 3; i++) // 3 needs to be 6 for moonwalking
				{
					u[i] = 0;
					for (j = 0; j < 14; j++)
						u[i] = u[i] + ((1-high)*KS[lowRow][i][j] + high*KS[lowRow+1][i][j])*(xhat[j]-ref[j]);
					u[i] = u[i] + ustar[i];
				}
				
			}
			else // mode == 2
			{
				//u = K*(xhat - ref) + ustar;
				for (i = 0; i < 3; i++) // 3 needs to be 6 for moonwalking
				{
					u[i] = 0;
					for (j = 0; j < 14; j++)
						u[i] = u[i] + K[i][j]*(xhat[j]-ref[j]);
					u[i] = u[i] + ustar[i];
				}
			}
			
			// friction compensator
			if (u[0] < FC_BETA)
			{
				if (u[0] > -FC_BETA)
					u[0] = u[0] * ((float) FC_ABS);
				else
					u[0] = u[0] - FC_ALPHA;
			}
			else
				u[0] = u[0] + FC_ALPHA;
			
			// proportional yaw controller
			u1y = TREADYAWGAIN*( (22.087)*(xhat[0]-xhat[1]) - yawRef); // 0.085 is quadrature encoder ticks gain
			u2y = KNEEYAWGAIN*( xhat[2]-xhat[4] - (xhat[3]-xhat[5]) ); // check that delta < 2pi?, same as (rightKneePos-leftKneePos)
			u3y = HIPYAWGAIN*(xhat[4]-xhat[5]); // same as (rightHipPos-leftHipPos)

			u[5] = u[2]-u3y;
			u[4] = u[2]+u3y;
			u[3] = u[1]-u2y;
			u[2] = u[1]+u2y;
			u[1] = u[0]-u1y;
			u[0] = u[0]+u1y;
			break;
		default: // modes other than 1, 2, 3, 31, 39, 4, 41, and 49
			for (i = 0; i < 6; i++)
				u[i] = 0;
			break;
	}
	
	// motor saturation
	for (i = 0; i < 6; i++)
	{
		if (u[i] < -ULIM)
			u[i] = -ULIM;
		else if (u[i] > ULIM)
			u[i] = ULIM;
	}
	/*for (i = 0; i < 2; i++)
	{
		if (u[i] < -0.7)
			u[i] = -0.7;
		else if (u[i] > 0.7)
			u[i] = 0.7;
	}//*/
	
	// motor direction
	for (i = 0; i < 6; i++)
		u[i] = UDIR[i] * u[i];
	
}

void debugOutput()
{
	// Function calls that output data through UART for Debugging
	//Outputs4Debugging_IMU();
	//Outputs4Debugging_Estimator();
	//Outputs4Debugging_Encoders();
	//UpdateAnalogRead();
	//Outputs4Debugging_ADC();
	
	
	//printf("%f\n",timeStamp);
	
	// output for debug
	/*if ( (mode != 2) && (mode != 4) )
	{
		//printf("%d\n",mode);
		//Outputs4Debugging_Encoders();
		//printf("\n");
	}//*/
	
	//beforeDebug = get_encoderRcount();// - loopStart;
	//printf("%f\t", afterDebug);
	//printf("%f\n", execTime);
	//printf("%f\t", timeStamp);
	//printf("%f\t", loopStart);
	//printf("%f\t", beforeDebug-loopStart);
	//afterDebug = get_encoderRcount();// - beforeDebug;
	//execTime = millis() - timeStamp;
	//printf("%f\n", afterDebug);
	
	/*beforeDebug = millis()-timeStamp;
	printf("%f\n", afterDebug);
	printf("%f\t", timeStamp);
	printf("%f\t", beforeDebug);
	afterDebug = millis()-timeStamp;//*/
	//printf("%f\n\n", afterDebug);
	
	//for (i = 0; i < 4; i++)
		//printf("%f\t", pots[i]);
	//printf("%f\t",JOYSTICK_YAW_GAIN*joy[0]);
	//printf("%f\t",yawRef);
	//printf("%f\n",u1y);
	//printf("%f\n",ref[0]);
	//for (i = 0; i < 7; i++)
		//printf("%f\t",(xhat[i]-ref[i]));
	//for (i = 6; i < 7; i++)
		//printf("%f\t",xhat[i]);
	//printf("%d\t%f\t%f\t%f\n",button,joy[0],joy[1],joy[3]);
	//printf("%d\n",button);
	//printf("%f\t",u1y);
	//for (i = 2; i < 6; i++)
		//printf("%f\t",u[i]);//*/
			//printf("\n");
	//printf("%f\t",2*K[0][0]*(xhat[0]-ref[0]));
	//printf("%f\t",K[0][0]*(xhat[0]-ref[0])+K[0][1]*(xhat[1]-ref[1]));
	//printf("%f\t",K[0][2]*(xhat[2]-ref[2]));
	//printf("%f\t",K[0][3]*(xhat[3]-ref[3]));
	//printf("%f\t",K[0][4]*(xhat[4]-ref[4]));
	//printf("%f\t",K[0][5]*(xhat[5]-ref[5]));
	//printf("%f\t",K[0][2]*(xhat[2]-ref[2])+K[0][3]*(xhat[3]-ref[3])+K[0][4]*(xhat[4]-ref[4])+K[0][5]*(xhat[5]-ref[5]));
	//printf("%f\t",K[0][6]*(xhat[6]-ref[6]));
	//printf("%f\t",K[0][2]*(xhat[2]-ref[2])+K[0][3]*(xhat[3]-ref[3])+K[0][4]*(xhat[4]-ref[4])+K[0][5]*(xhat[5]-ref[5])+K[0][6]*(xhat[6]-ref[6]));
	//printf("%f\t",K[0][7]*xhat[7]+K[0][8]*xhat[8]);
	//printf("%f\t",2*K[0][9]*xhat[9]);
	//printf("%f\t",2*K[0][11]*xhat[11]);
	//printf("%f\t",K[0][9]*xhat[9]+K[0][10]*xhat[10]+K[0][11]*xhat[11]+K[0][12]*xhat[12]);
	//printf("%f\t",K[0][13]*xhat[13]);//*/
	//printf("%f\t",K[0][9]*xhat[9]+K[0][10]*xhat[10]+K[0][11]*xhat[11]+K[0][12]*xhat[12]+K[0][13]*xhat[13]);
	//printf("%f\t",(2*K[0][9]+2*K[0][11]+K[0][13])*get_thetad());
	//printf("%f\t",(2*K[0][9]+2*K[0][11]+K[0][13])*xhat[13]);
	
	// for logging equilbrium points
	printf("%f\t%f\t%f\t%d\n",0.5*(xhat[2]+xhat[3]),0.5*(xhat[4]+xhat[5]),xhat[6],mode);
	
	//printf("%f\t",xhat[13]);
	//printf("%d",mode);
	//printf("%f\t%f\t%d\n",u[0],u[1],mode);
	//printf("%f\t%f\t%d\n",u[1],(xhat[8]-xhat[10]),mode);
	//printf("\n");
	
	//printf("%d\t%d\t%f\n",digitalRead(0,0),digitalRead(0,1),get_encoderLcount());
	//printf("%f\t%f\t%f\t%f\t%d\n",xhat[6],ref[6],u[4],-u[5],mode);
	//printf("%f\t",xhat[6]);
	//printf("%f\t%f\t%f\n",ref[1],xhat[1],-u[1]);
	
	//printf("%f\t%f\t%f\t%d\n",xhat[6],ref[6],t,mode);
	//printf("%f\t%f\t%f\t%d\n",(xhat[2]-ref[2])-(xhat[4]-ref[4]),(xhat[4]-ref[4])-(xhat[6]-ref[6]),xhat[6],mode);
	
	//printf("%f\t%f\t%f\t%d\n",xhat[2]-ref[2],xhat[4]-ref[4],xhat[6]-ref[6],mode);
	//printf("%f\t%f\t%f\t%d\n",xhat[2],xhat[4],xhat[6],mode);
	//printf("%f\t%f\t%f\t%d\n",xhat[2],xhat[4],xhat[6],mode);
	
	//printf("%f\t%f\t%f\t%d\n",0.5*(xhat[4]+xhat[5]),0.5*(pots[2]+pots[3]),xhat[6],mode);
}

main(void)
{   
	Init_System_Clocks_PLL();				//Initialize System Clocks
	Init_Uart0(115200);							//Initialize UART0 and set to baud rate of 115200
  Init_Digital_IMU2();							//Initialize IMU
	Init_GPIO_Output(3,6);					//Initialize GPIO as output out on (Port,Pin) for onboard LED
	Init_Motors();									//Initialize all Motors with PWM and Direction GPIO pins on Switchbot Carrier Board
	motorESTOP();										// turn off all motor drivers
	Init_Encoders();								//Initialize Encoders which Initializes External Interrupts
	//reset_Encoder();
  Init_ADC(0);										//Enabling ADC in continousmode on pin.  Init_ADC(pin)
	Init_ADC(1);										//Enabling ADC in continousmode on pin.  Init_ADC(pin)
	Init_ADC(5);										//Enabling ADC in continousmode on pin.  Init_ADC(pin)
	Init_ADC(6);										//Enabling ADC in continousmode on pin.  Init_ADC(pin)
	Initialize_Estimator();					//Initialize Estimator
	Init_Interrupt_Priority(10);			// set interrupt priorities
	Init_Timer2_ISR();    					//Initalize Timer 2 ISR. ISR can be located in Timer.c library file or in this main file. Currently set to 10ms
	Init_System_Millis_Timer();

	//maskK(r);
	
  while(1)
  {
	  //Uncomment to make sure microcontroller is actually running and that UART is working	
		//Timer_Count1++;
		//printf("%d\n",Timer_Count1);
		//printf("%f\n",xhat[6]);
		
   }
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////                                                                                      

////Timer2 ISR routine (10ms)
void TMR2_IRQHandler(void)
{
	TISR2 |= TMR_TIF; 																		// Clear timer2 interrupt flag
	//loopStart = get_encoderRcount();
	//timeStamp = millis();// - timeStamp;
	//printf("%f\t", timeStamp);
	//Checks to see that timer interrupt is working.
	Timer_Count++;																							
	//printf("ISR2 Loop Count: %d\n",Timer_Count);
	//Timer_Count1 = 0;		// reset main loop timer count
	
	// heart beat LED
	if (ESTOP == 0) // flash slowly if ESTOP is off
		if (Timer_Count%150 > 75)	digitalWrite(3,6,0);
		else	digitalWrite(3,6,1);
	else						// flash quickly if ESTOP is on
		if (Timer_Count%20 > 10)	digitalWrite(3,6,0);
		else	digitalWrite(3,6,1);
	
	
	estimator();			// estimate joint and body angles and velocities from sensors
	stateMachine();		// set mode from user input (over UART0) and state estimate
	reference();			// calculate reference position from mode, user input, and state estimate
	controller();			// calculate motor commands from mode, user input, reference, and state estimate
	driveMotors(u);		// update motor speed commands
	//debugOutput();		// output debug data over UART0
	
}
