
ARDUINO_WIRE_LIBRARY=$(ARDUINO_LIBS)/Wire/src

# Relative to ARDUINO_<LIBNAME>LIBRARY
WIRE_CSRC = utility/twi.c
WIRE_CXXSRC = Wire.cpp

WIRE_BUILD_DIR=$(BUILD_DIR)/Wire

WIRE_OBJECTS = $(WIRE_CXXSRC:.cpp=.cpp.o) $(WIRE_CSRC:.c=.c.o)
WIRE_OBJS = $(addprefix $(WIRE_BUILD_DIR)/,$(WIRE_OBJECTS))

#
## Extend parent variables

OBJS+=$(WIRE_BUILD_DIR)/Wire.cpp.o $(WIRE_BUILD_DIR)/utility/twi.c.o

INCLUDE_DIRS+=-I$(ARDUINO_WIRE_LIBRARY)/ -I$(ARDUINO_WIRE_LIBRARY)/utility/

CPPFLAGS+=-DUSE_LIBRARY_WIRE

#
## Local Targets

$(WIRE_OBJS): | $(WIRE_BUILD_DIR)/utility

$(WIRE_BUILD_DIR)/utility:
	mkdir -p $(WIRE_BUILD_DIR)/utility

$(WIRE_BUILD_DIR)/%.c.o: $(ARDUINO_WIRE_LIBRARY)/%.c
	$(CC) $< -o $@ $(CFLAGS)

$(WIRE_BUILD_DIR)/%.cpp.o: $(ARDUINO_WIRE_LIBRARY)/%.cpp
	$(CXX) $< -o $@ $(CXXFLAGS)
