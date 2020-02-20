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
#include <stdint.h>
#include <string.h>
#include "nordic_common.h"
#include "nrf.h"
#include "nrf_delay.h"
#include "nrf51_bitfields.h"
#include "app_error.h"
#include "ble.h"
#include "ble_error_log.h"
#include "ble_conn_params.h"
#include	"d_flash_data.h"

#include "d_persistent_storage.h"
#include "nst_ble_service.h"
#include "ble_wow_rss.h"

#include "advertiser_beacon.h"

#include "nrf_soc.h"
//=====================================================================================================================
const uint16_t conn_interval_table[9] = {  20/1.25,  50/1.25, 100/1.25,  200/1.25,
                                          300/1.25, 400/1.25, 500/1.25, 1000/1.25,
                                         2000/1.25};
const uint16_t adv_interval_table[9]  = { 200*1.6,  500*1.6, 1000*1.6, 1500*1.6,
                                         2000*1.6, 2500*1.6, 3000*1.6, 4000*1.6,
                                         5000*1.6,};
const int8_t tx_power_table[4]        = {4, 0, -4, -20};
//=====================================================================================================================
//static uint16_t                 conn_handle=0;
static uint16_t                 service_handle=0;
uint8_t mps_clear_flag = 0;
//=====================================================================================================================
static ble_gatts_char_handles_t ble_mps_device_name_char_handles;
static uint8_t                  ble_mps_device_name_char_buffer[20];
static ble_gatts_char_handles_t ble_mps_connection_interval_char_handles;
static uint8_t                  ble_mps_connection_interval_char_buffer;
static ble_gatts_char_handles_t ble_mps_reset_module_char_handles;
static uint8_t                  ble_mps_reset_module_char_buffer;
static ble_gatts_char_handles_t ble_mps_advertising_interval_char_handles;
static uint8_t                  ble_mps_advertising_interval_char_buffer;
static ble_gatts_char_handles_t ble_mps_transmit_power_char_handles;
static uint8_t                  ble_mps_transmit_power_char_buffer;
static ble_gatts_char_handles_t ble_mps_custom_broadcast_data_char_handles;
static uint8_t                  ble_mps_custom_broadcast_data_char_buffer[20];
static ble_gatts_char_handles_t ble_mps_connected_broadcast_data_char_handles;
       uint8_t                  ble_mps_connected_broadcast_data_char_buffer[20];
static ble_gatts_char_handles_t ble_mps_connected_broadcast_enable_char_handles;
static uint8_t                  ble_mps_connected_broadcast_enable_char_buffer;
//=====================================================================================================================
ble_wow_mps_data_t m_wow_mps_data;

static uint16_t ble_mps_conn_min_interval=0;
static uint16_t ble_mps_conn_max_interval=0;
//static uint16_t ble_mps_adv_interval=0;



void my_delay_ms(uint32_t number_of_ms)
{
	int i;
	while(number_of_ms--)
	{
		i++;
		nrf_delay_ms(1);
//		app_sched_execute();
//		sd_app_evt_wait();
		if(d_persisten_storage_check_busy() == 0)
		{
			return;
		}
	}
}
/*---------------------------------------------------------------------------------------------------------*/
/* Description:                                                                                            */
/*    Function to get connected_broadcast_enable                                                           */
/*---------------------------------------------------------------------------------------------------------*/
uint8_t ble_mps_get_connected_broadcast_enable(void)
{
    return ble_mps_connected_broadcast_enable_char_buffer;
}

