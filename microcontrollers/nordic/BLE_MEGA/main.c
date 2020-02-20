/*
 * Copyright (c) 2012 Nordic Semiconductor. All Rights Reserved.
 *
 * The information contained herein is confidential property of Nordic Semiconductor. The use,
 * copying, transfer or disclosure of such information is prohibited except by express written
 * agreement with Nordic Semiconductor.
 *
 */

/** @example Board/nrf6310/s120/experimental/ble_app_hrs_c/main.c
 *
 * @brief BLE Heart Rate Collector application main file.
 *
 * This file contains the source code for a sample heart rate collector.
 */
//#define DEBUG_MODE                        1
#ifdef DEBUG_MODE
#define BOARD_NRF6310
#include "boards.h"
#endif
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include "nordic_common.h"
#include "nrf_sdm.h"
#include "ble.h"
#include "ble_db_discovery.h"
#include "softdevice_handler.h"
#include "app_util.h"
#include "app_error.h"
#include "ble_advdata_parser.h"
#include "nrf_gpio.h"
#include "pstorage.h"
#include "device_manager.h"
#include "ble_hrs_c.h"
#include "app_util.h"
#include "uart_comm2.h"
#include "ble_hci.h"
#include "app_util_platform.h"
#include "SwitchbotNordic.h"  // setup for the new SB board, nuvoton + stm32f4 board (Andrew Kohlsmith board)
#include "ble_uart_c.h"
#include "time_utils.h"
#include "nrf_delay.h"
#include "debug.h"
//#include "segger/SEGGER_RTT.h"


#define BLE_GAP_ADDR_UNDEFINED                           0x04   // value used to check if the beacon has been discovered during scan or not
#define BOND_DELETE_ALL_BUTTON_ID  BUTTON_1                           /**< Button used for deleting all bonded centrals during startup. */
#define UART_OUTPUT_PIN                  LED_2
#define SCAN_LED_PIN_NO                  LED_2                                          /**< Is on when device is scanning. */
#define CONNECTED_LED_PIN_NO             LED_2                                          /**< Is on when device has connected. */
#define ASSERT_LED_PIN_NO                LED_7                                          /**< Is on when application has asserted. */

#define SEC_PARAM_BOND             1                                  /**< Perform bonding. */
#define SEC_PARAM_MITM             0                                  /**< Man In The Middle protection not required. */
#define SEC_PARAM_IO_CAPABILITIES  BLE_GAP_IO_CAPS_NONE               /**< No I/O capabilities. */
#define SEC_PARAM_OOB              0                                  /**< Out Of Band data not available. */
#define SEC_PARAM_MIN_KEY_SIZE     7                                  /**< Minimum encryption key size. */
#define SEC_PARAM_MAX_KEY_SIZE     16                                 /**< Maximum encryption key size. */

#define SCAN_INTERVAL              0x00A0                             /**< Determines scan interval in units of 0.625 millisecond. */
#define SCAN_WINDOW                0x0050                             /**< Determines scan window in units of 0.625 millisecond. */

#define MIN_CONNECTION_INTERVAL    MSEC_TO_UNITS(7.5, UNIT_1_25_MS)   /**< Determines maximum connection interval in millisecond. */
#define MAX_CONNECTION_INTERVAL    MSEC_TO_UNITS(30, UNIT_1_25_MS)    /**< Determines maximum connection interval in millisecond. */
#define SLAVE_LATENCY              0                                  /**< Determines slave latency in counts of connection events. */
#define SUPERVISION_TIMEOUT        MSEC_TO_UNITS(4000, UNIT_10_MS)    /**< Determines supervision time-out in units of 10 millisecond. */

#define TARGET_UUID                0x180D                             /**< Target device name that application is looking for. */
#define MAX_PEER_COUNT             DEVICE_MANAGER_MAX_CONNECTIONS     /**< Maximum number of peer's application intends to manage. */
#define UUID16_SIZE                2                                  /**< Size of 16 bit UUID */
#define BLE_NUS_MAX_DATA_LEN            (GATT_MTU_SIZE_DEFAULT - 3)
/**@breif Macro to unpack 16bit unsigned UUID from octet stream. */
#define UUID16_EXTRACT(DST,SRC)                                                                  \
        do                                                                                       \
        {                                                                                        \
            (*(DST)) = (SRC)[1];                                                                 \
            (*(DST)) <<= 8;                                                                      \
            (*(DST)) |= (SRC)[0];                                                                \
        } while(0)

/**@brief Variable length data encapsulation in terms of length and pointer to data */
typedef struct
{
	uint8_t * p_data; /**< Pointer to data. */
	uint16_t data_len; /**< Length of data. */
} data_t;

typedef enum
{
	BLE_NO_SCAN, /**< No advertising running. */
	BLE_WHITELIST_SCAN, /**< Advertising with whitelist. */
	BLE_FAST_SCAN, /**< Fast advertising running. */
} ble_advertising_mode_t;

static ble_db_discovery_t m_ble_db_discovery; /**< Structure used to identify the DB Discovery module. */
static ble_hrs_c_t m_ble_hrs_c; /**< Structure used to identify the heart rate client module. */
//static ble_bas_c_t                  m_ble_bas_c;                         /**< Structure used to identify the Battery Service client module. */
static ble_gap_scan_params_t m_scan_param; /**< Scan parameters requested for scanning and connection. */
static dm_application_instance_t m_dm_app_id; /**< Application identifier. */
static dm_handle_t m_dm_device_handle; /**< Device Identifier identifier. */
static uint8_t m_peer_count = 0; /**< Number of peer's connected. */
static uint8_t m_scan_mode; /**< Scan mode used by application. */

static bool m_memory_access_in_progress = false; /**< Flag to keep track of ongoing operations on persistent memory. */

static int stamp1, stamp2;

bool is_stop_condition = false;
//------------
#define MIN_RSSI                   -105
#define BUFFER_SIZE                 20
#define END_BYTE                    0xFF


typedef struct
{
	char * device_name;
	int rssi;
	uint32_t ir_signal_strengh;
	ble_gap_addr_t addr;
} beacon_t;

typedef struct
{
	enum
	{
		CONNECTING = 0, CONNECTED, DISCONNECTING, DISCONNECTED, INIT
	} state;
	uint8_t current_beacon_idx;
	uint8_t reading_counter;
	uint8_t connection_attempts;
	uint8_t connection_timeout;
} ir_measure_t;

static ir_measure_t m_ir_measure =
{ .state = INIT, .current_beacon_idx = 0, .reading_counter = 0,
		.connection_attempts = 0, .connection_timeout = 0 };

static ble_uart_c_t m_ble_uart_c; /**< Structure used to identify the heart rate client module. */
static bool m_connect = false;
static bool m_is_disconnected = true;
static uint16_t m_conn_handle;
static beacon_t m_beacons[MAX_BEACONS] =
                  {
                      { "ww_beacon_01", MIN_RSSI, 0, .addr =
                          { .addr_type = BLE_GAP_ADDR_UNDEFINED } },
                      { "ww_beacon_02", MIN_RSSI, 0, .addr =
                          { .addr_type = BLE_GAP_ADDR_UNDEFINED } },
                      { "ww_beacon_03", MIN_RSSI, 0, .addr =
                          { .addr_type = BLE_GAP_ADDR_UNDEFINED } },
                      { "ww_beacon_04", MIN_RSSI, 0, .addr =
                          { .addr_type = BLE_GAP_ADDR_UNDEFINED } },
                      { "ww_beacon_05", MIN_RSSI, 0, .addr =
                          { .addr_type = BLE_GAP_ADDR_UNDEFINED } },
                  };
static char * m_device_name = "ww_beacon_09";
static char * m_closeset_device = "ww_beacon_03";
static uint8_t m_closeset_idx= 9;
static int m_closeset_index = 0;
static int desiredAngle = 180;
//static int desiredAngle = 90;
static uint8_t m_dp_mode = TRACKING_MODE;

