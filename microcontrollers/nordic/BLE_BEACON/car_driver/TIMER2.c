//=======================================================================
//.T		����ͷ�ļ�.
//=======================================================================
#include	"nrf.h"
#include	"nrf_gpiote.h"
#include	"nrf_soc.h"
#include	"nrf_gpio.h"
#include	"ble_srv_common.h"
//-----------------------
#include	"Ppin.h"
#include	"Pram.h"
#include	"TIMER2.h"
//-----------------------
#include	"RGB_mode.h"

//=======================================================================
//.T		��������.
//=======================================================================
uint8_t		t2_100us = 100;
uint8_t		t2_10ms = 0;
//-----------------------���ⷢ��.
uint8_t		IR_SendStep = 0;
uint8_t		IR_SendCNT = 0;
uint8_t		IR_DATA = 0,data_bit = 0;
//-----------------------������մ�ǹ�뻺��.
uint8_t		IRM_ID[3] = {0,0,0};
uint8_t		ID_goal = 0;
uint16_t	gun_start_cnt = 0;
uint8_t		gun_10ms_cnt = 0;
uint8_t		Ramp_dist_cnt = 0;	//ƽ̨ǰ��ǹ��λ��ʱ.
//-----------------------��������.
uint8_t		cmd_SendStep = 0;
uint8_t		cmd_SendCNT = 0;
uint16_t	cmd_DATA = 0,cmd_bit = 0;
//-----------------------�������.
uint8_t		head_rx_CMD = 0,tail_rx_CMD = 0;
uint8_t		IRM_RxStep[2] = {0,0};
uint8_t		IRM_RxData[2] = {0,0};
uint16_t	IRM_cnt[2] = {0,0};
uint8_t		IRM_PINs[2] = {IRM_tail};
//--------
uint8_t		GUN_RxStep[2] = {0,0};
uint8_t		GUN_RxData[2] = {0,0};
uint8_t		GUN_cnt[2] = {0,0};
uint8_t 	goal[2] = {1,2};
//-----------------------�ǶȾ������.
uint8_t		sR2,sR4;
uint8_t		sRall,sRold;
uint16_t	perCnt,perCount;
uint8_t		br2,br4;
uint8_t		Tir[4];
//-----------------------��ȡ�汾.
uint8_t		Ver_DAC_step = 0;
uint16_t	Ver_DAC_cnt = 0;
uint8_t		Ver_DAC_data = 0;
uint16_t	Ver_cnt = 0;

extern volatile int testFlag;

