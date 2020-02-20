#ifndef __D_FLASH_DATA_H__
 #define __D_FLASH_DATA_H__

#include	"Pram.h"
#include	"nst_ble_mps.h"

//flash storage block 0
#define SAVED_DEVICE_NAME_ADDR_INDEX      0
#define SAVED_DEVICE_NAME_SIZE            sizeof(m_wow_mps_data)
#define SAVED_DEVICE_NAME_OFFSET          0

//flash storage block 1
#define SAVED_MOTOR_SETTING_ADDR_INDEX    1
#define SAVED_MOTOR_SETTING_SIZE          sizeof(Flash_struct)
#define SAVED_MOTOR_SETTING_OFFSET        0


/*=======================================================
Description:
 save device name
Parameter:
  [in] pu8_buf:   device name
  [out]
Return:
Note:
=======================================================*/
bool d_flash_data_save_device_name(uint8_t *pu8_device_name);

/*=======================================================
Description:
 load saved device name in flash
Parameter:
  [in]
  [out]pu8_buf:   device name
Return:
Note:
=======================================================*/
bool d_flash_data_load_device_name(uint8_t *pu8_device_name);

/*=======================================================
Description:
 save motor setting to flash
Parameter:
  [in]
  [out]pu8_motor_setting: motor setting
Return:
Note:
=======================================================*/
bool d_flash_data_save_motor_setting(uint8_t *pu8_motor_setting);

/*=======================================================
Description:
 load motor setting from flash
Parameter:
  [in]
  [out]pu8_motor_setting: motor setting
Return:
Note:
=======================================================*/
bool d_flash_data_load_motor_setting(uint8_t *pu8_motor_setting);

#endif