// IR algorithm variables
static uint8_t UART_data_index = 3;
uint32_t time_stamp_01 = 0, time_stamp_02 = 0, time_closest_beacon_expiry = 0;
uint8_t debug_counter_0 = 0; 
uint8_t debug_counter_1 = 0; 
uint8_t debug_counter_2 = 0; 
uint8_t r1, r2, r3, r4, r5, r6, r7, r8;
uint8_t rangeOld, rangeAll, rangeOld_far, rangeAll_far;
uint8_t intCount, perCount, perCount_copy;
uint8_t s1, s2, s3, s4, s5, s6, s7, s8;
uint8_t  IR[];
uint8_t debug_values[10];
uint8_t ir_values[8] = {0};
uint32_t timer2_counter = 0;
bool fNewData = false;
int Head, Range, oldRange = 30, easyRange, MaxRange = 95;
int16_t fwd_bwd;
int16_t lft_rgt;
uint8_t command;
/**
 * @brief Connection parameters requested for connection.
 */
static const ble_gap_conn_params_t m_connection_param =
{ (uint16_t)MIN_CONNECTION_INTERVAL,   // Minimum connection
		(uint16_t)MAX_CONNECTION_INTERVAL,   // Maximum connection
		0,                                   // Slave latency
		(uint16_t)SUPERVISION_TIMEOUT        // Supervision time-out
		};

static void scan_start(void);
/**@brief Function for error handling, which is called when an error has occurred.
 *
 * @warning This handler is an example only and does not fit a final product. You need to analyze
 *          how your product is supposed to react in case of error.
 *
 * @param[in] error_code  Error code supplied to the handler.
 * @param[in] line_num    Line number where the handler is called.
 * @param[in] p_file_name Pointer to the file name.
 */
void app_error_handler(uint32_t error_code, uint32_t line_num,
		const uint8_t * p_file_name)
{
	// APPL_LOG("[APPL]: ASSERT: %s, %d, error 0x%08x\r\n", p_file_name, line_num, error_code);
//	LOG("[APPL]: ASSERT: %s, %d, error 0x%08x\r\n");

//	nrf_gpio_pin_set(ASSERT_LED_PIN_NO);

	// This call can be used for debug purposes during development of an application.
	// @note CAUTION: Activating this code will write the stack to flash on an error.
	//                This function should NOT be used in a final product.
	//                It is intended STRICTLY for development/debugging purposes.
	//                The flash write will happen EVEN if the radio is active, thus interrupting
	//                any communication.
	//                Use with care. Un-comment the line below to use.
	// ble_debug_assert_handler(error_code, line_num, p_file_name);

	// On assert, the system can only recover with a reset.
	LOG("reboot ... r\n");
	//WR_SG(0, "reboot ...   r\n");
	NVIC_SystemReset();
}




void timer2_init(void)
{
	//Initialize timer1.
	timer2_counter = 0;
	NRF_TIMER2->INTENCLR = 0xffffffffUL;
	NRF_TIMER2->TASKS_STOP = 1;
	NRF_TIMER2->TASKS_CLEAR = 1;
	NRF_TIMER2->MODE = TIMER_MODE_MODE_Timer;
	NRF_TIMER2->EVENTS_COMPARE[0] = 0;
	NRF_TIMER2->EVENTS_COMPARE[1] = 0;
	NRF_TIMER2->EVENTS_COMPARE[2] = 0;
	NRF_TIMER2->EVENTS_COMPARE[3] = 0;
	NRF_TIMER2->SHORTS = 0;
	NRF_TIMER2->PRESCALER = 3;		// Input clock is 16MHz, timer clock = 2^3.
	NRF_TIMER2->BITMODE = TIMER_BITMODE_BITMODE_32Bit;
	NRF_TIMER2->INTENSET = (TIMER_INTENSET_COMPARE0_Enabled
			<< TIMER_INTENSET_COMPARE0_Pos);
	NRF_TIMER2->SHORTS = (TIMER_SHORTS_COMPARE0_CLEAR_Enabled
			<< TIMER_SHORTS_COMPARE0_CLEAR_Pos);
	NRF_TIMER2->CC[0] = 200;
	NRF_TIMER2->TASKS_START = 1;

	NVIC_SetPriority(TIMER2_IRQn, APP_IRQ_PRIORITY_LOW);
	NVIC_EnableIRQ(TIMER2_IRQn);
}

void timer2_stop(void)
{
	NVIC_DisableIRQ(TIMER2_IRQn);
}

void send_to_mediabox(uint8_t data[])
{

	simple_uart_put(data[0]);
	simple_uart_put(data[1]);
	simple_uart_put(data[2]);

}

void ble_disconnect()
{
	uint8_t p_is_nested_critical_region;
	sd_nvic_critical_region_enter(&p_is_nested_critical_region);
	timer2_stop();
	fNewData = false;
	m_connect = false;
	is_stop_condition = false;
	sd_nvic_critical_region_exit(p_is_nested_critical_region);

	uint32_t err_code  = sd_ble_gap_disconnect(m_conn_handle,
			BLE_HCI_REMOTE_USER_TERMINATED_CONNECTION);
	debug_counter_1++;  
	debug_save_state(1,  debug_counter_1); 
	debug_save_state(2, (uint8_t) err_code);

	if( (err_code == NRF_ERROR_INVALID_STATE) || (err_code == NRF_ERROR_SVC_HANDLER_MISSING) ) {
		APP_ERROR_CHECK(err_code);
	}


}




/**@brief Function for asserts in the SoftDevice.
 *
 * @details This function will be called in case of an assert in the SoftDevice.
 *
 * @warning This handler is an example only and does not fit a final product. You need to analyze
 *          how your product is supposed to react in case of Assert.
 * @warning On assert from the SoftDevice, the system can only recover on reset.
 *
 * @param[in] line_num     Line number of the failing ASSERT call.
 * @param[in] p_file_name  File name of the failing ASSERT call.
 */

void assert_nrf_callback(uint16_t line_num, const uint8_t * p_file_name)
{
	app_error_handler(0xDEADBEEF, line_num, p_file_name);
}

/**@brief Heart Rate Collector Handler.
 */
static void uart_c_evt_handler(ble_uart_c_t * p_uart_c,
		ble_uart_c_evt_t * p_uart_c_evt)
{
	uint32_t err_code;

	switch (p_uart_c_evt->evt_type)
	{
	case BLE_uart_C_EVT_DISCOVERY_COMPLETE:
		// Initiate bonding.
#ifdef BOND_MODE
		err_code = dm_security_setup_req(&m_dm_device_handle);
		APP_ERROR_CHECK(err_code);
#endif
		// Heart rate service discovered. Enable notification of Heart Rate Measurement.
		err_code = ble_uart_c_rx_notif_enable(p_uart_c);
		APP_ERROR_CHECK(err_code);
		break;

	case BLE_UART_C_EVT_HRM_NOTIFICATION:
	{
		for (uint32_t i = 0; i < p_uart_c_evt->params.uart.len; i++)
		{
			//   while(app_uart_put(p_uart_c_evt->params.uart.rx_data[i]) != NRF_SUCCESS);
		}

		break;
	}
	default:
		break;
	}
}

/**@brief Callback handling device manager events.
 *
 * @details This function is called to notify the application of device manager events.
 *
 * @param[in]   p_handle      Device Manager Handle. For link related events, this parameter
 *                            identifies the peer.
 * @param[in]   p_event       Pointer to the device manager event.
 * @param[in]   event_status  Status of the event.
 */
