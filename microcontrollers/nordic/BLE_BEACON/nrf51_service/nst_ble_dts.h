//=====================================================================================================================
/*---------------------------------------------------------------------------------------------------------*/
/* Receive Data Service(0xFFE0)                                                                            */
/* --Receive Data Characteristic(0xFFE4)                                W  20                              */
/* Send Data Service(0xFFE5)                                                                               */
/* --Send Data Characteristic(0xFFE9)                                   R  20                              */
/*---------------------------------------------------------------------------------------------------------*/
#ifndef __NST_BLE_DTS_H__
#define __NST_BLE_DTS_H__

void ble_dts_on_ble_evt(ble_evt_t * p_ble_evt);
void ble_dts_init(void);

/*---------------------------------------------------------------------------------------------------------*/
/* Description:                                                                                            */
/*    Function for sending data.                                                                           */
/* Parameter:                                                                                              */
/*    [in]  data   Value to be send.                                                                       */
/*    [in]  length Length to be send.                                                                      */
/* Return:                                                                                                 */
/*    NRF_SUCCESS on success, otherwise an error code.                                                     */
/*---------------------------------------------------------------------------------------------------------*/ 
uint32_t ble_dts_send_data(uint8_t* data, uint16_t length);

#endif // __NST_BLE_DTS_H__
//=====================================================================================================================
