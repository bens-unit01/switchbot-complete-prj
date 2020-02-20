#ifndef __D_PERSISTENT_STORAGE_H__
 #define __D_PERSISTENT_STORAGE_H__

#include "pstorage.h"

#define PS_BLOCK_SIZE  1024       //must >= 0x10
#define PS_BLOCK_COUNT 2


/*=======================================================
Description:
 persistent storage init
 setting the parameter of persistent storage
Parameter:
Return:
Note:
=======================================================*/
void d_persistent_storage_init(void);


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
bool  d_persistent_storage_block_update(uint8_t u8_block_index,uint8_t * pu8_buf);



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
bool d_persistent_storage_block_load(uint8_t u8_block_index, uint8_t * pu8_buf);

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
bool  d_persistent_storage_update(uint8_t u8_block_index,uint8_t * pu8_buf,pstorage_size_t size, pstorage_size_t offset);



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
bool d_persistent_storage_load(uint8_t u8_block_index, uint8_t * pu8_buf, pstorage_size_t size, pstorage_size_t offset);


bool  d_persistent_storage_clear(uint8_t u8_block_index,pstorage_size_t size);
/*=======================================================
Description:
Parameter:
Return:
  true:   flash busy  
  false:  flash idle 
Note:
=======================================================*/
bool d_persisten_storage_check_busy(void);


#endif
