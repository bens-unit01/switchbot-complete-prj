




#include <debug.h>


static uint32_t debug[DEBUG_TABLE_SIZE][2] = {0};
static uint32_t debug_state[DEBUG_STATE_SIZE] = {0};
static uint8_t debug_cnt = 0, dp_cnt = 0;


void debug_save_value(uint32_t key, uint32_t value){
	if(debug_cnt < DEBUG_TABLE_SIZE){
		debug[debug_cnt][0] = key;
		debug[debug_cnt][1] = value;
		debug_cnt++;
	} else {
		debug_cnt = 0;
		memset(debug, 0, sizeof(debug[0][0]) * DEBUG_TABLE_SIZE * 2);
		debug[debug_cnt][0] = key;
		debug[debug_cnt][1] = value;
		debug_cnt++;
	}
}

uint8_t debug_get_value(uint32_t i, uint32_t j){

	return debug[i][j]; 
}


void debug_save_state(uint8_t index, uint8_t state){
	debug_state[index] = state;   	 
}

uint8_t debug_get_state(uint8_t index ){
	return debug_state[index]; 
}