static api_result_t device_manager_event_handler(const dm_handle_t * p_handle,
		const dm_event_t * p_event, const api_result_t event_result)
{

	uint32_t err_code;

	switch (p_event->event_id)
	{
	case DM_EVT_CONNECTION:
	{

	       debug_counter_2++; 
               debug_save_state(3, debug_counter_2); 	       
		m_conn_handle = p_event->event_param.p_gap_param->conn_handle;
		//LOG("conn_handle"); LOG2(m_conn_handle);LOG("\n");
//		nrf_gpio_pin_set(CONNECTED_LED_PIN_NO);
		m_dm_device_handle = (*p_handle);
		m_is_disconnected = false;
		// Discover peer's services.
		err_code = ble_db_discovery_start(&m_ble_db_discovery,
				p_event->event_param.p_gap_param->conn_handle);
        //debug_save_value(2, err_code);
        //debug_save_value(3, m_peer_count);
		LOG("[DM_EVT_CONNECTION] connect err: %d ----------------------------------\n", err_code);
		//APP_ERROR_CHECK(err_code);

		m_peer_count++;
		if (m_peer_count < MAX_PEER_COUNT)
		{
			scan_start();
		}
		break;
	}

	case DM_EVT_DISCONNECTION:
	{
		//APPL_LOG("[APPL]: >> DM_EVT_DISCONNECTION\r\n");
		//LOG("DM_EVT_DISCONNECTION\r\n");
		m_is_disconnected = true;
		memset(&m_ble_db_discovery, 0, sizeof(m_ble_db_discovery));
		//m_connect = false;
		nrf_gpio_pin_clear(CONNECTED_LED_PIN_NO);

		if (m_peer_count == MAX_PEER_COUNT)
		{
			scan_start();
		}
		m_peer_count--;
		//m_dp_mode = TRACKING_MODE;
		desiredAngle = 180;
		LOG("[DM_EVT_DISCONNECTION] disconnect \n");
		break;
	}

	case DM_EVT_SECURITY_SETUP:
	{

		//LOG(" .DM_EVT_SECURITY_SETUP\r... \n");
		// Slave securtiy request recived from peer, if from a non bonded device,
		// initiate security setup, else, wait for encryption to complete.
		err_code = dm_security_setup_req(&m_dm_device_handle);
		LOG("DM_EVT_SECURITY_SETUP err: %d ... \n", err_code);
		APP_ERROR_CHECK(err_code);
		break;
	}
	case DM_EVT_SECURITY_SETUP_COMPLETE:
	{
		//LOG("DM_EVT_SECURITY_SETUP\r... \n");
		// Heart rate service discovered. Enable notification of Heart Rate Measurement.
		err_code = ble_hrs_c_hrm_notif_enable(&m_ble_hrs_c);
		LOG("DM_EVT_SECURITY_SETUP_COMPLETE err: %d ... \n", err_code);
		APP_ERROR_CHECK(err_code);
		break;
	}

	case DM_EVT_LINK_SECURED:
		LOG("DM_LINK_SECURED_IND ");
		break;

	case DM_EVT_DEVICE_CONTEXT_LOADED:

		//APP_ERROR_CHECK(event_result);
		LOG(" DM_EVT_DEVICE_CONTEXT_LOADED  ***------*** evt-result: %d \r\n",
				event_result);
		break;

	case DM_EVT_DEVICE_CONTEXT_STORED:
		LOG(" DM_EVT_DEVICE_CONTEXT_STORED evt-result: %d \r\n", event_result);
		APP_ERROR_CHECK(event_result);
		break;

	case DM_EVT_DEVICE_CONTEXT_DELETED:
		LOG("DM_EVT_DEVICE_CONTEXT_DELETED evt-result: %d \r\n", event_result);
		APP_ERROR_CHECK(event_result);
		break;

	default:
		break;
	}

	return NRF_SUCCESS;
}

/**
 * @brief Parses advertisement data, providing length and location of the field in case
 *        matching data is found.
 *
 * @param[in]  Type of data to be looked for in advertisement data.
 * @param[in]  Advertisement report length and pointer to report.
 * @param[out] If data type requested is found in the data report, type data length and
 *             pointer to data will be populated here.
 *
 * @retval NRF_SUCCESS if the data type is found in the report.
 * @retval NRF_ERROR_NOT_FOUND if the data type could not be found.
 */
static uint32_t adv_report_parse(uint8_t type, data_t * p_advdata,
		data_t * p_typedata)
{
	uint32_t index = 0;
	uint8_t * p_data;

	p_data = p_advdata->p_data;

	while (index < p_advdata->data_len)
	{
		uint8_t field_length = p_data[index];
		uint8_t field_type = p_data[index + 1];

		if (field_type == type)
		{
			p_typedata->p_data = &p_data[index + 2];
			p_typedata->data_len = field_length - 1;
			return NRF_SUCCESS;
		}
		index += field_length + 1;
	}
	return NRF_ERROR_NOT_FOUND;
}

/**@brief Function for handling the Application's BLE Stack events.
 *
 * @param[in]   p_ble_evt   Bluetooth stack event.
 */