//=======================================================================
//.T		��������.
//=======================================================================
//-----------------------�������.
#define		c_sync_max					88					//6800us:sync  max 8000us.
#define		c_sync_min					47					//6800us:sync  min 6100us.
#define		c_bit1_max					44					//3400us:bit_1 max 4400us.
#define		c_bit1_min					23					//3400us:bit_1 min 3000us.
#define		c_bit0_max					11					// 850us:bit_0 max 1800us.
#define		c_bit0_min					5						// 850us:bit_0 min  700us.
#define		c_stop_max					11					// 850us:stop  max 1800us.
#define		c_stop_min					5						// 850us:stop  min  700us.
//-----------------------��5bit��ǹ����.
#define		g_sync_max					58					//5100us:sync  max 5800us.
#define		g_sync_min					43					//5100us:sync  min 4300us.
#define		g_bit1_max					27					//2380us:bit_1 max 2700us.
#define		g_bit1_min					20					//2380us:bit_1 min 2000us.
#define		g_bit0_max					13					//1020us:bit_0 max 1300us.
#define		g_bit0_min					7						//1020us:bit_0 min  700us.
#define		g_stop_max					13					//1020us:stop  max 1300us.
#define		g_stop_min					7						//1020us:stop  min  700us.
//-----------------------��ȡ�汾.
#define		c_5ms_min						42					//5000us:�͵�ƽʱ��.
#define		c_5ms_max						58					//5000us:�͵�ƽʱ��.
#define		c_V00_min						84					//10ms:�ߵ�ƽʱ��.
#define		c_V00_max						116					//10ms:�ߵ�ƽʱ��.
#define		c_V01_min						126					//15ms:�ߵ�ƽʱ��.
#define		c_V01_max						174					//15ms:�ߵ�ƽʱ��.
//=======================================================================
//F_:IRM^receiver_coord()	//���պ������.
//=======================================================================
static void IRM_receiver_coord(void)
{
	sR2 = ( nrf_gpio_pin_read(IRM_tail)  == 0 );

	sRall = sR2 | sR4;	//�ж��Ƿ��н��յ���,ȫ��û�н��ղ�Ϊ0.
	if(perCnt < overflow_MAX)	perCnt++;

	if (sR2) br2++;
	if (sR4) br4++;	//���յ���,������һ.

//	if ( (sRold == 0) && (sRall == 1) )	//���书����ǿ����,���ն��½���ͬ��;��֮Ҫ��1,0.
	if ( (sRold == 1) && (sRall == 0) )		//���书��������ǿ,���ն�������ͬ��;��֮Ҫ��0,1.
	{
		mFlags.IRM_coord = 1;
		mFlags.gun_rising = 1;
		perCount = perCnt;														//�ж��Ƿ���յ�������������.
		perCnt = 0;

		Tir[1] = br2; Tir[3] = br4;
		br2 = 0; br4 = 0;	//��ȡ�������ݺ�����,Ϊ�´μ���׼��.
	}

	sRold = sRall;																	//�ݴ浱ǰ����״̬.
}

//=======================================================================
//F_:RAMP^send_ctl()	//ƽ̨��ǹ��Դ����.
//=======================================================================
static void RAMP_send_ctl(void)
{
	if(nrf_gpio_pin_read(ble_GPC2_ctl) == 1)
	{	//׼����ǹ.
		Ramp_dist_cnt ++;
		nrf_gpio_pin_clear(ble_Vctl);	//��IR��Դ.
		nrf_gpio_pin_set(IR_gun);			//��gun TX���ݿ��ƽ�.
		nrf_gpio_pin_clear(IR_back);	//�ر�IR  TX���ݿ��ƽ�.
		if(Ramp_dist_cnt < 140)
		{	//SYNC:5.1ms+(DATA1+STOP)3.4ms*2=12ms.
			nrf_gpio_pin_set(IR_head);		//��IR  TX���ݿ��ƽ�.
		}else
		{
			nrf_gpio_pin_clear(IR_head);	//�ر�IR  TX���ݿ��ƽ�.
		}
	}else
	{	//һ�δ�ǹ����.
		Ramp_dist_cnt = 0;
		if(mFlags.IR_set)
		{	//��ģʽ��IR.
			nrf_gpio_pin_clear(ble_Vctl);	//��IR��Դ.
			nrf_gpio_pin_clear(IR_gun);		//�ر�gun TX���ݿ��ƽ�.
			nrf_gpio_pin_set(IR_back);		//��IR  TX���ݿ��ƽ�.
			nrf_gpio_pin_set(IR_head);		//��IR  TX���ݿ��ƽ�.
		}else
		{	//����ģʽ����IR.
			nrf_gpio_pin_set(ble_Vctl);		//�ر�IR��Դ.
			nrf_gpio_pin_clear(IR_gun);		//�ر�gun TX���ݿ��ƽ�.
			nrf_gpio_pin_clear(IR_back);	//�ر�IR  TX���ݿ��ƽ�.
			nrf_gpio_pin_clear(IR_head);	//�ر�IR  TX���ݿ��ƽ�.
		}
	}
}

