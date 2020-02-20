SHELL=C:/Windows/System32/cmd.exe

LIBRARY_PATHS +=  ../nrf51_service
LIBRARY_PATHS +=  ../car_driver
SOURCE_PATHS +=  ../nrf51_service
SOURCE_PATHS +=  ../car_driver



# List all source files the application uses.
APPLICATION_SRCS = $(notdir $(wildcard ../*.c))
APPLICATION_SRCS += app_gpiote.c
APPLICATION_SRCS += app_button.c
APPLICATION_SRCS += app_timer.c
APPLICATION_SRCS += app_trace.c
APPLICATION_SRCS += ble_advdata.c
APPLICATION_SRCS += ble_conn_params.c
APPLICATION_SRCS += pstorage.c
APPLICATION_SRCS += device_manager_peripheral.c
APPLICATION_SRCS += ble_bas.c
APPLICATION_SRCS += ble_dis.c
APPLICATION_SRCS += ble_hrs.c
APPLICATION_SRCS += ble_srv_common.c
APPLICATION_SRCS += crc16.c
APPLICATION_SRCS += softdevice_handler.c
APPLICATION_SRCS += nrf_delay.c

APPLICATION_SRCS += ble_sensorsim.c 
APPLICATION_SRCS += ble_hids.c 


APPLICATION_SRCS += SEGGER_RTT.c                       
APPLICATION_SRCS += SEGGER_RTT_printf.c                


APPLICATION_SRCS += Vehicles.c
APPLICATION_SRCS += nst_ble_dts.c
APPLICATION_SRCS += TIMER2.c
APPLICATION_SRCS += RGB_mode.c

PROJECT_NAME = $(shell basename "$(realpath ../)")

DEVICE = NRF51
BOARD = BOARD_PCA10001
#SEGGER_SERIAL = 518004431
SEGGER_SERIAL = 518108213
#SEGGER_SERIAL = 518108276 

USE_SOFTDEVICE = s110

#SDK_PATH = $(HOME)/Projects/nrf51-sdk-6.0.0/nrf51822/
#TEMPLATE_PATH = $(HOME)/Projects/nrf51-pure-gcc-setup/template/
SDK_PATH = ../../../../../../../../../../Development/ble/NORDIC_DEV_6/nrf51822_sdk/
TOOLCHAIN_PATH = $(SDK_PATH)arm-gcc/bin/
TEMPLATE_PATH = $(SDK_PATH)nrf51-pure-gcc-setup/template/

#SOFTDEVICE = $(SDK_PATH)softdevice/s110_nrf51822_6.0.0_softdevice.hex
SOFTDEVICE = $(SDK_PATH)softdevice/s110_nrf51822_7.1.0_softdevice.hex
#CFLAGS = -Os
#CFLAGS += -ffunction-sections -fdata-sections -fno-strict-aliasing
#CFLAGS += -flto -fno-builtin
CFLAGS += -DDEBUG -ggdb -O0 # ligne a ajouter dans le makefile 
LDFLAGS += --specs=nano.specs -lc -lnosys  # fix the issue of :  region RAM overflowed with stack
GDB_PORT_NUMBER = 2331

include $(TEMPLATE_PATH)Makefile
