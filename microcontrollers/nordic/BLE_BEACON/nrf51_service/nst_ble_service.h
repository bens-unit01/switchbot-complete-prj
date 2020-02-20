//=====================================================================================================================
#ifndef __NST_BLE_SERVICE_H__
#define __NST_BLE_SERVICE_H__
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
/*   [in]  user_desc      Characteristic User Description.                                                 */
/* Return:                                                                                                 */
/*    NRF_SUCCESS on success, otherwise an error code.                                                     */
/*---------------------------------------------------------------------------------------------------------*/
uint32_t ble_char_add(uint16_t                   service_handle,
                      uint16_t                   uuid,
                      uint8_t                    char_props,
                      uint16_t                   char_len,
                      uint8_t *                  p_char_value,
                      ble_gatts_char_handles_t * p_handles,
                      char*                      user_desc);
/*---------------------------------------------------------------------------------------------------------*/
/* Description:                                                                                            */
/*    Function for sending value.                                                                          */
/* Parameter:                                                                                              */
/*   [in]  conn_handle    Connection Handle.                                                               */
/*   [in]  length         Length of sending data.                                                          */
/*   [in]  data           Data to be send.                                                                 */
/*   [out] p_char_value   Pointer to characteristic value.                                                 */
/*   [in]  handles        Handles of characteristic.                                                       */
/* Return:                                                                                                 */
/*    NRF_SUCCESS on success, otherwise an error code.                                                     */
/*---------------------------------------------------------------------------------------------------------*/
uint32_t ble_notify_send(uint16_t                 conn_handle,
                         uint16_t                 length,
                         uint8_t *                data,
                         uint8_t *                p_char_value,
                         ble_gatts_char_handles_t handles);
#endif // __NST_BLE_SERVICE_H__
//=====================================================================================================================

