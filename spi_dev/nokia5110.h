#ifndef __LCD_5110
#define __LCD_5110

#include "lcd_ioctl.h"

#define LCD_WIDTH			84
#define LCD_HEIGHT			48

#define LCD_POWERDOWN			0x04
#define LCD_ENTRYMODE			0x02
#define LCD_EXTENDEDINSTRUCTION		0x01
#define LCD_DISPLAYBLANK		0x00
#define LCD_DISPLAYNORMAL		0x04
#define LCD_DISPLAYALLON		0x01
#define LCD_DISPLAYINVERTED		0x05

#define LCD_FUNCTIONSET			0x20
#define LCD_DISPLAYCONTROL		0x08
#define LCD_SETYADDR			0x40
#define LCD_SETXADDR			0x80
#define LCD_SETTEMP			0x04
#define LCD_SETBIAS			0x10
#define LCD_SETVOP			0x80

#define LCD_BIAS			0x03
#define LCD_TEMP			0x02
#define LCD_CONTRAST			0x46

#define LCD_CHAR5x7_WIDTH		6
#define LCD_CHAR5x7_HEIGHT		8
#define LCD_CHAR3x5_WIDTH		4
#define LCD_CHAR3x5_HEIGHT		6

#define LCD_BUFFER_SIZE			(LCD_WIDTH * LCD_HEIGHT / 8)


struct nokia_5110 {
	int fd;
	char cs_pin[3];	
	char dc_pin[3];
	char rs_pin[3];
};

typedef enum {
	PIN_LOW = 0,
	PIN_HIGH = !PIN_LOW
} Pin_State_t;

typedef enum {
	LCD_COMMAND = 0,
	LCD_DATA = !LCD_COMMAND
} lcd_writeType_t;

typedef enum {
	LCD_State_Low = 0,
	LCD_State_High = !LCD_State_Low
} LCD_State_t;

typedef enum {
	LCD_Pin_DC = 1,
	LCD_Pin_RST = 2
} LCD_Pin_t;

typedef enum {
	LCD_Pixel_Clear = 0,
	LCD_Pixel_Set = !LCD_Pixel_Clear
} LCD_Pixel_t;

typedef enum {
	LCD_FontSize_5x7 = 0,
	LCD_FontSize_3x5 = !LCD_FontSize_5x7
} LCD_FontSize_t;

typedef enum {
	lcd_invert_Yes,
	lcd_invert_No
} lcd_invert_t;

void lcd_init(struct nokia_5110 *lcd, unsigned char contrast);
void lcd_write(struct nokia_5110 *lcd, lcd_writeType_t type, unsigned char data);
void lcd_home(struct nokia_5110 *lcd);
void lcd_setcontrast(struct nokia_5110 *lcd, unsigned char contrast);
void lcd_gotoxy(struct nokia_5110 *lcd, unsigned char x, unsigned char y);

void lcd_updatearea(unsigned char xMin, unsigned char yMin,
					unsigned char xMax, unsigned char yMax);
void lcd_refresh(struct nokia_5110 *lcd);
void lcd_clear(struct nokia_5110 *lcd);

void lcd_drawpixel(unsigned char x, unsigned char y, LCD_Pixel_t pixel);
void lcd_invert(struct nokia_5110 *lcd, lcd_invert_t invert);
void lcd_putc(char c, LCD_Pixel_t color, LCD_FontSize_t size);
void lcd_puts(char *s, LCD_Pixel_t color, LCD_FontSize_t size);

#endif