static void on_ble_evt(ble_evt_t * p_ble_evt)
{
	uint32_t err_code;
	const ble_gap_evt_t * p_gap_evt = &p_ble_evt->evt.gap_evt;


	switch (p_ble_evt->header.evt_id)
	{
	case BLE_GAP_EVT_ADV_REPORT:
	{
		//LOG("BLE_..ADV_REPORT \n");
		data_t adv_data;
		data_t type_data;
		// Initialize advertisement report for parsing.
		adv_data.p_data = (uint8_t *) p_gap_evt->params.adv_report.data;
		adv_data.data_len = p_gap_evt->params.adv_report.dlen;

//            err_code = adv_report_parse(BLE_GAP_AD_TYPE_16BIT_SERVICE_UUID_MORE_AVAILABLE,
//                                        &adv_data,
//                                        &type_data);
		//         LOG("s1 --> ");LOG(adv_data.p_data);LOG("\n");

		err_code = adv_report_parse(BLE_GAP_AD_TYPE_COMPLETE_LOCAL_NAME,
				&adv_data, &type_data);
		if (err_code != NRF_SUCCESS)
		{
			// Compare short local name in case complete name does not match.
			//   err_code = adv_report_parse(BLE_GAP_AD_TYPE_16BIT_SERVICE_UUID_COMPLETE,
			err_code = adv_report_parse(BLE_GAP_AD_TYPE_SHORT_LOCAL_NAME,
					&adv_data, &type_data);
		}
		//   LOG(err_code);

		// Verify if short or complete name matches target.
		if (err_code == NRF_SUCCESS)
		{
//             LOG("s2 --> ");LOG(adv_data.p_data);LOG("\n");

			uint8_t buf[20];
			uint8_t buf2[20];
			strcpy(buf, type_data.p_data);
			buf[12] = '\0'; // marking the end of the string with null character
			bool device_found =
					(strcmp(m_device_name, buf) == 0) ? true : false;

			bool is_current_index = false;

			for (int i = 0; i < MAX_BEACONS; i++)
			{
				strcpy(buf2, m_beacons[i].device_name);
				buf2[12] = '\0';
				is_current_index = (strcmp(buf2, buf) == 0) ? true : false;
				if (is_current_index)
				{
					m_beacons[i].rssi = p_gap_evt->params.adv_report.rssi;
					m_beacons[i].addr = p_gap_evt->params.adv_report.peer_addr;
					break;
				}
			}

			// UUIDs found, look for matching UUID
			for (uint32_t u_index = 0;
					u_index < (type_data.data_len / UUID16_SIZE); u_index++)
			{

				if (device_found && m_connect)
				{
					// Stop scanning.
					err_code = sd_ble_gap_scan_stop();
					LOG("scan stop err: %d \n", err_code);
					if (err_code != NRF_SUCCESS)
					{
						//   APPL_LOG("[APPL]: Scan stop failed, reason %d\r\n", err_code);
						//LOG("Scan stop failed, reason \n");
					}
//					nrf_gpio_pin_clear(SCAN_LED_PIN_NO);

					//       m_scan_param.selective = 0;

					// Initiate connection.
					err_code = sd_ble_gap_connect(
							&p_gap_evt->params.adv_report.peer_addr,
							&m_scan_param, &m_connection_param);

					if (err_code != NRF_SUCCESS)
					{
						//   APPL_LOG("[APPL]: Connection Request Failed, reason %d\r\n", err_code);
						//LOG("Connection Request Failed, reason \n");
					}
					break;
				}
			}
		}
		break;
	}
	case BLE_GAP_EVT_TIMEOUT:
		LOG("BLE_..EVT_TIMEOUT \n");
		if (p_gap_evt->params.timeout.src == BLE_GAP_TIMEOUT_SRC_SCAN)
		{
			//   APPL_LOG("[APPL]: Scan timed out.\r\n");
			//LOG("Scan timed out \n");
			if (m_scan_mode == BLE_WHITELIST_SCAN)
			{
				m_scan_mode = BLE_FAST_SCAN;

				// Start non selective scanning.
				scan_start();
			}
		}
		else if (p_gap_evt->params.timeout.src == BLE_GAP_TIMEOUT_SRC_CONN)
		{
			// APPL_LOG("[APPL]: Connection Request timed out.\r\n");
			//LOG(" Connection Request timed out \n");
		}
		break;
	case BLE_GAP_EVT_CONN_PARAM_UPDATE_REQUEST:
		LOG(" BLE_GAP_EVT_CONN_PARAM_UPDATE_REQUEST\n");
		// Accepting parameters requested by peer.
		err_code = sd_ble_gap_conn_param_update(p_gap_evt->conn_handle,
				&p_gap_evt->params.conn_param_update_request.conn_params);
		//APP_ERROR_CHECK(err_code);
		break;
	case BLE_GAP_EVT_CONN_PARAM_UPDATE:
		LOG("BLE_GAP_EVT_CONN_PARAM_UPDATE\n");
		break;
	case BLE_GAP_EVT_CONNECTED:
		LOG("BLE_GAP_EVT_CONNECTED\n");
		break;
	case BLE_GAP_EVT_DISCONNECTED:
		LOG(" BLE_GAP_EVT_DISCONNECTED\n");
		break;
	case BLE_GATTC_EVT_PRIM_SRVC_DISC_RSP:
		LOG("BLE_GATTC_EVT_PRIM_SRVC_DISC_RSP \n");
		break;
	case BLE_GATTC_EVT_CHAR_DISC_RSP:
		LOG("BLE_GATTC_EVT_CHAR_DISC_RSP \n");
		break;
	case BLE_GATTC_EVT_DESC_DISC_RSP:
		LOG("BLE_GATTC_EVT_DESC_DISC_RSP \n");
		break;
	case BLE_GATTC_EVT_WRITE_RSP:
		LOG("BLE_GATTC_EVT_WRITE_RSP \n");
		break;
	case BLE_GATTC_EVT_TIMEOUT:
		LOG("  BLE_GATTC_EVT_TIMEOUT    \n");
		break;

	default:
		LOG("default event: %d \n", p_ble_evt->header.evt_id);
		break;
	}
}

/**@brief Function for handling the Application's system events.
 *
 * @param[in]   sys_evt   system event.
 */
static void on_sys_evt(uint32_t sys_evt)
{
	//LOG("on_sys_evt \n");
	switch (sys_evt)
	{
	case NRF_EVT_FLASH_OPERATION_SUCCESS:
	case NRF_EVT_FLASH_OPERATION_ERROR:
		if (m_memory_access_in_progress)
		{
			m_memory_access_in_progress = false;
			scan_start();
		}
		break;
	default:
		// No implementation needed.
		break;
	}
}

/**@brief Function for dispatching a BLE stack event to all modules with a BLE stack event handler.
 *
 * @details This function is called from the scheduler in the main loop after a BLE stack event has
 *  been received.
 *
 * @param[in]   p_ble_evt   Bluetooth stack event.
 */
static void ble_evt_dispatch(ble_evt_t * p_ble_evt)
{
	dm_ble_evt_handler(p_ble_evt);
	ble_db_discovery_on_ble_evt(&m_ble_db_discovery, p_ble_evt);
	ble_hrs_c_on_ble_evt(&m_ble_hrs_c, p_ble_evt);
	//  ble_bas_c_on_ble_evt(&m_ble_bas_c, p_ble_evt);
	on_ble_evt(p_ble_evt);
}

/**@brief Function for dispatching a system event to interested modules.
 *
 * @details This function is called from the System event interrupt handler after a system
 *          event has been received.
 *
 * @param[in]   sys_evt   System stack event.
 */
static void sys_evt_dispatch(uint32_t sys_evt)
{
	pstorage_sys_event_handler(sys_evt);
	on_sys_evt(sys_evt);
}

/**@brief Function for initializing the BLE stack.
 *
 * @details Initializes the SoftDevice and the BLE event interrupt.
 */
static void ble_stack_init(void)
{
	uint32_t err_code;

	// Initialize the SoftDevice handler module.

//     SOFTDEVICE_HANDLER_INIT(NRF_CLOCK_LFCLKSRC_XTAL_20_PPM, false);
	SOFTDEVICE_HANDLER_INIT(NRF_CLOCK_LFCLKSRC_RC_250_PPM_4000MS_CALIBRATION,
			false);

	// Register with the SoftDevice handler module for BLE events.
	err_code = softdevice_ble_evt_handler_set(ble_evt_dispatch);
	APP_ERROR_CHECK(err_code);

	// Register with the SoftDevice handler module for System events.
	err_code = softdevice_sys_evt_handler_set(sys_evt_dispatch);
	APP_ERROR_CHECK(err_code);
}

/**@brief Function for initializing the Device Manager.
 *
 * @details Device manager is initialized here.
 */
static void device_manager_init(void)
{
	dm_application_param_t param;
	dm_init_param_t init_param;

	uint32_t err_code;

	err_code = pstorage_init();
	APP_ERROR_CHECK(err_code);

	// Clear all bonded devices if user requests to.
//    init_param.clear_persistent_data =
//        ((nrf_gpio_pin_read(BOND_DELETE_ALL_BUTTON_ID) == 0)? true: false);

	init_param.clear_persistent_data = false;
	err_code = dm_init(&init_param);
	APP_ERROR_CHECK(err_code);

	memset(&param.sec_param, 0, sizeof(ble_gap_sec_params_t));

	// Event handler to be registered with the module.
	param.evt_handler = device_manager_event_handler;

	// Service or protocol context for device manager to load, store and apply on behalf of application.
	// Here set to client as application is a GATT client.
	param.service_type = DM_PROTOCOL_CNTXT_GATT_CLI_ID;

	// Secuirty parameters to be used for security procedures.
	param.sec_param.bond = SEC_PARAM_BOND;
	param.sec_param.mitm = SEC_PARAM_MITM;
	param.sec_param.io_caps = SEC_PARAM_IO_CAPABILITIES;
	param.sec_param.oob = SEC_PARAM_OOB;
	param.sec_param.min_key_size = SEC_PARAM_MIN_KEY_SIZE;
	param.sec_param.max_key_size = SEC_PARAM_MAX_KEY_SIZE;
	param.sec_param.kdist_periph.enc = 1;
	param.sec_param.kdist_periph.id = 1;

	err_code = dm_register(&m_dm_app_id, &param);
	APP_ERROR_CHECK(err_code);
}

/**@brief Function for the LEDs initialization.
 *
 * @details Initializes all LEDs used by this application.
 */
