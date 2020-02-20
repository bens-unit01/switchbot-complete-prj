
#include <stdbool.h>
#include "SwitchbotNordic.h"
#include "debug.h"

#define MAX_SPEED  14
#define MAX_SPEED_LFT_RGT 16
int head, range;
uint8_t tmp_buffer[4];
uint8_t fl_new[8], fl_old[8];
int _head; 
int easy_range; 
//int Range, Head, easyRange;
static void motionControl_YAW(int Head, int Range, int MaxRange,  int16_t *lft_rgt)
{
	uint16_t yawSpeed;

	yawSpeed = 180 - abs(Head);

	yawSpeed = yawSpeed / 4;

	if (yawSpeed > 0)
	{
		yawSpeed += 1;
	//	yawSpeed += 4;
	}

	if (yawSpeed > MAX_SPEED_LFT_RGT)
	{
		yawSpeed = MAX_SPEED_LFT_RGT;
	}

	if (Head > 0)  //turn left
	{
		*lft_rgt = 0x60 + yawSpeed;
	}
	else
	{
		*lft_rgt = 0x40 + yawSpeed;
	}
	if ((180 - abs(Head) < 3) && (Range > (MaxRange - 10)))
//	if ((180 - abs(Head) < 6) && (Range > (MaxRange - 20)))
	{
		*lft_rgt = 0;
	}

}

static void motionControl_DriveFWD(int easyRange, int Head,
		int16_t *fwd_bwd)
{
	uint16_t fwdSpeed;
	uint16_t distance;

	distance = 30;
	//	distance = 10;

	fwdSpeed = abs(easyRange - distance);

	if (fwdSpeed > 0)
	{

		fwdSpeed += 1;
	}

	if (fwdSpeed > MAX_SPEED)
	{
		fwdSpeed = MAX_SPEED;
	}

	if ((180 - abs(Head)) <= 30)  //pitch forward
	{

		if (easyRange > distance) //move forward
		{
			*fwd_bwd = 0x00 + fwdSpeed;

		}
		else
		{

			*fwd_bwd = 0x00;

		}

	}
	else
	{

		*fwd_bwd = 0x00;
//        	fwd_bwd = 0x01;
	}

}


bool calculate_speed2(uint8_t IR[], int MaxRange, int16_t *fwd_bwd,
		int16_t *lft_rgt, uint8_t debug_table[])
{

	bool condition_1 = false;

	calc_coord(IR, &head, &range);  // calculate the range before filtering

	if (range >= MaxRange)  // we reached the beacon
	{
      condition_1 = true;
	}
	//PGM_LOG(" %d %d ", range, condition_2);

// filtering -----

	memcpy(fl_new, IR, 4);
	for (uint8_t i = 0; i < 4; i++)
	{
//		fl_new[i] = ((fl_old[i] * 4) + (fl_new[i])) / 5;
//		fl_new[i] = ((fl_old[i] * 8) + (fl_new[i])) / 9;
	fl_new[i] = ((fl_old[i] * 3) + (fl_new[i])) / 4;
	}

	memcpy(fl_old, fl_new, 4);

//----------------



	calc_coord(fl_new, &head, &range);

//		if (range >= MaxRange)  // we reached the beacon
//		{
//	      condition_1 = true;
//		}
	PGM_LOG(" %d %d \n", range, condition_1);
	//LOG(" %4d %4d %4d %4d \n", fl_new[0], fl_new[1], fl_new[2], fl_new[3]);

	_head = head;
	easy_range = 140 - range;
	motionControl_YAW(_head, range, MaxRange, lft_rgt);
	motionControl_DriveFWD(easy_range, _head, fwd_bwd);

//	if(*lft_rgt == 96) lft_rgt = 0;

	return condition_1;
}



