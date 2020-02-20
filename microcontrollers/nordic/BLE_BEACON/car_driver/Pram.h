//=======================================================================
//.T		包含文件.
//=======================================================================
#include <stdbool.h>
#include <stdint.h>
//-----------------------
#ifndef		__JC_PUBLIC_RAM_H__
#define		__JC_PUBLIC_RAM_H__
//=======================================================================
//.T0		数据格式声明.
//=======================================================================
//-----------------------测试模式寄存器.
#define PU_color			0			//上电RGB显示颜色.
#define PL_color			1			//低电压RGB显示颜色.
#define SLP_color			2			//睡眠时RGB显示颜色.
#define disCon_color	3			//失联RGB显示颜色.
#define PL_level			4			//低电压阀值.
#define PU_mode				5			//上电模式:0,0x1f,0x1b,0x1d,0x1e.
#define OD_L0					6			//Odometer Reading低字节.
#define OD_M1					7			//Odometer Reading.
#define OD_M2					8			//Odometer Reading.
#define OD_H3					9			//Odometer Reading高字节.
#define F_null				10		//数据最后字状态.
#define Fd_l					11		//数据最后字状态.
typedef struct
{
	uint32_t	status;		//Flash data状态.
	uint8_t		Fd[Fd_l + 1];	//Flash数据表白.
}Flash_struct;

//-----------------------测试模式寄存器.
typedef struct
{
	uint8_t		step;				//测试模式步骤.
	uint8_t		wait;				//输出高暂时用寄存器.
}Test_struct;

//-----------------------ADC寄存器.
typedef struct
{
	uint8_t		wait;				//等待时间.
	uint16_t	result;			//测试结果.
	uint16_t	average;		//测试结果.
	uint16_t	sum;				//测试结果.
	uint8_t		times;			//测试次数.
	uint8_t		index;			//结果等级.
}ADC_struct;

//-----------------------测试模式寄存器.
typedef struct
{
	uint8_t		ID;					//本身ID号.
	uint8_t		Sht_ID;			//中枪ID号.
	uint8_t		Sht_cnt;		//中枪次数.
	uint8_t		Sht_time;		//打枪时间.
}Gun_struct;

//-----------------------打枪寄存器.
typedef struct
{
	uint8_t		power;			//打枪功率.
	uint8_t		gun_ID;			//打枪ID号.
	uint8_t		rx_data;		//中枪数据.
	uint8_t		rx_goal;		//中枪方向.
	uint8_t		tx_step;		//打枪步骤.
	uint8_t		tx_cnt;			//打枪计时.
	uint8_t		tx_data;		//打枪数据.
}spcl_gun_struct;

//-----------------------RGB灯控制寄存器.
typedef struct
{
	uint8_t		step;					//显示方式.	0:显示颜色;1:闪烁;2:渐变;
	uint8_t		last_step;		//原来方式.	0:显示颜色;1:闪烁;2:渐变;
	uint8_t		colorSet;			//设置显示的颜色.
	uint8_t		colorNow;			//当前显示的颜色.
	uint16_t	real_10ms;		//10ms计数.
	uint8_t		times;				//闪烁次数.
	uint8_t		BackGround;		//背景背景颜色.
	uint8_t		ShowColor;		//显示颜色.
	uint8_t		SCtime;				//显示颜色时间.		//ON time.
	uint8_t		BGtime;				//闪烁时间.				//OFF time.
	uint8_t		Gradient;			//设置渐变的颜色.
	uint8_t		duty;					//渐变亮度.
	uint8_t		index;				//渐变索引.				//当前渐变步骤.
	uint8_t		speed_ON;			//渐变亮速度.			//ON速度.
	uint8_t		speed_OFF;		//渐变灭速度.			//OFF速度.
	uint8_t		speed_INC;		//渐变处理速度.
}RGB_struct;

//-----------------------标志结构.
typedef struct
{
	uint32_t		T2_10ms:1;
//------------
	uint32_t		testing:1;
	uint32_t		test_10ms:1;
	uint32_t		RGB_reflash:1;
	uint32_t		RGB_pwm_on:1;
//------------
	uint32_t		MOT_reflash:1;
	uint32_t		c_0x78_ctl:1;
//------------
	uint32_t		IRM_rx:1;
	uint32_t		IRM_gun:1;
	uint32_t		gun_right:1;
	uint32_t		gun_shoot:1;
//------------
	uint32_t		IRM_coord:1;
	uint32_t		gun_rising:1;	//上升沿对齐,为从车打枪用.
	uint32_t		coord_TSS_on:1;
	uint32_t		coord_tracking:1;
	uint32_t		coord_ctl:1;
	uint32_t		coord_escape:1;
	uint32_t		coord_loops:1;
//------------
	uint32_t		ble_connect:1;
	uint32_t		ble_cnnct_1st:1;
	uint32_t		ble_control:1;
	uint32_t		power_low:1;
//------------
	uint32_t		IR_status:1;
	uint32_t		IR_set:1;
	uint32_t		I2C_busy:1;
//------------
	uint32_t		Version:1;	//版本信息.
//------------
	uint32_t		M_nc:6;
}	Main_Flags;
//=======================================================================
//.T1		全局变量声明.
//=======================================================================
extern RGB_struct		RGB;
//-----------------------测试模式.
extern Test_struct	TestMode;
//-----------------------标志.
extern Flash_struct	Fdata;	//Flash数据RAM定义.
extern Flash_struct	Fchk;		//Flash验证RAM定义.
extern Main_Flags		mFlags;
extern uint8_t			REV_step;
extern Gun_struct		GUN;
extern spcl_gun_struct	spcl;
//-----------------------蓝牙接收.
extern uint8_t			APP_TX_index;	//APP发送索引.
extern uint8_t			BLE_RD_index;	//BLE读取索引.
extern uint8_t			BleBuf[10][20];
extern uint8_t			BleData[20];
extern uint8_t			BleReturn[20];
//-----------------------红外发射.
//extern uint8_t			IR_SendStep;
//extern uint8_t			IR_DATA;
//-----------------------红外接收.
extern uint8_t			IRM_ID[3];
extern uint8_t			ID_goal;
extern uint8_t			GUN_RxStep[2];
//-----------------------读取版本;
extern uint8_t			Ver_Voice_data;
extern uint8_t			Ver_DAC_data;
//-----------------------发送命令.
extern uint16_t			cmd_DATA;
extern uint8_t			cmd_SendStep;
extern uint8_t			cmd_SendCNT;
//-----------------------红外接收.
extern uint8_t			IRM_RxStep[2];
extern uint8_t			head_rx_CMD,tail_rx_CMD;
//=======================================================================
//.T2		代码表格定义.
//=======================================================================
//=======================================================================
//.T		全局函数声明.
//=======================================================================
extern uint32_t	ble_dts_send_data(uint8_t* data, uint16_t length);
//=======================================================================
#endif	//__JC_PUBLIC_RAM_H__.

//********************************* end *********************************//
