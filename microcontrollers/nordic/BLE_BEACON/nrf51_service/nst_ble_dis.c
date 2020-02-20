//=====================================================================================================================
/*---------------------------------------------------------------------------------------------------------*/
/* Device Information Service(0x180A)                                                                      */
/* --Device Information System ID Characteristic(0x2A23)                R   8                              */
/* --Device Information Module Software Ver Characteristic(0x2A26)      R  12                              */
/* --Device Information System Name Ver Characteristic(0x2A29)          R  20                              */
/*---------------------------------------------------------------------------------------------------------*/
#include <stdint.h>
#include <string.h>
#include "nordic_common.h"
#include "nrf.h"
#include "nrf51_bitfields.h"
#include "app_error.h"
#include "ble.h"
#include "ble_error_log.h"

#include "nst_ble_service.h"
//=====================================================================================================================
#define FIRMWARE_VER            "V0.11"
#define NST_MODULE              "Ramp"

extern uint8_t bootloader_version;
//=====================================================================================================================
static uint16_t                 service_handle;
//=====================================================================================================================
static ble_gatts_char_handles_t ble_dis_system_id_char_handles;
static uint8_t                  ble_dis_system_id_char_buffer[8];
static ble_gatts_char_handles_t ble_dis_module_software_ver_char_handles;
static uint8_t                  ble_dis_module_software_ver_char_buffer[12] = FIRMWARE_VER;
static ble_gatts_char_handles_t ble_dis_system_name_char_handles;
static uint8_t                  ble_dis_system_name_char_buffer[20]        = NST_MODULE;
//=====================================================================================================================
void ble_dis_on_ble_evt(ble_evt_t * p_ble_evt)
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
/*    Function to add Device Information Service(0x180A).                                                  */
/* Parameter:                                                                                              */
/*    NULL                                                                                                 */
/* Return:                                                                                                 */
/*    NULL                                                                                                 */
/*---------------------------------------------------------------------------------------------------------*/
void ble_dis_init(void)
{
    uint32_t       err_code;
    ble_uuid_t     service_uuid;
    ble_gap_addr_t gap_addr;

    // Load default data
    err_code = sd_ble_gap_address_get(&gap_addr);
    APP_ERROR_CHECK(err_code);
    ble_dis_system_id_char_buffer[0] = gap_addr.addr[5];
    ble_dis_system_id_char_buffer[1] = gap_addr.addr[4];
    ble_dis_system_id_char_buffer[2] = gap_addr.addr[3];
    ble_dis_system_id_char_buffer[3] = 0x00;
    ble_dis_system_id_char_buffer[4] = 0x00;
    ble_dis_system_id_char_buffer[5] = gap_addr.addr[2];
    ble_dis_system_id_char_buffer[6] = gap_addr.addr[1];
    ble_dis_system_id_char_buffer[7] = gap_addr.addr[0];

    if(bootloader_version != 0)
    {
        ble_dis_module_software_ver_char_buffer[strlen(FIRMWARE_VER) + 0] = '_';
        ble_dis_module_software_ver_char_buffer[strlen(FIRMWARE_VER) + 1] = 'V';
        ble_dis_module_software_ver_char_buffer[strlen(FIRMWARE_VER) + 2] = '0';
        ble_dis_module_software_ver_char_buffer[strlen(FIRMWARE_VER) + 3] = '.';
        ble_dis_module_software_ver_char_buffer[strlen(FIRMWARE_VER) + 4] = 0x30 + bootloader_version;
        ble_dis_module_software_ver_char_buffer[strlen(FIRMWARE_VER) + 5] = 0x00;
    }

    // Add service
    BLE_UUID_BLE_ASSIGN(service_uuid, 0x180A);
    err_code = sd_ble_gatts_service_add(BLE_GATTS_SRVC_TYPE_PRIMARY, &service_uuid, &service_handle);
    APP_ERROR_CHECK(err_code);

    // Add Characteristic
    err_code = ble_char_add(service_handle, 0x2A23, RD,  8,
                            ble_dis_system_id_char_buffer,
                            &ble_dis_system_id_char_handles,
                            NULL);
    APP_ERROR_CHECK(err_code);
    err_code = ble_char_add(service_handle, 0x2A26, RD, 12,
                            ble_dis_module_software_ver_char_buffer,
                            &ble_dis_module_software_ver_char_handles,
                            NULL);
    APP_ERROR_CHECK(err_code);
    err_code = ble_char_add(service_handle, 0x2A29, RD, 20,
                            ble_dis_system_name_char_buffer,
                            &ble_dis_system_name_char_handles,
                            NULL);
    APP_ERROR_CHECK(err_code);
}
//=====================================================================================================================
