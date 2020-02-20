//=====================================================================================================================
/*---------------------------------------------------------------------------------------------------------*/
/* Anti-Hijacking Service(0xFFC0)                                                                          */
/* --Anti-Hijacking Set Security Password Characteristic(0xFFC1)        W  12                              */
/* --Anti-Hijacking Receive Security Info Characteristic(0xFFC2)        N   1                              */
/*---------------------------------------------------------------------------------------------------------*/
#include <stdint.h>
#include <string.h>
#include "nordic_common.h"
#include "nrf.h"
#include "nrf51_bitfields.h"
#include "app_error.h"
#include "ble.h"
#include "ble_hci.h"
#include "ble_error_log.h"

#include "nst_ble_service.h"
//=====================================================================================================================
//static uint16_t                 conn_handle;
static uint16_t                 service_handle;  
//=====================================================================================================================
static ble_gatts_char_handles_t ble_ahs_set_security_password_char_handles;
static uint8_t                  ble_ahs_set_security_password_char_buffer[12];
static ble_gatts_char_handles_t ble_ahs_receive_security_info_char_handles;
static uint8_t                  ble_ahs_receive_security_info_char_buffer;
//=====================================================================================================================
/*---------------------------------------------------------------------------------------------------------*/
/* Description:                                                                                            */
/*    Function for handling the events.                                                                    */
/* Parameter:                                                                                              */
/*    p_ble_evt: Event received from the BLE stack.                                                        */
/* Return:                                                                                                 */
/*    NULL                                                                                                 */
/*---------------------------------------------------------------------------------------------------------*/
void ble_ahs_on_ble_evt(ble_evt_t * p_ble_evt)
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
/*    Function to add Anti-Hijacking Service(0xFFC0).                                                      */
/* Parameter:                                                                                              */
/*    NULL                                                                                                 */
/* Return:                                                                                                 */
/*    NULL                                                                                                 */
/*---------------------------------------------------------------------------------------------------------*/
void ble_ahs_init(void)
{
    uint32_t   err_code; 
    ble_uuid_t service_uuid;
    
    // Load default data
//    conn_handle = BLE_CONN_HANDLE_INVALID;
    
    // Add service 
    BLE_UUID_BLE_ASSIGN(service_uuid, 0xFFC0);
    err_code = sd_ble_gatts_service_add(BLE_GATTS_SRVC_TYPE_PRIMARY, &service_uuid, &service_handle);
    APP_ERROR_CHECK(err_code);
    
    // Add Characteristic
    err_code = ble_char_add(service_handle, 0xFFC1, WR, 12,
                            ble_ahs_set_security_password_char_buffer,
                            &ble_ahs_set_security_password_char_handles,
                            NULL);
    APP_ERROR_CHECK(err_code);
    err_code = ble_char_add(service_handle, 0xFFC2, NO,  1,
                            &ble_ahs_receive_security_info_char_buffer,
                            &ble_ahs_receive_security_info_char_handles,
                            NULL);
    APP_ERROR_CHECK(err_code);
}
//=====================================================================================================================