//=======================================================================
//F_:Version^DAC_GPC2()	//��ȡDAC�汾.
//=======================================================================
static void Version_DAC_GPC2(void)
{
	uint8_t cnt = 0;

	Ver_DAC_cnt ++;
	switch(Ver_DAC_step)
	{
		case	0:	//׼��.
			Ver_DAC_cnt = 0;
			Ver_DAC_data = 0;
			Ver_DAC_step ++;
			break;
		case	1:	//�ȴ���.
			if(nrf_gpio_pin_read(ble_GPC2_ctl))
			{
				Ver_DAC_cnt = 0;
			}else
			{
				Ver_DAC_step ++;
			}
			break;
		case	2:	//�������жϵ�5ms.
			if(nrf_gpio_pin_read(ble_GPC2_ctl))
			{
				cnt = Ver_DAC_cnt;
				Ver_DAC_cnt = 0;
				if((cnt > c_5ms_min) &&(cnt < c_5ms_max))
				{
					Ver_DAC_step ++;
				}else
				{
					Ver_DAC_step = 1;
				}
	//	}else
	//	{
			}
			break;
		case	3:	//�½����жϸ�10ms/15ms.
			if(nrf_gpio_pin_read(ble_GPC2_ctl))
			{
			}else
			{
				cnt = Ver_DAC_cnt;
				Ver_DAC_cnt = 0;
				if((cnt > c_V00_min) &&(cnt < c_V00_max))
				{
					Ver_DAC_step ++;
					Ver_DAC_data = 1;	//M1.
				}else if((cnt > c_V01_min) &&(cnt < c_V01_max))
				{
					Ver_DAC_step ++;
					Ver_DAC_data = 2;	//M2.
				}else
				{
					Ver_DAC_step = 1;
				}
			}
			break;
		case	4:	//�汾��Ϣ��ȡ����.
			break;
		default:
			break;
	}
}

//=======================================================================
//F_:gun^shooting_start()	//��ǹ��ʼ��.
//=======================================================================
static void gun_shooting_start(void)
{
	if(mFlags.gun_rising)
	{	//�����ض���.
		mFlags.gun_rising = 0;
		gun_start_cnt = 0;
		if(mFlags.gun_shoot == 0)
		{	//û�д�ǹ.
			gun_10ms_cnt = 0;
		}
	}else
	{	//��������״̬.
		gun_start_cnt ++;
		if(gun_start_cnt > PER_MAX)
		{
			gun_start_cnt = 0;
			gun_10ms_cnt = 0;
		}
		if((mFlags.gun_shoot) && (mFlags.I2C_busy == 0))
		{	//��ǹ���뿪ʼ��.
			if((GUN.Sht_time == 7) && (gun_start_cnt == 1))
			{	//��ʼ��ѡ��.
				GUN.Sht_time = 6;
				gun_10ms_cnt = 0;
				GUN_RxData[0] = 0;
				GUN_RxData[1] = 0;
				GUN_RxStep[0] = 1;
				GUN_RxStep[1] = 1;
			}
		}
	}
	gun_10ms_cnt ++;
	if(gun_10ms_cnt > 100)
	{	//10msʱ�䵽.
		gun_10ms_cnt = 0;
		if(GUN.Sht_time < 6)
		{
			GUN.Sht_time --;
			GUN_RxData[0] = 0;
			GUN_RxData[1] = 0;
			GUN_RxStep[0] = 1;
			GUN_RxStep[1] = 1;
		}
	}
}

