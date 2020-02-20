/*
 * blinkm.c
 *
 *  Created on: Jan 29, 2016
 *      Author:Raouf
 */

#include "blinkm.h"
#include "twi_master.h"

static void BlinkM_setFadeSpeed(byte addr, byte fadespeed)
{
	uint8_t data_table[4] = {'f', fadespeed};
  //  HAL_I2C_Master_Transmit(&hi2c1, addr, data_table, 4, 1000);
 bool s =	twi_master_transfer(addr, data_table, 4, TWI_ISSUE_STOP);
//	printf("setFadeSpeed  %d", s);
}



static void BlinkM_stopScript(byte addr)
{
	uint8_t data[] = {'o'};
   // HAL_I2C_Master_Transmit(&hi2c1, addr, &data, 1, 1000);
bool s =	twi_master_transfer(addr, data, 1, TWI_ISSUE_STOP);
//	printf("stopScript %d", s);
}



static void BlinkM_fadeToRGB(byte addr, byte red, byte grn, byte blu)
{
	uint8_t data_table[4] = {'c', red, grn, blu};
    //HAL_I2C_Master_Transmit(&hi2c1, addr, data_table, 4, 1000);
bool s =	twi_master_transfer(addr, data_table, 4, TWI_ISSUE_STOP);
//	printf("fadeToRGB %d", s);
}

static void BlinkM_playScript(byte addr, byte script_id, byte reps, byte pos)
{
	uint8_t data_table[4] = {'p', script_id, reps, pos};
   // HAL_I2C_Master_Transmit(&hi2c1, addr, data_table, 4, 1000);
bool s = 	twi_master_transfer(addr, data_table, 4, TWI_ISSUE_STOP);
//	printf("playScript %d", s);
}

static void BlinkM_setTimeAdj(byte addr, byte timeadj)
{
	uint8_t data_table[2] = {'t', timeadj};
    //HAL_I2C_Master_Transmit(&hi2c1, addr, data_table, 2, 1000);
bool s =	twi_master_transfer(addr, data_table, 2, TWI_ISSUE_STOP);
//	printf("setTime %d", s);

}

void BlinkM_init(byte addr){
	 BlinkM_stopScript( addr);
	 BlinkM_fadeToRGB( addr, 0xff,0,0);
}

void BlinkM_handleCmd(byte addr, byte script){

    switch (script)
         {

         case 1:  // Solid Red
                BlinkM_stopScript(addr);
        	    BlinkM_setFadeSpeed( addr, 200);
                BlinkM_fadeToRGB( addr, 0xff,0,0);
                 break;
        case 2:  // Solid Blue
                 BlinkM_stopScript(addr);
        	     BlinkM_setFadeSpeed( addr, 200);
                 BlinkM_fadeToRGB( addr, 0,0,0xff);
                 break;
         case 3:  // Solid Amber
                 BlinkM_stopScript( addr);
        	     BlinkM_setFadeSpeed( addr, 200);
                 BlinkM_fadeToRGB( addr, 255,191,0);
                 break;
         case 4:  // Solid Green
                 BlinkM_stopScript( addr);
        	     BlinkM_setFadeSpeed( addr, 200);
                 BlinkM_fadeToRGB( addr, 0,0xff,0);
                 break;
         case 5:  // Flash Green Slow
                  BlinkM_stopScript( addr);
        	      BlinkM_setFadeSpeed(addr, 10);
                  BlinkM_setTimeAdj(addr, 10);
                  BlinkM_playScript(addr, 4,0,0 );
                 break;
         case 6:  // Flash Green Quick
                  BlinkM_stopScript(addr);
        	      BlinkM_setFadeSpeed(addr, 255);
                  BlinkM_setTimeAdj(addr, -40);
                  BlinkM_playScript(addr, 4,0,0 );
                 break;
         case 7:  // Flash Blue Slow
                  BlinkM_stopScript( addr);
        	      BlinkM_setFadeSpeed( addr, 10);
                  BlinkM_setTimeAdj( addr, 10);
                  BlinkM_playScript( addr, 5,0,0 );
                 break;
          case 8:  // Flash Blue Quick
                  BlinkM_stopScript( addr );
        	      BlinkM_setFadeSpeed( addr, 255);
                  BlinkM_setTimeAdj( addr, -40);
                  BlinkM_playScript( addr, 5,0,0 );
                 break;
         case 0:
         default: //OFF
               BlinkM_stopScript( addr);
               BlinkM_playScript( addr, 9,0,0 );
               break;


         }
}

