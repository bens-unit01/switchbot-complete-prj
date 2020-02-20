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
#include	"RGB_mode.h"
//-----------------------

//=======================================================================
//.T		��������.
//=======================================================================
RGB_struct	RGB;

//=======================================================================

//=======================================================================
//F_:RGB^mode_gpio_init()	//RGB�ƽų�ʼ��.
//=======================================================================
void RGB_mode_gpio_init(void)
{
	nrf_gpio_cfg_output(RGB_red);
	nrf_gpio_cfg_output(RGB_green);
	nrf_gpio_cfg_output(RGB_blue);			//set LED pin as output 0.

	nrf_gpio_pin_set(RGB_red);
	nrf_gpio_pin_set(RGB_green);
	nrf_gpio_pin_set(RGB_blue);
}

//=======================================================================
//F_:RGB^8color_set(uint8_t i)	//�趨8��RGB��ɫ.
//=======================================================================
void RGB_8color_set(uint8_t i)
{
	switch(i)
	{			//clear 0 open LED & set 1 close LED.
		case 0:	//RGB_Black:		//output 111.	;��.
			nrf_gpio_pin_set(RGB_red);
			nrf_gpio_pin_set(RGB_green);
			nrf_gpio_pin_set(RGB_blue);
			break;
		case 1:	//RGB_Red:			//output 110.	;��.
			nrf_gpio_pin_clear(RGB_red);
			nrf_gpio_pin_set(RGB_green);
			nrf_gpio_pin_set(RGB_blue);
			break;
		case 2:	//RGB_Green:		//output 101.	;��.
			nrf_gpio_pin_set(RGB_red);
			nrf_gpio_pin_clear(RGB_green);
			nrf_gpio_pin_set(RGB_blue);
			break;
		case 3:	//RGB_Yollow:		//output 100.	;��.
			nrf_gpio_pin_clear(RGB_red);
			nrf_gpio_pin_clear(RGB_green);
			nrf_gpio_pin_set(RGB_blue);
			break;
		case 4:	//RGB_Blue:			//output 011.	;��.
			nrf_gpio_pin_set(RGB_red);
			nrf_gpio_pin_set(RGB_green);
			nrf_gpio_pin_clear(RGB_blue);
			break;
		case 5:	//RGB_Magenta:	//output 010.	;Ʒ��.
			nrf_gpio_pin_clear(RGB_red);
			nrf_gpio_pin_set(RGB_green);
			nrf_gpio_pin_clear(RGB_blue);
			break;
		case 6:	//RGB_Cyan:			//output 001.	;��.
			nrf_gpio_pin_set(RGB_red);
			nrf_gpio_pin_clear(RGB_green);
			nrf_gpio_pin_clear(RGB_blue);
			break;
		case 7:	//RGB_White:		//output 000.	;��.
			nrf_gpio_pin_clear(RGB_red);
			nrf_gpio_pin_clear(RGB_green);
			nrf_gpio_pin_clear(RGB_blue);
			break;
		default:								//output 111.	;��.
			nrf_gpio_pin_set(RGB_red);
			nrf_gpio_pin_set(RGB_green);
			nrf_gpio_pin_set(RGB_blue);
			break;
	}
/*	{			//set 1 open LED & clear 0 close LED.
		case 0:	//RGB_Black:		//output 000.	;��.
			nrf_gpio_pin_clear(RGB_red);
			nrf_gpio_pin_clear(RGB_green);
			nrf_gpio_pin_clear(RGB_blue);
			break;
		case 1:	//RGB_Red:			//output 001.	;��.
			nrf_gpio_pin_set(RGB_red);
			nrf_gpio_pin_clear(RGB_green);
			nrf_gpio_pin_clear(RGB_blue);
			break;
		case 2:	//RGB_Green:		//output 010.	;��.
			nrf_gpio_pin_clear(RGB_red);
			nrf_gpio_pin_set(RGB_green);
			nrf_gpio_pin_clear(RGB_blue);
			break;
		case 3:	//RGB_Yollow:		//output 011.	;��.
			nrf_gpio_pin_set(RGB_red);
			nrf_gpio_pin_set(RGB_green);
			nrf_gpio_pin_clear(RGB_blue);
			break;
		case 4:	//RGB_Blue:			//output 100.	;��.
			nrf_gpio_pin_clear(RGB_red);
			nrf_gpio_pin_clear(RGB_green);
			nrf_gpio_pin_set(RGB_blue);
			break;
		case 5:	//RGB_Magenta:	//output 101.	;Ʒ��.
			nrf_gpio_pin_set(RGB_red);
			nrf_gpio_pin_clear(RGB_green);
			nrf_gpio_pin_set(RGB_blue);
			break;
		case 6:	//RGB_Cyan:			//output 110.	;��.
			nrf_gpio_pin_clear(RGB_red);
			nrf_gpio_pin_set(RGB_green);
			nrf_gpio_pin_set(RGB_blue);
			break;
		case 7:	//RGB_White:		//output 111.	;��.
			nrf_gpio_pin_set(RGB_red);
			nrf_gpio_pin_set(RGB_green);
			nrf_gpio_pin_set(RGB_blue);
			break;
		default:								//output 000.	;��.
			nrf_gpio_pin_clear(RGB_red);
			nrf_gpio_pin_clear(RGB_green);
			nrf_gpio_pin_clear(RGB_blue);
			break;
	}*/
}