static void leds_init(void)
{
//	nrf_gpio_cfg_output(SCAN_LED_PIN_NO);
//	nrf_gpio_cfg_output(CONNECTED_LED_PIN_NO);
//	nrf_gpio_cfg_output(ASSERT_LED_PIN_NO);
//	nrf_gpio_cfg_output(LED_0);
//	nrf_gpio_cfg_output(LED_1);

	//receivers
	nrf_gpio_cfg_input(IRM_head, NRF_GPIO_PIN_PULLUP);
	nrf_gpio_cfg_input(IRM_tail, NRF_GPIO_PIN_PULLUP);
	nrf_gpio_cfg_input(IRM_left, NRF_GPIO_PIN_PULLUP);
	nrf_gpio_cfg_input(IRM_right, NRF_GPIO_PIN_PULLUP);
//	nrf_gpio_cfg_input(IRM_head_far, NRF_GPIO_PIN_PULLUP);
//	nrf_gpio_cfg_input(IRM_tail_far, NRF_GPIO_PIN_PULLUP);
//	nrf_gpio_cfg_input(IRM_left_far, NRF_GPIO_PIN_PULLUP);
//	nrf_gpio_cfg_input(IRM_right_far, NRF_GPIO_PIN_PULLUP);


	nrf_gpio_cfg_input(Switch, NRF_GPIO_PIN_PULLUP);
}

static void receiver_IRM_coord(void)
{

//	if(fNewData) return;
	r1 = (nrf_gpio_pin_read(IRM_right) == 0);
	r2 = (nrf_gpio_pin_read(IRM_tail) == 0);
	r3 = (nrf_gpio_pin_read(IRM_left) == 0);
	r4 = (nrf_gpio_pin_read(IRM_head) == 0);//Invert and check each IR receivers in turn and store its state.
//	r5 = (nrf_gpio_pin_read(IRM_right_far) == 0);
//	r6 = (nrf_gpio_pin_read(IRM_tail_far) == 0);
//	r7 = (nrf_gpio_pin_read(IRM_left_far) == 0);
//	r8 = (nrf_gpio_pin_read(IRM_head_far) == 0);//Invert and check each IR receivers in turn and store its state.


//	rangeAll = r1 | r2 | r3 | r4 | r5 | r6 | r7 | r8;		//Variable to hold "collective state"
	rangeAll = r1 | r2 | r3 | r4;
	intCount++;										//increment the ramp counter

	if (r1) s1++;  //For each receiver, if its high, increment the counter
	if (r2) s2++;  //this block shoulfd probably be in the else of the IF below)
	if (r3) s3++;
	if (r4) s4++;
//	if (r5) s5++;
//	if (r6) s6++;
//	if (r7) s7++;
//	if (r8) s8++;


	if ((rangeOld == 1) && (rangeAll == 0))				//look for falling edge
	{
		perCount = intCount;								//set the counter
		intCount = 0;
//		if (perCount >= 134)
	//	if (perCount >= 123)
		{
			IR[0] = s1;
			IR[1] = s2;
			IR[2] = s3;
			IR[3] = s4;				//Save the counters from the previous ramps
//			IR[4] = s5;
//			IR[5] = s6;
//			IR[6] = s7;
//			IR[7] = s8;

			fNewData = true;
		}

		s1 = 0;
		s2 = 0;
		s3 = 0;
		s4 = 0;									//reset the counters
//		s5 = 0;
//		s6 = 0;
//		s7 = 0;
//		s8 = 0;

	}

	rangeOld = rangeAll;
}


void motionControl_YAW2(void) {
	uint16_t yawSpeed;

	yawSpeed = 180 - abs(Head);

	yawSpeed = yawSpeed / 4;

	if (yawSpeed > 0) {
		yawSpeed += 1;
	}

	if (yawSpeed > 9) {
		yawSpeed = 9;
	}

	if (Head > 0)  //turn left
			{
		lft_rgt = 0x60 + yawSpeed;
	} else {
		lft_rgt = 0x40 + yawSpeed;
	}
	if ((180 - abs(Head) < 5) && (Range >= 110)) {
		lft_rgt = 0;
	}
}

void motionControl_DriveFWD2(void) {
	uint16_t fwdSpeed;
	uint16_t distance;

	//	distance = 40
	distance = 20;
//    fwdSpeed = abs(easyRange - distance);
	fwdSpeed = abs(easyRange - distance);

	if (fwdSpeed > 0) {

		fwdSpeed += 1;
	}

	if (fwdSpeed > 12) {
		fwdSpeed = 12;
	}

	if ((180 - abs(Head)) <= 30)  //pitch forward
			{

		if (easyRange > distance) //move forward
				{
			fwd_bwd = 0x00 + fwdSpeed;

		} else {

			fwd_bwd = 0x00;

		}

	} else {

		fwd_bwd = 0x00;
	}

}

int calc_coord2(void) {

	int sVal;
	int head, theta;
	int mIdx, i;
	int mVal, minV;
	int IRc[4];

// find max value in the array [M2 M3 M4 M1]

//   M3 - Back
//   M0 - Left
//   M1 - Front
//   M2 - Right

	mIdx = 0;
	mVal = IR[0];
	minV = IR[0];

	// find which receiver get the maximum intensity
	for (i = 0; i < 4; i++) {
		if (IR[i] > mVal) {
			mIdx = i;
			mVal = IR[i];
		}

		if (IR[i] < minV) {
			minV = IR[i];
		}
	}

	for (i = 0; i < 4; i++) {
		IRc[i] = IR[i] - minV;
	}

	// use the max intensity to orient the RX array
	// calculate the angle as a weighteed average
	switch (mIdx) {
	case 0:           //max = R0 - Right
		sVal = (IRc[3] + IRc[1] + IRc[0]);
		mVal = ((IR[3] + IR[1]) >> 1) + IR[0];
		if (sVal == 0)
			sVal = 1;
		head = (IRc[1] - IRc[3]);
		theta = (head * 90) / sVal;
		theta = theta - 90;

		break;

	case 1:           // max = R1 - Back
		sVal = (IRc[2] + IRc[0] + IRc[1]);
		mVal = ((IR[2] + IR[0]) >> 1) + IR[1];
		if (sVal == 0)
			sVal = 1;
		head = (IRc[2] - IRc[0]);
		theta = (head * 90) / sVal;

		break;

	case 2:           // max = R2 - Left
		sVal = (IRc[3] + IRc[1] + IRc[2]);
		mVal = ((IR[3] + IR[1]) >> 1) + IR[2];
		if (sVal == 0)
			sVal = 1;
		head = (IRc[3] - IRc[1]);
		theta = (head * 90) / sVal;
		theta = theta + 90;

		break;

	case 3:           // max = R4 - Front
		sVal = (IRc[2] + IRc[0] + IRc[3]);
		mVal = ((IR[2] + IR[0]) >> 1) + IR[3];
		if (sVal == 0)
			sVal = 1;
		head = (IRc[0] - IRc[2]);
		theta = (head * 90) / sVal;
		theta = theta + 180;
		if (theta > 180) {
			theta = theta - 360;
		}

		break;
	}

	Head = theta;
	Range = mVal;

	if (Range >= MaxRange) {
			is_stop_condition = true;
			easyRange = 5;
		} else {

			easyRange = 140 - Range;
		}


	return 1;
}




uint32_t ble_connect(int16_t index)
{
	uint32_t err_code = 18;
	m_connect = true;
        debug_counter_0++; 
	debug_save_value(0, 1); 
	debug_save_state(0, debug_counter_0); 
// Initiate connection.
	if (m_beacons[index].addr.addr_type != BLE_GAP_ADDR_UNDEFINED)
	{
		m_scan_param.selective = 0;
		err_code = sd_ble_gap_scan_stop();
		err_code = sd_ble_gap_connect(&m_beacons[index].addr, &m_scan_param,
				&m_connection_param);
		if( err_code == NRF_ERROR_INVALID_STATE) {
		    APP_ERROR_CHECK(err_code);
		}
	}

    LOG("ble_connect err_code %d \n", err_code);
	nrf_delay_ms(300);
	timer2_init();
    //debug_save_value(0, index);
    //debug_save_value(1, err_code);
    	time_closest_beacon_expiry = millis(); // reset the expiry time for the closest beacon position
	return err_code;
}



