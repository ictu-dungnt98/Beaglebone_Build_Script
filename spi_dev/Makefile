.PHONY : clean

SOURCES = $(shell echo *.c)
HEADERS = $(shell echo *.h)
OBJECTS = $(SOURCES:.c=.o)

TARGET = spi_dev

CC := /home/dungnt98/BBB_build_system/toolchain/gcc-linaro-7.4.1-2019.02-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-gcc

all: $(OBJECTS)
	$(CC) -o $(TARGET) $(OBJECTS)

$(OBJECTS):
	$(CC) -c -lgpiod $(SOURCES)

clean: 
	rm -f $(OBJECTS) $(TARGET)
