//=====================================================================================================================
/*---------------------------------------------------------------------------------------------------------*/
/* Module Parameters Service(0xFF90)                                                                       */
/* --Module Parameter Device Name Characteristic(0xFF91)                RW 16                              */
/* --Module Parameter BTCommunication Interval Characteristic(0xFF92)   RW  1                              */
/* --Module Parameter Reset Module Characteristic(0xFF94)               W   1                              */
/* --Module Parameter Broadcast Period Characteristic(0xFF95)           RW  1                              */
/* --Module Parameter Transmit Power Characteristic(0xFF97)             RW  1                              */
/* --Module Parameter Custom Broadcast Data Characteristic(0xFF98)      RW 16                              */
/* --Module Parameter Connected Broadcast Data Characteristic(0xFF9B)   W  20                              */
/* --Module Parameter Connected Broadcast Enable Characteristic(0xFF9C) RW  1                              */
/*---------------------------------------------------------------------------------------------------------*/
#ifndef __NST_BLE_MPS_H__
#define __NST_BLE_MPS_H__

#include "ble.h"

typedef struct ble_wow_mps_data_s
{
    uint32_t dummy;
    uint8_t  device_id[4];
    uint32_t active_status;
    uint8_t  device_name[16];
    uint8_t  custom_broadcast_data[16];
    uint8_t  custom_broadcast_data_num;
    uint8_t  dummy1[3];
} ble_wow_mps_data_t;

extern ble_wow_mps_data_t m_wow_mps_data;

void ble_mps_on_ble_evt(ble_evt_t * p_ble_evt);
void ble_mps_init(void);

/*---------------------------------------------------------------------------------------------------------*/
/* Description:                                                                                            */
/*    Function to get connected_broadcast_enable                                                           */
/*---------------------------------------------------------------------------------------------------------*/
uint8_t ble_mps_get_connected_broadcast_enable(void);
/*---------------------------------------------------------------------------------------------------------*/
/* Description:                                                                                            */
/*    Function to save module parameters.                                                                  */
/* Parameter:                                                                                              */
/*    NULL                                                                                                 */
/* Return:                                                                                                 */
/*    NULL                                                                                                 */
/*---------------------------------------------------------------------------------------------------------*/
void ble_mps_save_param(void);
/*---------------------------------------------------------------------------------------------------------*/
/* Description:                                                                                            */
/*    Function to load module parameters.                                                                  */
/* Parameter:                                                                                              */
/*    NULL                                                                                                 */
/* Return:                                                                                                 */
/*    NULL                                                                                                 */
/*---------------------------------------------------------------------------------------------------------*/
void ble_mps_load_param(void);
/*---------------------------------------------------------------------------------------------------------*/
/* Description:                                                                                            */
/*    Function to updata mps device name.                                                                  */
/* Parameter:                                                                                              */
/*    NULL                                                                                                 */
/* Return:                                                                                                 */
/*    NRF_SUCCESS on success, otherwise an error code.                                                     */
/*---------------------------------------------------------------------------------------------------------*/
uint32_t ble_mps_device_name_update(void);
/*---------------------------------------------------------------------------------------------------------*/
/* Description:                                                                                            */
/*    Function to updata mps connection interval.                                                          */
/* Parameter:                                                                                              */
/*    NULL                                                                                                 */
/* Return:                                                                                                 */
/*    NRF_SUCCESS on success, otherwise an error code.                                                     */
/*---------------------------------------------------------------------------------------------------------*/
uint32_t ble_mps_connection_interval_update(void);
/*---------------------------------------------------------------------------------------------------------*/
/* Description:                                                                                            */
/*    Function to updata mps advertising interval.                                                         */
/* Parameter:                                                                                              */
/*    NULL                                                                                                 */
/* Return:                                                                                                 */
/*    NRF_SUCCESS on success, otherwise an error code.                                                     */
/*---------------------------------------------------------------------------------------------------------*/
uint32_t ble_mps_advertising_interval_update(void);
/*---------------------------------------------------------------------------------------------------------*/
/* Description:                                                                                            */
/*    Function to updata mps transmit power.                                                               */
/* Parameter:                                                                                              */
/*    NULL                                                                                                 */
/* Return:                                                                                                 */
/*    NRF_SUCCESS on success, otherwise an error code.                                                     */
/*---------------------------------------------------------------------------------------------------------*/
uint32_t ble_mps_transmit_power_update(void);

#endif // __NST_BLE_MPS_H__
//=====================================================================================================================
