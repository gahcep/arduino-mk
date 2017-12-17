
#
## Board Options

CPU=avr

# boards.txt :: <BRD_TYPE>.build.mcu
MCU=atmega328p

# boards.txt :: <BRD_TYPE>.build.f_cpu
F_CPU=16000000L

# boards.txt :: <BRD_TYPE>.build.variant
BUILD_VARIANT := eightanaloginputs


#
## Variables

PORT ?= /dev/ttyS0
BAUD ?= 57600

ValidBaudRates := 300 600 1200 2400 4800 9600 14400 19200 28800 38400 57600 115200

ifeq ($(filter $(ValidBaudRates), $(BAUD)),)
  $(error Invalid customer log level selected: $(BAUD). Valid are: $(ValidBaudRates))
endif


# boards.txt :: <BRD_TYPE>.build.board
BRD ?= AVR_NANO

ValidBoards := \
	AVR_YUN AVR_UNO \
	AVR_DUEMILANOVE \
	AVR_NANO \
	AVR_MEGA2560 \
	AVR_ADK \
	AVR_LEONARDO \
	AVR_LEONARDO_ETH \
	AVR_MICRO \
	AVR_ESPLORA \
	AVR_MINI \
	AVR_ETHERNET \
	AVR_FIO \
	AVR_BT \
	AVR_LILYPAD_USB \
	AVR_LILYPAD \
	AVR_PRO \
	AVR_NG \
	AVR_ROBOT_CONTROL \
	AVR_ROBOT_MOTOR \
	AVR_GEMMA \
	AVR_CIRCUITPLAY \
	AVR_YUNMINI \
	AVR_INDUSTRIAL101 \
	AVR_LININO_ONE \
	AVR_UNO_WIFI_DEV_ED

ifeq ($(filter $(ValidBoards), $(BRD)),)
  $(error Invalid customer board selected: $(BRD). Valid are: $(ValidBoards))
endif

# Pretty print
ImplSpace :=
ImplSpace +=
PrettifyBaudRates:=$(subst $(ImplSpace),|,${ValidBaudRates})
PrettifyBoards:=$(subst $(ImplSpace),|,${ValidBoards})


#
## Directories Setup

CurrentDir := $(shell pwd)

BRD_DIR=arduino

BUILD_DIR=$(CurrentDir)/build

ARDUINO_SYS_DIR=/usr/local/arduino

# /usr/local/arduino/hardware
ARDUINO_HW_DIR=$(ARDUINO_SYS_DIR)/hardware

# /usr/local/arduino/hardware/arduino/avr
ARDUINO_ROOT_DIR=$(ARDUINO_HW_DIR)/$(BRD_DIR)/$(CPU)

# /usr/local/arduino/hardware/tools/avr/bin
ARDUINO_TOOLS_DIR=$(ARDUINO_HW_DIR)/tools/$(CPU)/bin

# /usr/local/arduino/hardware/tools/avr/etc/avrdude.conf
ARDUINO_CONF_FILE=$(ARDUINO_HW_DIR)/tools/$(CPU)/etc/avrdude.conf

# /usr/local/arduino/hardware/arduino/avr/cores/arduino
ARDUINO_CORES_PATH=$(ARDUINO_ROOT_DIR)/cores/$(BRD_DIR)

# /usr/local/arduino/hardware/arduino/avr/variants
ARDUINO_VAR_PATH=$(ARDUINO_ROOT_DIR)/variants

# /usr/local/arduino/hardware/arduino/avr/libraries
ARDUINO_LIBS=$(ARDUINO_ROOT_DIR)/libraries


#
## Toolchain

CC := $(ARDUINO_TOOLS_DIR)/avr-gcc

AR := $(ARDUINO_TOOLS_DIR)/avr-ar

CXX := $(ARDUINO_TOOLS_DIR)/avr-g++

OBJCOPY := $(ARDUINO_TOOLS_DIR)/avr-objcopy

#
## Tools

# boards.txt :: <BRD_TYPE>.upload.tool
AVRDUDE := avrdude.exe


#
## Compilation Flags

INCLUDE_DIRS=-I$(ARDUINO_CORES_PATH) -I$(ARDUINO_VAR_PATH)/$(BUILD_VARIANT)

LDFLAGS=-lm

# Main static library that holds all other
DEPS = $(BUILD_DIR)/core.a

OBJECTS = $(CXXSRC:.cpp=.cpp.o) $(CSRC:.c=.c.o) $(ASRC:.S=.S.o)
OBJS = $(addprefix $(BUILD_DIR)/,$(OBJECTS))

Ext_CPPFLAGS=

#
## Additional Arduino libraries

ifdef WITH_WIRE
-include mkfiles/Wire.mk
endif

ifdef WITH_SPI
-include mkfiles/SPI.mk
endif

ifdef WITH_HID
-include mkfiles/HID.mk
endif

ifdef WITH_SSERIAL
-include mkfiles/SoftwareSerial.mk
endif

CPPFLAGS+=${Ext_CPPFLAGS}

#
## Flags

GENERAL_FLAGS=-c -g -mmcu=$(MCU) -MMD -DF_CPU=$(F_CPU) -DARDUINO_${BRD} -DARDUINO_ARCH_AVR

# -- [-x] option lets you override the default by specifying the language of
#    the source file, rather than inferring the language from the file suffix.