//=======================================================================
//F_:GUN^receiver_data()	//���պ���ǹ����.
//=======================================================================
static void GUN_receiver_data(uint8_t IRMx)
{
	uint8_t step = 0,cnt = 0;
	step	=	GUN_RxStep[IRMx];

	if(step)										//starting receive IRM data at step1.
	{
		GUN_cnt[IRMx] ++;
		switch(step)
		{
			case	1:								//check IRM low sync start.
				if(nrf_gpio_pin_read(IRM_PINs[IRMx]))
				{
					GUN_cnt[IRMx] = 0;
				}else
				{
					GUN_RxStep[IRMx] = 2;
				}
				break;
			case	2:								//check IRM high sync end.
				if(nrf_gpio_pin_read(IRM_PINs[IRMx]))
				{
					cnt = GUN_cnt[IRMx];
					GUN_cnt[IRMx] = 0;
					if((cnt < g_sync_max) && (cnt > g_sync_min))
					{
						GUN_RxData[IRMx] = 0;
						GUN_RxStep[IRMx] += 1;
					}else
					{
						GUN_RxStep[IRMx] = 1;	//data error.
					}
		//	}else
		//	{
				}
				break;
			case	3:		//bit7.			//check IRM low BIT data.
			case	5:		//bit6.
			case	7:		//bit5.
			case	9:		//bit4.
			case	11:		//bit3.
	//	case	13:		//bit2.
	//	case	15:		//bit1.
	//	case	17:		//bit0.
				if(nrf_gpio_pin_read(IRM_PINs[IRMx]))
				{
				}else
				{
					cnt = GUN_cnt[IRMx];
					GUN_cnt[IRMx] = 0;
					GUN_RxData[IRMx] <<= 1;
					if((cnt > g_bit1_min) && (cnt < g_bit1_max))
					{
						GUN_RxData[IRMx] += 1;
						GUN_RxStep[IRMx] += 1;
					}else if((cnt > g_bit0_min) && (cnt < g_bit0_max))
					{
						GUN_RxStep[IRMx] += 1;
					}else
					{
			//		GUN_RxData[IRMx] = 0;
						GUN_RxStep[IRMx] = 1;												//data error.
					}
				}
				break;
			case	4:		//bit7.			//check IRM high BIT stop.
			case	6:		//bit6.
			case	8:		//bit5.
			case	10:		//bit4.
	//	case	12:		//bit3.
	//	case	14:		//bit2.
	//	case	16:		//bit1.
//		case	18:		//bit0.
				if(nrf_gpio_pin_read(IRM_PINs[IRMx]))
				{
					cnt = GUN_cnt[IRMx];
					GUN_cnt[IRMx] = 0;
					if((cnt > g_stop_max) || (cnt < g_stop_min))
					{
			//		GUN_RxData[IRMx] = 0;
						GUN_RxStep[IRMx] = 1;												//data error.
					}else
					{
						GUN_RxStep[IRMx] += 1;
					}
		//	}else
		//	{
				}
				break;
			case	12:								//check IRM high BIT stop.
				if(nrf_gpio_pin_read(IRM_PINs[IRMx]))
				{
					cnt = GUN_cnt[IRMx];
					GUN_cnt[IRMx] = 0;
					if((cnt > g_stop_max) || (cnt < g_stop_min))
					{
			//		GUN_RxData[IRMx] = 0;
						GUN_RxStep[IRMx] = 1;												//data error.
					}else
					{
						ID_goal = goal[IRMx];
						GUN.Sht_ID = GUN_RxData[IRMx] & 0x1F;
						mFlags.IRM_gun = 1;
						GUN_RxStep[0] = 1;
						GUN_RxStep[1] = 1;
					}
		//	}else
		//	{
				}
				break;
			default:
				GUN_RxStep[IRMx] = 1;
				break;
		}
	}
}

