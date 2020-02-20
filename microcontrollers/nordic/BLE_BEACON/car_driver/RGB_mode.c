//=======================================================================
//.T		包含头文件.
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
//.T		变量定义.
//=======================================================================
RGB_struct	RGB;

//=======================================================================

//=======================================================================
//F_:RGB^mode_gpio_init()	//RGB灯脚初始化.
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
//F_:RGB^8color_set(uint8_t i)	//设定8种RGB颜色.
//=======================================================================
void RGB_8color_set(uint8_t i)
{
	switch(i)
	{			//clear 0 open LED & set 1 close LED.
		case 0:	//RGB_Black:		//output 111.	;黑.
			nrf_gpio_pin_set(RGB_red);
			nrf_gpio_pin_set(RGB_green);
			nrf_gpio_pin_set(RGB_blue);
			break;
		case 1:	//RGB_Red:			//output 110.	;红.
			nrf_gpio_pin_clear(RGB_red);
			nrf_gpio_pin_set(RGB_green);
			nrf_gpio_pin_set(RGB_blue);
			break;
		case 2:	//RGB_Green:		//output 101.	;绿.
			nrf_gpio_pin_set(RGB_red);
			nrf_gpio_pin_clear(RGB_green);
			nrf_gpio_pin_set(RGB_blue);
			break;
		case 3:	//RGB_Yollow:		//output 100.	;黄.
			nrf_gpio_pin_clear(RGB_red);
			nrf_gpio_pin_clear(RGB_green);
			nrf_gpio_pin_set(RGB_blue);
			break;
		case 4:	//RGB_Blue:			//output 011.	;蓝.
			nrf_gpio_pin_set(RGB_red);
			nrf_gpio_pin_set(RGB_green);
			nrf_gpio_pin_clear(RGB_blue);
			break;
		case 5:	//RGB_Magenta:	//output 010.	;品红.
			nrf_gpio_pin_clear(RGB_red);
			nrf_gpio_pin_set(RGB_green);
			nrf_gpio_pin_clear(RGB_blue);
			break;
		case 6:	//RGB_Cyan:			//output 001.	;青.
			nrf_gpio_pin_set(RGB_red);
			nrf_gpio_pin_clear(RGB_green);
			nrf_gpio_pin_clear(RGB_blue);
			break;
		case 7:	//RGB_White:		//output 000.	;白.
			nrf_gpio_pin_clear(RGB_red);
			nrf_gpio_pin_clear(RGB_green);
			nrf_gpio_pin_clear(RGB_blue);
			break;
		default:								//output 111.	;黑.
			nrf_gpio_pin_set(RGB_red);
			nrf_gpio_pin_set(RGB_green);
			nrf_gpio_pin_set(RGB_blue);
			break;
	}
/*	{			//set 1 open LED & clear 0 close LED.
		case 0:	//RGB_Black:		//output 000.	;黑.
			nrf_gpio_pin_clear(RGB_red);
			nrf_gpio_pin_clear(RGB_green);
			nrf_gpio_pin_clear(RGB_blue);
			break;
		case 1:	//RGB_Red:			//output 001.	;红.
			nrf_gpio_pin_set(RGB_red);
			nrf_gpio_pin_clear(RGB_green);
			nrf_gpio_pin_clear(RGB_blue);
			break;
		case 2:	//RGB_Green:		//output 010.	;绿.
			nrf_gpio_pin_clear(RGB_red);
			nrf_gpio_pin_set(RGB_green);
			nrf_gpio_pin_clear(RGB_blue);
			break;
		case 3:	//RGB_Yollow:		//output 011.	;黄.
			nrf_gpio_pin_set(RGB_red);
			nrf_gpio_pin_set(RGB_green);
			nrf_gpio_pin_clear(RGB_blue);
			break;
		case 4:	//RGB_Blue:			//output 100.	;蓝.
			nrf_gpio_pin_clear(RGB_red);
			nrf_gpio_pin_clear(RGB_green);
			nrf_gpio_pin_set(RGB_blue);
			break;
		case 5:	//RGB_Magenta:	//output 101.	;品红.
			nrf_gpio_pin_set(RGB_red);
			nrf_gpio_pin_clear(RGB_green);
			nrf_gpio_pin_set(RGB_blue);
			break;
		case 6:	//RGB_Cyan:			//output 110.	;青.
			nrf_gpio_pin_clear(RGB_red);
			nrf_gpio_pin_set(RGB_green);
			nrf_gpio_pin_set(RGB_blue);
			break;
		case 7:	//RGB_White:		//output 111.	;白.
			nrf_gpio_pin_set(RGB_red);
			nrf_gpio_pin_set(RGB_green);
			nrf_gpio_pin_set(RGB_blue);
			break;
		default:								//output 000.	;黑.
			nrf_gpio_pin_clear(RGB_red);
			nrf_gpio_pin_clear(RGB_green);
			nrf_gpio_pin_clear(RGB_blue);
			break;
	}*/
}

