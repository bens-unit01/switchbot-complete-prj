/*
 * debug.h
 *
 *  Created on: Aug 12, 2015
 *      Author: Raouf
 */

#ifndef DEBUG_H_
#define DEBUG_H_
//#define DEBUG_MODE
//#define DEBUG_MODE_DEV   // setup for the dev-board
//#define DEBUG_MODE_MEDIABOX
//#define DEBUG_MODE_SEGGER
//#define BOND_MODE
//#define DUMP_MODE

#include <stdint.h>
#pragma GCC diagnostic ignored "-Wformat"
#pragma GCC diagnostic ignored "-Wpointer-sign"

#ifdef DEBUG_MODE
#define LOG  printf
#define PGM_LOG(...)
#else
#define LOG(...)
#define PGM_LOG(...)
#define WR_SG(...)
#endif


#define DEBUG_TABLE_SIZE  10
#define DEBUG_STATE_SIZE  10 


void debug_save_value(uint32_t key, uint32_t value); 
uint8_t debug_get_value(uint32_t i, uint32_t j); 
void debug_save_state(uint8_t index, uint8_t state); 
uint8_t debug_get_state(uint8_t index ); 

#endif /* DEBUG_H_ */
