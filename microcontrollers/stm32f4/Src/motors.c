#include "motors.h"
#include "main.h"
#include "Switchbot.h"
#include <stdbool.h> 


//This function enables timer1 used for the motor PWM 
//and starts the PWM signal for each of the 4 pins
//Sets the Compare Registers to 0 so that the PWM output will be low 
//and motors should not spin


void motor_dir(bool val, uint8_t motor_id) { 

   switch( motor_id){
   
   case 0 : HAL_GPIO_WritePin(GPIOA, GPIO_PIN_3, (val) ? GPIO_PIN_SET : GPIO_PIN_RESET);
            break; 

   case 1 : HAL_GPIO_WritePin(GPIOC, GPIO_PIN_4, (val) ? GPIO_PIN_SET : GPIO_PIN_RESET);
            break; 
   
   case 2 : HAL_GPIO_WritePin(GPIOC, GPIO_PIN_5, (val) ? GPIO_PIN_SET : GPIO_PIN_RESET);
            break;
   default : break; 
   
   
   }

}

void motor_enable(uint8_t motor_id){

 switch(motor_id){
 
    case 0 : HAL_GPIO_WritePin(GPIOC, GPIO_PIN_13, GPIO_PIN_SET);
             break;  

    case 1 : HAL_GPIO_WritePin(GPIOC, GPIO_PIN_14, GPIO_PIN_SET);
             break;  
    
    case 2 : HAL_GPIO_WritePin(GPIOC, GPIO_PIN_15, GPIO_PIN_SET);
             break;  
    default : break;  
 
 
 }

}





void enableMotors()
{
	htim2.Instance->CCR1 = 0x00000000;
	htim2.Instance->CCR2 = 0x00000000;
	htim2.Instance->CCR3 = 0x00000000;
	htim2.Instance->CCR4 = 0x00000000;

       // HAL_GPIO_WritePin(GPIOC, GPIO_PIN_13, GPIO_PIN_SET);  // enable the back motor 
       HAL_GPIO_WritePin(GPIOC, GPIO_PIN_14, GPIO_PIN_SET);  // enable the right motor 
       HAL_GPIO_WritePin(GPIOC, GPIO_PIN_15, GPIO_PIN_SET);   // enable the left motor 


	HAL_TIM_PWM_Start(&htim2,TIM_CHANNEL_1); 
	HAL_TIM_PWM_Start(&htim2,TIM_CHANNEL_2); 
	HAL_TIM_PWM_Start(&htim2,TIM_CHANNEL_3); 
	HAL_TIM_PWM_Start(&htim2,TIM_CHANNEL_4); 
}

//This function disables the generation of PWM signals for each of the 4 motors
void disableMotors()
{
	htim2.Instance->CCR1 = 0x00000000; 
	htim2.Instance->CCR2 = 0x00000000;  
	htim2.Instance->CCR3 = 0x00000000; 
	htim2.Instance->CCR4 = 0x00000000; 	

       // HAL_GPIO_WritePin(GPIOC, GPIO_PIN_13, GPIO_PIN_RESET);  // disable the back motor 
        HAL_GPIO_WritePin(GPIOC, GPIO_PIN_14, GPIO_PIN_RESET);  // disable the right motor 
        HAL_GPIO_WritePin(GPIOC, GPIO_PIN_15, GPIO_PIN_RESET);   // disable the left motor 

	HAL_TIM_PWM_Stop(&htim2,TIM_CHANNEL_1); 
	HAL_TIM_PWM_Stop(&htim2,TIM_CHANNEL_2); 
	HAL_TIM_PWM_Stop(&htim2,TIM_CHANNEL_3); 
	HAL_TIM_PWM_Stop(&htim2,TIM_CHANNEL_4); 
}

//This function will only work if the enableMotors() function has been called
//MotorPWM: input array of the 4 desired motor PWM values, note that the max value is 0x72
void writeMotors(uint32_t* MotorPWM)
{

	htim2.Instance->CCR1 = 0;
	htim2.Instance->CCR2 = MotorPWM[0];
	htim2.Instance->CCR3 = MotorPWM[1];  
	htim2.Instance->CCR4 = 0;  
}



void driveMotors(float u[])
{

	static uint32_t pwm[4] = {0};

	
	if( u[0] != 0 && u[1] != 0)
	{
//            LOG("DM\t");   
  
	    if (u[0] > 0){
		pwm[0] = (MaxPWM*(u[0]));
		motor_dir(true, 1); 
//		LOG(" 1\t");
	    }else{
	        pwm[0] = (MaxPWM*(-u[0]));
		motor_dir(false, 1 ); 
//		LOG(" -1\t");
	    }

	    if (u[1] < 0){
		pwm[1] = (MaxPWM*(-u[1]));
		motor_dir(true, 2); 
//                LOG(" 2\t");
	    }else{
		pwm[1] = (MaxPWM*(u[1]));
		motor_dir(false, 2); 
//		LOG(" -2\t");
            }
	
	LOG("driveMotors#  %d\t%d \n", pwm[0], pwm[1]);
	  writeMotors(pwm);

	} else {
          pwm[0] = 0;
	  pwm[1] = 0;
	  writeMotors(pwm);
        }
}





