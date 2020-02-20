/*-------------------------------------------------------
-------------------------------------------------------*/
#include <stdint.h>
#include <stdbool.h>
#include <string.h>

#include "nordic_common.h"
#include "nrf.h"
#include "app_error.h"
#include "pstorage.h"


#include "d_persistent_storage.h"

static pstorage_handle_t s_ps_id;
//static uint8_t u8_ps_buf[PS_BLOCK_SIZE];

//=0 means ps in idle
static uint8_t u8_ps_status;



/*=======================================================
Description:
    call back of queue excute.
Parameter:
Return:
Note:
=======================================================*/
static void d_persisten_storage_callback_handler(pstorage_handle_t *ps_ps_handle,
                                                 uint8_t           u8_op_code,
                                                 uint32_t          u32_result,
                                                 uint8_t           *pu8_data,
                                                 uint32_t          u32_data_len)
{
  switch(u8_op_code)
  {
    
    case PSTORAGE_LOAD_OP_CODE:
      if (u32_result == NRF_SUCCESS)
      {
        //load data sucess 
        u8_ps_status = 0;
      }
      else
      {
        //APP_ERROR_CHECK(u32_result);
      }
      break;
    case PSTORAGE_STORE_OP_CODE:
      if (u32_result == NRF_SUCCESS)
      {
        //store data sucess 
        u8_ps_status = 0;
      }
      else
      {
        //APP_ERROR_CHECK(u32_result);
      }
      break;
    case PSTORAGE_UPDATE_OP_CODE:
      if (u32_result == NRF_SUCCESS)
      {
        //update data sucess 
        u8_ps_status = 0;
      }
      else
      {
        //APP_ERROR_CHECK(u32_result);
      }
      break;
    case PSTORAGE_CLEAR_OP_CODE:
      if (u32_result == NRF_SUCCESS)
      {
        //store data sucess 
      }
      else
      {
        //APP_ERROR_CHECK(u32_result);
      }
      break;
  }
}

/*=======================================================
Description:
 persistent storage init
 setting the parameter of persistent storage
Parameter:
Return:
Note:
=======================================================*/
void d_persistent_storage_init(void)
{
  uint32_t u32_err_code;
  pstorage_module_param_t s_ps_param;
  s_ps_param.block_size  = PS_BLOCK_SIZE;
  s_ps_param.block_count = PS_BLOCK_COUNT;
  s_ps_param.cb          = d_persisten_storage_callback_handler;
  
  u32_err_code = pstorage_init();
  APP_ERROR_CHECK(u32_err_code);
  
  u32_err_code = pstorage_register(&s_ps_param,&s_ps_id);
  APP_ERROR_CHECK(u32_err_code);
}



/*=======================================================
Description:
     updated data to persistent storage
Parameter:
     [in] u8_block_index : index of ps data
     [out] pu8_buf       : point of data need to save in ps
Return:
     false : updated failed
     true  : push update queue sucess, no updated sucess 
Note:
  updated whole block 
  need several ble cycle to finished this action
  
=======================================================*/
bool  d_persistent_storage_block_update(uint8_t u8_block_index,uint8_t * pu8_buf)
{
  uint32_t u32_err_code;
  pstorage_handle_t s_ps_block_id;
  
  if(u8_ps_status != 0)
  {
      //this block is busy, can't be update
      return false;
  }
  u8_ps_status = 1;
  
  //memcpy(u8_ps_buf,pu8_buf,PS_BLOCK_SIZE);
  
  u32_err_code = pstorage_block_identifier_get(&s_ps_id,u8_block_index,&s_ps_block_id);
  APP_ERROR_CHECK(u32_err_code);
  
  u32_err_code = pstorage_clear(&s_ps_block_id,PS_BLOCK_SIZE);
  APP_ERROR_CHECK(u32_err_code);
  
  u32_err_code = pstorage_store(&s_ps_block_id,pu8_buf,PS_BLOCK_SIZE,0);
  APP_ERROR_CHECK(u32_err_code);
  
  return true;
  
  
}


