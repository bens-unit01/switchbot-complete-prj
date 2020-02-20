//=====================================================================================================================
/*---------------------------------------------------------------------------------------------------------*/
/* Receive Data Service(0xFFE0)                                                                            */
/* --Receive Data Characteristic(0xFFE4)                                W  20                              */
/* Send Data Service(0xFFE5)                                                                               */
/* --Send Data Characteristic(0xFFE9)                                   R  20                              */
/*---------------------------------------------------------------------------------------------------------*/
#include <stdint.h>
#include <string.h>
#include "nordic_common.h"
#include "nrf.h"
#include "nrf51_bitfields.h"
#include "app_error.h"
#include "ble.h"
#include "ble_error_log.h"
#include "ble_srv_common.h"
//-----------------------
#include	"Pram.h"
//=====================================================================================================================
static uint16_t                 conn_handle;
static uint16_t                 service_handle;
//=====================================================================================================================
static ble_gatts_char_handles_t ble_dts_receive_data_char_handles;
static uint8_t                  ble_dts_receive_data_char_buffer[20];
static ble_gatts_char_handles_t ble_dts_send_data_char_handles;
static uint8_t                  ble_dts_send_data_char_buffer[20];
//=====================================================================================================================
/*---------------------------------------------------------------------------------------------------------*/
/* Description:                                                                                            */
/*    Function for sending data.                                                                           */
/* Parameter:                                                                                              */
/*    [in]  data   Value to be send.                                                                       */
/*    [in]  length Length to be send.                                                                      */
/* Return:                                                                                                 */
/*    NRF_SUCCESS on success, otherwise an error code.                                                     */
/*---------------------------------------------------------------------------------------------------------*/
uint32_t ble_dts_send_data(uint8_t* data, uint16_t length)
{
    uint32_t               err_code = NRF_SUCCESS;
    ble_gatts_hvx_params_t hvx_params;

    memcpy(ble_dts_send_data_char_buffer, data, length);

    // Update data_to_app value.
    err_code = sd_ble_gatts_value_set(ble_dts_send_data_char_handles.value_handle,
                                      0,
                                      &length,
                                      ble_dts_send_data_char_buffer);
    APP_ERROR_CHECK(err_code);

    if(conn_handle != BLE_CONN_HANDLE_INVALID)
    {
        memset(&hvx_params, 0, sizeof(hvx_params));

        hvx_params.handle = ble_dts_send_data_char_handles.value_handle;
        hvx_params.type   = BLE_GATT_HVX_NOTIFICATION;
        hvx_params.offset = 0;
        hvx_params.p_len  = &length;
        hvx_params.p_data = ble_dts_send_data_char_buffer;

        err_code = sd_ble_gatts_hvx(conn_handle, &hvx_params);
    }
    else
        err_code = NRF_ERROR_INVALID_STATE;

    if ((err_code != NRF_SUCCESS) &&
        (err_code != NRF_ERROR_INVALID_STATE) &&
        (err_code != BLE_ERROR_NO_TX_BUFFERS) &&
        (err_code != BLE_ERROR_GATTS_SYS_ATTR_MISSING)
    )
    {
        APP_ERROR_HANDLER(err_code);
    }

    return err_code;
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
	conn_handle = p_ble_evt->evt.gap_evt.conn_handle;
	mFlags.ble_connect = 1;		//2014/9/9 Jeans 05:51:52.
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
	conn_handle = BLE_CONN_HANDLE_INVALID;
	mFlags.ble_connect = 0;		//2014/9/9 Jeans 05:51:59.
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
    ble_gatts_evt_write_t* p_evt_write;

    p_evt_write = &p_ble_evt->evt.gatts_evt.params.write;

	if(p_evt_write->handle == ble_dts_receive_data_char_handles.value_handle)
	{
		memcpy(&BleBuf[APP_TX_index][0],&p_evt_write->data[0],p_evt_write->len);
		APP_TX_index ++;
		if(APP_TX_index >= 10) APP_TX_index = 0;	//2015/3/25 Jeans 12:26:37.
		mFlags.ble_control	=	1;		//2014/9/8 Jeans 05:52:18.
	}
}
//------------------------------------------------------------------------------------------------------
void ble_dts_on_ble_evt(ble_evt_t * p_ble_evt)
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
//------------------------------------------------------------------------------------------------------
static void ble_dts_receive_data_char_ini(void)
{
    ble_uuid_t          ble_uuid;
    ble_gatts_char_md_t char_md;
    ble_gatts_attr_md_t attr_md;
    ble_gatts_attr_t    attr_char_value;
    uint32_t            err_code;
    char                user_desc[] = "B CHL(TX,20Byte)";

    memset(&char_md, 0, sizeof(char_md));

    char_md.char_props.write         = 1;
    char_md.char_props.write_wo_resp = 1;
    char_md.p_char_user_desc         = (uint8_t*)user_desc;
    char_md.char_user_desc_size      = strlen(user_desc);
    char_md.char_user_desc_max_size  = strlen(user_desc);
    char_md.p_char_pf                = NULL;
    char_md.p_user_desc_md           = NULL;
    char_md.p_cccd_md                = NULL;
    char_md.p_sccd_md                = NULL;

    BLE_UUID_BLE_ASSIGN(ble_uuid, 0xFFE9);

    memset(&attr_md, 0, sizeof(attr_md));

    BLE_GAP_CONN_SEC_MODE_SET_OPEN(&attr_md.write_perm);

    attr_md.vloc    = BLE_GATTS_VLOC_STACK;
    attr_md.rd_auth = 0;
    attr_md.wr_auth = 0;
    attr_md.vlen    = 1;

    memset(&attr_char_value, 0, sizeof(attr_char_value));

    attr_char_value.p_uuid    = &ble_uuid;
    attr_char_value.p_attr_md = &attr_md;
    attr_char_value.init_len  = 20*sizeof(uint8_t);
    attr_char_value.init_offs = 0;
    attr_char_value.max_len   = 20*sizeof(uint8_t);
    attr_char_value.p_value   = ble_dts_receive_data_char_buffer;

    err_code = sd_ble_gatts_characteristic_add(service_handle,
                                               &char_md,
                                               &attr_char_value,
                                               &ble_dts_receive_data_char_handles);
    APP_ERROR_CHECK(err_code);
}
//------------------------------------------------------------------------------------------------------
static void ble_dts_send_data_char_ini(void)
{
    ble_uuid_t          ble_uuid;
    ble_gatts_char_md_t char_md;
    ble_gatts_attr_md_t attr_md;
    ble_gatts_attr_t    attr_char_value;
    uint32_t            err_code;
    char                user_desc[] = "A CHL(RX,20Byte)";

    memset(&char_md, 0, sizeof(char_md));

    char_md.char_props.notify       = 1;
    char_md.p_char_user_desc        = (uint8_t*)user_desc;
    char_md.char_user_desc_size     = strlen(user_desc);
    char_md.char_user_desc_max_size = strlen(user_desc);
    char_md.p_char_pf               = NULL;
    char_md.p_user_desc_md          = NULL;
    char_md.p_cccd_md               = NULL;
    char_md.p_sccd_md               = NULL;

    BLE_UUID_BLE_ASSIGN(ble_uuid, 0xFFE4);

    memset(&attr_md, 0, sizeof(attr_md));

    BLE_GAP_CONN_SEC_MODE_SET_OPEN(&attr_md.read_perm);

    attr_md.vloc    = BLE_GATTS_VLOC_STACK;
    attr_md.rd_auth = 0;
    attr_md.wr_auth = 0;
    attr_md.vlen    = 1;

    memset(&attr_char_value, 0, sizeof(attr_char_value));

    attr_char_value.p_uuid    = &ble_uuid;
    attr_char_value.p_attr_md = &attr_md;
    attr_char_value.init_len  = 20*sizeof(uint8_t);
    attr_char_value.init_offs = 0;
    attr_char_value.max_len   = 20*sizeof(uint8_t);
    attr_char_value.p_value   = ble_dts_send_data_char_buffer;

    err_code = sd_ble_gatts_characteristic_add(service_handle,
                                               &char_md,
                                               &attr_char_value,
                                               &ble_dts_send_data_char_handles);
    APP_ERROR_CHECK(err_code);
}
/*---------------------------------------------------------------------------------------------------------*/
/* Description:                                                                                            */
/*    Function to add Receive Data Service(0xFFE0) and Send Data Service(0xFFE5)                           */
/* Parameter:                                                                                              */
/*    NULL                                                                                                 */
/* Return:                                                                                                 */
/*    NULL                                                                                                 */
/*---------------------------------------------------------------------------------------------------------*/
void ble_dts_init(void)
{
    ble_uuid_t service_uuid;
    uint32_t   err_code;

    // Add service(send data is for module to iphone)
    BLE_UUID_BLE_ASSIGN(service_uuid, 0xFFE0);
    err_code = sd_ble_gatts_service_add(BLE_GATTS_SRVC_TYPE_PRIMARY, &service_uuid, &service_handle);
    APP_ERROR_CHECK(err_code);
    ble_dts_send_data_char_ini();

    // Add service(receive data is for module from iphone)
    BLE_UUID_BLE_ASSIGN(service_uuid, 0xFFE5);
    err_code = sd_ble_gatts_service_add(BLE_GATTS_SRVC_TYPE_PRIMARY, &service_uuid, &service_handle);
    APP_ERROR_CHECK(err_code);
    ble_dts_receive_data_char_ini();
}
//=====================================================================================================================
