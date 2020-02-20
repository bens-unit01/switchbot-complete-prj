/**
  ******************************************************************************
  * File Name          : USART.c
  * Description        : This file provides code for the configuration
  *                      of the USART instances.
  ******************************************************************************
  *
  * COPYRIGHT(c) 2015 STMicroelectronics
  *
  * Redistribution and use in source and binary forms, with or without modification,
  * are permitted provided that the following conditions are met:
  *   1. Redistributions of source code must retain the above copyright notice,
  *      this list of conditions and the following disclaimer.
  *   2. Redistributions in binary form must reproduce the above copyright notice,
  *      this list of conditions and the following disclaimer in the documentation
  *      and/or other materials provided with the distribution.
  *   3. Neither the name of STMicroelectronics nor the names of its contributors
  *      may be used to endorse or promote products derived from this software
  *      without specific prior written permission.
  *
  * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
  * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
  * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
  * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
  * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
  * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
  * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
  * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
  * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  *
  ******************************************************************************
  */

/* Includes ------------------------------------------------------------------*/
#include "usart.h"

//#include "gpio.h"
//#include "dma.h"
#include "Switchbot.h"
#include <stdarg.h>
#include <stdbool.h>

/* USER CODE BEGIN 0 */

/* USER CODE END 0 */

#define PACKET_SIZE       3
#define UART_TIMEOUT	 270 					// milliseconds
#define MAX_ATTEMPTS     100 					// milliseconds

UART_HandleTypeDef huart1;
UART_HandleTypeDef huart3;
UART_HandleTypeDef huart4;

DMA_HandleTypeDef hdma_usart2_tx;
uint8_t buffer[20] = {0};
uint32_t timestamp1 = 0;
uint32_t timestamp6 = 0;
uint32_t timestamp4 = 0;
uint8_t  RX3Data[PACKET_SIZE] = {0};						
uint8_t  RX4Data[PACKET_SIZE] = {0};						
uint8_t  RX1Data[PACKET_SIZE] = {0};	


uint32_t millis(void) {
  return HAL_GetTick();
}

void uart_put(uint8_t uart_port, uint8_t ch)
{
	
}	


void MX_USART1_UART_Init(void)
{

  huart1.Instance = USART1;
  huart1.Init.BaudRate = 115200;
  huart1.Init.WordLength = UART_WORDLENGTH_8B;
  huart1.Init.StopBits = UART_STOPBITS_1;
  huart1.Init.Parity = UART_PARITY_NONE;
  huart1.Init.Mode = UART_MODE_TX_RX;
  huart1.Init.HwFlowCtl = UART_HWCONTROL_NONE;
  huart1.Init.OverSampling = UART_OVERSAMPLING_16;
  HAL_StatusTypeDef status =  HAL_UART_Init(&huart1);
  HAL_UART_Receive_IT(&huart1, RX1Data, PACKET_SIZE);

  LOG("uart 1 status: %d \n", status);
}

/* USART3 init function */
void MX_USART3_UART_Init(void)
{

  huart3.Instance = USART3;
  huart3.Init.BaudRate = 115200;
  huart3.Init.WordLength = UART_WORDLENGTH_8B;
  huart3.Init.StopBits = UART_STOPBITS_1;
  huart3.Init.Parity = UART_PARITY_NONE;
  huart3.Init.Mode = UART_MODE_TX_RX;
  huart3.Init.HwFlowCtl = UART_HWCONTROL_NONE;
  huart3.Init.OverSampling = UART_OVERSAMPLING_16;
  HAL_StatusTypeDef status =  HAL_UART_Init(&huart3);
  HAL_UART_Receive_IT(&huart3, RX3Data, PACKET_SIZE);
  
  LOG("uart 3 status: %d \n", status);
}


/* UART4 init function */
void MX_UART4_UART_Init(void)
{

	huart4.Instance = UART4;
	huart4.Init.BaudRate = 115200;
	huart4.Init.WordLength = UART_WORDLENGTH_8B;
	huart4.Init.StopBits = UART_STOPBITS_1;
	huart4.Init.Parity = UART_PARITY_NONE;
	huart4.Init.Mode = UART_MODE_TX_RX;
	huart4.Init.HwFlowCtl = UART_HWCONTROL_NONE;
	huart4.Init.OverSampling = UART_OVERSAMPLING_16;
	HAL_StatusTypeDef status =  HAL_UART_Init(&huart4);
	HAL_UART_Receive_IT(&huart4, RX4Data, PACKET_SIZE);

}


/* USER CODE BEGIN 1 */

