#ifndef M_SPI_H_
#define M_SPI_H_

#include <stdint.h>

#define ARRAY_SIZE(a) (sizeof(a) / sizeof((a)[0]))

int spi_init(int argc, char *argv[]);
void spi_deinit();
void spi_write(uint8_t *tx, int len);

#endif