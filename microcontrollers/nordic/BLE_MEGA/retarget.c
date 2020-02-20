/* Copyright (c) 2012 Nordic Semiconductor. All Rights Reserved.
 *
 * The information contained herein is property of Nordic Semiconductor ASA.
 * Terms and conditions of usage are described in detail in NORDIC
 * SEMICONDUCTOR STANDARD SOFTWARE LICENSE AGREEMENT.
 *
 * Licensees are granted free, non-transferable use of the information. NO
 * WARRANTY of ANY KIND is provided. This heading must NOT be removed from
 * the file.
 *
 */
 
#include <stdio.h>
#include <stdint.h>
#include "uart_comm2.h"
#include "nordic_common.h"
#include "nrf51.h"
#include "nrf51_bitfields.h"
#include "SwitchbotNordic.h"
//#include "boards.h"

struct __FILE { int handle; /* Add whatever you need here */ };
FILE __stdout;
FILE __stdin;

void retarget_init(void)
{
    simple_uart_config(RTS_PIN_NUMBER, TX_PIN_NUMBER, CTS_PIN_NUMBER, RX_PIN_NUMBER, HWFC);
}

int fputc(int ch, FILE * p_file) 
{
    simple_uart_put((uint8_t)ch);
    return 0;
}


int _write(int fd, char * str, int len)
{
    for (int i = 0; i < len; i++)
    {
        simple_uart_put(str[i]);
    }
    return len;
}


/**
 *@}
 **/
