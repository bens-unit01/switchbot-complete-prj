#ifndef __MAIN_H
#define __MAIN_H




extern TIM_HandleTypeDef htim2;
void Error_Handler(void);
int __io_putchar(int ch);
int __io_getchar(void);
void dump(uint8_t *buf, int len);

#endif /* __MAIN_H */
