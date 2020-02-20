//=======================================================================
//.T		����ͷ�ļ�.
//=======================================================================
#include <string.h>
#include	"nrf.h"
#include	"nrf_gpiote.h"
#include	"nrf_soc.h"
#include	"nrf_gpio.h"
#include	"ble_srv_common.h"
#include	"d_flash_data.h"
#include	"d_persistent_storage.h"
//-----------------------
#include	"Ppin.h"
#include	"Pram.h"
#include	"Vehicles.h"
//-----------------------
#include	"RGB_mode.h"
#include	"TIMER2.h"

//=======================================================================
//.T		��������.
//=======================================================================
Flash_struct	Fdata;
Flash_struct	Fchk;
Main_Flags	mFlags;
Gun_struct	GUN;
uint8_t		GUN_IR_dir = 0;
Test_struct	TestMode;
uint8_t		ramp_ID = 0;
uint8_t		T_RAMP_ID[5] = {0,0x1b,0x1d,0x1e,0x1f};
uint8_t		ramp6_index	=	0;
uint8_t		test_gun_ID = 5;
uint8_t		test_2sec = 0;
uint8_t		REV_step = 0;
uint16_t	DAC_IR_3Min	=	0;
//-----------------------
ADC_struct	PowerADC;
#define		c_ADC_times		16
//-----------------------
uint8_t		enter_sleep	=	0;
uint32_t	sleep_time	=	0;
#define		T32_SLEEP	(20 * 60 * 100)
uint16_t	Mode5_sec	=	0;
uint8_t		spcl_step	=	0;
spcl_gun_struct	spcl;
//-----------------------
uint8_t		APP_TX_index	=	0;	//APP��������.
uint8_t		BLE_RD_index	=	0;	//BLE��ȡ����.
uint8_t		BleBuf[10][20]	=
{
	{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
};
uint8_t		BleData[20]	=	{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
uint8_t		BleReturn[20]	=	{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};

uint8_t		Bootloader = 0;
extern uint8_t bootloader_version;




//=======================================================================
//.T		��������.
//=======================================================================

//=======================================================================

//=======================================================================
//F_:I2C^cmd_send_IR(uint8_t on)	//�������뿪������.
//=======================================================================
// Receives 16 bit value
// Follow the GPC_CMD Spreadsheet to determine what to send
void I2C_cmd_send_IR(uint16_t on)
{
	cmd_DATA = 0x1100 + on;	//����/�ر����뷢��.
	cmd_SendCNT = 0;
	cmd_SendStep = 1;			//��ʼ���Ʒ���.
}

//=======================================================================
//F_:I2C^cmd_GUN_ID(uint8_t ID)	//��ǹID����.
//=======================================================================
static void I2C_cmd_GUN_ID(uint8_t ID)
{
	mFlags.I2C_busy = 1;
	cmd_DATA = 0x1300 + ID;					//����ID��.
	cmd_SendCNT = 0;
	cmd_SendStep = 1;								//��ʼ���Ʒ���.
	DAC_IR_3Min = 0;
	GUN.Sht_time = 7;
	mFlags.gun_shoot = 1;	//��ʼ��ǹ.
	nrf_gpio_pin_clear(IR_back);	//�ر�IR  TX���ݿ��ƽ�.
	nrf_gpio_pin_clear(IR_head);	//�ر�IR  TX���ݿ��ƽ�.
}

//=======================================================================
//F_:I2C^cmd_Ramp_ID(uint8_t ID)	//����ƽ̨ID����.
//=======================================================================
static void I2C_cmd_Ramp_ID(uint8_t ID)
{
	cmd_DATA = 0x1700 + ID;					//����ID��.
	cmd_SendCNT = 0;
	cmd_SendStep = 1;								//��ʼ���Ʒ���.
}

//=======================================================================
//F_:I2C^cmd_DAC_AI()	//��ֹDAC�ӳ�6����˯��.
//=======================================================================
static void I2C_cmd_DAC_AI()
{
	mFlags.I2C_busy = 1;
	cmd_DATA = 0x1200 + 254;	//�����ر��ǹ����.
	cmd_SendCNT = 0;
	cmd_SendStep = 1;	//��ʼ���Ʒ���.
}

//=======================================================================
//F_:IOS^0x79_battery_life()	//0x79����ֵ.
//=======================================================================
static void IOS_0x79_battery_life(void)
{
	BleReturn[0] = 0x79;	//Battery Level.
	BleReturn[1] = PowerADC.result / 4;
	BleReturn[2] = 1;	//1:Normal;2:Re-charger.	//��ͨ���.
	ble_dts_send_data(BleReturn,3);
}

//=======================================================================
//F_:ble^parse_control()	//�����������.
//=======================================================================
static void ble_parse_control(void)
{
	uint8_t i = 0;

	if(mFlags.ble_control)
	{	//���յ�������ָ��.
		memcpy(BleData,&BleBuf[BLE_RD_index][0],20);
		BLE_RD_index ++;
		if(BLE_RD_index >= 10) BLE_RD_index = 0;
		if(BLE_RD_index == APP_TX_index) mFlags.ble_control = 0;

		sleep_time = 0;
		switch(BleData[0])
		{
			case	0x95:	//����REV����ID�Ų���ǹ.
				i = BleData[1];
				if(i > 31) i = 31;
				if(BleData[2] == 1)
				{	//1:ȫIR��ǹ.
					GUN_IR_dir = 1;
				}else if(BleData[2] == 2)
				{	//2:����3��+ǰ��2��IR��ǹ.
					GUN_IR_dir = 2;
				}else
				{	//3:ǹIR��ǹ.
					GUN_IR_dir = 3;
				}
				I2C_cmd_GUN_ID(i);	//����ID��.
				break;
			case	0x91:	//main STEPn.
				switch(BleData[1])
				{	//���ò�ѯ��ģʽ.
					case	1:	//Idle.
						REV_step = 1;
						mFlags.IR_status = 1;
						mFlags.IR_set = 0;
						ramp_ID = T_RAMP_ID[0];
						break;
					case	2:	//0X1B����IRģʽ.
						REV_step = 2;
						mFlags.IR_status = 0;
						mFlags.IR_set = 1;	//����IR.
						ramp_ID = T_RAMP_ID[1];	//0x1b;
						break;
					case	3:	//0X1D����IRģʽ.
						REV_step = 3;
						mFlags.IR_status = 0;
						mFlags.IR_set = 1;	//����IR.
						ramp_ID = T_RAMP_ID[2];	//0x1d;
						break;
					case	4:	//0X1E����IRģʽ.
						REV_step = 4;
						mFlags.IR_status = 0;
						mFlags.IR_set = 1;	//����IR.
						ramp_ID = T_RAMP_ID[3];	//0x1e;
						break;
					case	5:	//0X1F����IRģʽ.
						REV_step = 5;
						mFlags.IR_status = 0;
						mFlags.IR_set = 1;	//����IR.
						ramp_ID = T_RAMP_ID[4];	//0x1f;
						break;
					case	0xff:	//��ѯ��ģʽ.
						BleReturn[0] = 0x91;
						BleReturn[1] = REV_step;
						ble_dts_send_data(BleReturn,2);
						break;
					default:
						break;
				}
				break;
			case	0x79:	//��ѯ��ص���.
				IOS_0x79_battery_life();	//0x79����ֵ.
				break;
			case	0x83:	//��ѯRGB����.
				BleReturn[0] = 0x83;	//��ǰRGB����.
				if(RGB.step == 1)
				{	//��˸��ɫģʽ.
					BleReturn[1] = RGB.ShowColor;	//��˸��ɫ.
					BleReturn[2] = RGB.SCtime;		//��˸��ɫʱ��.
					BleReturn[3] = RGB.BGtime;		//��˸����ʱ��.
					BleReturn[4] = RGB.times;			//��˸����.
					ble_dts_send_data(BleReturn,5);
				}else if(RGB.step == 2)
				{	//��������ģʽ.
					BleReturn[1] = RGB.Gradient;	//�������ɫ.
					BleReturn[2] = RGB.speed_ON;	//�������ٶ�.
					BleReturn[3] = RGB.speed_OFF;	//�������ٶ�.
					ble_dts_send_data(BleReturn,4);
				}else
				{	//������Ϊ����ʾ��ɫģʽ.
					BleReturn[1] = RGB.BackGround;	//��ʾ��ɫ.
					ble_dts_send_data(BleReturn,2);
				}
				break;
			case	0x84:	//����RGB��ʾ��ɫ.
				if((BleData[1] > 0) && (BleData[1] < 8))
				{
					RGB_show_color(BleData[1]);	//RGB���趨��ʾ��ɫ.
				}else
				{
					RGB_show_color(clr_Black);	//RGB���趨��ʾ��ɫ.
				}
				break;
			case	0x89:	//����RGB��˸.
				if((BleData[1] > 0) && (BleData[1] < 8))
				{
					RGB.SCtime = BleData[2];	//ˢ����ʾ0.4S.
					RGB.BGtime = BleData[3];	//ˢ����ʾ0.6S.
					RGB.times = BleData[4];		//һֱ��˸.
					RGB_flash_color(BleData[1]);	//RGB���趨��˸��ʾ��ɫ.
				}
				break;
			case	0x90:	//����RGB��������.
				if((BleData[1] > 0) && (BleData[1] < 8))
				{
					RGB.speed_ON = BleData[2];
					RGB.speed_OFF = BleData[3];
					RGB_Gradient_color(BleData[1]);	//�򿪽�������.
				}
				break;
			case	0xFA:	//SLEEP.
				REV_step = 11;
				enter_sleep = 1;	//�������˯��.
				break;
			case	0x19:	//��ѯGPC����汾.
				BleReturn[0] = 0x19;	//GPC����汾.
				BleReturn[1] = 0xee;
				BleReturn[2] = Ver_DAC_data;
				ble_dts_send_data(BleReturn,3);
				break;
			case	0x14:	//��ѯble����汾.
				BleReturn[0] = 0x14;
				BleReturn[1] = 15;	//Year.
				BleReturn[2] = 6;	//Month.
				BleReturn[3] = 15;	//Day.
				BleReturn[4] = 11;	//Unique.
				BleReturn[5] = Bootloader;	//bootloader version.
				ble_dts_send_data(BleReturn,6);
				break;

			default:		break;
		}
	}
}

//=======================================================================
//F_:gun^send_ctl()	//���ƴ�ǹʱ��.
//=======================================================================
static void gun_send_ctl(void)
{
	if(mFlags.gun_shoot)
	{	//׼����ǹ.
		if(GUN.Sht_time == 6)
		{	//ʱ�䵽֪ͨ���뿪ʼ.
			GUN.Sht_time --;
			if(GUN_IR_dir == 1)
			{	//1:ȫIR��ǹ.
				nrf_gpio_pin_set(IR_gun);			//��gun TX���ݿ��ƽ�.
				nrf_gpio_pin_set(IR_back);		//��IR  TX���ݿ��ƽ�.
				nrf_gpio_pin_set(IR_head);		//��IR  TX���ݿ��ƽ�.
			}else if(GUN_IR_dir == 2)
			{	//2:����3��+ǰ��2��IR��ǹ.
				nrf_gpio_pin_clear(IR_gun);		//�ر�gun TX���ݿ��ƽ�.
				nrf_gpio_pin_set(IR_back);		//��IR  TX���ݿ��ƽ�.
				nrf_gpio_pin_clear(IR_head);	//�ر�IR  TX���ݿ��ƽ�.
			}else
			{	//3:ǹIR��ǹ.
				nrf_gpio_pin_set(IR_gun);			//��gun TX���ݿ��ƽ�.
				nrf_gpio_pin_clear(IR_back);	//�ر�IR  TX���ݿ��ƽ�.
				nrf_gpio_pin_clear(IR_head);	//�ر�IR  TX���ݿ��ƽ�.
			}
			nrf_gpio_pin_clear(ble_Vctl);			//��IR��Դ.
			nrf_gpio_cfg_output(ble_GPC2_ctl);
			nrf_gpio_pin_set(ble_GPC2_ctl);		//֪ͨ��ǹ��ʼ�����.
		}else if(GUN.Sht_time == 4)
		{	//֪ͨ�������.
			GUN.Sht_time --;
			nrf_gpio_pin_clear(ble_GPC2_ctl);	//֪ͨ��ǹ���������.
		}else if(GUN.Sht_time == 0)
		{	//һ�δ�ǹ����.
			nrf_gpio_pin_clear(IR_gun);		//�ر�gun TX���ݿ��ƽ�.
			if(mFlags.IR_set)
			{	//��ģʽ��IR.
				nrf_gpio_cfg_input(ble_GPC2_ctl,NRF_GPIO_PIN_NOPULL);
				nrf_gpio_pin_clear(ble_Vctl);	//��IR��Դ.
				nrf_gpio_pin_set(IR_back);		//��IR  TX���ݿ��ƽ�.
				nrf_gpio_pin_set(IR_head);		//��IR  TX���ݿ��ƽ�.
			}else
			{	//����ģʽ����IR.
				nrf_gpio_pin_set(ble_Vctl);		//�ر�IR��Դ.
				nrf_gpio_pin_clear(IR_back);	//�ر�IR  TX���ݿ��ƽ�.
				nrf_gpio_pin_clear(IR_head);	//�ر�IR  TX���ݿ��ƽ�.
			}
			GUN.Sht_time = 0xFF;
			mFlags.gun_shoot = 0;
		}
	}
}

//=======================================================================
//F_1:REV^main_initialize()	//��ʼ��.
//=======================================================================
void REV_main_initialize(void)
{	//��ʼ��.
	uint8_t i = 0;

	RGB_mode_gpio_init();

	mFlags.testing = 0;
	TestMode.step = 0;
	TestMode.wait = 0;
	test_gun_ID = 5;

	RGB_show_color(clr_Red);	//RGB���趨��ʾ��ɫ.

	IR_gpio_init();

	TIMER2_init();

	mFlags.Version = 1;
	while(mFlags.Version)
	{	//�ȴ����汾����.
		if(mFlags.T2_10ms)
		{	//10msʱ�䵽.
			mFlags.T2_10ms = 0;
			RGB_reflash_ctl();		//ˢ�µ���ʾ.
		}
	}

	//I2C_cmd_send_IR(0x1FE);
	I2C_cmd_send_IR(0x812);
	nrf_gpio_pin_clear(ble_Vctl);	//��IR��Դ.  Open the IR power
	nrf_gpio_pin_clear(IR_back);		//��IR  TX���ݿ��ƽ�.
	nrf_gpio_pin_clear(IR_head);		//��IR  TX���ݿ��ƽ�.
	nrf_gpio_pin_clear(IR_gun);
	for(i=0;i<6;)
	{	//�ȴ����汾����.
		if(mFlags.T2_10ms)
		{	//10msʱ�䵽.
			mFlags.T2_10ms = 0;
			i ++;
			RGB_reflash_ctl();		//ˢ�µ���ʾ.
		}
	}

//	Bootloader = bootloader_version;

	IRM_RxStep[0]	=	1;
	IRM_RxStep[1]	=	1;
	GUN_RxStep[0]	=	1;
}

//=======================================================================
//F_0:REV^main_Loop()	//��ѭ��.
//=======================================================================
void REV_main_Loop(void)
{
	if(0)
	{	//RAMP mode & shoot GUN.
		I2C_cmd_Ramp_ID(0x1f);	//RAMP OFF or enter RAMP mode 1~4.
		// 0:close IR & waiting NEW CMD;
		// 0x1f,0x1e,0x1d,0x1b:ramp mode 1~4.

		I2C_cmd_GUN_ID(0x05);	//shooting GUN with ID=5.
	}
	if(0)
	{	//REV beacon mode.
		I2C_cmd_send_IR(0);	// 0/1:REV Beacon mode off/on.
		// 0:close IR & waiting NEW CMD;
		// 1:10ms DAC IR output + 30ms waiting ... .
	}
	if(0)
	{	//BLE ctl sent IR data.GPC ctl 38kHz and sent pwr.
		I2C_cmd_DAC_AI();	//set IR 38kHz output and DAC IR power @ 254/255 * VCC.
		//cmd_DATA = 0x12pp,set DAC IR power : pp/256 * VCC.
		//U can send IR data controled by BLE,set IR distance using the CMD 0x12pp.
	}

	gun_send_ctl();	//���ƴ�ǹʱ��.
	if(mFlags.ble_connect)
	{	//���Ӽ��,ֱ�����.
		if(mFlags.ble_cnnct_1st)
		{
			ble_parse_control();	//�����������.
		}else
		{
			mFlags.ble_cnnct_1st = 1;
		}
	}else
	{	//ʧ��.
		if(mFlags.ble_cnnct_1st)
		{
			mFlags.ble_cnnct_1st = 0;
			sleep_time = T32_SLEEP - 2 * 60 * 100;	//�Ͽ����Ӻ����������������ӵ�ʱ����5����.
			mFlags.IR_set = 0;
			mFlags.IR_status = 1;
			RGB.speed_ON = 4;
			RGB.speed_OFF = 4;
			RGB_Gradient_color(clr_White);	//�򿪽�������.
			REV_step = 8;	//ʧ�����˳���ǰģʽ,����step8,�ȴ�������ģʽ.
		}
	}

	if(mFlags.T2_10ms)
	{	//10msʱ�䵽.
		mFlags.T2_10ms = 0;

		if(DAC_IR_3Min < 3 * 60 * 100)
		{	//AI�����޲�����ʱ.
			DAC_IR_3Min ++;
		}else if(DAC_IR_3Min == 3 * 60 * 100)
		{	//AI����3����.
			DAC_IR_3Min ++;
			I2C_cmd_DAC_AI();	//�ӳ��Ƚ����ʷ���ģʽ�ٻشӳ�ģʽ.
		}else if(mFlags.I2C_busy == 0)
		{
			DAC_IR_3Min = 0;
			I2C_cmd_send_IR(0);	//�ر�10ms/40ms����.
		}

		RGB_reflash_ctl();		//ˢ�µ���ʾ.
	}
}






//********************************* end *********************************//