# -- [-x assembler-with-cpp] indicates that the assembly code contains
#    C directives and armclang must run the C preprocessor.

ASMFLAGS = $(INCLUDE_DIRS) -x assembler-with-cpp $(GENERAL_FLAGS)

# -- [-ffunction-sections] generates a separate ELF section for each function in 
#    the source file. The unused section elimination feature of the linker can 
#    then remove unused functions at link time.

# -- [-fdata-sections] enables or disables the generation of one ELF section for
#    each variable in the source file.

# -- [-fno-threadsafe-statics] do not emit the extra code to use the routines 
#    specified in the C++ ABI for thread-safe initialization of local statics.

CFLAGS = \
  $(INCLUDE_DIRS) \
  $(CPPFLAGS) \
  -Os -Wall -Wextra -std=gnu11 -ffunction-sections -fdata-sections \
  $(GENERAL_FLAGS)

CXXFLAGS = \
  $(INCLUDE_DIRS) \
  $(CPPFLAGS) \
  -Os -Wall -Wextra -std=gnu++11 -ffunction-sections -fdata-sections \
  -fpermissive -fno-exceptions -fno-threadsafe-statics \
  $(GENERAL_FLAGS)

#
## Sources

# ASM sources
ASRC = $(notdir $(wildcard $(ARDUINO_CORES_PATH)/*.S))
# C sources
CSRC = $(notdir $(wildcard $(ARDUINO_CORES_PATH)/*.c))
# C++ sources
CXXSRC = $(notdir $(filter-out $(ARDUINO_CORES_PATH)/main.cpp, $(wildcard $(ARDUINO_CORES_PATH)/*.cpp)))


#
## Targets


.DEFAULT_GOAL: all

all: fwimage

.PHONY: all clean build builddir fwimage



$(BUILD_DIR)/%.c.o: $(ARDUINO_CORES_PATH)/%.c
	$(CC) $< -o $@ $(CFLAGS)

$(BUILD_DIR)/%.cpp.o: $(ARDUINO_CORES_PATH)/%.cpp
	$(CXX) $< -o $@ $(CXXFLAGS)

$(BUILD_DIR)/%.S.o: $(ARDUINO_CORES_PATH)/%.S
	$(CC) $< -o $@ $(ASMFLAGS)


archive: $(OBJS)
	@rm -f $(BUILD_DIR)/core.a
	$(foreach OBJ,$(OBJS), \
		$(AR) rcs $(BUILD_DIR)/core.a $(OBJ); \
	)

$(OBJS): | $(BUILD_DIR)


fwimage: archive
	$(CXX) main.cpp -o $(BUILD_DIR)/main.cpp.o $(CXXFLAGS)
	$(CC) -Wall -Wextra -Os -g -Wl,--gc-sections -mmcu=$(MCU) -o $(BUILD_DIR)/$@.elf \
		$(BUILD_DIR)/main.cpp.o $(DEPS) $(LDFLAGS)
	$(OBJCOPY) -O ihex -R .eeprom $(BUILD_DIR)/$@.elf $@.hex

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

#
## Miscelaneous Targets

upload:
	$(AVRDUDE) -C $(ARDUINO_CONF_FILE) -p $(MCU) -c $(BRD_DIR) -P $(PORT) -b $(BAUD) -D -U flash:w:fwimage.hex:i

clean:
	rm -rf *.hex 
	rm -rf $(BUILD_DIR)

#
## Usage

help:
	@echo 
	@echo "Usage: make <targets> [BRD=<board>] [PORT=<port>] [BAUD=<baud>] [WITH_WIRE=1] [WITH_SPI=1] [WITH_HID=1] [WITH_SSERIAL=1]"
	@echo
	@echo "  ENV:"
	@echo
	@echo "    BRD"
	@echo "        Type of Arduino board. For a list of possible values check the board.txt"
	@echo "        or this Makefile's source. Default: AVR_NANO"
	@echo
	@echo "    PORT"
	@echo "        Communication port:"
	@echo "            * COMx - for Windows [MinGW] if [0 < x < 9]"
	@echo "            * \\\\.\\COMx - for Windows [MinGW] if x >= 10"  
	@echo "            * /dev/ttySx - for Linux (classic)"
	@echo "            * /dev/ttyUSBx - for Linux (RS232 adapter, i.e. FTDI232)"
	@echo "          Default: /dev/ttyS0"
	@echo
	@echo "    BAUD"
	@echo "        Serial port baudrate. Possible values:"
	@echo "            ${PrettifyBaudRates}"
	@echo "          Default: 57600"
	@echo
	@echo "    WITH_WIRE"
	@echo "        Includes Arduino's Wire library to the project"
	@echo
	@echo "    WITH_SPI"
	@echo "        Includes Arduino's SPI library to the project"
	@echo
	@echo "    WITH_HID"
	@echo "        Includes Arduino's HID library to the project"
	@echo
	@echo "    WITH_SSERIAL"
	@echo "        Includes Arduino's Software Serial library to the project"
	@echo
	@echo "  targets:"
	@echo
	@echo "    help        - Prints usage"
	@echo "    fwimage     - Builds firmware image (elf file)"
	@echo "    upload      - Uploads the HEX file to Arduino"
	@echo
