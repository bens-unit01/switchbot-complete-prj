/*
 Copyright (c) 2013 OpenSourceRF.com.  All right reserved.

 This library is free software; you can redistribute it and/or
 modify it under the terms of the GNU Lesser General Public
 License as published by the Free Software Foundation; either
 version 2.1 of the License, or (at your option) any later version.

 This library is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 See the GNU Lesser General Public License for more details.

 You should have received a copy of the GNU Lesser General Public
 License along with this library; if not, write to the Free Software
 Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

/*
  Copyright (c) 2011 Arduino.  All right reserved.

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 2.1 of the License, or (at your option) any later version.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  See the GNU Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public
  License along with this library; if not, write to the Free Software
  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
*/

#include "time_utils.h"

// widen rtc1 to 40-bit (1099511627775 ticks = 33554431999969us = 388 days)
// (dont overflow uint64_t when multipying by 1000000)
volatile uint64_t rtc1 = 0;

void RTC1_IRQHandler( void )
{
  if (NRF_RTC1->EVENTS_OVRFLW)
  {
    // extend counter
    rtc1 += 0x1000000LLU;
    // truncate to 40-bit
    rtc1 &= 0xffffffffffLLU;
    NRF_RTC1->EVENTS_OVRFLW = 0;
  }

  NRF_RTC1->EVENTS_COMPARE[0] = 0;
}

uint64_t millis64( void )
{
  return (rtc1 + NRF_RTC1->COUNTER) * 1000 >> 15;  // divide by 32768
}

uint64_t micros64( void )
{
  // accurate to 30.517us
  return (rtc1 + NRF_RTC1->COUNTER) * 1000000 >> 15;  // divide by 32768
}

uint32_t millis( void )
{
	return millis64();
}

uint32_t micros( void )
{
  return micros64();
}

void delay( uint32_t ms )
{
  uint32_t start = millis();
 // while (millis() - start < ms)
  //  yield();
}

void delayMicroseconds( uint32_t us )
{
    while (us--)
    {
        __ASM(" NOP\n\t"
        " NOP\n\t"
        " NOP\n\t"
        " NOP\n\t"
        " NOP\n\t"
        " NOP\n\t"
        " NOP\n\t"
        " NOP\n\t"
        " NOP\n\t"
        " NOP\n\t"
        " NOP\n\t");
    };
}


void rtc_config()
{
    NRF_RTC1->TASKS_STOP = 1;	// Stop RTC timer
    NRF_RTC1->TASKS_CLEAR = 1;	// Clear timer
	NRF_RTC1->PRESCALER = 0;	// No prescaling => 1 tick = 1/32768Hz = 30.517us
	NRF_RTC1->EVTENSET = (RTC_EVTENSET_OVRFLW_Set << RTC_EVTENSET_OVRFLW_Pos); // Enable OVRFLW Event
    NRF_RTC1->INTENSET = (RTC_INTENSET_OVRFLW_Set << RTC_INTENSET_OVRFLW_Pos); // Enable OVRFLW Interrupt

	NVIC_SetPriority(RTC1_IRQn, APP_IRQ_PRIORITY_LOW);
	NVIC_EnableIRQ(RTC1_IRQn);

	NRF_RTC1->TASKS_START = 1;	// Start RTC
}