void get_closest_beacon(void)
{

	if (m_closeset_idx == 9)
	{
		m_dp_mode = IR_MEASURING_MODE;
	}
	else
	{
         uint8_t data[3] = {NOTF_DP_CLOSEST_BEACON, m_closeset_idx, 0x05};
//    	PR_SG(0, "- notf_closest idx: %d \n", m_closeset_idx);
    	simple_uart_put(data[0]);
        simple_uart_put(data[1]);
        simple_uart_put(data[2]);

//		send_to_mediabox(data);


	}
}


void ParseCommandUART(uint8_t cr)
{

	uint8_t data[3] =
	{ 0, 0, 0 };

	//If waiting for a new command
	if (UART_data_index == 3)
	{
		//Figure out which tyoe of command it is:
		switch (cr)
		{
		case 0x61: //standup
		case 0x62: //kneel
		case 0x63: // lean (one parameter)
		case 0x65: //estop
		case 0x66: //clear estop
		case DRIVE:
		case NOTF_SET_STATUS:
		case DP_NORDIC_MB_TEST:
		case DP_GOTO_BEACON:
		case DP_STOP:
		case DP_GET_CLOSEST_BEACON:
		case DP_CHANGE_RANGE:
		case IR_CTRL:
		case TEST_01:
		case TEST_02:
		case NOTF_DP_TARGET_REACHED:
		case RGB_CTRL_COMMAND:
		case DEBUG_DUMP:
		case DEBUG_STATE:

			command = cr;
			UART_data_index = 0;

			/*
			 err_code = ble_nus_send_string(&m_nus, "X", 1);
			 if (err_code != NRF_ERROR_INVALID_STATE)
			 {
			 APP_ERROR_CHECK(err_code);
			 }
			 */

			break;

		default:                           //do nothinh

			//    err_code = ble_nus_send_string(&m_nus, "?", 1);
//                                        if (err_code != NRF_ERROR_INVALID_STATE)
//                                        {
			//       APP_ERROR_CHECK(err_code);
//                                        }
			break;

		}

	}
	else
	{ //its an ongoing command

		//Ready for the data
		if (UART_data_index == 0) //its the fwd_bwd byte
		{
			fwd_bwd = cr;
			UART_data_index = 1;
			//simple_uart_put('F');
		}
		else
		{
			if (UART_data_index == 1) //its the lft_rgt byte
			{
				lft_rgt = cr;

				//all data received, time to calculate and drive
				UART_data_index = 3;

				uint32_t err_code;
				//debug_save_value(5, command);
				//debug_save_value(6, fwd_bwd);
				nrf_delay_us(5);
//      		debug_save_value(2, lft_rgt);


//                PR_SG(0, "p-c %03x %03x \n", command, fwd_bwd);
				LOG("[ParseCommand] cmd : %d param: %d \n", command, fwd_bwd);
				switch (command)
				{

				case NOTF_DP_TARGET_REACHED:
					nrf_delay_ms(50);
					data[0] = NOTF_DP_TARGET_REACHED;
					data[1] = 0;
					data[2] = 0;
					send_to_mediabox(data);
					break;

				case DP_GOTO_BEACON:
//                                      dp_cnt++;
					m_device_name = m_beacons[fwd_bwd - 1].device_name; //
					m_closeset_idx = fwd_bwd;
					ble_connect(fwd_bwd - 1);
					//SEGGER_RTT_printf(0,"beacon id: %d ", fwd_bwd);
					LOG(" go to beacon ...\r\n");
					break;

				case DP_STOP:
					// simple_uart_put('d');
					ble_disconnect();
					//nrf_delay_ms(100);

					break;

				case DP_NORDIC_MB_TEST:
					//get_closest_beacon();
//					nrf_delay_ms(50);
					data[0] = NOTF_NORDIC_MB_TEST;
					data[1] = 7;
					//data[2] = dp_cnt;
					data[2] = 0x00;
					send_to_mediabox(data);

					nrf_delay_ms(120);
		/*			
		 			for(uint8_t i = 0; i < debug_cnt; i++){
					data[0] = NOTF_NORDIC_MB_TEST;
					data[1] = debug[i][0];
					data[2] = debug[i][1];
					send_to_mediabox(data);
					nrf_delay_ms(120);
					}
               */ 

//					data[0] = NOTF_NORDIC_MB_TEST;
//		            data[1] = 0;
//					data[2] = 0;
//					send_to_mediabox(data);
					nrf_delay_ms(120);
					//     uint8_t data[3]  = {IR_CTRL, IR_GUN_ON, 0x00};  // command to turn on the near IR transmitter
					//	 err_code = ble_uart_c_write_string(&m_ble_uart_c, data, 3);
					//	 APP_ERROR_CHECK(err_code);
					break;

				case ESTOP:
					simple_uart_put(ESTOP);
					simple_uart_put(0);
					simple_uart_put(0);
					break;

				case CLEAR_ESTOP:
					simple_uart_put(CLEAR_ESTOP);
					simple_uart_put(0);
					simple_uart_put(0);
					break;

				case DRIVE:
					simple_uart_put(DRIVE);
					simple_uart_put(fwd_bwd);
					simple_uart_put(lft_rgt);
					break;
				case DP_GET_CLOSEST_BEACON:
					get_closest_beacon();
					break;
				case IR_CTRL: // command to control IR transmitters
					data[0] = IR_CTRL;
					data[1] = fwd_bwd;
					data[2] = 0x00;
					err_code = ble_uart_c_write_string(&m_ble_uart_c, data, 3);
					APP_ERROR_CHECK(err_code);
					LOG("[IR_CRTL] %d  %d \n", fwd_bwd, err_code);

					break;
				case DP_CHANGE_RANGE:
					MaxRange = fwd_bwd;
					break;
				case TEST_01:
					data[0] = NOTF_GET_NEXT_BEACON;
					data[1] = 0;
					data[2] = 0;
					send_to_mediabox(data);
					simple_uart_putstring("test 01 ok ..");

					// timer2_init();
					break;

				case TEST_02:
					simple_uart_putstring("test 02 ok ..");
					//timer2_stop();
					break;
				case RGB_CTRL_COMMAND:
                    BlinkM_handleCmd((BLINKM_ADDR << 1), fwd_bwd);
					break;
				case DEBUG_DUMP:
					for(uint8_t i =0; i < DEBUG_TABLE_SIZE; i++) {
						simple_uart_put(DEBUG_DUMP);  
						simple_uart_put(debug_get_value(i, 0));  
						simple_uart_put(debug_get_value(i, 1));
					        nrf_delay_ms(40); 	
					}
					break; 
				case DEBUG_STATE: 
					for(uint8_t i =0; i < DEBUG_STATE_SIZE; i++) {
						simple_uart_put(DEBUG_STATE);  
						simple_uart_put(debug_get_state(i));  
						simple_uart_put(0x00);  
						nrf_delay_ms(40); 	
					}

					break; 
				default:
					break;
				}

			}
		}

	}

}



void TIMER2_IRQHandler(void)
{
timer2_counter++;
#ifndef DEBUG_MODE_DEV
	if (m_connect)
		receiver_IRM_coord();          //calculate the relative distance and the angle coord.
#endif

	NRF_TIMER2->EVENTS_COMPARE[0] = 0;
}



/** @brief Function for the Power manager.
 */
static void power_manage(void)
{
	uint32_t err_code = sd_app_evt_wait();
	APP_ERROR_CHECK(err_code);
}

