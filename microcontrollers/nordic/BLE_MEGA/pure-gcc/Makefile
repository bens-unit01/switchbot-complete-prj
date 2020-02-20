SHELL=C:/Windows/System32/cmd.exe
# List all source files the application uses.
APPLICATION_SRCS = $(notdir $(wildcard ../*.c))
APPLICATION_SRCS += nrf_delay.c
APPLICATION_SRCS += app_gpiote.c
APPLICATION_SRCS += ble_hrs_c.c 
APPLICATION_SRCS += ble_debug_assert_handler.c 
APPLICATION_SRCS += pstorage.c 
APPLICATION_SRCS += device_manager_central.c 
APPLICATION_SRCS += softdevice_handler.c 
APPLICATION_SRCS += ble_db_discovery.c 





PROJECT_NAME = $(shell basename "$(realpath ../)")

DEVICE = NRF51
BOARD = BOARD_PCA10001
#BOARD = BOARD_NRF6310
#SEGGER_SERIAL = 518108213
SEGGER_SERIAL = 518108276 

USE_SOFTDEVICE = s120
USE_EXT_SENSORS = 1

SDK_PATH = ../../../../../../../../../../Development/ble/NORDIC_DEV_6/nrf51822_sdk/
TOOLCHAIN_PATH = $(SDK_PATH)arm-gcc/bin/
TEMPLATE_PATH = $(SDK_PATH)nrf51-pure-gcc-setup/template/
SOFTDEVICE = $(SDK_PATH)softdevice/s120_nrf51822_1.0.1_softdevice.hex
#CFLAGS = -Os

#flags common to all targets
#CFLAGS  = -DNRF51
#CFLAGS += -DBLE_STACK_SUPPORT_REQD # already defined in pure-gcc/template/Makefile
#CFLAGS += -DSOFTDEVICE_PRESENT
#CFLAGS += -DBOARD_NRF6310
#CFLAGS += -mcpu=cortex-m0
#CFLAGS += -mthumb -mabi=aapcs --std=gnu99
#CFLAGS += -Wall -Werror -O3
#CFLAGS += -mfloat-abi=soft
# keep every function in separate section. This will allow linker to dump unused functions
#CFLAGS += -ffunction-sections -fdata-sections -fno-strict-aliasing
#CFLAGS += -flto -fno-builtin
CFLAGS += -DDEBUG -ggdb -O0 # ligne a ajouter dans le makefile 
# keep every function in separate section. This will allow linker to dump unused functions
#LDFLAGS += -Xlinker -Map=$(LISTING_DIRECTORY)/$(OUTPUT_FILENAME).map
#LDFLAGS += -mthumb -mabi=aapcs -L $(TEMPLATE_PATH) -T$(LINKER_SCRIPT)
#LDFLAGS += -mcpu=cortex-m0
# let linker to dump unused sections
#LDFLAGS += -Wl,--gc-sections
# use newlib in nano version
LDFLAGS += --specs=nano.specs -lc -lnosys  # fix the issue of :  region RAM overflowed with stack


  
GDB_PORT_NUMBER = 2331

include $(TEMPLATE_PATH)Makefile
