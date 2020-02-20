//=====================================================================================================================
/*---------------------------------------------------------------------------------------------------------*/
/* Programmable IO Service(0xFFF0)                                                                         */
/* --Programmable IO Configure Pin Characteristic(0xFFF1)              RW   1                              */
/* --Programmable IO Set Pin Characteristic(0xFFF2)                     W   1                              */
/* --Programmable IO Read Or Notify Pin Characteristic(0xFFF3)         RN   1                              */
/*---------------------------------------------------------------------------------------------------------*/
#include <stdint.h>
#include <string.h>
#include "nordic_common.h"
#include "nrf.h"
#include "nrf51_bitfields.h"
#include "nrf_gpio.h"
#include "app_error.h"
#include "app_gpiote.h"
#include "ble.h"
#include "ble_error_log.h"

#include "nst_ble_service.h"
//=====================================================================================================================
//static uint16_t                 conn_handle;
static uint16_t                 service_handle;  
//=====================================================================================================================
static ble_gatts_char_handles_t ble_pios_configure_pin_handles;
static uint8_t                  ble_pios_configure_pin_buffer;
static ble_gatts_char_handles_t ble_pios_set_pin_handles;
static uint8_t                  ble_pios_set_pin_buffer;
static ble_gatts_char_handles_t ble_pios_read_or_notify_pin_handles;
static uint8_t                  ble_pios_read_or_notify_pin_buffer;
//=====================================================================================================================
/*---------------------------------------------------------------------------------------------------------*/
/* Description:                                                                                            */
/*    Function for handling the events.                                                                    */
/* Parameter:                                                                                              */
/*    p_ble_evt: Event received from the BLE stack.                                                        */
/* Return:                                                                                                 */
/*    NULL                                                                                                 */
/*---------------------------------------------------------------------------------------------------------*/
void ble_pios_on_ble_evt(ble_evt_t * p_ble_evt)
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
/*    Function to add Programmable IO Service(0xFFF0).                                                     */
/* Parameter:                                                                                              */
/*    NULL                                                                                                 */
/* Return:                                                                                                 */
/*    NULL                                                                                                 */
/*---------------------------------------------------------------------------------------------------------*/
void ble_pios_init(void)
{
    uint32_t   err_code; 
    ble_uuid_t service_uuid;
    
    // Load Default Data
//    conn_handle                        = BLE_CONN_HANDLE_INVALID;
    ble_pios_configure_pin_buffer      = 0x00;
    ble_pios_read_or_notify_pin_buffer = 0x00;
    
    // Add Service 
    BLE_UUID_BLE_ASSIGN(service_uuid, 0xFFF0);
    err_code = sd_ble_gatts_service_add(BLE_GATTS_SRVC_TYPE_PRIMARY, &service_uuid, &service_handle);
    APP_ERROR_CHECK(err_code);
    
    // Add Characteristic
    err_code = ble_char_add(service_handle, 0xFFF1, RD|WR, 1,
                            &ble_pios_configure_pin_buffer,
                            &ble_pios_configure_pin_handles,
                            NULL);
    APP_ERROR_CHECK(err_code);
    err_code = ble_char_add(service_handle, 0xFFF2,    WR, 1,
                            &ble_pios_set_pin_buffer,
                            &ble_pios_set_pin_handles,
                            NULL);
    APP_ERROR_CHECK(err_code);
    err_code = ble_char_add(service_handle, 0xFFF3, RD|NO, 1,
                            &ble_pios_read_or_notify_pin_buffer,
                            &ble_pios_read_or_notify_pin_handles,
                            NULL);
    APP_ERROR_CHECK(err_code);
}
//=====================================================================================================================
