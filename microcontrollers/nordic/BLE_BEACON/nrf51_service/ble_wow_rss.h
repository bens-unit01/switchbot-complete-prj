//=====================================================================================================================
/*---------------------------------------------------------------------------------------------------------*/
/* Photo Setting Service(0xFF10)                                                                           */
/* --Activation Status(0xFF1B)                                         RW   1                              */
/*---------------------------------------------------------------------------------------------------------*/
#ifndef __WW_BLE_PSS_H__
#define __WW_BLE_PSS_H__

#include <stdint.h>
#include <stdbool.h>
#include "ble.h"
#include "ble_srv_common.h"
/*---------------------------------------------------------------------------------------------------------*/
/* Define Some Setting                                                                                     */
/*---------------------------------------------------------------------------------------------------------*/

#define PSS_STATUS_FACTORY               0x00
#define PSS_STATUS_ACTIVATED             0x01
#define PSS_STATUS_FLURRY                0x02

/*---------------------------------------------------------------------------------------------------------*/
/* Define Photo Setting Service structure. This contains various status information for the service.       */
/*---------------------------------------------------------------------------------------------------------*/
typedef struct ble_wow_pss_s
{
    uint16_t                 conn_handle;
    uint16_t                 service_handle;
    ble_gatts_char_handles_t ble_pss_activation_status_char_handles;
} ble_wow_pss_t;

typedef struct ble_wow_pss_data_s
{
    uint8_t  activation_status;
} ble_wow_pss_data_t;

extern ble_wow_pss_data_t m_wow_pss_data;


/*---------------------------------------------------------------------------------------------------------*/
/* Description:                                                                                            */
/*    Function for handling the events.                                                                    */
/* Parameter:                                                                                              */
/*    p_ble_evt: Event received from the BLE stack.                                                        */
/* Return:                                                                                                 */
/*    NULL                                                                                                 */
/*---------------------------------------------------------------------------------------------------------*/
void ble_pss_on_ble_evt(ble_evt_t * p_ble_evt);
/*---------------------------------------------------------------------------------------------------------*/
/* Description:                                                                                            */
/*    Function to add Photo Setting Service(0xFF10).                                                       */
/* Parameter:                                                                                              */
/*    NULL                                                                                                 */
/* Return:                                                                                                 */
/*    NULL                                                                                                 */
/*---------------------------------------------------------------------------------------------------------*/
void ble_pss_init(void);

#endif // __WW_BLE_PSS_H__
//=====================================================================================================================

