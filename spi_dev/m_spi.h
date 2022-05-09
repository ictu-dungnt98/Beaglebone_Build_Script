#ifndef M_SPI_H_
#define M_SPI_H_

#include <stdint.h>

#define ARRAY_SIZE(a) (sizeof(a) / sizeof((a)[0]))

int spi_init(int argc, char *argv[]);
void spi_deinit();
void spi_transfer(uint8_t const *tx, uint8_t const *rx, int len);
void spi_write(uint8_t const *tx, int len);

#endif