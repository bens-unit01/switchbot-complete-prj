//=====================================================================================================================
#include <stdint.h>
#include <string.h>
#include "nordic_common.h"
#include "nrf.h"
#include "app_error.h"
#include "nrf51_bitfields.h"
#include "ble.h"
#include "ble_error_log.h"
//=====================================================================================================================
/*---------------------------------------------------------------------------------------------------------*/
/* Define Characteristic Properties                                                                        */
/*---------------------------------------------------------------------------------------------------------*/
#define     RD                          0x01
#define     WR                          0x02
#define     WO                          0x04
#define     NO                          0x08
#define     ID                          0x10
/*---------------------------------------------------------------------------------------------------------*/
/* Description:                                                                                            */
/*    Function for adding the Characteristic.                                                              */
/* Parameter:                                                                                              */
/*   [in]  uuid           UUID of characteristic to be added.                                              */
/*   [in]  char_props     Characteristic Properties.                                                       */
/*   [in]  char_len       Length of initial value. This will also be the maximum value.                    */
/*   [in]  p_char_value   Initial value of characteristic to be added.                                     */
/*   [out] p_handles      Handles of new characteristic.                                                   */
/* Return:                                                                                                 */
/*    NRF_SUCCESS on success, otherwise an error code.                                                     */
/*---------------------------------------------------------------------------------------------------------*/
uint32_t ble_char_add(uint16_t                   service_handle,
                      uint16_t                   uuid,
                      uint8_t                    char_props,
                      uint16_t                   char_len,
                      uint8_t *                  p_char_value,
                      ble_gatts_char_handles_t * p_handles,
                      char*                      user_desc)
{
    ble_uuid_t          char_uuid;    
    ble_gatts_char_md_t char_md;     
    ble_gatts_attr_md_t attr_md;
    ble_gatts_attr_t    attr_char_value;   
    
//    APP_ERROR_CHECK_BOOL(p_char_value != NULL);
//    APP_ERROR_CHECK_BOOL(char_len > 0);

    memset(&char_md, 0, sizeof(char_md));

    if(char_props & RD)
        char_md.char_props.read          = 1;
    if(char_props & WR)
        char_md.char_props.write         = 1;
    if(char_props & WO)
        char_md.char_props.write_wo_resp = 1;
    if(char_props & NO)
        char_md.char_props.notify        = 1;    
    if(char_props & ID)
        char_md.char_props.indicate      = 1;    
    
    char_md.p_char_user_desc        = (uint8_t*)user_desc;
    char_md.char_user_desc_size     = strlen(user_desc);
    char_md.char_user_desc_max_size = strlen(user_desc);
    char_md.p_char_pf               = NULL;
    char_md.p_user_desc_md          = NULL;
    char_md.p_cccd_md               = NULL;
    char_md.p_sccd_md               = NULL;
    
    BLE_UUID_BLE_ASSIGN(char_uuid, uuid);
    
    memset(&attr_md, 0, sizeof(attr_md));
    
    if(char_props & RD)
        BLE_GAP_CONN_SEC_MODE_SET_OPEN(&attr_md.read_perm);
    if((char_props & WR) || (char_props & WO))
        BLE_GAP_CONN_SEC_MODE_SET_OPEN(&attr_md.write_perm);
        
    attr_md.vloc       = BLE_GATTS_VLOC_STACK;
    attr_md.rd_auth    = 0;
    attr_md.wr_auth    = 0;
    attr_md.vlen       = 1;
    
    memset(&attr_char_value, 0, sizeof(attr_char_value));    
     
    attr_char_value.p_uuid       = &char_uuid;
    attr_char_value.p_attr_md    = &attr_md;
    attr_char_value.init_len     = char_len;
    attr_char_value.init_offs    = 0;
    attr_char_value.max_len      = char_len;
    attr_char_value.p_value      = p_char_value;
    
    return sd_ble_gatts_characteristic_add(service_handle, &char_md, &attr_char_value, p_handles);
}
/*---------------------------------------------------------------------------------------------------------*/
/* Description:                                                                                            */
/*    Function for sending value.                                                                          */
/* Parameter:                                                                                              */
/*    [in]  conn_handle    Connection Handle.                                                              */
/*    [in]  length         Length of sending data.                                                         */
/*    [in]  data           Data to be send.                                                                */
/*    [out] p_char_value   Pointer to characteristic value.                                                */
/*    [in]  handles        Handles of characteristic.                                                      */
/* Return:                                                                                                 */
/*    NRF_SUCCESS on success, otherwise an error code.                                                     */
/*---------------------------------------------------------------------------------------------------------*/
uint32_t ble_notify_send(uint16_t                 conn_handle,
                         uint16_t                 length,
                         uint8_t *                data,
                         uint8_t *                p_char_value,
                         ble_gatts_char_handles_t handles)
{
    uint32_t               err_code = NRF_SUCCESS;
    ble_gatts_hvx_params_t hvx_params;
    
    // Update database
    memcpy(p_char_value, data, length);
    err_code = sd_ble_gatts_value_set(handles.value_handle,
                                      0,
                                      &length,
                                      p_char_value);
    if(err_code != NRF_SUCCESS)
        return err_code;
    
    // Send value if connected
    if(conn_handle != BLE_CONN_HANDLE_INVALID)
    {
        memset(&hvx_params, 0, sizeof(hvx_params));
        
        hvx_params.handle   = handles.value_handle;
        hvx_params.type     = BLE_GATT_HVX_NOTIFICATION;
        hvx_params.offset   = 0;
        hvx_params.p_len    = &length;
        hvx_params.p_data   = p_char_value;
        
        err_code = sd_ble_gatts_hvx(conn_handle, &hvx_params);
    }
    else
        err_code = NRF_ERROR_INVALID_STATE;
        
    return err_code;
}
//=====================================================================================================================
