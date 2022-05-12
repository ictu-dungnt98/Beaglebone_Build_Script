#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include "nokia5110.h"
#include "m_spi.h"
#include "m_gpio.h"

struct nokia_5110 lcd = {
	.cs_pin = "31",
	.dc_pin = "30",
	.rs_pin = "48",
};

void draw_string(char *str, Pixel_t color, FontSize_t font)
{
	lcd_puts(str, color, font);
}

int main(int argc, char *argv[])
{
    char c;

	spi_init(argc, argv);
 	lcd_init(&lcd, 0x38);
 
    while (1) {
        printf("0: Exit\n");
        printf("1: Trong Dung\n");
        printf("2: Dungnt98 Linux\n");
        printf("3; Linux Embedded\n");

        scanf("%d", &c);

        switch (c) {
            case 0:
                return 0;
            case 1:
                lcd_gotoxy(&lcd, 0, 0);
                draw_string("Trong Dung", Pixel_Set, FontSize_5x7);
                break;
            case 2:
                lcd_gotoxy(&lcd, 15, 10); 				
				draw_string("Dungnt98 Linux", Pixel_Set, FontSize_5x7); 
				break;
 			case 3: 				
			 	lcd_gotoxy(&lcd, 20, 24);
				draw_string("Linux Embedded", Pixel_Set, FontSize_5x7); 	
				break; 			
			default:
				lcd_gotoxy(&lcd, 0, 0);
				lcd_clear(&lcd);
				draw_string("Default !", Pixel_Set, FontSize_5x7); 				
				break;
        }
		
		lcd_refresh(&lcd);

        do {
            c = getchar();
        } while (c != '\n' && c != EOF);
    }
    return 0;
}
