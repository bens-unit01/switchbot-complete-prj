//=====================================================================================================================
/*---------------------------------------------------------------------------------------------------------*/
/* RSSI Report Service(0xFFA0)                                                                             */
/* --RSSI Report Read Characteristic(0xFFA1)                           RN   1                              */
/* --RSSI Report Set Interval Characteristic(0xFFA2)                   RW   2                              */
/*---------------------------------------------------------------------------------------------------------*/
/* Need one app timer.                                                                                     */
/*---------------------------------------------------------------------------------------------------------*/
#include <stdint.h>
#include <string.h>
#include "nordic_common.h"
#include "nrf.h"
#include "nrf51_bitfields.h"
#include "app_error.h"
#include "app_timer.h"
#include "ble.h"
#include "ble_error_log.h"

#include "nst_ble_service.h"
//=====================================================================================================================
static app_timer_id_t           rrs_app_timer_id; 
static uint16_t                 timer_interval;
//=====================================================================================================================
static uint16_t                 conn_handle;
static uint16_t                 service_handle;  
//=====================================================================================================================
static ble_gatts_char_handles_t ble_rrs_read_char_handles;
static uint8_t                  ble_rrs_read_char_buffer;
static ble_gatts_char_handles_t ble_rrs_set_interval_char_handles;
static uint8_t                  ble_rrs_set_interval_buffer[2];
//=====================================================================================================================
/*---------------------------------------------------------------------------------------------------------*/
/* Description:                                                                                            */
/*    Function for updating RSSI value.                                                                    */
/* Parameter:                                                                                              */
/*    [in]  data  Value to be send.                                                                        */
/* Return:                                                                                                 */
/*    NULL                                                                                                 */
/*---------------------------------------------------------------------------------------------------------*/ 
static void ble_rrs_read_update(uint8_t data)
{    
    uint32_t err_code;
    
    err_code = ble_notify_send(conn_handle, 
                               1, 
                               &data, 
                               &ble_rrs_read_char_buffer, 
                               ble_rrs_read_char_handles);
    if ((err_code != NRF_SUCCESS) &&
        (err_code != NRF_ERROR_INVALID_STATE) &&
        (err_code != BLE_ERROR_NO_TX_BUFFERS) &&
        (err_code != BLE_ERROR_GATTS_SYS_ATTR_MISSING)
    )
    {
        APP_ERROR_HANDLER(err_code);
    }
}
/*---------------------------------------------------------------------------------------------------------*/
/* Description:                                                                                            */
/*    timer timeout handler.                                                                               */
/*    This function will be called each time the timer expires.                                            */
/* Parameter:                                                                                              */
/*    [in]  p_context  Pointer used for passing some arbitrary information (context) from the              */
/*                     app_start_timer() call to the timeout handler                                       */
/* Return:                                                                                                 */
/*    NULL                                                                                                 */
/*---------------------------------------------------------------------------------------------------------*/ 
static void ble_rrs_timeout_handler(void * p_context)
{
    uint32_t err_code;
    
    err_code = sd_ble_gap_rssi_start(conn_handle);
    APP_ERROR_CHECK(err_code);
}
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
    uint32_t err_code;
    
    conn_handle = p_ble_evt->evt.gap_evt.conn_handle;
    
    if(timer_interval != 0)
        err_code = app_timer_start(rrs_app_timer_id, 32 * timer_interval, NULL);
    else
    	err_code = app_timer_stop(rrs_app_timer_id);
    APP_ERROR_CHECK(err_code); 
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
    uint32_t err_code;
    
    conn_handle = BLE_CONN_HANDLE_INVALID;
    
    err_code = app_timer_stop(rrs_app_timer_id);
    APP_ERROR_CHECK(err_code); 
}
/*---------------------------------------------------------------------------------------------------------*/
/* Description:                                                                                            */
/*    Function for handling the RSSI Changed event.                                                        */
/* Parameter:                                                                                              */
/*    p_ble_evt: Event received from the BLE stack.                                                        */
/* Return:                                                                                                 */
/*    NULL                                                                                                 */
/*---------------------------------------------------------------------------------------------------------*/
static void on_rssi_changed(ble_evt_t * p_ble_evt)
{
    uint32_t err_code;
    
    ble_rrs_read_update(p_ble_evt->evt.gap_evt.params.rssi_changed.rssi);
    
    err_code = sd_ble_gap_rssi_stop(conn_handle);
    APP_ERROR_CHECK(err_code);
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
    uint32_t               err_code;
    ble_gatts_evt_write_t* p_evt_write;
    
    p_evt_write = &p_ble_evt->evt.gatts_evt.params.write;
    
    if(p_evt_write->handle == ble_rrs_set_interval_char_handles.value_handle)
    {
        timer_interval = (p_evt_write->data[0] << 8) + p_evt_write->data[1];
        if(timer_interval == 0)
            err_code = app_timer_stop(rrs_app_timer_id);
        else
            err_code = app_timer_start(rrs_app_timer_id, 32 * timer_interval, NULL);
        APP_ERROR_CHECK(err_code); 
    }
}
//------------------------------------------------------------------------------------------------------
void ble_rrs_on_ble_evt(ble_evt_t * p_ble_evt)
{
    switch (p_ble_evt->header.evt_id)
    {
        case BLE_GAP_EVT_CONNECTED:
            on_connect(p_ble_evt);
            break;
        case BLE_GAP_EVT_DISCONNECTED:
            on_disconnect(p_ble_evt);
            break; 
        case BLE_GAP_EVT_RSSI_CHANGED:
            on_rssi_changed(p_ble_evt);
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
/*    Function to add RSSI Report Service(0xFFA0).                                                         */
/* Parameter:                                                                                              */
/*    NULL                                                                                                 */
/* Return:                                                                                                 */
/*    NULL                                                                                                 */
/*---------------------------------------------------------------------------------------------------------*/
void ble_rrs_init(void)
{
    uint32_t   err_code; 
    ble_uuid_t service_uuid;
    
    // Create RSSI check timer.
    err_code = app_timer_create(&rrs_app_timer_id, APP_TIMER_MODE_REPEATED, ble_rrs_timeout_handler);
    APP_ERROR_CHECK(err_code); 
    
    // Load default data
    conn_handle                    = BLE_CONN_HANDLE_INVALID;
    timer_interval                 = 0x0000;
    ble_rrs_read_char_buffer       = 0x00;
    ble_rrs_set_interval_buffer[0] = 0x00;
    ble_rrs_set_interval_buffer[1] = 0x00;
    
    // Add service 
    BLE_UUID_BLE_ASSIGN(service_uuid, 0xFFA0);
    err_code = sd_ble_gatts_service_add(BLE_GATTS_SRVC_TYPE_PRIMARY, &service_uuid, &service_handle);
    APP_ERROR_CHECK(err_code);
    
    // Add Characteristic
    err_code = ble_char_add(service_handle, 0xFFA1, RD|NO, 1,
                            &ble_rrs_read_char_buffer,
                            &ble_rrs_read_char_handles,
                            NULL);
    APP_ERROR_CHECK(err_code);
    err_code = ble_char_add(service_handle, 0xFFA2, RD|WR, 2,
                            ble_rrs_set_interval_buffer,
                            &ble_rrs_set_interval_char_handles,
                            NULL);
    APP_ERROR_CHECK(err_code);
}
//=====================================================================================================================
