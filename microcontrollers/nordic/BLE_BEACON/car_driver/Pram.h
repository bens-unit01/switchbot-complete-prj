//=======================================================================
//.T		�����ļ�.
//=======================================================================
#include <stdbool.h>
#include <stdint.h>
//-----------------------
#ifndef		__JC_PUBLIC_RAM_H__
#define		__JC_PUBLIC_RAM_H__
//=======================================================================
//.T0		���ݸ�ʽ����.
//=======================================================================
//-----------------------����ģʽ�Ĵ���.
#define PU_color			0			//�ϵ�RGB��ʾ��ɫ.
#define PL_color			1			//�͵�ѹRGB��ʾ��ɫ.
#define SLP_color			2			//˯��ʱRGB��ʾ��ɫ.
#define disCon_color	3			//ʧ��RGB��ʾ��ɫ.
#define PL_level			4			//�͵�ѹ��ֵ.
#define PU_mode				5			//�ϵ�ģʽ:0,0x1f,0x1b,0x1d,0x1e.
#define OD_L0					6			//Odometer Reading���ֽ�.
#define OD_M1					7			//Odometer Reading.
#define OD_M2					8			//Odometer Reading.
#define OD_H3					9			//Odometer Reading���ֽ�.
#define F_null				10		//���������״̬.
#define Fd_l					11		//���������״̬.
typedef struct
{
	uint32_t	status;		//Flash data״̬.
	uint8_t		Fd[Fd_l + 1];	//Flash���ݱ��.
}Flash_struct;

//-----------------------����ģʽ�Ĵ���.
typedef struct
{
	uint8_t		step;				//����ģʽ����.
	uint8_t		wait;				//�������ʱ�üĴ���.
}Test_struct;

//-----------------------ADC�Ĵ���.
typedef struct
{
	uint8_t		wait;				//�ȴ�ʱ��.
	uint16_t	result;			//���Խ��.
	uint16_t	average;		//���Խ��.
	uint16_t	sum;				//���Խ��.
	uint8_t		times;			//���Դ���.
	uint8_t		index;			//����ȼ�.
}ADC_struct;

//-----------------------����ģʽ�Ĵ���.
typedef struct
{
	uint8_t		ID;					//����ID��.
	uint8_t		Sht_ID;			//��ǹID��.
	uint8_t		Sht_cnt;		//��ǹ����.
	uint8_t		Sht_time;		//��ǹʱ��.
}Gun_struct;

//-----------------------��ǹ�Ĵ���.
typedef struct
{
	uint8_t		power;			//��ǹ����.
	uint8_t		gun_ID;			//��ǹID��.
	uint8_t		rx_data;		//��ǹ����.
	uint8_t		rx_goal;		//��ǹ����.
	uint8_t		tx_step;		//��ǹ����.
	uint8_t		tx_cnt;			//��ǹ��ʱ.
	uint8_t		tx_data;		//��ǹ����.
}spcl_gun_struct;

//-----------------------RGB�ƿ��ƼĴ���.
typedef struct
{
	uint8_t		step;					//��ʾ��ʽ.	0:��ʾ��ɫ;1:��˸;2:����;
	uint8_t		last_step;		//ԭ����ʽ.	0:��ʾ��ɫ;1:��˸;2:����;
	uint8_t		colorSet;			//������ʾ����ɫ.
	uint8_t		colorNow;			//��ǰ��ʾ����ɫ.
	uint16_t	real_10ms;		//10ms����.
	uint8_t		times;				//��˸����.
	uint8_t		BackGround;		//����������ɫ.
	uint8_t		ShowColor;		//��ʾ��ɫ.
	uint8_t		SCtime;				//��ʾ��ɫʱ��.		//ON time.
	uint8_t		BGtime;				//��˸ʱ��.				//OFF time.
	uint8_t		Gradient;			//���ý������ɫ.
	uint8_t		duty;					//��������.
	uint8_t		index;				//��������.				//��ǰ���䲽��.
	uint8_t		speed_ON;			//�������ٶ�.			//ON�ٶ�.
	uint8_t		speed_OFF;		//�������ٶ�.			//OFF�ٶ�.
	uint8_t		speed_INC;		//���䴦���ٶ�.
}RGB_struct;

//-----------------------��־�ṹ.
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
	uint32_t		gun_rising:1;	//�����ض���,Ϊ�ӳ���ǹ��.
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
	uint32_t		Version:1;	//�汾��Ϣ.
//------------
	uint32_t		M_nc:6;
}	Main_Flags;
//=======================================================================
//.T1		ȫ�ֱ�������.
//=======================================================================
extern RGB_struct		RGB;
//-----------------------����ģʽ.
extern Test_struct	TestMode;
//-----------------------��־.
extern Flash_struct	Fdata;	//Flash����RAM����.
extern Flash_struct	Fchk;		//Flash��֤RAM����.
extern Main_Flags		mFlags;
extern uint8_t			REV_step;
extern Gun_struct		GUN;
extern spcl_gun_struct	spcl;
//-----------------------��������.
extern uint8_t			APP_TX_index;	//APP��������.
extern uint8_t			BLE_RD_index;	//BLE��ȡ����.
extern uint8_t			BleBuf[10][20];
extern uint8_t			BleData[20];
extern uint8_t			BleReturn[20];
//-----------------------���ⷢ��.
//extern uint8_t			IR_SendStep;
//extern uint8_t			IR_DATA;
//-----------------------�������.
extern uint8_t			IRM_ID[3];
extern uint8_t			ID_goal;
extern uint8_t			GUN_RxStep[2];
//-----------------------��ȡ�汾;
extern uint8_t			Ver_Voice_data;
extern uint8_t			Ver_DAC_data;
//-----------------------��������.
extern uint16_t			cmd_DATA;
extern uint8_t			cmd_SendStep;
extern uint8_t			cmd_SendCNT;
//-----------------------�������.
extern uint8_t			IRM_RxStep[2];
extern uint8_t			head_rx_CMD,tail_rx_CMD;
//=======================================================================
//.T2		��������.
//=======================================================================
//=======================================================================
//.T		ȫ�ֺ�������.
//=======================================================================
extern uint32_t	ble_dts_send_data(uint8_t* data, uint16_t length);
//=======================================================================
#endif	//__JC_PUBLIC_RAM_H__.

//********************************* end *********************************//
