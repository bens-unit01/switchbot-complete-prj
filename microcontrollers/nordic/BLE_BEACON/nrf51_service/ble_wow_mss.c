//=====================================================================================================================
/*---------------------------------------------------------------------------------------------------------*/
/* Module Setting Service(0xFF30)                                                                          */
/* --Reboot Characteristic(0xFF31)                                      W   1                              */
/*---------------------------------------------------------------------------------------------------------*/
#include <stdint.h>
#include <string.h>
#include "nordic_common.h"
#include "nrf.h"
#include "nrf51_bitfields.h"
#include "app_error.h"
#include "nrf_gpio.h"
#include "ble.h"
#include "ble_error_log.h"
#include "nrf_soc.h"
#include "app_scheduler.h"

#include "nst_ble_service.h"
#include "ble_wow_mss.h"
//=====================================================================================================================
ble_wow_mss_t m_wow_mss;
//=====================================================================================================================
/*---------------------------------------------------------------------------------------------------------*/
/* Description:                                                                                            */
/*    Function for handling the Connected event.                                                           */
/* Parameter:                                                                                              */
/*    p_ble_evt: Event received from the BLE stack.                                                        */
/* Return:                                                                                                 */
/*    NULL                                                                                                 */
/*---------------------------------------------------------------------------------------------------------*/
static void on_connect(ble_evt_t * p_ble_evt)
{
    m_wow_mss.conn_handle = p_ble_evt->evt.gap_evt.conn_handle;
}
/*---------------------------------------------------------------------------------------------------------*/
/* Description:                                                                                            */
/*    Function for handling the Disconnected event.                                                        */
/* Parameter:                                                                                              */
/*    p_ble_evt: Event received from the BLE stack.                                                        */
/* Return:                                                                                                 */
/*    NULL                                                                                                 */
/*---------------------------------------------------------------------------------------------------------*/
static void on_disconnect(ble_evt_t * p_ble_evt)
{
    m_wow_mss.conn_handle = BLE_CONN_HANDLE_INVALID;
}
/*---------------------------------------------------------------------------------------------------------*/
/* Description:                                                                                            */
/*    Function for handling the Write event.                                                               */
/* Parameter:                                                                                              */
/*    p_ble_evt: Event received from the BLE stack.                                                        */
/* Return:                                                                                                 */
/*    NULL                                                                                                 */
/*---------------------------------------------------------------------------------------------------------*/
static void on_write(ble_evt_t * p_ble_evt)
{
    uint32_t               err_code = NRF_SUCCESS;
    ble_gatts_evt_write_t* p_evt_write;
    
    p_evt_write = &p_ble_evt->evt.gatts_evt.params.write;
    
//    if(m_wow_sss_data.pin_passed)
    {
        if(p_evt_write->handle == m_wow_mss.ble_mss_reboot_char_handles.value_handle)
        {
            if(p_evt_write->data[0] == MSS_REBOOT_APP)
            {	
                err_code = sd_power_gpregret_clr(0xFF);
                APP_ERROR_CHECK(err_code); 
                
                err_code = sd_nvic_SystemReset();
                APP_ERROR_CHECK(err_code);  
            }
            else if(p_evt_write->data[0] == MSS_REBOOT_DFU)
            {
                err_code = sd_power_gpregret_clr(0xFF);
                APP_ERROR_CHECK(err_code);  
                
                err_code = sd_power_gpregret_set(0xB1);
                APP_ERROR_CHECK(err_code);  
                
                err_code = sd_nvic_SystemReset();
                APP_ERROR_CHECK(err_code);  
            }
        }
   }
}
/*---------------------------------------------------------------------------------------------------------*/
/* Description:                                                                                            */
/*    Function for handling the events.                                                                    */
/* Parameter:                                                                                              */
/*    p_ble_evt: Event received from the BLE stack.                                                        */
/* Return:                                                                                                 */
/*    NULL                                                                                                 */
/*---------------------------------------------------------------------------------------------------------*/
void ble_mss_on_ble_evt(ble_evt_t * p_ble_evt)
{
    switch (p_ble_evt->header.evt_id)
    {
        case BLE_GAP_EVT_CONNECTED:
            on_connect(p_ble_evt);
            break;
        case BLE_GAP_EVT_DISCONNECTED:
            on_disconnect(p_ble_evt);
            break;    
        case BLE_GATTS_EVT_WRITE:
            on_write(p_ble_evt);
            break;
        default:
            break;
    }    
}
/*---------------------------------------------------------------------------------------------------------*/
/* Description:                                                                                            */
/*    Function to add Module Setting Service(0xFF30).                                                      */
/* Parameter:                                                                                              */
/*    NULL                                                                                                 */
/* Return:                                                                                                 */
/*    NULL                                                                                                 */
/*---------------------------------------------------------------------------------------------------------*/
void ble_mss_init(void)
{
    uint32_t   err_code; 
    ble_uuid_t service_uuid;
    
    // Load default data
    m_wow_mss.conn_handle = BLE_CONN_HANDLE_INVALID;
    
    // Add service 
    BLE_UUID_BLE_ASSIGN(service_uuid, 0xFF30);
    err_code = sd_ble_gatts_service_add(BLE_GATTS_SRVC_TYPE_PRIMARY, &service_uuid, &m_wow_mss.service_handle);
    APP_ERROR_CHECK(err_code);
    
    // Add Characteristic
    err_code = ble_char_add(m_wow_mss.service_handle, 0xFF31, WR,
                            sizeof(uint8_t),
                            NULL,
                            &m_wow_mss.ble_mss_reboot_char_handles,
                            NULL);
    APP_ERROR_CHECK(err_code);
}
//=====================================================================================================================
