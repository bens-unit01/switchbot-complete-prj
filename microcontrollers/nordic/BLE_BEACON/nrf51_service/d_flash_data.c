/*--------------------------------------------------------
block 0     --------------------
1024bytes   |device name       |
            |other user data   |
            |                  |
            |                  |
block 1     --------------------
1024bytes   |motor data        | 
            |other factory data|
            |                  |
swap        --------------------
1024bytes   |swap area         | 
            |                  |
            --------------------
--------------------------------------------------------*/

#include <stdint.h>
#include <stdbool.h>

#include "d_flash_data.h"
#include "d_persistent_storage.h"



/*=======================================================
Description:
 save device name
Parameter:
  [in] pu8_buf:   device name 
  [out]
Return:
Note:
=======================================================*/
bool d_flash_data_save_device_name(uint8_t *pu8_device_name)
{
  return  d_persistent_storage_update(SAVED_DEVICE_NAME_ADDR_INDEX,pu8_device_name,SAVED_DEVICE_NAME_SIZE,SAVED_DEVICE_NAME_OFFSET);
}


/*=======================================================
Description:
 load saved device name in flash
Parameter:
  [in]
  [out]pu8_buf:   device name 
Return:
Note:
=======================================================*/
bool d_flash_data_load_device_name(uint8_t *pu8_device_name)
{
  return d_persistent_storage_load(SAVED_DEVICE_NAME_ADDR_INDEX,pu8_device_name,SAVED_DEVICE_NAME_SIZE,SAVED_DEVICE_NAME_OFFSET);
}

/*=======================================================
Description:
 save motor setting to flash
Parameter:
  [in]
  [out]pu8_motor_setting: motor setting
Return:
Note:
=======================================================*/
bool d_flash_data_save_motor_setting(uint8_t *pu8_motor_setting)
{ 
  return d_persistent_storage_update(SAVED_MOTOR_SETTING_ADDR_INDEX,pu8_motor_setting,SAVED_MOTOR_SETTING_SIZE,SAVED_MOTOR_SETTING_OFFSET);
}

/*=======================================================
Description:
 load motor setting from flash
Parameter:
  [in]
  [out]pu8_motor_setting: motor setting
Return:
Note:
=======================================================*/
bool d_flash_data_load_motor_setting(uint8_t *pu8_motor_setting)
{ 
  return d_persistent_storage_load(SAVED_MOTOR_SETTING_ADDR_INDEX,pu8_motor_setting,SAVED_MOTOR_SETTING_SIZE,SAVED_MOTOR_SETTING_OFFSET);
}


/*=======================================================
Description:
Parameter:
  [in]
  [out]
Return:
Note:
=======================================================*/


/*=======================================================
Description:
Parameter:
  [in]
  [out]
Return:
Note:
=======================================================*/