//=======================================================================
//F_:reflash^RGB()	//RGB灯闪烁.
//=======================================================================
static void reflash_RGB(void)
{
	uint16_t i = 0,j = 0;
	i = RGB.SCtime * 2;
	j = RGB.SCtime * 2 + RGB.BGtime * 2;

	RGB.real_10ms ++;
	if(RGB.real_10ms == 1)
	{	//10ms时间到.
		RGB_8color_set(RGB.ShowColor);	//显示闪烁颜色.
	}else if(RGB.real_10ms == i)
	{	//亮灯时间到.
		RGB_8color_set(RGB.BackGround);	//显示背景颜色.
	}else if(RGB.real_10ms >= j)
	{	//闪烁周期到.
		RGB.real_10ms = 0;
		if(RGB.times)	RGB.times --;
	}
}

//=======================================================================
//F_:RGB^reflash_ctl()	//刷新控制RGB灯.
//=======================================================================
void RGB_reflash_ctl(void)
{
	switch(RGB.step)
	{
		case 0:	//设定更新颜色.
			if(RGB.colorNow != RGB.colorSet)
			{	//设置新颜色.
				RGB_8color_set(RGB.colorSet);	//刷新RGB显示.
				RGB.colorNow = RGB.colorSet;
			}
			break;
		case 1:	//设定闪烁颜色.
			if(RGB.times)
			{	//如果设定闪烁次数.
				reflash_RGB();
				if(RGB.times == 0)
				{	//闪烁结束.
					RGB.colorSet = RGB.BackGround;
					RGB.colorNow = clr_NULL;	//需要刷新STEP0闪烁颜色.
					RGB.real_10ms = 0;
					RGB.step = RGB.last_step;
					if(RGB.last_step == 2)
					{
						mFlags.RGB_pwm_on = 1;	//打开渐明渐暗.
					}
				}
			}else
			{	//一直闪烁.
				reflash_RGB();
			}
			break;
		case 2:	//设定渐明渐暗及闪烁速度.
			if(RGB.index < 100)
			{	//ON渐明.
				if(RGB.speed_ON < 5)
				{	//快速变化.
					RGB.index += (5 - RGB.speed_ON);
					if(RGB.index > 100) RGB.index = 100;
				}else
				{	//慢速变化.
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
			{	//OFF渐暗.
				if(RGB.speed_OFF < 5)
				{	//快速变化.
					RGB.index += (5 - RGB.speed_OFF);
					if(RGB.index > 200) RGB.index = 200;
				}else
				{	//慢速变化.
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
			{	//重新开始.
				RGB.index = 0;
				RGB.duty = 0;
			}
			break;
		default:
			break;
	}
}

//=======================================================================
//F_:RGB^show_color(uint8_t i)	//RGB灯设定显示颜色.
//=======================================================================
void RGB_show_color(uint8_t i)
{
	mFlags.RGB_pwm_on = 0;	//关闭渐明渐暗.
	RGB.BackGround = i;
	RGB.colorSet = RGB.BackGround;
	RGB.colorNow = clr_NULL;	//需要刷新STEP0闪烁颜色.
	RGB.step = 0;
	RGB.last_step = 0;
}

//=======================================================================
//F_:RGB^flash_color(uint8_t i)	//RGB灯设定闪烁显示颜色.
//=======================================================================
void RGB_flash_color(uint8_t i)
{
	mFlags.RGB_pwm_on = 0;	//关闭渐明渐暗.
	RGB.ShowColor = i;
	RGB.real_10ms = 0;
	RGB.step = 1;
}

//=======================================================================
//F_:RGB^Gradient_color(uint8_t i)	//RGB灯设定渐明渐暗显示颜色.
//=======================================================================
void RGB_Gradient_color(uint8_t i)
{
	RGB.Gradient = i;
	RGB.real_10ms = 0;
	RGB.speed_INC = 0;
	RGB.index = 0;
	RGB.step = 2;
	mFlags.RGB_pwm_on = 1;	//打开渐明渐暗.
}

//=======================================================================
//=======================================================================

//********************************* end *********************************//