//=======================================================================
//F_:IRM^receiver_data()	//���պ�������.
//=======================================================================
static void IRM_receiver_data(uint8_t IRMx)
{
	uint8_t step = 0,cnt = 0;
	step	=	IRM_RxStep[IRMx];

	if(step)										//starting receive IRM data at step1.
	{
		IRM_cnt[IRMx] ++;
		switch(step)
		{
			case	1:								//check IRM low sync start.
				if(nrf_gpio_pin_read(IRM_PINs[IRMx]))
				{
					IRM_cnt[IRMx] = 0;
				}else
				{
					IRM_RxStep[IRMx] = 2;
				}
				break;
			case	2:								//check IRM high sync end.
				if(nrf_gpio_pin_read(IRM_PINs[IRMx]))
				{
					cnt = IRM_cnt[IRMx];
					IRM_cnt[IRMx] = 0;
					if((cnt < c_sync_max) && (cnt > c_sync_min))
					{
						IRM_RxData[IRMx] = 0;
						IRM_RxStep[IRMx] += 1;
					}else
					{
						IRM_RxStep[IRMx] = 1;	//data error.
					}
		//	}else
		//	{
				}
				break;
			case	3:		//bit7.			//check IRM low BIT data.
			case	5:		//bit6.
			case	7:		//bit5.
			case	9:		//bit4.
			case	11:		//bit3.
			case	13:		//bit2.
			case	15:		//bit1.
			case	17:		//bit0.
				if(nrf_gpio_pin_read(IRM_PINs[IRMx]))
				{
				}else
				{
					cnt = IRM_cnt[IRMx];
					IRM_cnt[IRMx] = 0;
					IRM_RxData[IRMx] <<= 1;
					if((cnt > c_bit1_min) && (cnt < c_bit1_max))
					{
						IRM_RxData[IRMx] += 1;
						IRM_RxStep[IRMx] += 1;
					}else if((cnt > c_bit0_min) && (cnt < c_bit0_max))
					{
						IRM_RxStep[IRMx] += 1;
					}else
					{
			//		IRM_RxData[IRMx] = 0;
						IRM_RxStep[IRMx] = 1;	//data error.
					}
				}
				break;
			case	4:		//bit7.			//check IRM high BIT stop.
			case	6:		//bit6.
			case	8:		//bit5.
			case	10:		//bit4.
			case	12:		//bit3.
			case	14:		//bit2.
			case	16:		//bit1.
//		case	18:		//bit0.
				if(nrf_gpio_pin_read(IRM_PINs[IRMx]))
				{
					cnt = IRM_cnt[IRMx];
					IRM_cnt[IRMx] = 0;
					if((cnt > c_stop_max) || (cnt < c_stop_min))
					{
			//		IRM_RxData[IRMx] = 0;
						IRM_RxStep[IRMx] = 1;	//data error.
					}else
					{
						IRM_RxStep[IRMx] += 1;
					}
				}
				break;
			case	18:								//check IRM high BIT stop.
				if(nrf_gpio_pin_read(IRM_PINs[IRMx]))
				{
					cnt = IRM_cnt[IRMx];
					IRM_cnt[IRMx] = 0;
					if((cnt > c_stop_max) || (cnt < c_stop_min))
					{
			//		IRM_RxData[IRMx] = 0;
						IRM_RxStep[IRMx] = 1;	//data error.
					}else
					{
						switch(IRMx)
						{
							case 0:
								head_rx_CMD = IRM_RxData[IRMx];
								if(head_rx_CMD == 0) head_rx_CMD = 0x80;
								break;
							case 1:
								tail_rx_CMD = IRM_RxData[IRMx];
								if(tail_rx_CMD == 0) tail_rx_CMD = 0x80;
								break;
						}
						mFlags.IRM_rx = 1;	//��ʾ�յ���ȷң����.
						IRM_RxStep[IRMx] = 1;
					}
				}
				break;
			default:
				IRM_RxStep[IRMx] = 1;
				break;
		}
	}
}