/**@brief Heart Rate Collector Handler.
 */
static void hrs_c_evt_handler(ble_hrs_c_t * p_hrs_c,
		ble_hrs_c_evt_t * p_hrs_c_evt)
{
	uint32_t err_code;

	switch (p_hrs_c_evt->evt_type)
	{
	case BLE_HRS_C_EVT_DISCOVERY_COMPLETE:
		// Initiate bonding.
//            err_code = dm_security_setup_req(&m_dm_device_handle);
//            APP_ERROR_CHECK(err_code);
		// Heart rate service discovered. Enable notification of Heart Rate Measurement.
		err_code = ble_hrs_c_hrm_notif_enable(p_hrs_c);
		APP_ERROR_CHECK(err_code);
		break;

	case BLE_HRS_C_EVT_HRM_NOTIFICATION:
	{
		//  char hr_as_string[LCD_LLEN];
		//  sprintf(hr_as_string, "Heart Rate %d", p_hrs_c_evt->params.hrm.hr_value);
		APP_ERROR_CHECK_BOOL(true);
		break;
	}
	default:
		break;
	}
}

/**
 * @brief Heart rate collector initialization.
 */
static void hrs_c_init(void)
{
	ble_hrs_c_init_t hrs_c_init_obj;

	hrs_c_init_obj.evt_handler = hrs_c_evt_handler;

	uint32_t err_code = ble_hrs_c_init(&m_ble_hrs_c, &hrs_c_init_obj);
	APP_ERROR_CHECK(err_code);
}

/**
 * @brief UART service initialization.
 */
static void uart_c_init(void)
{
	ble_uart_c_init_t uart_c_init_obj;

	uart_c_init_obj.evt_handler = uart_c_evt_handler;

	uint32_t err_code = ble_uart_c_init(&m_ble_uart_c, &uart_c_init_obj);
	LOG("[uart_c_init]: error code : %d \n", err_code);
	APP_ERROR_CHECK(err_code);
}

/**
 * @brief Database discovery collector initialization.
 */
static void db_discovery_init(void)
{
	uint32_t err_code = ble_db_discovery_init();
	APP_ERROR_CHECK(err_code);
}

/**@breif Function to start scanning.
 */
static void scan_start(void)
{
	ble_gap_whitelist_t whitelist;
	ble_gap_addr_t * p_whitelist_addr[BLE_GAP_WHITELIST_ADDR_MAX_COUNT];
	ble_gap_irk_t * p_whitelist_irk[BLE_GAP_WHITELIST_IRK_MAX_COUNT];
	uint32_t err_code;
	uint32_t count;

	// Verify if there is any flash access pending, if yes delay starting scanning until
	// it's complete.
	err_code = pstorage_access_status_get(&count);
	APP_ERROR_CHECK(err_code);

	if (count != 0)
	{
		m_memory_access_in_progress = true;
		return;
	}

	// Initialize whitelist parameters.
	whitelist.addr_count = BLE_GAP_WHITELIST_ADDR_MAX_COUNT;
	whitelist.irk_count = 0;
	whitelist.pp_addrs = p_whitelist_addr;
	whitelist.pp_irks = p_whitelist_irk;

	// Request creating of whitelist.
	err_code = dm_whitelist_create(&m_dm_app_id, &whitelist);
	APP_ERROR_CHECK(err_code);

	if (((whitelist.addr_count == 0) && (whitelist.irk_count == 0))
			|| (m_scan_mode != BLE_WHITELIST_SCAN))
	{
		// No devices in whitelist, hence non selective performed.
		m_scan_param.active = 0;            // Active scanning set.
		m_scan_param.selective = 0;            // Selective scanning not set.
		m_scan_param.interval = SCAN_INTERVAL;            // Scan interval.
		m_scan_param.window = SCAN_WINDOW;  // Scan window.
		m_scan_param.p_whitelist = NULL;         // No whitelist provided.
		m_scan_param.timeout = 0x0000;       // No timeout.
	}
	else
	{
		// Selective scanning based on whitelist first.
		m_scan_param.active = 0;            // Active scanning set.
		m_scan_param.selective = 1;            // Selective scanning not set.
		m_scan_param.interval = SCAN_INTERVAL;            // Scan interval.
		m_scan_param.window = SCAN_WINDOW;  // Scan window.
		m_scan_param.p_whitelist = &whitelist;   // Provide whitelist.
		m_scan_param.timeout = 0x001E;       // 30 seconds timeout.

		// Set whitelist scanning state.
		m_scan_mode = BLE_WHITELIST_SCAN;
	}

	err_code = sd_ble_gap_scan_start(&m_scan_param);
	APP_ERROR_CHECK(err_code);

//	nrf_gpio_pin_set(SCAN_LED_PIN_NO);
}

// uart init

/**@brief  Function for initializing the UART module.
 */
static void uart_init(void)
{
	/**@snippet [UART Initialization] */
	//simple_uart_config(RTS_PIN_NUMBER, TX_PIN_NUMBER, CTS_PIN_NUMBER, RX_PIN_NUMBER, HWFC);
	simple_uart_config(RTS_PIN_NUMBER, TX_PIN_NUMBER, CTS_PIN_NUMBER, RX_PIN_NUMBER, HWFC);

	nrf_gpio_cfg_output(TX_MEDIA_BOX);

	NRF_UART0->INTENSET = UART_INTENSET_RXDRDY_Enabled
			<< UART_INTENSET_RXDRDY_Pos;

	NVIC_SetPriority(UART0_IRQn, APP_IRQ_PRIORITY_LOW);
	NVIC_EnableIRQ(UART0_IRQn);
	/**@snippet [UART Initialization] */
}

void UART0_IRQHandler(void)
{

	static uint8_t data_array[BLE_NUS_MAX_DATA_LEN];
	static uint8_t index = 0;

	/**@snippet [Handling the data received over UART] */

	data_array[index] = simple_uart_get();
	index++;
	ParseCommandUART(data_array[index - 1]);
	index = 0;
}

void handle_tracking(void)
{


	if (fNewData)
	{

		fNewData = false;

//		calc_coord2();
//		motionControl_YAW2();
//		motionControl_DriveFWD2();
//			stamp2 = millis();
			bool flag = calculate_speed2(IR, MaxRange, &fwd_bwd, &lft_rgt, debug_values);

//			LOG("%4d %4d -- ", fwd_bwd, lft_rgt);

//			LOG(" %4d %4d %4d %4d ", ir_values[0], ir_values[1], ir_values[2], ir_values[3]);
//			LOG(" -- %4d %4d %4d %4d -- %4d %4d %4d %4d %4d \n", ir_values[4],  ir_values[5], ir_values[6], ir_values[7] , Range, flag, perCount, (millis() -stamp1), (millis() - stamp2));
//			LOG(" -- %4d %4d %4d %4d %4d %4d \n",  Head, Range, flag, perCount, (millis() -stamp1), (millis() - stamp2));

			if (flag)
			{
						ble_disconnect();
						m_dp_mode = STOP_MODE;
				LOG("stopping ...\n");
						return;
			}



#ifndef DEBUG_MODE
		    simple_uart_put(DRIVE);
       		simple_uart_put(fwd_bwd);
		    simple_uart_put(lft_rgt);
#else
		    LOG(" #\t%d %d %d %d\t%d\t%d -- %d \n",IR[0], IR[1], IR[2], IR[3], fwd_bwd, lft_rgt);
#endif

			stamp1 = millis();
		    nrf_delay_ms(40);


	}

    if((millis() - time_closest_beacon_expiry) > (240000)){  // closest beacon position expires after 4 minutes
    	time_closest_beacon_expiry = millis();
        m_closeset_idx = 9;
    	LOG("closest beacon time expired %d \n", millis());
    }
}



