//=====================================================================================================================
/*---------------------------------------------------------------------------------------------------------*/
/* Programmable IO Service(0xFFF0)                                                                         */
/* --Programmable IO Configure Pin Characteristic(0xFFF1)              RW   1                              */
/* --Programmable IO Set Pin Characteristic(0xFFF2)                     W   1                              */
/* --Programmable IO Read Or Notify Pin Characteristic(0xFFF3)         RN   1                              */
/*---------------------------------------------------------------------------------------------------------*/
#ifndef __NST_BLE_PIOS_H__
#define __NST_BLE_PIOS_H__

void ble_pios_on_ble_evt(ble_evt_t * p_ble_evt);
void ble_pios_init(void);

#endif // __NST_BLE_PIOS_H__
//=====================================================================================================================