//=======================================================================
//F_:send^GPC_cmd()	//����I2C����GPC����.
//=======================================================================
void send_GPC_cmd(void)
{

	if(cmd_SendCNT == 0)
	{
		switch(cmd_SendStep)
		{
			case	0:		//waiting.
				break;
			case	1:		//start.	//�����ز�.	//200us.
				nrf_gpio_pin_clear(ble_GPC_data);
				cmd_SendCNT = 2;
				cmd_SendStep ++;
				break;
			case	2:		//sync.		//�����ز�.	//5000us.
				nrf_gpio_pin_set(ble_GPC_data);
				cmd_bit = 0x2000;		//( 9bits:0x0100;10bits:0x0200;11bits:0x0400;12bits:0x0800;).
		//	cmd_bit = 0x8000;		//(13bits:0x1000;14bits:0x2000;15bits:0x4000;16bits:0x8000;).
				cmd_SendCNT = 47;	//50;
				cmd_SendStep ++;
				break;
			case	3:		//bit7.		//�����ز�.	//0:1000us,1:3000us.
			case	5:		//bit6.
			case	7:		//bit5.
			case	9:		//bit4.
			case	11:		//bit3.
			case	13:		//bit2.
			case	15:		//bit1.
			case	17:		//bit0.
			case	19:		//bit0(9bits).
			case	21:		//bit0(10bits).
			case	23:		//bit0(11bits).
			case	25:		//bit0(12bits).
			case	27:		//bit0(13bits).
			case	29:		//bit0(14bits).
	//	case	31:		//bit0(15bits).
	//	case	33:		//bit0(16bits).			//���ֻ����15bits,�򽫸�������.
				nrf_gpio_pin_clear(ble_GPC_data);
				if(cmd_DATA & cmd_bit)
				{
					cmd_SendCNT = 26;	//30;
				}else
				{
					cmd_SendCNT = 9;	//10;
				}
				cmd_bit >>= 1;
				cmd_SendStep ++;
				break;
			case	4:		//bit7.		//�����ز�.	//1000us.
			case	6:		//bit6.
			case	8:		//bit5.
			case	10:		//bit4.
			case	12:		//bit3.
			case	14:		//bit2.
			case	16:		//bit1.
			case	18:		//bit0.
			case	20:		//bit0(9bits).
			case	22:		//bit0(10bits).
			case	24:		//bit0(11bits).
			case	26:		//bit0(12bits).
			case	28:		//bit0(13bits).
			case	30:		//bit0(14bits).
	//	case	32:		//bit0(15bits).
	//	case	34:		//bit0(16bits).			//���ֻ����15bits,�򽫸�������.
				nrf_gpio_pin_set(ble_GPC_data);
				cmd_SendCNT = 9;	//10;
				cmd_SendStep ++;
				break;
			case	31:		//���������м����ֹͣλ.		//�����ز�.	//3000us.
				nrf_gpio_pin_clear(ble_GPC_data);
				cmd_SendCNT = 30;
				cmd_SendStep ++;
				break;
			case	32:		//����Ƿ�Ҫ������.
			default:		//stop.		//�����ز�.
				nrf_gpio_pin_clear(ble_GPC_data);
				cmd_SendStep = 0;									//ֹͣ����.
				mFlags.I2C_busy = 0;
				break;
		}
	}else
	{
		cmd_SendCNT --;
	}
}

//=======================================================================
//F_0:TIMER2^IRQHandler()	//��ʱ�ж�.
//=======================================================================
void TIMER2_IRQHandler(void)
{

	if(cmd_SendStep)
	{	//��ʼ����GPC��������.
		send_GPC_cmd();
	}

	if(mFlags.Version)
	{	//��ȡ�汾.
		Ver_cnt ++;
		Version_DAC_GPC2();		//��ȡDAC�汾.
		if((Ver_cnt > 10000) || (Ver_DAC_step == 4))
		{	//��ȡ�汾����.
			mFlags.Version = 0;
		}
	}

	if(t2_10ms < 100)
	{	//100us++.
		t2_10ms ++;
	}else
	{	//100 * 100us = 10ms.
		t2_10ms = 0;
		mFlags.T2_10ms = 1;
		mFlags.test_10ms = 1;
	}

	if(mFlags.RGB_pwm_on)
	{	//��������.
		t2_100us --;
		if(t2_100us == RGB.duty)
		{
			RGB_8color_set(RGB.Gradient);	//ˢ�½���������ʾ.
		}else if(t2_100us == 1)
		{
			t2_100us = 101;
			RGB_8color_set(clr_Black);	//ˢ�½��������ʾ.
		}
	}

	if(REV_step == 0)
	{	//.
		IRM_receiver_data(0);
		IRM_receiver_data(1);	//���պ�������.
		if(TestMode.step == 9)
		{	//����ģʽ9,ǰ��ǹ,����ң����.
			GUN_receiver_data(0);	//M2�½���ǹ.
		}else if(TestMode.step == 3)
		{
			if(mFlags.gun_shoot == 0)
			{
				RAMP_send_ctl();	//ƽ̨��ǹ��Դ����.
			}
			gun_shooting_start();	//��ǹ��ʼ��.
		}
	}else
	{
		GUN_receiver_data(0);
		GUN_receiver_data(1);	//����ǹ.
		if(mFlags.gun_shoot == 0)
		{
			RAMP_send_ctl();	//ƽ̨��ǹ��Դ����.
		}
		IRM_receiver_coord();	//���ǶȾ���.
		gun_shooting_start();	//��ǹ��ʼ��.
	}

//	nrf_gpio_pin_clear(test_LED);

	NRF_TIMER2->EVENTS_COMPARE[0] = 0;
}

