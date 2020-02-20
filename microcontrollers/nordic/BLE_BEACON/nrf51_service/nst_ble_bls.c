//=====================================================================================================================
/*---------------------------------------------------------------------------------------------------------*/
/* Battery Level Service(0x180F)                                                                           */
/* --Battery Level Report Characteristic(0x2A19)                       RN   1                              */
/*---------------------------------------------------------------------------------------------------------*/
#include <stdint.h>
#include <string.h>
#include "nordic_common.h"
#include "nrf.h"
#include "nrf51_bitfields.h"
#include "app_error.h"
#include "app_timer.h"
#include "ble.h"
#include "ble_bas.h"
#include "ble_error_log.h"

#include "nst_ble_service.h"
//=====================================================================================================================
//static uint16_t                 conn_handle;
static uint16_t                 service_handle;  
//=====================================================================================================================
static ble_gatts_char_handles_t ble_bls_battery_level_char_handles;
static uint8_t                  ble_bls_battery_level_char_buffer;
//=====================================================================================================================
/*---------------------------------------------------------------------------------------------------------*/
/* Description:                                                                                            */
/*    Battery Level Service event handler.                                                                 */
/* Parameter:                                                                                              */
/*    p_ble_evt: Event received from the BLE stack.                                                        */
/* Return:                                                                                                 */
/*    NULL                                                                                                 */
/*---------------------------------------------------------------------------------------------------------*/
void ble_bls_on_ble_evt(ble_evt_t * p_ble_evt)
{
    switch (p_ble_evt->header.evt_id)
    {
        case BLE_GAP_EVT_CONNECTED:
//            on_connect(p_ble_evt);
            break;
        case BLE_GAP_EVT_DISCONNECTED:
//            on_disconnect(p_ble_evt);
            break; 
        case BLE_GATTS_EVT_WRITE:
//            on_write(p_ble_evt);
            break;
        default:
            break;
    }  
}
/*---------------------------------------------------------------------------------------------------------*/
/* Description:                                                                                            */
/*    Function to add Battery Level Service(0x180F).                                                       */
/* Parameter:                                                                                              */
/*    NULL                                                                                                 */
/* Return:                                                                                                 */
/*    NULL                                                                                                 */
/*---------------------------------------------------------------------------------------------------------*/
void ble_bls_init(void)
{
    uint32_t   err_code; 
    ble_uuid_t service_uuid;
    
    // Load default data
//    conn_handle                    = BLE_CONN_HANDLE_INVALID;
    ble_bls_battery_level_char_buffer = 100;
    
    // Add service 
    BLE_UUID_BLE_ASSIGN(service_uuid, 0x180F);
    err_code = sd_ble_gatts_service_add(BLE_GATTS_SRVC_TYPE_PRIMARY, &service_uuid, &service_handle);
    APP_ERROR_CHECK(err_code);
    
    // Add Characteristic
    err_code = ble_char_add(service_handle, 0x2A19, RD|NO, 1,
                            &ble_bls_battery_level_char_buffer,
                            &ble_bls_battery_level_char_handles,
                            NULL);
    APP_ERROR_CHECK(err_code);
}
//=====================================================================================================================
