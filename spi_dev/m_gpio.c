#include <stdio.h>
#include <errno.h>
#include <fcntl.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <linux/gpio.h>

void gpio_export(char* gpio)
{
	int fd;

	fd = open("/sys/class/gpio/export", O_WRONLY);
	if (fd < 0) {
		printf("gpio/export: %s\n", strerror(errno));
		exit(1);
	}
	printf("export gpio %s fd: %d\n", gpio, fd);

	if (write(fd, gpio, strlen(gpio)) < 0) {
		printf("Failed to export GPIO: %s\n", strerror(errno));
	}

	close(fd);
}

void set_gpio_direction(char* gpio, char* direction)
{
	int fd;
	char filenamep[128];

	memset(filenamep, 0, sizeof(filenamep));
	sprintf(filenamep, "/sys/class/gpio/gpio%s/direction", gpio);

	fd = open(filenamep, O_WRONLY);
	if (fd < 0) {
		printf("can not open %s\n", filenamep);
		exit(1);
	}

	if (write(fd, direction, strlen(direction) < 0)) {
		printf("Failed to set GPIO direction: %s\n", strerror(errno));
	}
	
	close(fd);
}

void set_gpio_value(char* gpio, char* value)
{
	int fd;
	char filenamep[128];

	memset(filenamep, 0, sizeof(filenamep));
	sprintf(filenamep, "/sys/class/gpio/gpio%s/value", gpio);

	fd = open(filenamep, O_WRONLY);
	if (fd < 0) {
		printf("can not open %s\n", filenamep);
		exit(1);
	}

	if (write(fd, value, strlen(value) < 0)) {
		printf("Failed to set GPIO value: %s\n", strerror(errno));
	}

	close(fd);
}