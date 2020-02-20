//=======================================================================
//.T		包含头文件.
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
//.T		变量定义.
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
uint8_t		APP_TX_index	=	0;	//APP发送索引.
uint8_t		BLE_RD_index	=	0;	//BLE读取索引.
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
//.T		常量定义.
//=======================================================================

//=======================================================================

//=======================================================================
//F_:I2C^cmd_send_IR(uint8_t on)	//设置球码开关命令.
//=======================================================================
// Receives 16 bit value
// Follow the GPC_CMD Spreadsheet to determine what to send
void I2C_cmd_send_IR(uint16_t on)
{
	cmd_DATA = 0x1100 + on;	//开启/关闭球码发射.
	cmd_SendCNT = 0;
	cmd_SendStep = 1;			//开始控制发码.
}

//=======================================================================
//F_:I2C^cmd_GUN_ID(uint8_t ID)	//打枪ID命令.
//=======================================================================
static void I2C_cmd_GUN_ID(uint8_t ID)
{
	mFlags.I2C_busy = 1;
	cmd_DATA = 0x1300 + ID;					//设置ID号.
	cmd_SendCNT = 0;
	cmd_SendStep = 1;								//开始控制发码.
	DAC_IR_3Min = 0;
	GUN.Sht_time = 7;
	mFlags.gun_shoot = 1;	//开始打枪.
	nrf_gpio_pin_clear(IR_back);	//关闭IR  TX数据控制脚.
	nrf_gpio_pin_clear(IR_head);	//关闭IR  TX数据控制脚.
}

//=======================================================================
//F_:I2C^cmd_Ramp_ID(uint8_t ID)	//设置平台ID命令.
//=======================================================================
static void I2C_cmd_Ramp_ID(uint8_t ID)
{
	cmd_DATA = 0x1700 + ID;					//设置ID号.
	cmd_SendCNT = 0;
	cmd_SendStep = 1;								//开始控制发码.
}

//=======================================================================
//F_:I2C^cmd_DAC_AI()	//防止DAC从车6分钟睡眠.
//=======================================================================
static void I2C_cmd_DAC_AI()
{
	mFlags.I2C_busy = 1;
	cmd_DATA = 0x1200 + 254;	//设置特别打枪功率.
	cmd_SendCNT = 0;
	cmd_SendStep = 1;	//开始控制发码.
}

//=======================================================================
//F_:IOS^0x79_battery_life()	//0x79返回值.
//=======================================================================
static void IOS_0x79_battery_life(void)
{
	BleReturn[0] = 0x79;	//Battery Level.
	BleReturn[1] = PowerADC.result / 4;
	BleReturn[2] = 1;	//1:Normal;2:Re-charger.	//普通电池.
	ble_dts_send_data(BleReturn,3);
}