/*=======================================================
Description:
 load data from persitent storage
Parameter:
   [in] u8_block_index: index of ps data
   [out] pu8_buf      : point of data read from ps
Return:
     false : load failed
     true  : load sucess
Note:
  load whole block, the pu8_buf size >= block size
=======================================================*/
bool d_persistent_storage_block_load(uint8_t u8_block_index, uint8_t * pu8_buf)
{
  uint32_t u32_err_code;
  pstorage_handle_t s_ps_block_id;
  
  if(u8_ps_status != 0)
  {
      //this block is busy, can't be read
      return false;
  }
  u8_ps_status = 1;
  
  u32_err_code = pstorage_block_identifier_get(&s_ps_id,u8_block_index,&s_ps_block_id);
  APP_ERROR_CHECK(u32_err_code);
  
  u32_err_code = pstorage_load(pu8_buf,&s_ps_block_id,PS_BLOCK_SIZE,0);
  APP_ERROR_CHECK(u32_err_code);
  return true;
  
}

/*=======================================================
Description:
     updated data to persistent storage
Parameter:
     [in]  u8_block_index : index of ps data
     [out] pu8_buf        : point of data need to save in ps
     [in]  size           : updated data size
     [in]  offset         : updated data offset
Return:
     false : updated failed
     true  : push update queue sucess, no updated sucess 
Note:
  need several ble cycle to finished this action
  do not change the pu8_buf before update finished
  
=======================================================*/
bool  d_persistent_storage_update(uint8_t u8_block_index,uint8_t * pu8_buf,pstorage_size_t size, pstorage_size_t offset)
{
  
  uint32_t u32_err_code;
  pstorage_handle_t s_ps_block_id;
  
  if(u8_ps_status != 0)
  {
      //this block is busy, can't be update
      return false;
  }
  
  u8_ps_status = 1;
  
//  memcpy(u8_ps_buf,pu8_buf,PS_BLOCK_SIZE);
  
  u32_err_code = pstorage_block_identifier_get(&s_ps_id,u8_block_index,&s_ps_block_id);
  APP_ERROR_CHECK(u32_err_code);
  
  
  u32_err_code = pstorage_update(&s_ps_block_id,pu8_buf,size,offset);
  APP_ERROR_CHECK(u32_err_code);
  
  return true;
}

bool  d_persistent_storage_clear(uint8_t u8_block_index,pstorage_size_t size)
{
  
  uint32_t u32_err_code;
  pstorage_handle_t s_ps_block_id;
  
  if(u8_ps_status != 0)
  {
      //this block is busy, can't be update
      return false;
  }
  
  u8_ps_status = 1;
  
//  memcpy(u8_ps_buf,pu8_buf,PS_BLOCK_SIZE);
  
  u32_err_code = pstorage_block_identifier_get(&s_ps_id,u8_block_index,&s_ps_block_id);
  APP_ERROR_CHECK(u32_err_code);
  
  
  u32_err_code = pstorage_clear(&s_ps_block_id,size);
  APP_ERROR_CHECK(u32_err_code);
  
  return true;
}

/*=======================================================
Description:
 load data from persitent storage
Parameter:
   [in]  u8_block_index    : index of ps data
   [out] pu8_buf           : point of data read from ps
   [in]  size              : load data size
   [in]  offset            : load data offset
Return:
   false : load failed
   true  : load sucess
Note:
 
=======================================================*/
bool d_persistent_storage_load(uint8_t u8_block_index, uint8_t * pu8_buf, pstorage_size_t size, pstorage_size_t offset)
{
  uint32_t u32_err_code;
  pstorage_handle_t s_ps_block_id;
  
  if(u8_ps_status != 0)
  {
      //this block is busy, can't be read
      return false;
  }
  u8_ps_status = 1;
  
  u32_err_code = pstorage_block_identifier_get(&s_ps_id,u8_block_index,&s_ps_block_id);
  APP_ERROR_CHECK(u32_err_code);
  
  u32_err_code = pstorage_load(pu8_buf,&s_ps_block_id,size,offset);
  APP_ERROR_CHECK(u32_err_code);
  return true;
  
}

/*=======================================================
Description:
Parameter:
Return:
  true:   flash busy  
  false:  flash idle 
Note:
=======================================================*/
bool d_persisten_storage_check_busy(void)
{
  if(u8_ps_status != 0)
  {
    return true;
  }
  else
  {
    return false;
  }
}

/*=======================================================
Description:
Parameter:
  [in]
  [out]
Return:
Note:
=======================================================*/