/**
* @brief This function handles USART1 global interrupt / USART1 wake-up interrupt through EXTI line 25.
*/
void USART1_IRQHandler(void)
{
   /* USER CODE BEGIN USART1_IRQn 0 */
 
  /* USER CODE END USART1_IRQn 0 */
  HAL_UART_IRQHandler(&huart1);
	
  /* USER CODE BEGIN USART1_IRQn 1 */

	
  /* USER CODE END USART1_IRQn 1 */

}

/**
* @brief This function handles USART2 global interrupt.
*/
static HAL_StatusTypeDef reset_uart3(){

	__HAL_LOCK(&huart3);
	huart3.RxState = HAL_UART_STATE_READY;   
//	huart3.RxXferCount--;
	__HAL_UNLOCK(&huart3);
	HAL_UART_Receive_IT(&huart3, RX3Data, PACKET_SIZE); 
	return HAL_OK;


}
void USART3_IRQHandler(void)
{
  /* USER CODE BEGIN USART2_IRQn 0 */
  /* USER CODE END USART2_IRQn 0 */
        if((0xFF == RX3Data[0]) || (0xFF == RX3Data[0]) ||  (0xFF == RX3Data[0])){
//		reset_uart3(); 
	}

	HAL_UART_IRQHandler(&huart3);
  /* USER CODE BEGIN USART2_IRQn 1 */
//   LOG("irq3 %03x\t%03x\t%03x\t%d... \n", RX3Data[0], RX3Data[1], RX3Data[2], huart3.RxXferCount);  
	
  /* USER CODE END USART2_IRQn 1 */
}


void UART4_IRQHandler(void)
{
	/* USER CODE BEGIN USART2_IRQn 0 */
	/* USER CODE END USART2_IRQn 0 */

	HAL_UART_IRQHandler(&huart4);
	/* USER CODE BEGIN USART2_IRQn 1 */
	//   LOG("irq3 %03x\t%03x\t%03x\t%d... \n", RX3Data[0], RX3Data[1], RX3Data[2], huart3.RxXferCount);  

	/* USER CODE END USART2_IRQn 1 */
}



void reset_IT(UART_HandleTypeDef *UartHandle)
{

	if (UartHandle == &huart1)
	{
		HAL_UART_Receive_IT(UartHandle, RX1Data, PACKET_SIZE);
		timestamp1 = millis();
//		LOG("uart1 %d %d %d %d \n", RX1Data[0], RX1Data[1], RX1Data[2], timestamp1);
	}
	else if(UartHandle == &huart3)
	{
		HAL_UART_Receive_IT(UartHandle, RX3Data, PACKET_SIZE);
		timestamp6 = millis();
	}
	else if(UartHandle == &huart4)
	{
		HAL_UART_Receive_IT(UartHandle, RX4Data, PACKET_SIZE);
		timestamp4 = millis();
	}

}

/**
  * @brief  Rx Transfer completed callback
  * @param  UartHandle: UART handle
  * @note   This example shows a simple way to report end of DMA Rx transfer, and 
  *         you can add your own implementation.
  * @retval None
  */
void HAL_UART_RxCpltCallback(UART_HandleTypeDef *UartHandle)
{
  
//   LOG("Rx completed ... \n");
  reset_IT(UartHandle);
	 
}

/**
  * @brief  UART error callbacks
  * @param  UartHandle: UART handle
  * @note   This example shows a simple way to report transfer error, and you can
  *         add your own implementation.
  * @retval None
  */
 void HAL_UART_ErrorCallback(UART_HandleTypeDef *UartHandle)
{
	 
	 //LOG4(" Error callback ... error code : %d ", UartHandle->ErrorCode);
	   reset_IT(UartHandle);
}

void HAL_UART_TxCpltCallback(UART_HandleTypeDef *UartHandle)
{
   // LOG("Tx completed ... \n");
  
}


void send_with_ack(uint8_t byte_to_send_1, uint8_t byte_to_send_2){

float m =0; 
bool received_ack = false; 
uint8_t c1 = 0, c2 = 0;  


   uint8_t data[3] = {byte_to_send_1, byte_to_send_2, 0x00}; 
   HAL_StatusTypeDef  st =  HAL_UART_Transmit(&huart1, data, 3, 1000);
   LOG("uart3 notf_get_next, notf_closest_beacon  %03x %03x %d\n", data[0], data[1], st); 

   while( !received_ack ){
          
       m = (millis() - timestamp1); 
       if( m < UART_TIMEOUT){
           if(RX1Data[0] == ACK_BYTE){
	       received_ack = true;  
	   } 
       }

       c1++; 
       
       if( (c1 == 10) && (c2 <= MAX_ATTEMPTS)  && !received_ack ) {
          c1 = 0; 
	  c2++;
          HAL_UART_Transmit(&huart1, data, 3, 1000);  // we didn't receive an ACK, we try again 
	  LOG("attempt %d %.3f \n", c2, m);

	  if( c2 == MAX_ATTEMPTS) received_ack = true; // this is the last attempt, we give up 
       }
       HAL_Delay(20); 
   }

}



