//=====================================================================================================================
/*---------------------------------------------------------------------------------------------------------*/
/* Photo Setting Service(0xFF10)                                                                           */
/* --Activation Status(0xFF1B)                                         RW   1                              */
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

//#include "main.h"

#include "nst_ble_service.h"
#include "ble_wow_rss.h"
#include "nst_ble_mps.h"
//=====================================================================================================================
ble_wow_pss_t      m_wow_pss;
ble_wow_pss_data_t m_wow_pss_data;

const uint8_t ble_wow_pss_data_default[] = {0x0}; 

void ble_mps_save_param(void);
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
    m_wow_pss.conn_handle      = p_ble_evt->evt.gap_evt.conn_handle;
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
    m_wow_pss.conn_handle      = BLE_CONN_HANDLE_INVALID;
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
    bool                   m_wow_pss_data_updated = false;                   
    ble_gatts_evt_write_t* p_evt_write;
    
    p_evt_write = &p_ble_evt->evt.gatts_evt.params.write;
    
    if(p_evt_write->handle == m_wow_pss.ble_pss_activation_status_char_handles.value_handle)
    {
        if(((p_evt_write->data[0] == PSS_STATUS_FACTORY) || (p_evt_write->data[0] == PSS_STATUS_ACTIVATED) || (p_evt_write->data[0] == PSS_STATUS_FLURRY)))
        {
            m_wow_pss_data.activation_status = p_evt_write->data[0];
            m_wow_mps_data.active_status     = m_wow_pss_data.activation_status;
            m_wow_pss_data_updated           = true;
        }
        else
        {
            uint16_t length;

            length = 1;
            err_code = sd_ble_gatts_value_set(m_wow_pss.ble_pss_activation_status_char_handles.value_handle,
                                              0,
                                              &length,
                                              &m_wow_pss_data.activation_status);
            APP_ERROR_CHECK(err_code);  
        }
    }
     
    if(m_wow_pss_data_updated)
    {
        ble_mps_save_param();
    }
//*        psetting_update(PSETTING_BLOCK_PHOTO, (uint8_t*)&m_wow_pss_data);
}
/*---------------------------------------------------------------------------------------------------------*/
/* Description:                                                                                            */
/*    Function for handling the events.                                                                    */
/* Parameter:                                                                                              */
/*    p_ble_evt: Event received from the BLE stack.                                                        */
/* Return:                                                                                                 */
/*    NULL                                                                                                 */
/*---------------------------------------------------------------------------------------------------------*/
void ble_pss_on_ble_evt(ble_evt_t * p_ble_evt)
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
/*    Function to add Photo Setting Service(0xFF10).                                                       */
/* Parameter:                                                                                              */
/*    NULL                                                                                                 */
/* Return:                                                                                                 */
/*    NULL                                                                                                 */
/*---------------------------------------------------------------------------------------------------------*/
void ble_pss_init(void)
{
    uint32_t   err_code; 
    ble_uuid_t service_uuid;
    
    // Load default data
    m_wow_pss.conn_handle = BLE_CONN_HANDLE_INVALID;
    
    
    //load  activation_status
    //*
    m_wow_pss_data.activation_status = m_wow_mps_data.active_status;
    
    // Add service 
    BLE_UUID_BLE_ASSIGN(service_uuid, 0xFF10);
    err_code = sd_ble_gatts_service_add(BLE_GATTS_SRVC_TYPE_PRIMARY, &service_uuid, &m_wow_pss.service_handle);
    APP_ERROR_CHECK(err_code);
    
            
    err_code = ble_char_add(m_wow_pss.service_handle, 0xFF1B, RD|WR,
                            sizeof(m_wow_pss_data.activation_status),
                            &m_wow_pss_data.activation_status,
                            &m_wow_pss.ble_pss_activation_status_char_handles,
                            NULL);
    APP_ERROR_CHECK(err_code);
}
//=====================================================================================================================