//=======================================================================
//F_:IR^gpio_init()	//IO�ڳ�ʼ��.
//=======================================================================
void IR_gpio_init(void)
{
	nrf_gpio_cfg_output(test_LED);
	nrf_gpio_cfg_output(ble_Vctl);
	nrf_gpio_cfg_output(ble_GPC_data);
	nrf_gpio_cfg_output(IRM_rec_Vctl);
	nrf_gpio_cfg_output(IR_back);
	nrf_gpio_cfg_output(IR_head);
	nrf_gpio_cfg_output(IR_gun);			//Initialized the pin for send IR data as output.

	nrf_gpio_pin_set(ble_Vctl);					//output 1.

	nrf_gpio_pin_clear(test_LED);
	nrf_gpio_pin_clear(ble_GPC_data);
	nrf_gpio_pin_clear(IRM_rec_Vctl);	//��IRM��Դ���ƽ�.
	nrf_gpio_pin_clear(IR_back);
	nrf_gpio_pin_clear(IR_head);
	nrf_gpio_pin_clear(IR_gun);		//output 0.

	nrf_gpio_cfg_input(ble_GPC2_ctl,NRF_GPIO_PIN_NOPULL);
	nrf_gpio_cfg_input(IRM_tail,NRF_GPIO_PIN_NOPULL);		//Initialized IRMs pin as input.
}

//=======================================================================
//F_1:TIMER2^init()	//��ʼ��.
//=======================================================================
void TIMER2_init(void)
{
	//Initialize timer1.
	NRF_TIMER2->INTENCLR          = 0xffffffffUL;
	NRF_TIMER2->TASKS_STOP        = 1;
	NRF_TIMER2->TASKS_CLEAR       = 1;
	NRF_TIMER2->MODE              = TIMER_MODE_MODE_Timer;
	NRF_TIMER2->EVENTS_COMPARE[0] = 0;
	NRF_TIMER2->EVENTS_COMPARE[1] = 0;
	NRF_TIMER2->EVENTS_COMPARE[2] = 0;
	NRF_TIMER2->EVENTS_COMPARE[3] = 0;
	NRF_TIMER2->SHORTS            = 0;
	NRF_TIMER2->PRESCALER         = 3;																// Input clock is 16MHz, timer clock = 2^3.
	NRF_TIMER2->BITMODE           = TIMER_BITMODE_BITMODE_32Bit;
	NRF_TIMER2->INTENSET          = (TIMER_INTENSET_COMPARE0_Enabled << TIMER_INTENSET_COMPARE0_Pos);
	NRF_TIMER2->SHORTS            = (TIMER_SHORTS_COMPARE0_CLEAR_Enabled << TIMER_SHORTS_COMPARE0_CLEAR_Pos);
	NRF_TIMER2->CC[0]             = 200;
	NRF_TIMER2->TASKS_START       = 1;

	NVIC_EnableIRQ(TIMER2_IRQn);
}

//********************************* end *********************************//
