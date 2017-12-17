
ARDUINO_SPI_LIBRARY=$(ARDUINO_LIBS)/SPI/src

# Relative to ARDUINO_<LIBNAME>LIBRARY
SPI_CXXSRC = SPI.cpp

SPI_BUILD_DIR=$(BUILD_DIR)/SPI

SPI_OBJECTS = $(SPI_CXXSRC:.cpp=.cpp.o)
SPI_OBJS = $(addprefix $(SPI_BUILD_DIR)/,$(SPI_OBJECTS))

#
## Extend parent variables

OBJS+=$(SPI_BUILD_DIR)/SPI.cpp.o

INCLUDE_DIRS+=-I$(ARDUINO_SPI_LIBRARY)/

CPPFLAGS+=-DUSE_LIBRARY_SPI

#
## Local Targets

$(SPI_OBJS): | $(SPI_BUILD_DIR)/utility

$(SPI_BUILD_DIR)/%.cpp.o: $(ARDUINO_SPI_LIBRARY)/%.cpp
	$(CXX) $< -o $@ $(CXXFLAGS)
