LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

TARGET_PLATFORM := android-3
LOCAL_MODULE    := sercd
LOCAL_SRC_FILES :=  SerialPort.c 
LOCAL_CFLAGS    := -DVERSION=\"3.0.0\"
LOCAL_LDLIBS    := -llog
include $(BUILD_SHARED_LIBRARY)
