//=====================================================================================================================
/*---------------------------------------------------------------------------------------------------------*/
/* Device Information Service(0x180A)                                                                      */
/* --Device Information System ID Characteristic(0x2A23)                R   8                              */
/* --Device Information Module Software Ver Characteristic(0x2A26)      R   5                              */
/* --Device Information System Name Ver Characteristic(0x2A29)          R  20                              */
/*---------------------------------------------------------------------------------------------------------*/
#ifndef __NST_BLE_DIS_H__
#define __NST_BLE_DIS_H__

void ble_dis_on_ble_evt(ble_evt_t * p_ble_evt);
void ble_dis_init(void);

#endif // __NST_BLE_DIS_H__
//=====================================================================================================================

