/*
 * debug.h
 *
 *  Created on: Aug 12, 2015
 *      Author: Raouf
 */

#ifndef DEBUG_H_
#define DEBUG_H_
//#define DEBUG_MODE
//#define DEBUG_MODE_DEV
//#define DEBUG_MODE_MEDIABOX
//#define DEBUG_MODE_SEGGER
//#define BOND_MODE



#pragma GCC diagnostic ignored "-Wformat"
#pragma GCC diagnostic ignored "-Wpointer-sign"

#ifdef DEBUG_MODE
#define LOG  printf
#define PGM_LOG printf
#else
#define LOG(...)
#define PGM_LOG(...)
#endif

#endif /* DEBUG_H_ */
