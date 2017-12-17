
ARDUINO_SPI_LIBRARY=$(ARDUINO_LIBS)/HID/src

# Relative to ARDUINO_<LIBNAME>LIBRARY
HID_CXXSRC = HID.cpp

HID_BUILD_DIR=$(BUILD_DIR)/HID

HID_OBJECTS = $(HID_CXXSRC:.cpp=.cpp.o)
HID_OBJS = $(addprefix $(HID_BUILD_DIR)/,$(HID_OBJECTS))

#
## Extend parent variables

OBJS+=$(HID_BUILD_DIR)/HID.cpp.o

INCLUDE_DIRS+=-I$(ARDUINO_HID_LIBRARY)/

Ext_CPPFLAGS+=-DUSE_LIBRARY_HID

#
## Local Targets

$(HID_OBJS): | $(HID_BUILD_DIR)

$(HID_BUILD_DIR):
	mkdir -p $(HID_BUILD_DIR)

$(HID_BUILD_DIR)/%.cpp.o: $(ARDUINO_HID_LIBRARY)/%.cpp
	$(CXX) $< -o $@ $(CXXFLAGS)