/////////////////////////////////////////////////////////////////////////////////////////////////////////
// parse UART0 buffer and set command variables

int parseUARTbuffer(float joy[])
{
	int button = 0;
  float m = 0;
	joy[0] = 0;
	joy[1] = 0;
	joy[2] = 0;

// Handling UART3, commands from the BLE
   m = (millis() - timestamp6);
	if( m < 0) {  // bug fix where the millis() restart counting after ~ 3min, maybe we should change millis() implementation ?	          
	  RX3Data[0] = 0;
	} else if ( m < UART_TIMEOUT)
	{
	//	LOG("uart3 -- %03x %03x %03x \r\n", RX3Data[0], RX3Data[1], RX3Data[2]);
		switch(RX3Data[0])
		{
			
	
			case 0x50: // push to talk has been pressed
				LOG("Push button ... uart6 \n");
				RX3Data[0] = 0;
				break;
			case ESTOP: // emergency stop
				button = ESTOP;
				RX3Data[0] = 0;
				break;
			case CLEAR_ESTOP: // reset emergency stop
				button = CLEAR_ESTOP;
				RX3Data[0] = 0;
				break;
			case DRIVE: // drive, any mode
//		   	LOG("drive 0x81\t%3d\t%3d \n", RX3Data[1], RX3Data[2]);
			  // LOG("drive 0x78 \n");
				// 0 is stop, 01-32 is forward, 33-64 is backwards
				// 0 is straight, 65-96 is right, 97-128 is left
				if (RX3Data[1] > 0) // not stopped
				{
					if (RX3Data[1] < 33) // forward
						joy[1] = ((float) RX3Data[1]) / 32.0;
					else if (RX3Data[1] < 65)// backward
						joy[1] = -((float) (RX3Data[1] - 32)) / 32.0;
				}
				if (RX3Data[2] > 64) // not straight
				{
					if (RX3Data[2] < 96) // right
						joy[0] = ((float) (RX3Data[2] - 64)) / 32.0;
					else if (RX3Data[2] < 129)// left
						joy[0] = -((float) (RX3Data[2] - 96)) / 32.0;
				}

				break;
				
			case NOTF_GET_NEXT_BEACON:
			case NOTF_DP_CLOSEST_BEACON:
                             send_with_ack(RX3Data[0], RX3Data[1]); 
			     RX3Data[0] = 0;      // we reset the command data to avoid resending it again
			     
			   break;
		       case  RGB_CTRL_COMMAND: 
		    	  // HAL_UART_Transmit(&huart1, RX3Data, 3, 1000);
		    	   //RX3Data[0] = 0;
		         LOG("echo test ... \r\n");
		       break;
  		      case 0x05:  // bug fix where BLE reboot and the buffer gets shifted  
		      LOG("uart3 - faults ... \n"); 
		      RX3Data[0] = 0;
		      reset_uart3();  
		      //		      NVIC_SystemReset();
		      break;
		      case DEBUG_DUMP: LOG(" -- %d\t%d \n", RX3Data[1], RX3Data[2]); 
		           RX3Data[0] = 0; 
		      break; 
		      case DEBUG_STATE: LOG("%d ", RX3Data[1]); 
		           RX3Data[0] = 0; 
		      break;  
	
		     default:
			  break;
		}
	} 
	
	
	// Handling UART1, commands from android board
        m = (millis() - timestamp1); //;
	
	if( m < 0) {  // bug fix where the millis() restart counting        
	  RX1Data[0] = 0;
	} else if ( m < UART_TIMEOUT)
	{
         //	HAL_UART_Transmit(&huart1, RX1Data, 3, 1000);
//		LOG("uart1 -- %04x %04x %04x \r\n", RX1Data[0], RX1Data[1], RX1Data[2]);
		switch(RX1Data[0])
		{
			
			case 0x50: // push to talk has been pressed
				LOG("Push button ... uart1  \n");RX1Data[0] = 0;
        	                uint8_t test[3] = { RGB_CTRL_COMMAND ,0x00 , 0x00};
        	                HAL_UART_Transmit(&huart3, test, 3, 1000);
				break;
			case ESTOP: // emergency stop
				button = ESTOP; 
				RX1Data[0] = 0;
				break;
			case CLEAR_ESTOP: // reset emergency stop
				button = CLEAR_ESTOP;
				RX1Data[0] = 0;
				break;
			case DRIVE: // drive, any mode
				
//		   	LOG("drive 0x81 \r\n");
				// 0 is stop, 01-32 is forward, 33-64 is backwards
				// 0 is straight, 65-96 is right, 97-128 is left
				if (RX1Data[1] > 0) // not stopped
				{
					if (RX1Data[1] < 33) // forward
						joy[1] = ((float) RX1Data[1]) / 32.0;
					else if (RX1Data[1] < 64)// backward
						joy[1] = -((float) (RX1Data[1] - 32)) / 32.0;
				}
				if (RX1Data[2] > 66) // not straight
				{
					if (RX1Data[2] < 97) // right
						joy[0] = ((float) (RX1Data[2] - 64)) / 32.0;
					else if (RX1Data[2] < 129)// left
						joy[0] = -((float) (RX1Data[2] - 96)) / 32.0;
				}

				break;
				
		 case DP_STOP:
                     HAL_Delay(20); 
                     uint8_t pData[3] = {RX1Data[0], 0x00, 0x00};
        	     HAL_UART_Transmit(&huart3, pData, 3, 1000);
			    RX1Data[0] = 0;      // we reset the command data to avoid resending it again
    			 break;
	


                 case NOTF_DP_TARGET_REACHED:{
                 uint8_t pData[3] = {RX1Data[0], 0x00, 0x00};
		     HAL_Delay(20); 
        	     HAL_UART_Transmit(&huart1, pData, 3, 1000);
			     RX1Data[0] = 0;      // we reset the command data to avoid resending it again
			     }
    			 break;
	
		
                 case DP_CHANGE_RANGE:
			case RGB_CTRL_COMMAND:
				
		    HAL_UART_Transmit(&huart3, RX1Data, 3, 1000);
		 	    LOG("uart 1 - RGB ctrl %03x %03x %03x \r\n", RX1Data[0], RX1Data[1], RX1Data[2]);  
			    RX1Data[0] = 0;      // we reset the command data to avoid resending it again

				break;

                   case DP_GET_CLOSEST_BEACON:
		      case DP_GOTO_BEACON: 
        	     HAL_UART_Transmit(&huart3, RX1Data, 3, 1000);
                 LOG("uart1 get_closest - goto_beacon ... %03x %03x \r\n", RX1Data[0], RX1Data[1]); 					
                 RX1Data[0] = 0;      // we reset the command data to avoid resending it again
//	                   button = (int)DRIVE;
  		           break; 
		     
			default:break;
		}
	}

	m = (millis() - timestamp4); //;

	if( m < 0) {  // bug fix where the millis() restart counting        
		RX4Data[0] = 0;
	} else if ( m < UART_TIMEOUT)
	{

/*		LOG(" %X\t%X\t%X \n",
				
				RX4Data[0] , 
				RX4Data[1] , 
				RX4Data[2]  
				);
				*/
		switch(RX4Data[0])
		{ 
			case 0x01: 
				RX4Data[0] = 0; 
				RX4Data[1] = 0; 
				RX4Data[2] = 0; 
				printf("data received \n"); 
				HAL_Delay(50); 
				break;
			case DEBUG_DUMP: 
				uint8_t pData[3] = {DEBUG_DUMP, 0x00, 0x00};
				HAL_UART_Transmit(&huart3, pData, 3, 1000);
				RX4Data[0] = 0; 

				break; 	
			case DEBUG_STATE:{
						 uint8_t pData[3] = {DEBUG_STATE, 0x00, 0x00};
						 HAL_UART_Transmit(&huart3, pData, 3, 1000);
						 RX4Data[0] = 0; 
					 }
					 break;  
			case DEBUG_ST_STATE:{
  					LOG(" stm state %d %d %d \n", RX3Data[0],RX3Data[1],RX3Data[2]);
					RX4Data[0] = 0; 
					 } 
					 break; 
			case DEBUG_TEST_01:
					LOG("USART3 reset ...\n"); 
					reset_uart3(); 
				        RX3Data[0] = 0; 	
				        RX3Data[1] = 0; 	
				        RX3Data[2] = 0; 	
					RX4Data[0] = 0; 
					 break; 
			default: break; 
		}


	}


	return button;
}



/* USER CODE END 1 */

/**
  * @}
  */

/**
  * @}
  */

/************************ (C) COPYRIGHT STMicroelectronics *****END OF FILE****/