bool calculate_speed(uint8_t IR[], int MaxRange, int16_t *fwd_bwd,
		int16_t *lft_rgt, uint8_t debug_table[])
{

	bool condition_1 = false;
	bool condition_2 = false;

	calc_coord(IR, &head, &range);  // calculate the range before filtering

	if (range >= MaxRange)  // we reached the beacon
	{
      condition_2 = true;
	}
	PGM_LOG(" %d %d ", range, condition_2);
// filtering -----
	memcpy(fl_new, IR, 8);
	for (uint8_t i = 0; i < 8; i++)
	{
		fl_new[i] = ((fl_old[i] * 4) + (fl_new[i])) / 5;
	}

	memcpy(fl_old, fl_new, 8);
//----------------


	for (uint8_t i = 0; i < 4; i++)
		tmp_buffer[i] = fl_new[i + 4]; // we take values for the far receivers
	calc_coord(tmp_buffer, &head, &range);

	if (range >= 54)
	{
		condition_1 = true;
		for (uint8_t i = 0; i < 4; i++)
			tmp_buffer[i] = fl_new[i]; // we take the values for the close receivers
		calc_coord(tmp_buffer, &head, &range);
	}

	PGM_LOG(" %d %d \n", range, condition_1);
	//LOG(" %4d %4d %4d %4d \n", fl_new[0], fl_new[1], fl_new[2], fl_new[3]);

	_head = head;
	easy_range = 140 - range;
	motionControl_YAW(_head, range, MaxRange, lft_rgt);
	motionControl_DriveFWD(easy_range, _head, fwd_bwd);

//	if(*lft_rgt == 96) lft_rgt = 0;

	return condition_1 && condition_2;
}

int calc_coord(uint8_t IR[], int *Head, int *Range)
{

	int sVal;
	int head, theta;
	int mIdx, i;
	int mVal, minV;
	int IRc[4];

// find max value in the array [M2 M3 M4 M1]

//   M3 - Back
//   M0 - Left
//   M1 - Front
//   M2 - Right

	mIdx = 0;
	mVal = IR[0];
	minV = IR[0];

	// find which receiver get the maximum intensity
	for (i = 0; i < 4; i++)
	{
		if (IR[i] > mVal)
		{
			mIdx = i;
			mVal = IR[i];
		}

		if (IR[i] < minV)
		{
			minV = IR[i];
		}
	}

	for (i = 0; i < 4; i++)
	{
		IRc[i] = IR[i] - minV;
	}

	// use the max intensity to orient the RX array
	// calculate the angle as a weighteed average
	switch (mIdx)
	{
	case 0:           //max = R0 - Right
		sVal = (IRc[3] + IRc[1] + IRc[0]);
		mVal = ((IR[3] + IR[1]) >> 1) + IR[0];
		if (sVal == 0)
			sVal = 1;
		head = (IRc[1] - IRc[3]);
		theta = (head * 90) / sVal;
		theta = theta - 90;

		break;

	case 1:           // max = R1 - Back
		sVal = (IRc[2] + IRc[0] + IRc[1]);
		mVal = ((IR[2] + IR[0]) >> 1) + IR[1];
		if (sVal == 0)
			sVal = 1;
		head = (IRc[2] - IRc[0]);
		theta = (head * 90) / sVal;

		break;

	case 2:           // max = R2 - Left
		sVal = (IRc[3] + IRc[1] + IRc[2]);
		mVal = ((IR[3] + IR[1]) >> 1) + IR[2];
		if (sVal == 0)
			sVal = 1;
		head = (IRc[3] - IRc[1]);
		theta = (head * 90) / sVal;
		theta = theta + 90;

		break;

	case 3:           // max = R4 - Front
		sVal = (IRc[2] + IRc[0] + IRc[3]);
		mVal = ((IR[2] + IR[0]) >> 1) + IR[3];
		if (sVal == 0)
			sVal = 1;
		head = (IRc[0] - IRc[2]);
		theta = (head * 90) / sVal;
		theta = theta + 180;
		if (theta > 180)
		{
			theta = theta - 360;
		}

		break;
	}

	*Head = theta;
	*Range = mVal;

	/*
	 if (Range >= MaxRange)
	 {
	 is_stop_condition = true;
	 easyRange = 5;
	 }
	 else
	 {

	 easyRange = 140 - Range;
	 }
	 */

	return 1;
}