//=======================================================================
//F_:reflash^RGB()	//RGB����˸.
//=======================================================================
static void reflash_RGB(void)
{
	uint16_t i = 0,j = 0;
	i = RGB.SCtime * 2;
	j = RGB.SCtime * 2 + RGB.BGtime * 2;

	RGB.real_10ms ++;
	if(RGB.real_10ms == 1)
	{	//10msʱ�䵽.
		RGB_8color_set(RGB.ShowColor);	//��ʾ��˸��ɫ.
	}else if(RGB.real_10ms == i)
	{	//����ʱ�䵽.
		RGB_8color_set(RGB.BackGround);	//��ʾ������ɫ.
	}else if(RGB.real_10ms >= j)
	{	//��˸���ڵ�.
		RGB.real_10ms = 0;
		if(RGB.times)	RGB.times --;
	}
}

//=======================================================================
//F_:RGB^reflash_ctl()	//ˢ�¿���RGB��.
//=======================================================================
void RGB_reflash_ctl(void)
{
	switch(RGB.step)
	{
		case 0:	//�趨������ɫ.
			if(RGB.colorNow != RGB.colorSet)
			{	//��������ɫ.
				RGB_8color_set(RGB.colorSet);	//ˢ��RGB��ʾ.
				RGB.colorNow = RGB.colorSet;
			}
			break;
		case 1:	//�趨��˸��ɫ.
			if(RGB.times)
			{	//����趨��˸����.
				reflash_RGB();
				if(RGB.times == 0)
				{	//��˸����.
					RGB.colorSet = RGB.BackGround;
					RGB.colorNow = clr_NULL;	//��Ҫˢ��STEP0��˸��ɫ.
					RGB.real_10ms = 0;
					RGB.step = RGB.last_step;
					if(RGB.last_step == 2)
					{
						mFlags.RGB_pwm_on = 1;	//�򿪽�������.
					}
				}
			}else
			{	//һֱ��˸.
				reflash_RGB();
			}
			break;
		case 2:	//�趨������������˸�ٶ�.
			if(RGB.index < 100)
			{	//ON����.
				if(RGB.speed_ON < 5)
				{	//���ٱ仯.
					RGB.index += (5 - RGB.speed_ON);
					if(RGB.index > 100) RGB.index = 100;
				}else
				{	//���ٱ仯.
					RGB.speed_INC ++;
					if(RGB.speed_INC >= (RGB.speed_ON - 5))
					{
						RGB.speed_INC = 0;
						RGB.index ++;
					}
				}
				if(RGB.index < 5)
				{
					RGB.duty = 3;
				}else
				{
					RGB.duty = RGB.index;
				}
			}else if(RGB.index < 200)
			{	//OFF����.
				if(RGB.speed_OFF < 5)
				{	//���ٱ仯.
					RGB.index += (5 - RGB.speed_OFF);
					if(RGB.index > 200) RGB.index = 200;
				}else
				{	//���ٱ仯.
					RGB.speed_INC ++;
					if(RGB.speed_INC >= (RGB.speed_OFF - 5))
					{
						RGB.speed_INC = 0;
						RGB.index ++;
					}
				}
				if(RGB.index > 195)
				{
					RGB.duty = 3;
				}else
				{
					RGB.duty = 200 - RGB.index;
				}
			}else
			{	//���¿�ʼ.
				RGB.index = 0;
				RGB.duty = 0;
			}
			break;
		default:
			break;
	}
}

//=======================================================================
//F_:RGB^show_color(uint8_t i)	//RGB���趨��ʾ��ɫ.
//=======================================================================
void RGB_show_color(uint8_t i)
{
	mFlags.RGB_pwm_on = 0;	//�رս�������.
	RGB.BackGround = i;
	RGB.colorSet = RGB.BackGround;
	RGB.colorNow = clr_NULL;	//��Ҫˢ��STEP0��˸��ɫ.
	RGB.step = 0;
	RGB.last_step = 0;
}

//=======================================================================
//F_:RGB^flash_color(uint8_t i)	//RGB���趨��˸��ʾ��ɫ.
//=======================================================================
void RGB_flash_color(uint8_t i)
{
	mFlags.RGB_pwm_on = 0;	//�رս�������.
	RGB.ShowColor = i;
	RGB.real_10ms = 0;
	RGB.step = 1;
}

//=======================================================================
//F_:RGB^Gradient_color(uint8_t i)	//RGB���趨����������ʾ��ɫ.
//=======================================================================
void RGB_Gradient_color(uint8_t i)
{
	RGB.Gradient = i;
	RGB.real_10ms = 0;
	RGB.speed_INC = 0;
	RGB.index = 0;
	RGB.step = 2;
	mFlags.RGB_pwm_on = 1;	//�򿪽�������.
}

//=======================================================================
//=======================================================================

//********************************* end *********************************//