//=======================================================================
//F_:ble^parse_control()	//蓝牙命令控制.
//=======================================================================
static void ble_parse_control(void)
{
	uint8_t i = 0;

	if(mFlags.ble_control)
	{	//接收到新蓝牙指令.
		memcpy(BleData,&BleBuf[BLE_RD_index][0],20);
		BLE_RD_index ++;
		if(BLE_RD_index >= 10) BLE_RD_index = 0;
		if(BLE_RD_index == APP_TX_index) mFlags.ble_control = 0;

		sleep_time = 0;
		switch(BleData[0])
		{
			case	0x95:	//设置REV车仔ID号并打枪.
				i = BleData[1];
				if(i > 31) i = 31;
				if(BleData[2] == 1)
				{	//1:全IR打枪.
					GUN_IR_dir = 1;
				}else if(BleData[2] == 2)
				{	//2:后面3个+前面2个IR打枪.
					GUN_IR_dir = 2;
				}else
				{	//3:枪IR打枪.
					GUN_IR_dir = 3;
				}
				I2C_cmd_GUN_ID(i);	//设置ID号.
				break;
			case	0x91:	//main STEPn.
				switch(BleData[1])
				{	//设置查询主模式.
					case	1:	//Idle.
						REV_step = 1;
						mFlags.IR_status = 1;
						mFlags.IR_set = 0;
						ramp_ID = T_RAMP_ID[0];
						break;
					case	2:	//0X1B发射IR模式.
						REV_step = 2;
						mFlags.IR_status = 0;
						mFlags.IR_set = 1;	//开启IR.
						ramp_ID = T_RAMP_ID[1];	//0x1b;
						break;
					case	3:	//0X1D发射IR模式.
						REV_step = 3;
						mFlags.IR_status = 0;
						mFlags.IR_set = 1;	//开启IR.
						ramp_ID = T_RAMP_ID[2];	//0x1d;
						break;
					case	4:	//0X1E发射IR模式.
						REV_step = 4;
						mFlags.IR_status = 0;
						mFlags.IR_set = 1;	//开启IR.
						ramp_ID = T_RAMP_ID[3];	//0x1e;
						break;
					case	5:	//0X1F发射IR模式.
						REV_step = 5;
						mFlags.IR_status = 0;
						mFlags.IR_set = 1;	//开启IR.
						ramp_ID = T_RAMP_ID[4];	//0x1f;
						break;
					case	0xff:	//查询主模式.
						BleReturn[0] = 0x91;
						BleReturn[1] = REV_step;
						ble_dts_send_data(BleReturn,2);
						break;
					default:
						break;
				}
				break;
			case	0x79:	//查询电池电量.
				IOS_0x79_battery_life();	//0x79返回值.
				break;
			case	0x83:	//查询RGB设置.
				BleReturn[0] = 0x83;	//当前RGB设置.
				if(RGB.step == 1)
				{	//闪烁颜色模式.
					BleReturn[1] = RGB.ShowColor;	//闪烁颜色.
					BleReturn[2] = RGB.SCtime;		//闪烁颜色时间.
					BleReturn[3] = RGB.BGtime;		//闪烁周期时间.
					BleReturn[4] = RGB.times;			//闪烁次数.
					ble_dts_send_data(BleReturn,5);
				}else if(RGB.step == 2)
				{	//渐明渐暗模式.
					BleReturn[1] = RGB.Gradient;	//渐变的颜色.
					BleReturn[2] = RGB.speed_ON;	//渐变亮速度.
					BleReturn[3] = RGB.speed_OFF;	//渐变灭速度.
					ble_dts_send_data(BleReturn,4);
				}else
				{	//其他认为是显示颜色模式.
					BleReturn[1] = RGB.BackGround;	//显示颜色.
					ble_dts_send_data(BleReturn,2);
				}
				break;
			case	0x84:	//设置RGB显示颜色.
				if((BleData[1] > 0) && (BleData[1] < 8))
				{
					RGB_show_color(BleData[1]);	//RGB灯设定显示颜色.
				}else
				{
					RGB_show_color(clr_Black);	//RGB灯设定显示颜色.
				}
				break;
			case	0x89:	//设置RGB闪烁.
				if((BleData[1] > 0) && (BleData[1] < 8))
				{
					RGB.SCtime = BleData[2];	//刷新显示0.4S.
					RGB.BGtime = BleData[3];	//刷新显示0.6S.
					RGB.times = BleData[4];		//一直闪烁.
					RGB_flash_color(BleData[1]);	//RGB灯设定闪烁显示颜色.
				}
				break;
			case	0x90:	//设置RGB渐明渐暗.
				if((BleData[1] > 0) && (BleData[1] < 8))
				{
					RGB.speed_ON = BleData[2];
					RGB.speed_OFF = BleData[3];
					RGB_Gradient_color(BleData[1]);	//打开渐明渐暗.
				}
				break;
			case	0xFA:	//SLEEP.
				REV_step = 11;
				enter_sleep = 1;	//进入深度睡眠.
				break;
			case	0x19:	//查询GPC软件版本.
				BleReturn[0] = 0x19;	//GPC软件版本.
				BleReturn[1] = 0xee;
				BleReturn[2] = Ver_DAC_data;
				ble_dts_send_data(BleReturn,3);
				break;
			case	0x14:	//查询ble软件版本.
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
//F_:gun^send_ctl()	//控制打枪时间.
//=======================================================================
static void gun_send_ctl(void)
{
	if(mFlags.gun_shoot)
	{	//准备打枪.
		if(GUN.Sht_time == 6)
		{	//时间到通知球码开始.
			GUN.Sht_time --;
			if(GUN_IR_dir == 1)
			{	//1:全IR打枪.
				nrf_gpio_pin_set(IR_gun);			//打开gun TX数据控制脚.
				nrf_gpio_pin_set(IR_back);		//打开IR  TX数据控制脚.
				nrf_gpio_pin_set(IR_head);		//打开IR  TX数据控制脚.
			}else if(GUN_IR_dir == 2)
			{	//2:后面3个+前面2个IR打枪.
				nrf_gpio_pin_clear(IR_gun);		//关闭gun TX数据控制脚.
				nrf_gpio_pin_set(IR_back);		//打开IR  TX数据控制脚.
				nrf_gpio_pin_clear(IR_head);	//关闭IR  TX数据控制脚.
			}else
			{	//3:枪IR打枪.
				nrf_gpio_pin_set(IR_gun);			//打开gun TX数据控制脚.
				nrf_gpio_pin_clear(IR_back);	//关闭IR  TX数据控制脚.
				nrf_gpio_pin_clear(IR_head);	//关闭IR  TX数据控制脚.
			}
			nrf_gpio_pin_clear(ble_Vctl);			//打开IR电源.
			nrf_gpio_cfg_output(ble_GPC2_ctl);
			nrf_gpio_pin_set(ble_GPC2_ctl);		//通知打枪开始输出高.
		}else if(GUN.Sht_time == 4)
		{	//通知球码结束.
			GUN.Sht_time --;
			nrf_gpio_pin_clear(ble_GPC2_ctl);	//通知打枪结束输出低.
		}else if(GUN.Sht_time == 0)
		{	//一次打枪结束.
			nrf_gpio_pin_clear(IR_gun);		//关闭gun TX数据控制脚.
			if(mFlags.IR_set)
			{	//主模式发IR.
				nrf_gpio_cfg_input(ble_GPC2_ctl,NRF_GPIO_PIN_NOPULL);
				nrf_gpio_pin_clear(ble_Vctl);	//打开IR电源.
				nrf_gpio_pin_set(IR_back);		//打开IR  TX数据控制脚.
				nrf_gpio_pin_set(IR_head);		//打开IR  TX数据控制脚.
			}else
			{	//其他模式不发IR.
				nrf_gpio_pin_set(ble_Vctl);		//关闭IR电源.
				nrf_gpio_pin_clear(IR_back);	//关闭IR  TX数据控制脚.
				nrf_gpio_pin_clear(IR_head);	//关闭IR  TX数据控制脚.
			}
			GUN.Sht_time = 0xFF;
			mFlags.gun_shoot = 0;
		}
	}
}

//=======================================================================
//F_1:REV^main_initialize()	//初始化.
//=======================================================================
void REV_main_initialize(void)
{	//初始化.
	uint8_t i = 0;

	RGB_mode_gpio_init();

	mFlags.testing = 0;
	TestMode.step = 0;
	TestMode.wait = 0;
	test_gun_ID = 5;

	RGB_show_color(clr_Red);	//RGB灯设定显示颜色.

	IR_gpio_init();

	TIMER2_init();

	mFlags.Version = 1;
	while(mFlags.Version)
	{	//等待读版本结束.
		if(mFlags.T2_10ms)
		{	//10ms时间到.
			mFlags.T2_10ms = 0;
			RGB_reflash_ctl();		//刷新灯显示.
		}
	}

	//I2C_cmd_send_IR(0x1FE);
	I2C_cmd_send_IR(0x812);
	nrf_gpio_pin_clear(ble_Vctl);	//打开IR电源.  Open the IR power
	nrf_gpio_pin_clear(IR_back);		//打开IR  TX数据控制脚.
	nrf_gpio_pin_clear(IR_head);		//打开IR  TX数据控制脚.
	nrf_gpio_pin_clear(IR_gun);
	for(i=0;i<6;)
	{	//等待读版本结束.
		if(mFlags.T2_10ms)
		{	//10ms时间到.
			mFlags.T2_10ms = 0;
			i ++;
			RGB_reflash_ctl();		//刷新灯显示.
		}
	}

//	Bootloader = bootloader_version;

	IRM_RxStep[0]	=	1;
	IRM_RxStep[1]	=	1;
	GUN_RxStep[0]	=	1;
}

//=======================================================================
//F_0:REV^main_Loop()	//主循环.
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

	gun_send_ctl();	//控制打枪时间.
	if(mFlags.ble_connect)
	{	//连接检测,直控马达.
		if(mFlags.ble_cnnct_1st)
		{
			ble_parse_control();	//蓝牙命令控制.
		}else
		{
			mFlags.ble_cnnct_1st = 1;
		}
	}else
	{	//失联.
		if(mFlags.ble_cnnct_1st)
		{
			mFlags.ble_cnnct_1st = 0;
			sleep_time = T32_SLEEP - 2 * 60 * 100;	//断开连接后留给蓝牙重新连接的时间是5分钟.
			mFlags.IR_set = 0;
			mFlags.IR_status = 1;
			RGB.speed_ON = 4;
			RGB.speed_OFF = 4;
			RGB_Gradient_color(clr_White);	//打开渐明渐暗.
			REV_step = 8;	//失联后退出当前模式,进入step8,等待设置主模式.
		}
	}

	if(mFlags.T2_10ms)
	{	//10ms时间到.
		mFlags.T2_10ms = 0;

		if(DAC_IR_3Min < 3 * 60 * 100)
		{	//AI空闲无操作计时.
			DAC_IR_3Min ++;
		}else if(DAC_IR_3Min == 3 * 60 * 100)
		{	//AI空闲3分钟.
			DAC_IR_3Min ++;
			I2C_cmd_DAC_AI();	//从车先进功率发码模式再回从车模式.
		}else if(mFlags.I2C_busy == 0)
		{
			DAC_IR_3Min = 0;
			I2C_cmd_send_IR(0);	//关闭10ms/40ms球码.
		}

		RGB_reflash_ctl();		//刷新灯显示.
	}
}






//********************************* end *********************************//