/*---------------------------------------------------------------------------------------------------------*/
/* Description:                                                                                            */
/*    Function to clear module parameters.                                                                 */
/* Parameter:                                                                                              */
/*    NULL                                                                                                 */
/* Return:                                                                                                 */
/*    NULL                                                                                                 */
/*---------------------------------------------------------------------------------------------------------*/
static void ble_mps_clear_param(void)
{
    uint32_t	module_addr;
	
    m_wow_mps_data.dummy                     = 0xFFFFFFFF;
    m_wow_mps_data.device_id[0]              = 'R';
    m_wow_mps_data.device_id[1]              = 'a';
    m_wow_mps_data.device_id[2]              = 'm';
    m_wow_mps_data.device_id[3]              = 'p';
    m_wow_mps_data.custom_broadcast_data_num = 0x10;
	
    memset(m_wow_mps_data.device_name,           0, sizeof(m_wow_mps_data.device_name));
    memcpy(m_wow_mps_data.device_name, "Ramp-XXXXX", strlen("Ramp-XXXXX"));
    
    module_addr = NRF_FICR->DEVICEADDR[0];
    m_wow_mps_data.device_name[9] = 0x30 + module_addr % 10;
    module_addr /= 10;
    m_wow_mps_data.device_name[8] = 0x30 + module_addr % 10;
    module_addr /= 10;
    m_wow_mps_data.device_name[7] = 0x30 + module_addr % 10;
    module_addr /= 10;
    m_wow_mps_data.device_name[6] = 0x30 + module_addr % 10;
    module_addr /= 10;
    m_wow_mps_data.device_name[5] = 0x30 + module_addr % 10;
	
    memset(m_wow_mps_data.custom_broadcast_data, 0x00, sizeof(m_wow_mps_data.custom_broadcast_data));
	  d_flash_data_save_device_name((uint8_t*)&m_wow_mps_data);
    mps_clear_flag = 1;
//    d_flash_data_save_device_name((uint8_t*)&m_wow_mps_data);
}
/*---------------------------------------------------------------------------------------------------------*/
/* Description:                                                                                            */
/*    Function to save module parameters.                                                                  */
/* Parameter:                                                                                              */
/*    NULL                                                                                                 */
/* Return:                                                                                                 */
/*    NULL                                                                                                 */
/*---------------------------------------------------------------------------------------------------------*/
void ble_mps_save_param(void)
{
    m_wow_mps_data.dummy        = 0xFFFFFFFF;
    m_wow_mps_data.device_id[0] = 'R';
    m_wow_mps_data.device_id[1] = 'a';
    m_wow_mps_data.device_id[2] = 'm';
    m_wow_mps_data.device_id[3] = 'p';
    d_flash_data_save_device_name((uint8_t*)&m_wow_mps_data);
}
/*---------------------------------------------------------------------------------------------------------*/
/* Description:                                                                                            */
/*    Function to load module parameters.                                                                  */
/* Parameter:                                                                                              */
/*    NULL                                                                                                 */
/* Return:                                                                                                 */
/*    NULL                                                                                                 */
/*---------------------------------------------------------------------------------------------------------*/
void ble_mps_load_param(void)
{
    uint32_t	module_addr;

    d_flash_data_load_device_name((uint8_t*)&m_wow_mps_data);
    if((m_wow_mps_data.device_id[0] != 'R') || (m_wow_mps_data.device_id[1] != 'a') ||
    	 (m_wow_mps_data.device_id[2] != 'm') || (m_wow_mps_data.device_id[3] != 'p'))
    {
        memset(m_wow_mps_data.device_name,          0, sizeof(m_wow_mps_data.device_name));
        memset(m_wow_mps_data.custom_broadcast_data,0, sizeof(m_wow_mps_data.custom_broadcast_data));
        m_wow_mps_data.custom_broadcast_data_num = 16;
			
        m_wow_mps_data.active_status = PSS_STATUS_FACTORY;

		memcpy(m_wow_mps_data.device_name, "ww_beacon_07", strlen("ww_beacon_07"));
    }
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
//    conn_handle = p_ble_evt->evt.gap_evt.conn_handle;
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
//    conn_handle = BLE_CONN_HANDLE_INVALID;
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

    if(p_evt_write->handle == ble_mps_device_name_char_handles.value_handle)
    {
        memset(m_wow_mps_data.device_name, 0, sizeof(m_wow_mps_data.device_name));
        memcpy(m_wow_mps_data.device_name, &p_evt_write->data[0], p_evt_write->len);
        ble_mps_save_param();
    }
    else if(p_evt_write->handle == ble_mps_connection_interval_char_handles.value_handle)
    {
        if(p_evt_write->data[0] < 9)
        {
            ble_gap_conn_params_t gap_conn_params;

            ble_mps_connection_interval_char_buffer = p_evt_write->data[0];

            if(p_evt_write->data[0] == 0)
                ble_mps_conn_min_interval = conn_interval_table[p_evt_write->data[0]] - 8;
            else
                ble_mps_conn_min_interval = conn_interval_table[p_evt_write->data[0]] - 16;
            ble_mps_conn_max_interval = conn_interval_table[p_evt_write->data[0]];

            memset(&gap_conn_params, 0, sizeof(gap_conn_params));

            gap_conn_params.min_conn_interval = ble_mps_conn_min_interval;
            gap_conn_params.max_conn_interval = ble_mps_conn_max_interval;
            gap_conn_params.slave_latency     = 0;
            gap_conn_params.conn_sup_timeout  = 400;

            err_code = ble_conn_params_change_conn_params(&gap_conn_params);
            APP_ERROR_CHECK(err_code);
        }
        else
        {
            uint16_t length;

            length = 1;
            err_code = sd_ble_gatts_value_set(ble_mps_connection_interval_char_handles.value_handle,
                                              0,
                                              &length,
                                              &ble_mps_connection_interval_char_buffer);
            APP_ERROR_CHECK(err_code);
        }
    }
    else if(p_evt_write->handle == ble_mps_reset_module_char_handles.value_handle)
    {
        switch(p_evt_write->data[0])
        {
            case 0x00:
                NVIC_SystemReset();
                break;
            case 0x01:
						    ble_mps_clear_param();
                break;
        }
    }
    else if(p_evt_write->handle == ble_mps_advertising_interval_char_handles.value_handle)
    {
        if(p_evt_write->data[0] < 9)
        {
            ble_mps_advertising_interval_char_buffer = p_evt_write->data[0];
//            ble_mps_adv_interval = adv_interval_table[p_evt_write->data[0]];
        }
        else
        {
            uint16_t length;

            length = 1;
            err_code = sd_ble_gatts_value_set(ble_mps_advertising_interval_char_handles.value_handle,
                                              0,
                                              &length,
                                              &ble_mps_advertising_interval_char_buffer);
            APP_ERROR_CHECK(err_code);
        }
    }
    else if(p_evt_write->handle == ble_mps_transmit_power_char_handles.value_handle)
    {
        if(p_evt_write->data[0] < 4)
        {
            ble_mps_transmit_power_char_buffer = p_evt_write->data[0];
            err_code = sd_ble_gap_tx_power_set(tx_power_table[p_evt_write->data[0]]);
            APP_ERROR_CHECK(err_code);
        }
        else
        {
            uint16_t length;

            length = 1;
            err_code = sd_ble_gatts_value_set(ble_mps_transmit_power_char_handles.value_handle,
                                              0,
                                              &length,
                                              &ble_mps_transmit_power_char_buffer);
            APP_ERROR_CHECK(err_code);
        }
    }
    else if(p_evt_write->handle == ble_mps_custom_broadcast_data_char_handles.value_handle)
    {
        memset(m_wow_mps_data.custom_broadcast_data, 0, sizeof(m_wow_mps_data.custom_broadcast_data));
        memcpy(m_wow_mps_data.custom_broadcast_data, &p_evt_write->data[0], p_evt_write->len);
        m_wow_mps_data.custom_broadcast_data_num = p_evt_write->len;
        ble_mps_save_param();
    }
    else if(p_evt_write->handle == ble_mps_connected_broadcast_data_char_handles.value_handle)
    {
        memset(ble_mps_connected_broadcast_data_char_buffer, 0, sizeof(ble_mps_connected_broadcast_data_char_buffer));
        memcpy(ble_mps_connected_broadcast_data_char_buffer, &p_evt_write->data[0], p_evt_write->len);
    }
    else if(p_evt_write->handle == ble_mps_connected_broadcast_enable_char_handles.value_handle)
    {
        if(p_evt_write->data[0] == 0x00)
        {
            if(ble_mps_connected_broadcast_enable_char_buffer != 0x00)
            {
                ble_mps_connected_broadcast_enable_char_buffer = 0;
                app_beacon_stop();
            }
        }
        else if(p_evt_write->data[0] == 0x01)
        {
            if(ble_mps_connected_broadcast_enable_char_buffer != 0x01)
            {
                ble_mps_connected_broadcast_enable_char_buffer = 1;
                app_beacon_start();
            }
        }
        else
        {
            uint16_t length;

            length = 1;
            err_code = sd_ble_gatts_value_set(ble_mps_connected_broadcast_enable_char_handles.value_handle,
                                              0,
                                              &length,
                                              &ble_mps_connected_broadcast_enable_char_buffer);
            APP_ERROR_CHECK(err_code);
        }
    }
}
//------------------------------------------------------------------------------------------------------
void ble_mps_on_ble_evt(ble_evt_t * p_ble_evt)
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
/*    Function to add Module Parameters Service(0xFF90).                                                   */
/* Parameter:                                                                                              */
/*    NULL                                                                                                 */
/* Return:                                                                                                 */
/*    NULL                                                                                                 */
/*---------------------------------------------------------------------------------------------------------*/
void ble_mps_init(void)
{
    uint32_t   err_code;
    ble_uuid_t service_uuid;

    // Load default data
//    conn_handle = BLE_CONN_HANDLE_INVALID;

    memset(ble_mps_device_name_char_buffer,              0, sizeof(ble_mps_device_name_char_buffer));
    memset(ble_mps_custom_broadcast_data_char_buffer,    0, sizeof(ble_mps_custom_broadcast_data_char_buffer));
    memset(ble_mps_connected_broadcast_data_char_buffer, 0, sizeof(ble_mps_connected_broadcast_data_char_buffer));
    memcpy(ble_mps_device_name_char_buffer,           m_wow_mps_data.device_name,           sizeof(m_wow_mps_data.device_name));
    memcpy(ble_mps_custom_broadcast_data_char_buffer, m_wow_mps_data.custom_broadcast_data, m_wow_mps_data.custom_broadcast_data_num);

    ble_mps_connection_interval_char_buffer        = 0;
    ble_mps_transmit_power_char_buffer             = 1;
    ble_mps_reset_module_char_buffer               = 0;
    ble_mps_advertising_interval_char_buffer       = 0;
    ble_mps_connected_broadcast_enable_char_buffer = 0;

    // Add service
    BLE_UUID_BLE_ASSIGN(service_uuid, 0xFF90);
    err_code = sd_ble_gatts_service_add(BLE_GATTS_SRVC_TYPE_PRIMARY, &service_uuid, &service_handle);
    APP_ERROR_CHECK(err_code);

    // Add Characteristic
    err_code = ble_char_add(service_handle, 0xFF91, RD|WR, 16,
                            ble_mps_device_name_char_buffer,
                            &ble_mps_device_name_char_handles,
                            NULL);
    APP_ERROR_CHECK(err_code);
    err_code = ble_char_add(service_handle, 0xFF92, RD|WR,  1,
                            &ble_mps_connection_interval_char_buffer,
                            &ble_mps_connection_interval_char_handles,
                            NULL);
    APP_ERROR_CHECK(err_code);
    err_code = ble_char_add(service_handle, 0xFF94, WR,     1,
                            &ble_mps_reset_module_char_buffer,
                            &ble_mps_reset_module_char_handles,
                            NULL);
    APP_ERROR_CHECK(err_code);
    err_code = ble_char_add(service_handle, 0xFF95, RD|WR,  1,
                            &ble_mps_advertising_interval_char_buffer,
                            &ble_mps_advertising_interval_char_handles,
                            NULL);
    APP_ERROR_CHECK(err_code);
    err_code = ble_char_add(service_handle, 0xFF97, RD|WR,  1,
                            &ble_mps_transmit_power_char_buffer,
                            &ble_mps_transmit_power_char_handles,
                            NULL);
    APP_ERROR_CHECK(err_code);
    err_code = ble_char_add(service_handle, 0xFF98, RD|WR, 16,
                            ble_mps_custom_broadcast_data_char_buffer,
                            &ble_mps_custom_broadcast_data_char_handles,
                            NULL);
    APP_ERROR_CHECK(err_code);
    err_code = ble_char_add(service_handle, 0xFF9B, WR,    20,
                            ble_mps_connected_broadcast_data_char_buffer,
                            &ble_mps_connected_broadcast_data_char_handles,
                            NULL);
    APP_ERROR_CHECK(err_code);
    err_code = ble_char_add(service_handle, 0xFF9C, RD|WR, 1,
                            &ble_mps_connected_broadcast_enable_char_buffer,
                            &ble_mps_connected_broadcast_enable_char_handles,
                            NULL);
    APP_ERROR_CHECK(err_code);
}
//=====================================================================================================================
