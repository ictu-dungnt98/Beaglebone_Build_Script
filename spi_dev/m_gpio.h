#ifndef M_GPIO_H_
#define M_GPIO_H_

void gpio_export(char* gpio);
void set_gpio_direction(char* gpio, char* direction);
void set_gpio_value(char* gpio, char* value);

#endif