void handle_stop()
{
#ifdef DEBUG_MODE
	LOG("[handle_stop] STOP ....\n");
#else
	nrf_delay_ms(20);
#endif

	desiredAngle = 180;
	fNewData = false;
	m_connect = false;
	if (m_is_disconnected)
	{
    	nrf_delay_ms(150);
		m_dp_mode = TRACKING_MODE;
		uint8_t data[3] =
		{ NOTF_GET_NEXT_BEACON, 0, 0 }; // we ask for the next beacon
		send_to_mediabox(data);
//		PR_SG(0, "NOTF_GET_NEXT ... \n");
        //debug_save_value(4, m_closeset_idx -1);
		IR[0] = 0; IR[1] = 0; IR[2] = 0; IR[3] = 0;
		LOG("get next ...\r\n");
		m_dp_mode = TRACKING_MODE;
	}

}


/**
 * function that reads IR signal from all beacons and determine which one is closest
 */

void handle_ir_measuring()
{

	// state machine model processing
	switch (m_ir_measure.state)
	{
	case INIT:                                      // state 1, start
		PGM_LOG("Initializing IR measurement ... \n");

		m_ir_measure.current_beacon_idx = 0;
		m_ir_measure.reading_counter = 0;
		m_ir_measure.connection_attempts = 0;
		m_ir_measure.connection_timeout = 0;
		m_ir_measure.state = DISCONNECTED;
		time_stamp_01 = millis();
		time_stamp_02 = time_stamp_01;
		for (uint8_t i = 0; i < MAX_BEACONS; i++)
		{
			m_beacons[i].ir_signal_strengh = 0;
		}

		break;

	case DISCONNECTED:     // state 2 + exit condition
		PGM_LOG("disconnected \n");

		if (m_is_disconnected)
		{
			if (m_ir_measure.current_beacon_idx >= MAX_BEACONS)
			{
				m_ir_measure.state = INIT;
				m_dp_mode = TRACKING_MODE;

				for (uint8_t i = 0; i < MAX_BEACONS; i++)
					PGM_LOG("beacon %d  ir: %d \n", i,
							m_beacons[i].ir_signal_strengh);
				PGM_LOG("going to tracking mode ...  %d \n",
						(millis() - time_stamp_01)); // finished reading IR, we go back to tracking mode
				// we determine the maximum IR signal

				uint32_t max_ir  = 0;
				uint8_t max_idx = 0;
				for(uint8_t i = 0; i < MAX_BEACONS; i++){
			        if(m_beacons[i].ir_signal_strengh >= max_ir){
			        	max_ir = m_beacons[i].ir_signal_strengh;
			        	max_idx =i;
			        }
				}

				// we send the result to the mediabox
				max_idx++;
				m_closeset_idx = max_idx;
				if(max_ir == 0) m_closeset_idx = 9;  // we didn't get the id of the closest beacon
				uint8_t data[3] = {NOTF_DP_CLOSEST_BEACON, max_idx, 0x05};
//				PR_SG(0, "notf_closest idx: %d \n", max_idx);
				simple_uart_put(data[0]);
				simple_uart_put(data[1]);
				simple_uart_put(data[2]);
//				send_to_mediabox(data);
				//debug_save_value(4, m_closeset_idx);


		 	}
			else
			{
				if (m_beacons[m_ir_measure.current_beacon_idx].addr.addr_type
						!= BLE_GAP_ADDR_UNDEFINED)
				{
					nrf_delay_ms(5);
					m_device_name = m_beacons[m_ir_measure.current_beacon_idx].device_name; //
					uint32_t err_code = ble_connect(
							m_ir_measure.current_beacon_idx);
					PGM_LOG("connection to %d err_code: %d time: %d \n",
							m_ir_measure.current_beacon_idx, err_code, (millis() - time_stamp_02));
					time_stamp_02 = millis();
					m_ir_measure.current_beacon_idx++;
					m_ir_measure.state = CONNECTING;
				}
				else
				{
					m_ir_measure.current_beacon_idx++; // we try with the next beacon
				}
			}

		}
		break;
	case CONNECTING:    // state 3
		PGM_LOG("connecting to %d \n", m_ir_measure.current_beacon_idx - 1);

		if (!m_is_disconnected)
		{
			m_ir_measure.state = CONNECTED;
		}
		else
		{
			m_ir_measure.connection_timeout++;
			nrf_delay_ms(5);
			if (m_ir_measure.connection_timeout >= 4)
			{
				// we are not connected, we try again
				m_ir_measure.connection_attempts++;
				if (m_ir_measure.connection_attempts >= 3)
				{
					// connection failed, we try with the next beacon
					m_ir_measure.connection_attempts = 0;
					m_ir_measure.connection_timeout = 0;
					m_ir_measure.state = DISCONNECTED;
					PGM_LOG("Trying with : %d \n",
							m_ir_measure.current_beacon_idx);
				}
				else
				{ // we try again to reconnect
					m_ir_measure.connection_timeout = 0;
					uint32_t err_code = ble_connect(
							m_ir_measure.current_beacon_idx - 1);
					PGM_LOG(
							"try again a connection to %d err_code: %d -------------------------------\n",
							m_ir_measure.current_beacon_idx - 1, err_code);
				}
			}
		}
		break;

	case CONNECTED:     // state 4
		PGM_LOG("connected to %d \n", m_ir_measure.current_beacon_idx - 1);

		if (fNewData && (m_ir_measure.reading_counter < 6)) // we read 6 values
		{
			fNewData = false;
			m_ir_measure.reading_counter++;
			PGM_LOG("idx: %d  %d %d %d %d \n ",
					m_ir_measure.current_beacon_idx - 1, IR[0], IR[1], IR[2],
					IR[3]);

			for (uint8_t i = 0; i < 4; i++)
				m_beacons[m_ir_measure.current_beacon_idx - 1].ir_signal_strengh +=
						IR[i]; // calculating the sum for 6 readings
			nrf_delay_ms(5);
		}
		else
		{
			m_beacons[m_ir_measure.current_beacon_idx - 1].ir_signal_strengh /=
					24; // calculating the average
			m_ir_measure.reading_counter = 0;
			m_ir_measure.state = DISCONNECTING;
			ble_disconnect();

		}

		break;

	case DISCONNECTING:    // state 5,  transition to state 2
		PGM_LOG("disconnecting\n");

		if (m_is_disconnected)
		{
			m_ir_measure.state = DISCONNECTED;
		}
		nrf_delay_ms(20);
		break;

	}

	nrf_delay_ms(5);

}




void drive_path_handle(void)
{
	switch (m_dp_mode)
	{
	case IR_MEASURING_MODE:
		handle_ir_measuring();
		break;
	case RSSI_MEASURING_MODE:
//		handle_rssi_measuring();
		break;
	default:
	case TRACKING_MODE:
		handle_tracking();
		break;
	case STOP_MODE:
		handle_stop();
		break;
	}
}



int main(void)
{
	// Initialization of various modules.

	uart_init();
	// app_trace_init();
	leds_init();
	timer2_init();  // we init the timer after connecting see --> ble_connect()
	ble_stack_init();
	device_manager_init();
	db_discovery_init();
	hrs_c_init();
	uart_c_init();
	rtc_config();
	twi_master_init();





    nrf_delay_ms(500);  // wait for the i2c bus
    BlinkM_handleCmd((BLINKM_ADDR << 1), 1);

    LOG("SB - setup completed ... \n ");



//     simple_uart_put(0xff);   // we notify the st chip that we are booting up  
	
	scan_start();


	for (;;)
	{
		power_manage();
		drive_path_handle();

//		 if(fNewData){
//		 fNewData = false; 	 
//			LOG(" %d %d  %d %d  %d\n", IR[0], IR[1], IR[2], IR[3], perCount ); 
//		}
		nrf_delay_ms(20);
	}



}




