
ARDUINO_SSERIAL_LIBRARY=$(ARDUINO_LIBS)/SoftwareSerial/src

# Relative to ARDUINO_<LIBNAME>LIBRARY
SSERIAL_CXXSRC = SoftwareSerial.cpp

SSERIAL_BUILD_DIR=$(BUILD_DIR)/SoftwareSerial

SSERIAL_OBJECTS = $(SSERIAL_CXXSRC:.cpp=.cpp.o)
SSERIAL_OBJS = $(addprefix $(SSERIAL_BUILD_DIR)/,$(SSERIAL_OBJECTS))

#
## Extend parent variables

OBJS+=$(SSERIAL_BUILD_DIR)/SoftwareSerial.cpp.o

INCLUDE_DIRS+=-I$(ARDUINO_SSERIAL_LIBRARY)/

Ext_CPPFLAGS+=-DUSE_LIBRARY_SSERIAL

#
## Local Targets

$(SSERIAL_OBJS): | $(SSERIAL_BUILD_DIR)

$(SSERIAL_BUILD_DIR):
	mkdir -p $(SSERIAL_BUILD_DIR)

$(SSERIAL_BUILD_DIR)/%.cpp.o: $(ARDUINO_SSERIAL_LIBRARY)/%.cpp
	$(CXX) $< -o $@ $(CXXFLAGS)
